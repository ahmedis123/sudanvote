import 'package:flutter/material.dart';

class Election {
  final int elctionID;
  final String elctionStatus, elctionType;
  final DateTimeRange elctionDate;

  Election(
      {required this.elctionID,
      required this.elctionStatus,
      required this.elctionType,
      required this.elctionDate});

  factory Election.formJson(Map<String, dynamic> json) {
    String electionDateStr = json['ElectionDate'];
    List<String> dates = electionDateStr.split(' - ');

    DateTimeRange electioDateTimeRange = DateTimeRange(
        start: DateTime.parse(dates[0]), end: DateTime.parse(dates[1]));
    return Election(
        elctionID: json['ElectionID'],
        elctionStatus: json['ElectionStatus'],
        elctionType: json['ElectionType'],
        elctionDate: electioDateTimeRange);
  }
}
