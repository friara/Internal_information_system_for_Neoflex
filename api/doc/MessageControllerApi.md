# openapi.api.MessageControllerApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createMessage**](MessageControllerApi.md#createmessage) | **POST** /api/messages | 
[**deleteMessage**](MessageControllerApi.md#deletemessage) | **DELETE** /api/messages/{id} | 
[**getAllMessages**](MessageControllerApi.md#getallmessages) | **GET** /api/messages | 
[**getMessageById**](MessageControllerApi.md#getmessagebyid) | **GET** /api/messages/{id} | 


# **createMessage**
> MessageDTO createMessage(messageDTO)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessageControllerApi();
final MessageDTO messageDTO = ; // MessageDTO | 

try {
    final response = api.createMessage(messageDTO);
    print(response);
} catch on DioException (e) {
    print('Exception when calling MessageControllerApi->createMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messageDTO** | [**MessageDTO**](MessageDTO.md)|  | 

### Return type

[**MessageDTO**](MessageDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteMessage**
> deleteMessage(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessageControllerApi();
final int id = 789; // int | 

try {
    api.deleteMessage(id);
} catch on DioException (e) {
    print('Exception when calling MessageControllerApi->deleteMessage: $e\n');
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

# **getAllMessages**
> BuiltList<MessageDTO> getAllMessages()



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessageControllerApi();

try {
    final response = api.getAllMessages();
    print(response);
} catch on DioException (e) {
    print('Exception when calling MessageControllerApi->getAllMessages: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;MessageDTO&gt;**](MessageDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMessageById**
> MessageDTO getMessageById(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getMessageControllerApi();
final int id = 789; // int | 

try {
    final response = api.getMessageById(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling MessageControllerApi->getMessageById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**MessageDTO**](MessageDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

