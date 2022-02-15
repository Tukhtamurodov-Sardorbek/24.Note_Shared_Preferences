import 'package:all_in_one/services/preferences_service.dart';
import 'package:flutter/foundation.dart';

class Note implements Comparable<Note> {
  late int id;
  late DateTime lastEditedTime;
  late String title;
  late String note;
  late String importanceLevel;


  Note(
      {
        required this.id,
        required this.lastEditedTime,
        required this.title,
        required this.note,
        required this.importanceLevel,
      }
  );

  /// Map to Object
  Note.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lastEditedTime = DateTime.parse(json['lastEditedTime']);
    title = json['title'];
    note = json['note'];
    importanceLevel = json['importanceLevel'];
  }

  /// Object to Map
  Map<String, dynamic> toJson() => {
    'id' : id,
    'lastEditedTime' : lastEditedTime.toString(),
    'title' : title,
    'note' : note,
    'importanceLevel' : importanceLevel,
  };

  @override
  int compareTo(Note other) {
    return importanceLevel.compareTo(other.importanceLevel);
  }
}