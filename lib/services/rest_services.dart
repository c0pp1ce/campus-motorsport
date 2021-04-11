import 'dart:async';

import 'package:campus_motorsport/models/utility/response_data.dart';
import 'package:dio/dio.dart';

/// Service class for communicating with the REST backend.
class RestServices {
  static const apiEndpoint = 'http://10.0.2.2:8000/api';
  BaseOptions options = BaseOptions(
    baseUrl: apiEndpoint,
    connectTimeout: 5000, // 5s
    receiveTimeout: 5000,
  );

  /// Returns a map {'statusCode' : int, 'decodedJson' : Map}.
  ///
  /// [route] will be added to the [apiEndpoint].
  Future<JsonResponseData> postJson(String route, Map<String, dynamic> data,
      {String? token}) async {
    JsonResponseData responseData;
    Dio dio = Dio(options);
    if (token != null) {
      dio.options.headers["Authorization"] = 'Bearer $token';
    }

    try {
      var response = await dio.post(route, data: data);
      print(response); // TODO : Remove print at some point.
      responseData = JsonResponseData(
          statusCode: response.statusCode ?? 900,
          data: response.data,
          errorMessage: response.statusCode != null
              ? null
              : "Kein Status Code empfangen.");
    } on DioError catch (error) {
      responseData = _handleError(error);
    }

    return responseData;
  }

  JsonResponseData _handleError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectTimeout:
        return JsonResponseData(
            statusCode: 503, errorMessage: "Verbindungsaufbau fehlgeschlagen.");
      case DioErrorType.sendTimeout:
        return JsonResponseData(
            statusCode: 408, errorMessage: "Timeout während des Requests.");
      case DioErrorType.receiveTimeout:
        return JsonResponseData(
            statusCode: 504, errorMessage: "Timeout während Serverantwort.");
      case DioErrorType.response:

        /// Unauthorized.
        if (error.response?.statusCode == 401) {
          return JsonResponseData(
            statusCode: 401,
            errorMessage: "Authentifizierung fehlgeschlagen.",
          );

          /// Validation error.
        } else if (error.response?.statusCode == 422) {
          return JsonResponseData(
              statusCode: 422,
              errorMessage: _handleValidationError(error.response?.data ??
                  {'detail': []})); // Empty list if no data in response.

          /// Other response errors.
        } else {
          // TODO : Extend for other error types if needed.
          print(error.response);
          print(error.response?.statusCode);
          return JsonResponseData(
            statusCode: error.response?.statusCode ?? 900,
            errorMessage: "Anfrage ist fehlgeschlagen.",
          );
        }
      case DioErrorType.cancel:
        return JsonResponseData(
            statusCode: 503, errorMessage: "Request wurde abgebrochen.");
      case DioErrorType.other:
        print(error);
        return JsonResponseData(
            statusCode: 900, errorMessage: "Scheint als gäbe es ein Problem.");
    }
  }

  /// Format the error string if validation error occurred.
  String _handleValidationError(Map<String, dynamic> response) {
    var errorList = response["detail"] as List<dynamic>;
    String error = '';

    /// Multiple errors possible.
    for (int i = 0; i < errorList.length; i++) {
      List<dynamic> location = errorList[i]["loc"];
      error = error + location.last + ' ' + errorList[i]["msg"];
      if (i != errorList.length - 1) error = error + "\n";
    }

    if (error.isEmpty) {
      print(response);
      error = "Validation Error, aber keine Validierungsfehler gefunden.";
    }

    return error;
  }
}
