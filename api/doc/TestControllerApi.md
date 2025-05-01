# openapi.api.TestControllerApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**privateHello**](TestControllerApi.md#privatehello) | **GET** /api/private/hello | 
[**publicHello**](TestControllerApi.md#publichello) | **GET** /api/public/hello | 


# **privateHello**
> String privateHello()



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getTestControllerApi();

try {
    final response = api.privateHello();
    print(response);
} catch on DioException (e) {
    print('Exception when calling TestControllerApi->privateHello: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**String**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publicHello**
> String publicHello()



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getTestControllerApi();

try {
    final response = api.publicHello();
    print(response);
} catch on DioException (e) {
    print('Exception when calling TestControllerApi->publicHello: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**String**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

