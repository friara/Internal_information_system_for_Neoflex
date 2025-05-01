# openapi.api.MediaControllerApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getMediaFile**](MediaControllerApi.md#getmediafile) | **GET** /api/media/{filename} | 


# **getMediaFile**
> Uint8List getMediaFile(filename)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMediaControllerApi();
final String filename = filename_example; // String | 

try {
    final response = api.getMediaFile(filename);
    print(response);
} catch on DioException (e) {
    print('Exception when calling MediaControllerApi->getMediaFile: $e\n');
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

