import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants.dart';

/// Thrown for any non-2xx response, or when the response can't be parsed.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => "ApiException($statusCode): $message";
}

/// Minimal JSON REST client wrapping `package:http`.
///
/// Kept dependency-free of Riverpod on purpose so it can be unit-tested
/// or swapped out (e.g. for `dio`) without touching feature code.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConstants.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse("$_baseUrl$path");

  Map<String, String> _headers({String? token}) => {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final response = await _client
          .post(
            _uri(path),
            headers: _headers(token: token),
            body: jsonEncode(body),
          )
          .timeout(AppConstants.apiTimeout);
      return _decode(response);
    } on SocketException {
      throw ApiException(
        "Server-এর সাথে যোগাযোগ করা যাচ্ছে না। ইন্টারনেট/সার্ভার চেক করো।",
      );
    } on HttpException {
      throw ApiException("Unexpected server response.");
    } on FormatException {
      throw ApiException("সার্ভার থেকে ভুল ফরম্যাটের ডেটা এসেছে।");
    }
  }

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    try {
      final response = await _client
          .get(_uri(path), headers: _headers(token: token))
          .timeout(AppConstants.apiTimeout);
      return _decode(response);
    } on SocketException {
      throw ApiException(
        "Server-এর সাথে যোগাযোগ করা যাচ্ছে না। ইন্টারনেট/সার্ভার চেক করো।",
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    final isJson =
        response.headers["content-type"]?.contains("application/json") ??
            false;
    final dynamic decoded =
        response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{"data": decoded};
    }

    // FastAPI error shape: {"detail": "..."} or {"detail": [{"msg": "..."}]}
    String message = "Something went wrong (${response.statusCode}).";
    if (isJson && decoded is Map<String, dynamic> && decoded["detail"] != null) {
      final detail = decoded["detail"];
      if (detail is String) {
        message = detail;
      } else if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        message = first is Map && first["msg"] != null
            ? first["msg"].toString()
            : detail.toString();
      }
    }
    throw ApiException(message, statusCode: response.statusCode);
  }
}
