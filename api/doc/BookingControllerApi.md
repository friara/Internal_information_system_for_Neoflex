# openapi.api.BookingControllerApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createBooking**](BookingControllerApi.md#createbooking) | **POST** /api/bookings | 
[**deleteBooking**](BookingControllerApi.md#deletebooking) | **DELETE** /api/bookings/{id} | 
[**getAllBookings**](BookingControllerApi.md#getallbookings) | **GET** /api/bookings | 
[**getBookingById**](BookingControllerApi.md#getbookingbyid) | **GET** /api/bookings/{id} | 
[**getBookings**](BookingControllerApi.md#getbookings) | **GET** /api/bookings/me | 


# **createBooking**
> BookingDTO createBooking(bookingRequestDTO)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getBookingControllerApi();
final BookingRequestDTO bookingRequestDTO = ; // BookingRequestDTO | 

try {
    final response = api.createBooking(bookingRequestDTO);
    print(response);
} catch on DioException (e) {
    print('Exception when calling BookingControllerApi->createBooking: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **bookingRequestDTO** | [**BookingRequestDTO**](BookingRequestDTO.md)|  | 

### Return type

[**BookingDTO**](BookingDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteBooking**
> deleteBooking(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getBookingControllerApi();
final int id = 789; // int | 

try {
    api.deleteBooking(id);
} catch on DioException (e) {
    print('Exception when calling BookingControllerApi->deleteBooking: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAllBookings**
> PageBookingDTO getAllBookings(pageable)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getBookingControllerApi();
final Pageable pageable = ; // Pageable | 

try {
    final response = api.getAllBookings(pageable);
    print(response);
} catch on DioException (e) {
    print('Exception when calling BookingControllerApi->getAllBookings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pageable** | [**Pageable**](.md)|  | 

### Return type

[**PageBookingDTO**](PageBookingDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBookingById**
> BookingDTO getBookingById(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getBookingControllerApi();
final int id = 789; // int | 

try {
    final response = api.getBookingById(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling BookingControllerApi->getBookingById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**BookingDTO**](BookingDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBookings**
> PageBookingDTO getBookings(pageable)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getBookingControllerApi();
final Pageable pageable = ; // Pageable | 

try {
    final response = api.getBookings(pageable);
    print(response);
} catch on DioException (e) {
    print('Exception when calling BookingControllerApi->getBookings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pageable** | [**Pageable**](.md)|  | 

### Return type

[**PageBookingDTO**](PageBookingDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

