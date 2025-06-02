# openapi.api.ChatControllerApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addParticipants**](ChatControllerApi.md#addparticipants) | **POST** /api/chats/{chatId}/participants | 
[**createChat**](ChatControllerApi.md#createchat) | **POST** /api/chats | 
[**deleteChat**](ChatControllerApi.md#deletechat) | **DELETE** /api/chats/{id} | 
[**exitFromChat**](ChatControllerApi.md#exitfromchat) | **DELETE** /api/chats/{chatId}/exit | 
[**getChatById**](ChatControllerApi.md#getchatbyid) | **GET** /api/chats/{id} | 
[**getMyChats**](ChatControllerApi.md#getmychats) | **GET** /api/chats/my | 
[**removeParticipant**](ChatControllerApi.md#removeparticipant) | **DELETE** /api/chats/{chatId}/participants/{userId} | 
[**updateChat**](ChatControllerApi.md#updatechat) | **PUT** /api/chats/{id} | 
[**updateChatName**](ChatControllerApi.md#updatechatname) | **PATCH** /api/chats/{id}/name | 


# **addParticipants**
> ChatDTO addParticipants(chatId, requestBody)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatControllerApi();
final int chatId = 789; // int | 
final BuiltList<int> requestBody = ; // BuiltList<int> | 

try {
    final response = api.addParticipants(chatId, requestBody);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ChatControllerApi->addParticipants: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatId** | **int**|  | 
 **requestBody** | [**BuiltList&lt;int&gt;**](int.md)|  | 

### Return type

[**ChatDTO**](ChatDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createChat**
> ChatDTO createChat(chatDTO)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatControllerApi();
final ChatDTO chatDTO = ; // ChatDTO | 

try {
    final response = api.createChat(chatDTO);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ChatControllerApi->createChat: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatDTO** | [**ChatDTO**](ChatDTO.md)|  | 

### Return type

[**ChatDTO**](ChatDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteChat**
> deleteChat(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatControllerApi();
final int id = 789; // int | 

try {
    api.deleteChat(id);
} catch on DioException (e) {
    print('Exception when calling ChatControllerApi->deleteChat: $e\n');
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

# **exitFromChat**
> ChatDTO exitFromChat(chatId)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatControllerApi();
final int chatId = 789; // int | 

try {
    final response = api.exitFromChat(chatId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ChatControllerApi->exitFromChat: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatId** | **int**|  | 

### Return type

[**ChatDTO**](ChatDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatById**
> ChatDTO getChatById(id)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatControllerApi();
final int id = 789; // int | 

try {
    final response = api.getChatById(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ChatControllerApi->getChatById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**ChatDTO**](ChatDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyChats**
> PageChatSummaryDTO getMyChats(page, size, search)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatControllerApi();
final int page = 56; // int | 
final int size = 56; // int | 
final String search = search_example; // String | 

try {
    final response = api.getMyChats(page, size, search);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ChatControllerApi->getMyChats: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | [optional] [default to 0]
 **size** | **int**|  | [optional] [default to 10]
 **search** | **String**|  | [optional] 

### Return type

[**PageChatSummaryDTO**](PageChatSummaryDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeParticipant**
> ChatDTO removeParticipant(chatId, userId)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatControllerApi();
final int chatId = 789; // int | 
final int userId = 789; // int | 

try {
    final response = api.removeParticipant(chatId, userId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ChatControllerApi->removeParticipant: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatId** | **int**|  | 
 **userId** | **int**|  | 

### Return type

[**ChatDTO**](ChatDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateChat**
> ChatDTO updateChat(id, chatDTO)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatControllerApi();
final int id = 789; // int | 
final ChatDTO chatDTO = ; // ChatDTO | 

try {
    final response = api.updateChat(id, chatDTO);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ChatControllerApi->updateChat: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **chatDTO** | [**ChatDTO**](ChatDTO.md)|  | 

### Return type

[**ChatDTO**](ChatDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateChatName**
> ChatDTO updateChatName(id, updateChatNameRequest)



### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getChatControllerApi();
final int id = 789; // int | 
final UpdateChatNameRequest updateChatNameRequest = ; // UpdateChatNameRequest | 

try {
    final response = api.updateChatName(id, updateChatNameRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ChatControllerApi->updateChatName: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **updateChatNameRequest** | [**UpdateChatNameRequest**](UpdateChatNameRequest.md)|  | 

### Return type

[**ChatDTO**](ChatDTO.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

