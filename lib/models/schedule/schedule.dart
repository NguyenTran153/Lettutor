import '../tutor/tutor.dart';
import 'schedule_detail.dart';

class Schedule {
  String? id;
  String? tutorId;
  String? startTime;
  String? endTime;
  int? startTimestamp;
  int? endTimestamp;
  String? createdAt;
  bool? isBooked;
  List<ScheduleDetail>? scheduleDetails;
  Tutor? tutorInfo;

  Schedule({
    this.id,
    this.tutorId,
    this.startTime,
    this.endTime,
    this.startTimestamp,
    this.endTimestamp,
    this.createdAt,
    this.isBooked,
    this.scheduleDetails,
    this.tutorInfo,
  });

  Schedule.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tutorId = json['tutorId'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    startTimestamp = json['startTimestamp'];
    endTimestamp = json['endTimestamp'];
    createdAt = json['createdAt'];
    isBooked = json['isBooked'];
    if (json['scheduleDetails'] != null) {
      scheduleDetails = <ScheduleDetail>[];
      json['scheduleDetails'].forEach((v) {
        scheduleDetails!.add(ScheduleDetail.fromJson(v));
      });
    }
    tutorInfo = json['tutorInfo'] != null ? Tutor.fromJson(json['tutorInfo']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['tutorId'] = tutorId;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['startTimestamp'] = startTimestamp;
    data['endTimestamp'] = endTimestamp;
    data['createdAt'] = createdAt;
    data['isBooked'] = isBooked;
    if (scheduleDetails != null) {
      data['scheduleDetails'] = scheduleDetails!.map((v) => v.toJson()).toList();
    }
    if (tutorInfo != null) {
      data['tutorInfo'] = tutorInfo!.toJson();
    }
    return data;
  }
}