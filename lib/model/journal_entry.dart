import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  String? id;
  final String title;
  final String description;
  final String imageUrl;
  final Timestamp timestamp;
  final GeoPoint? location;

  JournalEntry({
    this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    this.location,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> data) {
    return JournalEntry(
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
      location: data['location'] != null ? data['location'] as GeoPoint : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'location': location,
    };
  }
}
