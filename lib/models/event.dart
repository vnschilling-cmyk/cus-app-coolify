class Event {
  final String id;
  final String name;
  final String type; // e.g., 'Messe', 'Hausmesse'

  const Event({
    required this.id,
    required this.name,
    required this.type,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }
}
