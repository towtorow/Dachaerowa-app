class Event {
  final int id;
  final String imageUrl;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime startDateTime;
  final DateTime endDateTime;

  Event({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.startDateTime,
    required this.endDateTime,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      imageUrl: json['imageUrl'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      location: json['location'],
      startDateTime: DateTime.parse(json['startDateTime']),
      endDateTime: DateTime.parse(json['endDateTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
    };
  }
}
