# openapi.api.ImageControllerApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getImage**](ImageControllerApi.md#getimage) | **GET** /api/images/{filename} | 
[**uploadImage**](ImageControllerApi.md#uploadimage) | **POST** /api/images/upload | 


# **getImage**
> Uint8List getImage(filename)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getImageControllerApi();
final String filename = filename_example; // String | 

try {
    final response = api.getImage(filename);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ImageControllerApi->getImage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **filename** | **String**|  | 

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadImage**
> String uploadImage(uploadAvatarRequest)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getImageControllerApi();
final UploadAvatarRequest uploadAvatarRequest = ; // UploadAvatarRequest | 

try {
    final response = api.uploadImage(uploadAvatarRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ImageControllerApi->uploadImage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **uploadAvatarRequest** | [**UploadAvatarRequest**](UploadAvatarRequest.md)|  | [optional] 

### Return type

**String**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

