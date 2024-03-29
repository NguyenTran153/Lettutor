import 'dart:convert';
import 'dart:async';

import 'package:flutter_project/models/schedule/schedule.dart';
import 'package:http/http.dart';

import '../envs/environment.dart';
import '../models/schedule/booking_info.dart';

class ScheduleService {
  static final _baseUrl = EnvironmentConfig.apiUrl;

  static Future<Map<String, dynamic>> getBookedClasses({
    required String token,
    required int page,
    required int perPage,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    String url =
        '$_baseUrl/booking/list/student?page=$page&perPage=$perPage&dateTimeGte=$now&orderBy=meeting&sortBy=asc';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Response response = await get(Uri.parse(url), headers: headers);

    final jsonDecode = json.decode(response.body);
    if (response.statusCode != 200) {
      throw Exception(
          'Error: Cannot get upcoming classes. ${jsonDecode['message']}');
    }

    final List<dynamic> classes = jsonDecode['data']['rows'];
    return {
      'count': jsonDecode['data']['count'],
      'classes':
          classes.map((schedule) => BookingInfo.fromJson(schedule)).toList(),
    };
  }

  static Future<Map<String, dynamic>> getHistory({
    required String token,
    required int page,
    required int perPage,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    String url =
        '$_baseUrl/booking/list/student?page=$page&perPage=$perPage&dateTimeLte=$now&orderBy=meeting&sortBy=desc';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Response response = await get(Uri.parse(url), headers: headers);

    final jsonDecode = json.decode(response.body);
    if (response.statusCode != 200) {
      throw Exception('Error: Cannot get history. ${jsonDecode['message']}');
    }

    final List<dynamic> classes = jsonDecode['data']['rows'];
    return {
      'count': jsonDecode['data']['count'],
      'classes':
          classes.map((schedule) => BookingInfo.fromJson(schedule)).toList(),
    };
  }

  static Future<List<Schedule>> getScheduleByTutorId({
    required String token,
    required String userId,
  }) async {
    String url = '$_baseUrl/schedule';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, String> body = {
      'tutorId': userId,
    };

    Response response =
        await post(Uri.parse(url), headers: headers, body: jsonEncode(body));
    final jsonDecode = json.decode(response.body);
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(['message']));
    }
    final schedules = jsonDecode['data'] as List;
    return schedules.map((schedule) => Schedule.fromJson(schedule)).toList();
  }

  static Future<List<Schedule>> getTutorScheduleById({
    required String token,
    required String userId,
    required int startDate,
    required int endDate,
  }) async {
    final response = await get(
        Uri.parse(
            '$_baseUrl/schedule?tutorId=$userId&startTimestamp=$startDate&endTimestamp=$endDate'),
        headers: {'Authorization': 'Bearer $token'});

    final jsonDecode = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(['message']));
    }

    final schedules = jsonDecode['scheduleOfTutor'] as List;
    return schedules.map((schedule) => Schedule.fromJson(schedule)).toList();
  }

  static Future<void> bookAClass({
    required List<String> scheduleDetailIds,
    required String note,
    required String token,
  }) async {
    String url = '$_baseUrl/booking';
    Map<String, String> headers = {
      'Content-Type': 'application/json;encoding=utf-8',
      'Authorization': 'Bearer $token',
    };

    Response response = await post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(
        {
          'scheduleDetailIds': scheduleDetailIds,
          'note': note,
        },
      ),
    );

    final jsonDecode = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(jsonDecode['message']);
    }
  }

  static Future<String> cancelBookedClass({
    required List<String> scheduleDetailIds,
    required String token,
  }) async {
    final response = await delete(
      Uri.parse('$_baseUrl/booking'),
      headers: {
        'Content-Type': 'application/json;encoding=utf-8',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(
        {
          'scheduleDetailIds': scheduleDetailIds,
        },
      ),
    );

    if (response.statusCode != 200) {
      return json.decode(response.body)['message'];
    }
    return "Class Cancelled Successfully";
  }
}
