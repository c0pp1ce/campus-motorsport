import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Service class for communicating with the REST backend.
class RestServices {
  static const apiEndpoint = 'http://10.0.2.2:8000/api';

  /// Returns a map {'statusCode' : int, 'decodedJson' : Map}.
  ///
  /// [route] will be added to the [apiEndpoint].
  static Future<Map<String, dynamic>> postJson(
      String route, Map<String, dynamic> data) async {
    Map<String, dynamic>? decodedJson = new Map();
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
      decodedJson!['detail'] = 'Request Timeout.';
    } on FormatException {
      decodedJson!['detail'] = 'Unerwartete Antwort.';
    } on SocketException {
      decodedJson!['detail'] = 'Verbindungsfehler.';
    }

    return {
      'statusCode': response?.statusCode ?? 900,
      'decodedJson': decodedJson,
    };
  }
}
