# openapi.api.RepostControllerApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createRepost**](RepostControllerApi.md#createrepost) | **POST** /api/posts/{postId}/reposts | 
[**deleteRepost**](RepostControllerApi.md#deleterepost) | **DELETE** /api/posts/{postId}/reposts/{id} | 
[**getRepostById**](RepostControllerApi.md#getrepostbyid) | **GET** /api/posts/{postId}/reposts/{id} | 
[**getRepostsByPost**](RepostControllerApi.md#getrepostsbypost) | **GET** /api/posts/{postId}/reposts | 


# **createRepost**
> RepostDTO createRepost(postId, repostDTO)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getRepostControllerApi();
final int postId = 789; // int | 
final RepostDTO repostDTO = ; // RepostDTO | 

try {
    final response = api.createRepost(postId, repostDTO);
    print(response);
} catch on DioException (e) {
    print('Exception when calling RepostControllerApi->createRepost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **postId** | **int**|  | 
 **repostDTO** | [**RepostDTO**](RepostDTO.md)|  | 

### Return type

[**RepostDTO**](RepostDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteRepost**
> deleteRepost(postId, id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getRepostControllerApi();
final int postId = 789; // int | 
final int id = 789; // int | 

try {
    api.deleteRepost(postId, id);
} catch on DioException (e) {
    print('Exception when calling RepostControllerApi->deleteRepost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **postId** | **int**|  | 
 **id** | **int**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRepostById**
> RepostDTO getRepostById(postId, id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getRepostControllerApi();
final int postId = 789; // int | 
final int id = 789; // int | 

try {
    final response = api.getRepostById(postId, id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling RepostControllerApi->getRepostById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **postId** | **int**|  | 
 **id** | **int**|  | 

### Return type

[**RepostDTO**](RepostDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRepostsByPost**
> BuiltList<RepostDTO> getRepostsByPost(postId)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getRepostControllerApi();
final int postId = 789; // int | 

try {
    final response = api.getRepostsByPost(postId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling RepostControllerApi->getRepostsByPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **postId** | **int**|  | 

### Return type

[**BuiltList&lt;RepostDTO&gt;**](RepostDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

