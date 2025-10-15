import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiClient {
  static const String baseUrl = 'https://frijo.noviindus.in/api';
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  String? get token => _token;

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  Future<dynamic> get(String endpoint, {bool includeAuth = true}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _getHeaders(includeAuth: includeAuth),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data, {bool includeAuth = true}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _getHeaders(includeAuth: includeAuth),
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> postFormData(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, File>? files,
    bool includeAuth = true,
    Function(int, int)? onProgress,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$endpoint'),
      );

      // Add headers
      if (includeAuth && _token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Add fields
      data.forEach((key, value) {
        if (value is List) {
          for (var i = 0; i < value.length; i++) {
            request.fields['$key[$i]'] = value[i].toString();
          }
        } else {
          request.fields[key] = value.toString();
        }
      });

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          final file = entry.value;
          final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
          final mimeTypeParts = mimeType.split('/');
          
          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      return decoded;
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}