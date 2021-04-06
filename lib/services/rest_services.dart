import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Service class for communicating with the REST backend.
class RestServices {
  static const apiEndpoint = 'http://127.0.0.1:8000/api';

  /// Returns a map {'statusCode' : int, 'decodedJson' : Map}.
  ///
  /// [route] will be added to the [apiEndpoint].
  static Future<Map<String, dynamic>> postJson(
      String route, Map<String, dynamic> data) async {
    Map<String, dynamic> decodedJson = new Map();
    http.Response? response;

    try {
      response = await http
          .post(
        Uri.parse(apiEndpoint + route),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      )
          .timeout(
        Duration(seconds: 10),
      );

      decodedJson = jsonDecode(response.body);
    } on TimeoutException {
      decodedJson['message'] = 'Request Timeout.';
    } on FormatException {
      decodedJson['message'] = 'Unerwartete Antwort.';
    } on SocketException {
      decodedJson['message'] = 'Verbindungsfehler.';
    }

    return {
      'statusCode': response?.statusCode ?? 900,
      'decodedJson': decodedJson,
    };
  }
}