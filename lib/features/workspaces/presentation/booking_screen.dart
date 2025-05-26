import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:news_feed_neoflex/app_routes.dart';
import 'package:news_feed_neoflex/role_manager/users_page/user_profile_page.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:intl/intl.dart' as intl;
import 'package:xml/xml.dart';
import 'package:openapi/openapi.dart';
import 'package:get_it/get_it.dart';
import 'package:time_range_picker/time_range_picker.dart';
import '../data/workspace_repository.dart';

final getIt = GetIt.instance;

typedef WorkspaceData = ({Size size, Map<String, Workspace> workspaces});

class Workspace {
  Workspace(Path originalPath) {
    rect = originalPath.getBounds();
    path = originalPath.shift(-rect.topLeft);
  }

  late final Path path;
  late final Rect rect;
  bool selected = false;
  int? id;
  String? name;
  bool available = true;
  List<BookingDTO> currentBookings = [];
}

class WorkspaceBorder extends ShapeBorder {
  final Path path;
  final Color strokeColor;
  final double strokeWidth;

  const WorkspaceBorder(
    this.path, {
    this.strokeColor = Colors.black,
    this.strokeWidth = 1,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(strokeWidth);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      rect.topLeft == Offset.zero ? path : path.shift(rect.topLeft);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}

class WorkspaceSelector extends StatefulWidget {
  final Color selectedColor;
  final Color unselectedColor;
  final Color bookedColor;
  final Color strokeColor;
  final double strokeWidth;
  final DateTime? startTime;
  final DateTime? endTime;
  final void Function(String workspaceId) onWorkspaceTap;

  const WorkspaceSelector({
    super.key,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.bookedColor = Colors.red,
    this.strokeColor = Colors.black,
    this.strokeWidth = 1,
    required this.onWorkspaceTap,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<WorkspaceSelector> createState() => _WorkspaceSelectorState();
}

class _WorkspaceSelectorState extends State<WorkspaceSelector> {
  late Future<WorkspaceData> data;
  final _repository = getIt<WorkspaceRepository>();

  @override
  void initState() {
    super.initState();
    data = loadWorkspaces();
  }

  @override
  void didUpdateWidget(WorkspaceSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.startTime != widget.startTime || oldWidget.endTime != widget.endTime) {
    //   setState(() {
    //     data = loadWorkspaces();
    //   });
    // }
    setState(() {
      data = loadWorkspaces();
    });
  }

  Future<WorkspaceData> loadWorkspaces() async {
    final svgString = await loadSvgString();
    final doc = XmlDocument.parse(svgString);
    final viewBox = doc.rootElement.getAttribute('viewBox')!.split(' ');
    final size = Size(double.parse(viewBox[2]), double.parse(viewBox[3]));

    final workspacesDTO = widget.startTime != null && widget.endTime != null
        ? await _repository.getAvailableWorkspaces(
            widget.startTime!, widget.endTime!)
        : await _repository.getWorkspaces();

    final workspaceMap = <String, Workspace>{};
    final svgWorkspaces = doc.rootElement
        .findAllElements('g')
        .where((e) => e.getAttribute('id')?.startsWith('workspace_') ?? false);

    for (final ws in svgWorkspaces) {
      final paths = ws.findAllElements('path');
      if (paths.isEmpty) continue;

      final svgId = ws.getAttribute('id')!;
      final id = int.tryParse(svgId.split('_').last);
      if (id == null) continue;

      WorkspaceDTO? dto;
      try {
        dto = workspacesDTO.firstWhere((d) => d.id == id);
      } catch (e) {
        dto = null;
      }

      final path = parseSvgPathData(paths.first.getAttribute('d')!);
      final workspace = Workspace(path)
        ..id = id
        ..name = dto?.workspaceName ?? 'Неизвестное место'
        ..available = dto != null
        ..currentBookings = dto?.currentBookings?.toList() ?? [];

      workspaceMap[svgId] = workspace;
    }

    return (size: size, workspaces: workspaceMap);
  }

  Color _getWorkspaceColor(Workspace workspace) {
    if (workspace.selected) return widget.selectedColor;
    if (!workspace.available) {
      return widget.bookedColor;
    }
    return widget.unselectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkspaceData>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return FittedBox(
            child: SizedBox.fromSize(
              size: snapshot.data!.size,
              child: Stack(
                children: [
                  for (final entry in snapshot.data!.workspaces.entries)
                    Positioned.fromRect(
                      rect: entry.value.rect,
                      child: GestureDetector(
                        onTap: entry.value.available
                            ? () => widget.onWorkspaceTap(entry.key)
                            : null,
                        child: Container(
                          decoration: ShapeDecoration(
                            color: _getWorkspaceColor(entry.value),
                            shape: WorkspaceBorder(
                              entry.value.path,
                              strokeColor: widget.strokeColor,
                              strokeWidth: widget.strokeWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text('Данные не найдены'));
        }
      },
    );
  }
}

Future<String> loadSvgString() async {
  return await rootBundle.loadString('assets/office_map.svg');
}

class BookingDialog extends StatefulWidget {
  final String workspaceId;
  final DateTime initialStart; // Изменили на обязательный параметр
  final DateTime initialEnd; // Изменили на обязательный параметр

  const BookingDialog({
    super.key,
    required this.workspaceId,
    required this.initialStart, // Добавили required
    required this.initialEnd, // Добавили required
  });

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  final _repository = getIt<WorkspaceRepository>();

  @override
  void initState() {
    super.initState();
    // Устанавливаем значения из переданных параметров
    _selectedDate = widget.initialStart;
    _selectedStartTime = TimeOfDay.fromDateTime(widget.initialStart);
    _selectedEndTime = TimeOfDay.fromDateTime(widget.initialEnd);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Бронирование ${widget.workspaceId}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Дата: ${intl.DateFormat('dd.MM.yyyy').format(_selectedDate)}'),
          const SizedBox(height: 16),
          Text('Начало: ${_selectedStartTime.format(context)}'),
          const SizedBox(height: 16),
          Text('Окончание: ${_selectedEndTime.format(context)}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () async {
            final startDateTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedStartTime.hour,
              _selectedStartTime.minute,
            );

            final endDateTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedEndTime.hour,
              _selectedEndTime.minute,
            );

            try {
              await _repository.bookWorkspace(
                widget.workspaceId.split('_').last,
                startDateTime,
                endDateTime,
              );
              Navigator.pop(context, true);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка: $e')),
              );
            }
          },
          child: const Text('Подтвердить'),
        ),
      ],
    );
  }
}

class WorkspacesScreen extends StatefulWidget {
  const WorkspacesScreen({super.key});

  @override
  State<WorkspacesScreen> createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends State<WorkspacesScreen> {
  final _repository = getIt<WorkspaceRepository>();
  int _selectedIndex = 1;
  bool _isAdmin = false;
  bool _isRoleLoaded = false;
  String? _currentUserRole;
  DateTime? _selectedStart;
  DateTime? _selectedEnd;
  late Future<List<BookingDTO>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _bookingsFuture = _repository.getBookings();
  }

  Future<void> _refreshData() async {
    if (_selectedStart != null && _selectedEnd != null) {
      await _repository.getAvailableWorkspaces(_selectedStart!, _selectedEnd!);
    } else {
      await _repository.refreshWorkspaces();
    }
    setState(() {});
  }

  Future<void> _refreshBookings() async {
    setState(() {
      _bookingsFuture = _repository.getBookings();
    });
  }

  Future<void> _cancelBooking(int bookingId) async {
    try {
      await _repository.cancelBooking(bookingId);
      await _refreshBookings();
      await _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Бронирование отменено')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка отмены: $e')),
        );
      }
    }
  }

  Widget _buildBookingItem(BookingDTO booking) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text('Место ${booking.workspaceId ?? ''}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Дата: ${_formatDate(booking.bookingStart)}'),
            Text(
                'Время: ${_formatTime(booking.bookingStart)} - ${_formatTime(booking.bookingEnd)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showCancelDialog(booking.id!),
        ),
      ),
    );
  }

  void _showCancelDialog(int bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить бронирование?'),
        content:
            const Text('Вы уверены, что хотите отменить это бронирование?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(bookingId);
            },
            child:
                const Text('Подтвердить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    return date != null
        ? intl.DateFormat('dd.MM.yyyy').format(date)
        : '--.--.----';
  }

  String _formatTime(DateTime? time) {
    return time != null ? intl.DateFormat('HH:mm').format(time) : '--:--';
  }

  Future<void> _loadUserRole() async {
    try {
      final userApi = GetIt.I<Openapi>().getUserControllerApi();
      final response = await userApi.getCurrentUser();

      if (response.data == null || response.data!.roleName == null) {
        throw Exception('User data or role is null');
      }

      setState(() {
        _currentUserRole = response.data!.roleName!.toUpperCase().trim();
        _isAdmin = _currentUserRole == 'ROLE_ADMIN';
        _isRoleLoaded = true;
      });
    } catch (e) {
      debugPrint('Error loading user role: $e');
      setState(() => _isRoleLoaded = true);
    }
  }

  DateTime _getNextWeekday(DateTime date) {
    // Keep adding days until we find a weekday (Mon-Fri)
    while (
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  Future<void> _selectTimeRange() async {
    final DateTime initialDate = _getNextWeekday(DateTime.now());

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime date) {
        return date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday;
      },
    );

    if (pickedDate != null) {
      final TimeRange? timeRange = await showTimeRangePicker(
        context: context,
        start: const TimeOfDay(hour: 9, minute: 0),
        end: const TimeOfDay(hour: 18, minute: 0),
        interval: const Duration(minutes: 15),
        disabledTime: TimeRange(
          startTime: const TimeOfDay(hour: 18, minute: 0),
          endTime: const TimeOfDay(hour: 9, minute: 0),
        ),
        minDuration: const Duration(minutes: 15),
        maxDuration: const Duration(hours: 9),
        disabledColor: Colors.red.withOpacity(0.5),
      );

      if (timeRange != null) {
        setState(() {
          _selectedStart = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            timeRange.startTime.hour,
            timeRange.startTime.minute,
          );
          _selectedEnd = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            timeRange.endTime.hour,
            timeRange.endTime.minute,
          );
        });
        _refreshData();
      }
    }
  }

  void _onItemTapped(int index) async {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.newsFeed,
          (route) => false,
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.chatPage,
          (route) => false,
        );
        break;
      case 3:
        if (_isAdmin) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.listOfUsers,
            (route) => false,
          );
        } else {
          try {
            final userApi = GetIt.I<Openapi>().getUserControllerApi();
            final response = await userApi.getCurrentUser();
            if (response.data != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(
                    userData: {
                      'id': response.data!.id?.toString() ?? '',
                      'fio':
                          '${response.data!.firstName ?? ''} ${response.data!.lastName ?? ''} ${response.data!.patronymic ?? ''}',
                      'phone': response.data!.phoneNumber ?? '',
                      'position': response.data!.appointment ?? '',
                      'role': response.data!.roleName ?? 'ROLE_USER',
                      'login': response.data!.login ?? '',
                      'birthDate': response.data!.birthday?.toString() ?? '',
                      'avatarUrl': response.data!.avatarUrl ?? '',
                    },
                    onSave: (updatedUser) async {
                      try {
                        await GetIt.I<Openapi>()
                            .getUserControllerApi()
                            .updateCurrentUser(userDTO: updatedUser);

                        final updatedResponse = await userApi.getCurrentUser();
                        if (updatedResponse.data != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Профиль успешно обновлен')),
                          );
                        }
                      } catch (e) {
                        debugPrint('API Error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Ошибка сохранения: ${e.toString()}')),
                        );
                        rethrow;
                      }
                    },
                    onDelete: (userId) {},
                    onAvatarChanged: (file) {},
                    isAdmin: false,
                  ),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Ошибка загрузки профиля: ${e.toString()}')),
            );
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRoleLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.purple,
        automaticallyImplyLeading: false,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Выбор рабочего места",
            style: TextStyle(
              fontFamily: 'Osmo Font',
              fontSize: 36.0,
              color: Colors.purple,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: _selectTimeRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshData();
              _refreshBookings();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _selectedStart == null
                          ? 'Выберите время'
                          : '${intl.DateFormat('dd.MM.yyyy HH:mm').format(_selectedStart!)} - '
                              '${intl.DateFormat('HH:mm').format(_selectedEnd!)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: WorkspaceSelector(
                      startTime: _selectedStart,
                      endTime: _selectedEnd,
                      onWorkspaceTap: (workspaceId) {
                        if (_selectedStart == null || _selectedEnd == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Сначала выберите время')),
                          );
                          return;
                        }

                        showDialog(
                          context: context,
                          builder: (context) => BookingDialog(
                            workspaceId: workspaceId,
                            initialStart: _selectedStart!,
                            initialEnd: _selectedEnd!,
                          ),
                        ).then((result) {
                          if (result == true) {
                            _refreshData();
                            _refreshBookings();
                          }
                        });
                      },
                    ),
                    //   onWorkspaceTap: (workspaceId) => showDialog(
                    //     context: context,
                    //     builder: (context) => BookingDialog(
                    //       workspaceId: workspaceId,
                    //       initialStart: _selectedStart,
                    //       initialEnd: _selectedEnd,
                    //     ),
                    //   ).then((result) {
                    //     if (result == true) {
                    //       _refreshData();
                    //       _refreshBookings();
                    //     }
                    //   }),
                    // ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Мои бронирования',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<BookingDTO>>(
                      future: _bookingsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Ошибка: ${snapshot.error}'));
                        }
                        final bookings = snapshot.data ?? [];
                        if (bookings.isEmpty) {
                          return const Center(
                              child: Text('Нет активных бронирований'));
                        }
                        return RefreshIndicator(
                          onRefresh: _refreshBookings,
                          child: ListView.builder(
                            itemCount: bookings.length,
                            itemBuilder: (context, index) =>
                                _buildBookingItem(bookings[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.computer),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_sharp),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF48036F),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
