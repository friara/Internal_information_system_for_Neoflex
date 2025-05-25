# openapi.api.NotificationControllerApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getNotifications**](NotificationControllerApi.md#getnotifications) | **GET** /api/notifications | 
[**getNotificationsCount**](NotificationControllerApi.md#getnotificationscount) | **GET** /api/notifications/count | 
[**markAllAsRead**](NotificationControllerApi.md#markallasread) | **PATCH** /api/notifications/read-all | 
[**markAsRead**](NotificationControllerApi.md#markasread) | **PATCH** /api/notifications/{id}/read | 
[**markAsReadForChat**](NotificationControllerApi.md#markasreadforchat) | **PATCH** /api/notifications/chat/{id}/read | 


# **getNotifications**
> BuiltList<MessageNotification> getNotifications(limit)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getNotificationControllerApi();
final int limit = 56; // int | 

try {
    final response = api.getNotifications(limit);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NotificationControllerApi->getNotifications: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **int**|  | [optional] [default to 50]

### Return type

[**BuiltList&lt;MessageNotification&gt;**](MessageNotification.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNotificationsCount**
> int getNotificationsCount()



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getNotificationControllerApi();

try {
    final response = api.getNotificationsCount();
    print(response);
} catch on DioException (e) {
    print('Exception when calling NotificationControllerApi->getNotificationsCount: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**int**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markAllAsRead**
> markAllAsRead()



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getNotificationControllerApi();

try {
    api.markAllAsRead();
} catch on DioException (e) {
    print('Exception when calling NotificationControllerApi->markAllAsRead: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markAsRead**
> markAsRead(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getNotificationControllerApi();
final int id = 789; // int | 

try {
    api.markAsRead(id);
} catch on DioException (e) {
    print('Exception when calling NotificationControllerApi->markAsRead: $e\n');
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

# **markAsReadForChat**
> markAsReadForChat(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getNotificationControllerApi();
final int id = 789; // int | 

try {
    api.markAsReadForChat(id);
} catch on DioException (e) {
    print('Exception when calling NotificationControllerApi->markAsReadForChat: $e\n');
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

