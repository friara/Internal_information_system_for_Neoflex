import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for BookingControllerApi
void main() {
  final instance = Openapi().getBookingControllerApi();

  group(BookingControllerApi, () {
    //Future<BookingDTO> createBooking(BookingRequestDTO bookingRequestDTO) async
    test('test createBooking', () async {
      // TODO
    });

    //Future deleteBooking(int id) async
    test('test deleteBooking', () async {
      // TODO
    });

    //Future<PageBookingDTO> getAllBookings(Pageable pageable) async
    test('test getAllBookings', () async {
      // TODO
    });

    //Future<BookingDTO> getBookingById(int id) async
    test('test getBookingById', () async {
      // TODO
    });

    //Future<PageBookingDTO> getBookings(Pageable pageable) async
    test('test getBookings', () async {
      // TODO
    });

  });
}
