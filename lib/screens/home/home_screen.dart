import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:state_change_demo/constants/constants.dart';
import 'package:state_change_demo/model/journal_entry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String route = '/home';
  static const String path = "/home";
  static const String name = "Home Screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  Stream<List<JournalEntry>> _fetchJournalEntries() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('User not logged in');
      return Stream.value([]);
    }

    print('Fetching entries for user ID: $userId');

    // Fetch all entries for the user
    Query query = FirebaseFirestore.instance
        .collection('journal_entries')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true);

    return query.snapshots().map((snapshot) {
      print('Snapshot received with ${snapshot.docs.length} documents');
      List<JournalEntry> entries = snapshot.docs
          .map((doc) {
            final data = doc.data()
                as Map<String, dynamic>; // Ensure data is cast properly
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

      // Filter entries based on the search query
      if (_searchQuery.isNotEmpty) {
        final searchLowerCase = _searchQuery.toLowerCase();
        entries = entries
            .where(
                (entry) => entry.title.toLowerCase().contains(searchLowerCase))
            .toList();
      }

      return entries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lwhite,
      appBar: AppBar(
        title: Text(
          'Trails',
          style: GoogleFonts.poppins(
            color: ldarkblue,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: lwhite,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: SizedBox(
            width: 100,
            height: 100,
            child: Image.asset(
              'assets/images/Tap & Tell-4.png',
              fit: BoxFit
                  .contain, // Ensures the image fits within the AspectRatio
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              iconSize: 30,
              icon: const Icon(Icons.notifications, color: llightgray),
              onPressed: () {},
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          height: 52,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Color.fromARGB(179, 237, 236, 236),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                      style: GoogleFonts.poppins(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Search for articles...',
                        hintStyle: GoogleFonts.poppins(fontSize: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    width: 47,
                    height: 49,
                    decoration: BoxDecoration(
                      color: lmainblue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.search,
                        color: Color(0xFFF5F5F5),
                        size: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
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
                        child: Text('Journal entry not found!'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final entry = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: lwhite,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: entry.imageUrl.isNotEmpty
                                    ? Image.network(
                                        entry.imageUrl,
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey[200],
                                        width: double.infinity,
                                        height: 120,
                                        child: Center(
                                          child: Text(
                                            'No Image',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ldarkblue,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.timestamp.toDate().toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: lsecfontcolor,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
