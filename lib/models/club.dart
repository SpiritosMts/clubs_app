
import 'event.dart';

class Club {
  String name;
  String id;
  String desc;
  String logoUrl;
  String createdTime;
  List<String> members;
  List<ClubEvent> events;

  Club({
    this.name = '',
    this.id = '',
    this.desc = '',
    this.logoUrl = '',
    this.createdTime = '',
    this.members = const [],
    this.events = const [],
  });

  // Convert Club object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'logoUrl': logoUrl,
      'createdTime': createdTime,
      'members': members,
      'events': events.map((ClubEvent event) => event.toJson()).toList(),
    };
  }

  // Create Club object from JSON
  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      desc: json['desc'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      createdTime: json['createdTime'] ?? '',
      members: List<String>.from(json['members'] ?? []),
      events: json.containsKey('events') && json['events'] != null
          ? (json['events'] as List).map((eventJson) => ClubEvent.fromJson(eventJson)).toList()
          : [],
    );
  }
}