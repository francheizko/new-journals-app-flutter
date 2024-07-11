import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:state_change_demo/model/journal_entry.dart';

class HomeScreen extends StatelessWidget {
  static const String route = '/home';
  static const String path = "/home";
  static const String name = "Home Screen";

  const HomeScreen({super.key});

  Stream<List<JournalEntry>> _fetchJournalEntries() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('User not logged in');
      return Stream.value([]);
    }

    print('Fetching entries for user ID: $userId');

    return FirebaseFirestore.instance
        .collection('journal_entries')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Snapshot received with ${snapshot.docs.length} documents');
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            print('Document data: $data');
            try {
              return JournalEntry.fromMap(data); // Return JournalEntry instance
            } catch (e) {
              print('Error parsing document data: $e');
              return null; // Return null if there is an error
            }
          })
          .where((entry) => entry != null) // Filter out null entries
          .cast<JournalEntry>() // Cast to List<JournalEntry>
          .toList(); // Convert to List<JournalEntry>
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          height: 52,
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<JournalEntry>>(
          stream: _fetchJournalEntries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return const Center(
                  child: Text('Error fetching journal entries'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text(
                      'Your journal list is empty, create your journal entry now!'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final entry = snapshot.data![index];
                return ListTile(
                  title: Text(entry.title), // Use correct property name
                  subtitle: Text(entry.timestamp
                      .toDate()
                      .toString()), // Use correct property name
                  leading: entry.imageUrl.isNotEmpty
                      ? Image.network(entry.imageUrl,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
