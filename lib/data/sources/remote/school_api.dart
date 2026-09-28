import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/teacher.dart';

/// Client for the public API behind ausc.edu.bd.
///
/// The site doesn't send CORS headers, so browsers can't call it directly.
/// On web, requests go through the `/ausc-api` rewrite in vercel.json, which
/// makes them same-origin. Override with
/// `--dart-define=AUSC_API_BASE=...` (e.g. for local web development).
class SchoolApi {
  static const String _override = String.fromEnvironment('AUSC_API_BASE');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    return kIsWeb ? '/ausc-api' : 'https://ausc.edu.bd';
  }

  final http.Client _client;

  SchoolApi({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches every teacher (the directory has ~120 rows, so one page).
  Future<List<Teacher>> fetchTeachers() async {
    final teachers = <Teacher>[];
    var page = 1;
    var lastPage = 1;

    do {
      final uri = Uri.parse(
        '$baseUrl/get-teachers',
      ).replace(queryParameters: {'page': '$page', 'per_page': '200'});
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw Exception('Teacher directory returned ${response.statusCode}');
      }

      final body = jsonDecode(utf8.decode(response.bodyBytes));
      lastPage = body['last_page'] as int? ?? 1;
      for (final row in (body['data'] as List).cast<Map<String, dynamic>>()) {
        // The same endpoint lists office staff; the Teachers page skips them.
        final isStaff = row['designation_title'] == 'Staff';
        final isArchived = row['is_archived'] == 1;
        if (row['type'] == 'teacher' && !isStaff && !isArchived) {
          teachers.add(Teacher.fromApi(row));
        }
      }
      page++;
    } while (page <= lastPage);

    return teachers;
  }
}
