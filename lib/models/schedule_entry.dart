class ScheduleEntry {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String type; // CLASS, EXAM, HOLIDAY
  final String? venue;
  final String createdBy;

  ScheduleEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.venue,
    required this.createdBy,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      type: json['type'] ?? 'CLASS',
      venue: json['venue'],
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type,
      'venue': venue,
      'createdBy': createdBy,
    };
  }
}
