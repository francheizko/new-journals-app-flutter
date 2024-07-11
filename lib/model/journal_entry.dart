import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;
  final String title;
  final String imageUrl;
  final GeoPoint location;
  final Timestamp timestamp;

  JournalEntry({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.location,
    required this.timestamp,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    try {
      return JournalEntry(
        id: map['id'] ?? '', // Ensure you have 'id' in your documents
        title: map['title'] ?? '', // Map 'title' to 'title'
        imageUrl: map['imageUrl'] ?? '',
        location: map['location'] ?? GeoPoint(0, 0),
        timestamp: map['timestamp'] ??
            Timestamp.now(), // Map 'timestamp' to 'timestamp'
      );
    } catch (e) {
      print('Error creating JournalEntry from map: $e');
      rethrow;
    }
  }
}
