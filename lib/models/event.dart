class Event {
  final String? id;
  final String title;
  final DateTime date;
  final String description;
  final String venue;
  final bool isPublic;
  final String? createdBy;
  final bool registrationStarted;
  final String? imageUrl;

  Event({
    this.id,
    required this.title,
    required this.date,
    required this.description,
    this.venue = 'TBD',
    this.isPublic = true,
    this.createdBy,
    this.registrationStarted = false,
    this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      description: json['description'],
      venue: json['venue'] ?? 'TBD',
      isPublic: json['public'] ?? true, 
      createdBy: json['createdBy'],
      registrationStarted: json['registrationStarted'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'description': description,
      'venue': venue,
      'public': isPublic,
      'createdBy': createdBy,
      'registrationStarted': registrationStarted,
      'imageUrl': imageUrl,
    };
  }
}
