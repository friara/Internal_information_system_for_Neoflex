# openapi.api.UserControllerApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createUser**](UserControllerApi.md#createuser) | **POST** /api/users | 
[**deleteUser**](UserControllerApi.md#deleteuser) | **DELETE** /api/users/{id} | 
[**getAllUsers**](UserControllerApi.md#getallusers) | **GET** /api/users | 
[**getUserById**](UserControllerApi.md#getuserbyid) | **GET** /api/users/{id} | 
[**updateUser**](UserControllerApi.md#updateuser) | **PUT** /api/users/{id} | 
[**uploadAvatar**](UserControllerApi.md#uploadavatar) | **POST** /api/users/{id}/avatar | 


# **createUser**
> UserDTO createUser(userDTO)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUserControllerApi();
final UserDTO userDTO = ; // UserDTO | 

try {
    final response = api.createUser(userDTO);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UserControllerApi->createUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userDTO** | [**UserDTO**](UserDTO.md)|  | 

### Return type

[**UserDTO**](UserDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteUser**
> deleteUser(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUserControllerApi();
final int id = 789; // int | 

try {
    api.deleteUser(id);
} catch on DioException (e) {
    print('Exception when calling UserControllerApi->deleteUser: $e\n');
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

# **getAllUsers**
> BuiltList<UserDTO> getAllUsers()



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUserControllerApi();

try {
    final response = api.getAllUsers();
    print(response);
} catch on DioException (e) {
    print('Exception when calling UserControllerApi->getAllUsers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;UserDTO&gt;**](UserDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserById**
> UserDTO getUserById(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUserControllerApi();
final int id = 789; // int | 

try {
    final response = api.getUserById(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UserControllerApi->getUserById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**UserDTO**](UserDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateUser**
> UserDTO updateUser(id, userDTO)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUserControllerApi();
final int id = 789; // int | 
final UserDTO userDTO = ; // UserDTO | 

try {
    final response = api.updateUser(id, userDTO);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UserControllerApi->updateUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **userDTO** | [**UserDTO**](UserDTO.md)|  | 

### Return type

[**UserDTO**](UserDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadAvatar**
> String uploadAvatar(id, uploadAvatarRequest)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUserControllerApi();
final int id = 789; // int | 
final UploadAvatarRequest uploadAvatarRequest = ; // UploadAvatarRequest | 

try {
    final response = api.uploadAvatar(id, uploadAvatarRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UserControllerApi->uploadAvatar: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **uploadAvatarRequest** | [**UploadAvatarRequest**](UploadAvatarRequest.md)|  | [optional] 

### Return type

**String**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

