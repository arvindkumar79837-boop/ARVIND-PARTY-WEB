import 'package:dio/dio.dart';

class ErrorHandler {
  static String getMessage(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) return 'Session expired. Please login again.';
      if (statusCode == 403) return 'You don\'t have permission for this action.';
      if (statusCode == 404) return 'Resource not found.';
      if (statusCode != null && statusCode >= 500) return 'Server error. Contact tech team.';
      return error.response?.data?['message']?.toString() ?? 'Network error.';
    }
    return error.toString().replaceAll('Exception: ', '');
  }
}
