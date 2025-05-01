# openapi.api.LikeControllerApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createLike**](LikeControllerApi.md#createlike) | **POST** /api/likes | 
[**deleteLike**](LikeControllerApi.md#deletelike) | **DELETE** /api/likes/{id} | 
[**getAllLikes**](LikeControllerApi.md#getalllikes) | **GET** /api/likes | 
[**getLikeById**](LikeControllerApi.md#getlikebyid) | **GET** /api/likes/{id} | 


# **createLike**
> LikeDTO createLike(likeDTO)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLikeControllerApi();
final LikeDTO likeDTO = ; // LikeDTO | 

try {
    final response = api.createLike(likeDTO);
    print(response);
} catch on DioException (e) {
    print('Exception when calling LikeControllerApi->createLike: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **likeDTO** | [**LikeDTO**](LikeDTO.md)|  | 

### Return type

[**LikeDTO**](LikeDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteLike**
> deleteLike(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLikeControllerApi();
final int id = 789; // int | 

try {
    api.deleteLike(id);
} catch on DioException (e) {
    print('Exception when calling LikeControllerApi->deleteLike: $e\n');
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

# **getAllLikes**
> BuiltList<LikeDTO> getAllLikes()



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLikeControllerApi();

try {
    final response = api.getAllLikes();
    print(response);
} catch on DioException (e) {
    print('Exception when calling LikeControllerApi->getAllLikes: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;LikeDTO&gt;**](LikeDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLikeById**
> LikeDTO getLikeById(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLikeControllerApi();
final int id = 789; // int | 

try {
    final response = api.getLikeById(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling LikeControllerApi->getLikeById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**LikeDTO**](LikeDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

