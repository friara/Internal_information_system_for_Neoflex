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
  final void Function(String workspaceId) onWorkspaceTap;

  const WorkspaceSelector({
    super.key,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.bookedColor = Colors.red,
    this.strokeColor = Colors.black,
    this.strokeWidth = 1,
    required this.onWorkspaceTap,
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

  Future<WorkspaceData> loadWorkspaces() async {
    final svgString = await loadSvgString();
    final doc = XmlDocument.parse(svgString);
    final viewBox = doc.rootElement.getAttribute('viewBox')!.split(' ');
    final size = Size(double.parse(viewBox[2]), double.parse(viewBox[3]));

    final workspacesDTO = await _repository.getWorkspaces();

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

      final dto = workspacesDTO.firstWhere(
        (d) => d.id == id,
        orElse: () => workspacesDTO.firstWhere((d) => false),
      );

      final path = parseSvgPathData(paths.first.getAttribute('d')!);
      final workspace = Workspace(path)
        ..id = id
        ..name = dto.workspaceName
        ..available = dto.available ?? true
        ..currentBookings = dto.currentBookings?.toList() ?? [];

      workspaceMap[svgId] = workspace;
    }

    return (size: size, workspaces: workspaceMap);
  }

  Color _getWorkspaceColor(Workspace workspace) {
    if (workspace.selected) return widget.selectedColor;
    if (!workspace.available || workspace.currentBookings.isNotEmpty) {
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
                        onTap: () => widget.onWorkspaceTap(entry.key),
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

  const BookingDialog({
    super.key,
    required this.workspaceId,
  });

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  required bool Function(TimeOfDay) selectableTimePredicate,
}) async {
  TimeOfDay? pickedTime;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Select Time"),
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 24 * 60, // Number of minutes in a day
            itemBuilder: (BuildContext context, int index) {
              final hour = index ~/ 60;
              final minute = index % 60;
              final time = TimeOfDay(hour: hour, minute: minute);

              if (!selectableTimePredicate(time)) {
                return const SizedBox.shrink();
              }

              return ListTile(
                title: Text(time.format(context)),
                onTap: () {
                  pickedTime = time;
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      );
    },
  );

  return pickedTime;
}

class _BookingDialogState extends State<BookingDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  final _repository = getIt<WorkspaceRepository>();

  bool _isTimeInRange(TimeOfDay time) {
    final totalMinutes = time.hour * 60 + time.minute;
    return totalMinutes >= 9 * 60 && totalMinutes <= 18 * 60;
  }

  bool _isAfterStartTime(TimeOfDay time) {
    if (_selectedStartTime == null) return true;
    final start = _selectedStartTime!;
    return time.hour > start.hour ||
        (time.hour == start.hour && time.minute > start.minute);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime date) {
        return date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday;
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectStartTime() async {
    TimeOfDay initialTime = _selectedStartTime ?? TimeOfDay.now();

    if (!_isTimeInRange(initialTime)) {
      initialTime = initialTime.hour < 9
          ? TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay(hour: 17, minute: 45);
    }

    final TimeOfDay? picked = await showCustomTimePicker(
      context: context,
      initialTime: initialTime,
      selectableTimePredicate: _isTimeInRange,
    );
    if (picked != null) {
      setState(() => _selectedStartTime = picked);
    }
  }

  Future<void> _selectEndTime() async {
    if (_selectedStartTime == null) return;

    int startTotal = _selectedStartTime!.hour * 60 + _selectedStartTime!.minute;
    int endTotal = startTotal + 15;
    if (endTotal > 18 * 60) endTotal = 18 * 60;

    TimeOfDay initialTime = TimeOfDay(
      hour: endTotal ~/ 60,
      minute: endTotal % 60,
    );

    if (!_isTimeInRange(initialTime)) {
      initialTime = TimeOfDay(hour: 18, minute: 0);
    }

    final TimeOfDay? picked = await showCustomTimePicker(
      context: context,
      initialTime: initialTime,
      selectableTimePredicate: (time) =>
          _isTimeInRange(time) && _isAfterStartTime(time),
    );
    if (picked != null) {
      setState(() => _selectedEndTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Бронирование ${widget.workspaceId}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(_selectedDate == null
                  ? 'Дата не выбрана'
                  : 'Дата: ${intl.DateFormat('dd.MM.yyyy').format(_selectedDate!)}'),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _selectDate,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(_selectedStartTime == null
                  ? 'Начало не выбрано'
                  : 'Начало: ${_selectedStartTime!.format(context)}'),
              IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: _selectedDate == null ? null : _selectStartTime,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(_selectedEndTime == null
                  ? 'Окончание не выбрано'
                  : 'Окончание: ${_selectedEndTime!.format(context)}'),
              IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: _selectedStartTime == null ? null : _selectEndTime,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_selectedDate == null ||
                _selectedStartTime == null ||
                _selectedEndTime == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Заполните все поля')),
              );
              return;
            }

            final startDateTime = DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _selectedStartTime!.hour,
              _selectedStartTime!.minute,
            );

            final endDateTime = DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _selectedEndTime!.hour,
              _selectedEndTime!.minute,
            );

            if (endDateTime.isBefore(startDateTime)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Окончание должно быть после начала')),
              );
              return;
            }

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

  Future<void> _refreshData() async {
    await _repository.refreshWorkspaces();
    setState(() {});
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
        // Уже на этом экране
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
                    onDelete: (userId) {
                      // Логика удаления
                    },
                    onAvatarChanged: (file) {
                      // Логика обновления аватара
                    },
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
  void initState() {
    super.initState();
    _loadUserRole();
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
        title: const Text('Выбор рабочего места'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Center(
        child: WorkspaceSelector(
          onWorkspaceTap: (workspaceId) => showDialog(
            context: context,
            builder: (context) => BookingDialog(
              workspaceId: workspaceId,
            ),
          ).then((result) {
            if (result == true) _refreshData();
          }),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
