# openapi.api.CommentControllerApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createComment**](CommentControllerApi.md#createcomment) | **POST** /api/comments | 
[**deleteComment**](CommentControllerApi.md#deletecomment) | **DELETE** /api/comments/{id} | 
[**getAllComments**](CommentControllerApi.md#getallcomments) | **GET** /api/comments | 
[**getCommentById**](CommentControllerApi.md#getcommentbyid) | **GET** /api/comments/{id} | 


# **createComment**
> CommentDTO createComment(commentDTO)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getCommentControllerApi();
final CommentDTO commentDTO = ; // CommentDTO | 

try {
    final response = api.createComment(commentDTO);
    print(response);
} catch on DioException (e) {
    print('Exception when calling CommentControllerApi->createComment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **commentDTO** | [**CommentDTO**](CommentDTO.md)|  | 

### Return type

[**CommentDTO**](CommentDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteComment**
> deleteComment(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getCommentControllerApi();
final int id = 789; // int | 

try {
    api.deleteComment(id);
} catch on DioException (e) {
    print('Exception when calling CommentControllerApi->deleteComment: $e\n');
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

# **getAllComments**
> BuiltList<CommentDTO> getAllComments()



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getCommentControllerApi();

try {
    final response = api.getAllComments();
    print(response);
} catch on DioException (e) {
    print('Exception when calling CommentControllerApi->getAllComments: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;CommentDTO&gt;**](CommentDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCommentById**
> CommentDTO getCommentById(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getCommentControllerApi();
final int id = 789; // int | 

try {
    final response = api.getCommentById(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling CommentControllerApi->getCommentById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**CommentDTO**](CommentDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

