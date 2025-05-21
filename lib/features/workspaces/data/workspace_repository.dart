import 'package:openapi/openapi.dart';

class WorkspaceRepository {
  final WorkspaceControllerApi _apiWorkspace;
  final BookingControllerApi _apiBooking;
  List<WorkspaceDTO>? _cachedWorkspaces;

  WorkspaceRepository(this._apiWorkspace, this._apiBooking);

  Future<List<WorkspaceDTO>> getWorkspaces() async {
    if (_cachedWorkspaces != null) {
      return _cachedWorkspaces!;
    }
    try {
      final response = await _apiWorkspace.getAllWorkspaces();
      _cachedWorkspaces = response.data!.map((dto) => WorkspaceDTO(
        (b) => b
          ..id = dto.id
          ..workspaceName = dto.workspaceName
          ..currentBookings.replace(dto.currentBookings ?? [])
          ..available = dto.available
      )).toList();
      return _cachedWorkspaces!;
    } catch (e) {
      throw Exception('Failed to load workspaces: $e');
    }
  }

  Future<void> refreshWorkspaces() async {
    _cachedWorkspaces = null; // Сбрасываем кеш
    try {
      final response = await _apiWorkspace.getAllWorkspaces();
      _cachedWorkspaces = response.data!.map((dto) => WorkspaceDTO(
        (b) => b
          ..id = dto.id
          ..workspaceName = dto.workspaceName
          ..currentBookings.replace(dto.currentBookings ?? [])
          ..available = dto.available
      )).toList();
    } catch (e) {
      throw Exception('Failed to refresh workspaces: $e');
    }
  }

  Future<List<WorkspaceDTO>> getAvailableWorkspaces(DateTime start, DateTime end) async {
    try {
      final response = await _apiWorkspace.getAvailableWorkspaces(
        start: start.toUtc(),
        end: end.toUtc()
      );
      return response.data!.map((dto) => WorkspaceDTO(
        (b) => b
          ..id = dto.id
          ..workspaceName = dto.workspaceName
          ..currentBookings.replace(dto.currentBookings ?? [])
          ..available = dto.available
      )).toList();
    } catch (e) {
      throw Exception('Failed to load available workspaces: $e');
    }
  }

Future<void> bookWorkspace(String id, DateTime startTime, DateTime endTime) async {
  try {
    final workspaceId = int.parse(id);
    final request = BookingRequestDTO(
      (b) => b
        ..workspaceId = workspaceId
        ..bookingStart = startTime.toUtc()
        ..bookingEnd = endTime.toUtc(),
    );
    
    await _apiBooking.createBooking(bookingRequestDTO: request);
  } on FormatException {
    throw Exception('Неверный формат ID');
  } catch (e) {
    throw Exception('Ошибка бронирования: $e');
  }
}

}