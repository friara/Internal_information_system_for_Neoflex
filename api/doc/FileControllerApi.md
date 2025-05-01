# openapi.api.FileControllerApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createFile**](FileControllerApi.md#createfile) | **POST** /api/files | 
[**deleteFile**](FileControllerApi.md#deletefile) | **DELETE** /api/files/{id} | 
[**getAllFiles**](FileControllerApi.md#getallfiles) | **GET** /api/files | 
[**getFileById**](FileControllerApi.md#getfilebyid) | **GET** /api/files/{id} | 


# **createFile**
> FileDTO createFile(fileDTO)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getFileControllerApi();
final FileDTO fileDTO = ; // FileDTO | 

try {
    final response = api.createFile(fileDTO);
    print(response);
} catch on DioException (e) {
    print('Exception when calling FileControllerApi->createFile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **fileDTO** | [**FileDTO**](FileDTO.md)|  | 

### Return type

[**FileDTO**](FileDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteFile**
> deleteFile(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getFileControllerApi();
final int id = 789; // int | 

try {
    api.deleteFile(id);
} catch on DioException (e) {
    print('Exception when calling FileControllerApi->deleteFile: $e\n');
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

# **getAllFiles**
> BuiltList<FileDTO> getAllFiles()



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getFileControllerApi();

try {
    final response = api.getAllFiles();
    print(response);
} catch on DioException (e) {
    print('Exception when calling FileControllerApi->getAllFiles: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;FileDTO&gt;**](FileDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFileById**
> FileDTO getFileById(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getFileControllerApi();
final int id = 789; // int | 

try {
    final response = api.getFileById(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling FileControllerApi->getFileById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**FileDTO**](FileDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

