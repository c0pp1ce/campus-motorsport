/// Helper class for easier error management.
///
/// The json response body is stored in [data] if response was successful.
/// If an error occurred no [data] will be stored.
/// instead a readable [errorMessage] is stored.
class JsonResponseData {
  int statusCode;
  Map<String, dynamic>? data;
  String? errorMessage;

  JsonResponseData({required this.statusCode, this.data, this.errorMessage});
}
