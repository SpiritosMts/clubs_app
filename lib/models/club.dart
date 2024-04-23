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
    // Convert the list of events to a map where the key is the event ID and the value is the JSON representation of the event
    Map<String, dynamic> eventsToMap = {};
    for (var event in events) {
      if (event.id != null && event.id.isNotEmpty) {
        eventsToMap[event.id] = event.toJson();
      }
    }

    return {
      'id': id,
      'name': name,
      'desc': desc,
      'logoUrl': logoUrl,
      'createdTime': createdTime,
      'members': members,
      'events': eventsToMap,
    };
  }

  // Create Club object from JSON
  factory Club.fromJson(Map<String, dynamic> json) {
    // Convert the JSON map of events to a list of ClubEvent objects
    List<ClubEvent> eventsFromMap = [];
    if (json.containsKey('events') && json['events'] != null) {
      (json['events'] as Map<String, dynamic>).forEach((key, eventJson) {
        if (eventJson is Map<String, dynamic>) {
          eventsFromMap.add(ClubEvent.fromJson(eventJson));
        }
      });
    }

    return Club(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      desc: json['desc'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      createdTime: json['createdTime'] ?? '',
      members: List<String>.from(json['members'] ?? []),
      events: eventsFromMap,
    );
  }
}
