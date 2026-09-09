import 'dart:convert';

class CounterSession {
  final String id;
  final String dhikrId;
  final String dhikrTitle;
  final int count;
  final DateTime timestamp;
  final int durationSeconds;

  CounterSession({
    required this.id,
    required this.dhikrId,
    required this.dhikrTitle,
    required this.count,
    required this.timestamp,
    required this.durationSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dhikrId': dhikrId,
      'dhikrTitle': dhikrTitle,
      'count': count,
      'timestamp': timestamp.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  factory CounterSession.fromMap(Map<String, dynamic> map) {
    return CounterSession(
      id: map['id'] ?? '',
      dhikrId: map['dhikrId'] ?? '',
      dhikrTitle: map['dhikrTitle'] ?? '',
      count: map['count'] ?? 0,
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      durationSeconds: map['durationSeconds'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory CounterSession.fromJson(String source) =>
      CounterSession.fromMap(json.decode(source));
}
