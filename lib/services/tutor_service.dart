import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import '../envs/environment.dart';
import '../models/tutor/tutor.dart';
import '../models/tutor/tutor_info.dart';
import '../models/user/learn_topic.dart';
import '../models/user/test_preparation.dart';

class TutorService {
  static final _baseUrl = EnvironmentConfig.apiUrl;

  static Future<List<LearnTopic>> getTopics() async {
    return <LearnTopic>[];
  }

  static Future<List<TestPreparation>> getTestPreparations() async {
    return <TestPreparation>[];
  }

  static Future<List<Tutor>> getListTutorWithPagination({
    required int page,
    required int perPage,
    required String token,
  }) async {
    String url = '$_baseUrl/tutor/more?perPage=$perPage&page=$page';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Response response = await get(Uri.parse(url), headers: headers);

    final jsonDecode = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(jsonDecode['message']);
    }

    final List<dynamic> tutors = jsonDecode['tutors']['rows'];
    return tutors.map((tutor) => Tutor.fromJson(tutor)).toList();
  }

  static Future<void> writeReviewForTutor({
    required String token,
    required String bookingId,
    required String userId,
    required int rate,
    required String content,
  }) async {
    final response = await post(
      Uri.parse('$_baseUrl/user/feedbackTutor'),
      headers: {
        'Content-Type': 'application/json;encoding=utf-8',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'bookingId': bookingId,
        'userId': userId,
        'rating': rate,
        'content': content,
      }),
    );

    final jsonDecode = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(jsonDecode['message']);
    }
  }

  static Future<TutorInfo> getTutorInformationById({
    required String token,
    required String userId,
  }) async {
    String url = '$_baseUrl/tutor/$userId';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Response response = await get(Uri.parse(url), headers: headers);

    final jsonDecode = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(jsonDecode['message']);
    }

    return TutorInfo.fromJson(jsonDecode);
  }

  static Future<Map<String, dynamic>> searchTutor({
    required String token,
    String search = '',
    required int page,
    required int perPage,
    required Map<String, bool> nationality,
    required List<String> specialties,
  }) async {
    final response = await post(
      Uri.parse('$_baseUrl/tutor/search'),
      headers: {
        'Content-Type': 'application/json;encoding=utf-8',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'page': page,
        'perPage': perPage,
        'search': search,
        'filters': {
          'specialties': specialties,
          'nationality': nationality,
        },
      }),
    );

    final jsonDecode = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(jsonDecode['message']);
    }

    final List<dynamic> tutors = jsonDecode['rows'];

    return {
      'count': jsonDecode['count'],
      'tutors': tutors.map((tutor) => Tutor.fromJson(tutor)).toList(),
    };
  }

  static Future<void> addTutorToFavorite({
    required String token,
    required String userId,
  }) async {
    final response = await post(
      Uri.parse('$_baseUrl/user/manageFavoriteTutor'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(
        {
          'tutorId': userId,
        },
      ),
    );

    final jsonDecode = json.decode(response.body);
    if (response.statusCode != 200) {
      throw Exception(jsonDecode['message']);
    }
  }

  static Future<void> reportTutor({
    required String token,
    required String userId,
    required String content,
  }) async {
    final response = await post(
      Uri.parse('$_baseUrl/report'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(
        {
          'tutorId': userId,
          'content': content,
        },
      ),
    );

    final jsonDecode = json.decode(response.body);
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(['message']));
    }
  }
}
