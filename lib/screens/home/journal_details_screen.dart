import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:state_change_demo/constants/constants.dart';
import 'package:state_change_demo/model/journal_entry.dart';
import 'package:state_change_demo/screens/home/create_journal_entry.dart';
import 'package:intl/intl.dart'; // Import intl package

class DetailScreen extends StatefulWidget {
  final JournalEntry entry;

  const DetailScreen({super.key, required this.entry});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late JournalEntry _entry;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
    print('Entry ID: ${_entry.id}');
  }

  void showEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => CreateJournalEntryScreen(
        entry: _entry,
        location: _entry.location != null
            ? LatLng(_entry.location!.latitude, _entry.location!.longitude)
            : const LatLng(0.0, 0.0),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          _refreshEntry();
        });
      }
    });
  }

  Future<void> _refreshEntry() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('journal_entries')
          .doc(_entry.id);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          _entry = JournalEntry.fromMap(data)..id = docSnapshot.id;
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error refreshing entry: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_entry.location != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_entry.location!.latitude, _entry.location!.longitude),
          15, // Adjust the zoom level here
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the timestamp
    String formattedDate =
        DateFormat('MMMM d, yyyy').format(_entry.timestamp.toDate());
    String formattedTime =
        DateFormat('h:mm a').format(_entry.timestamp.toDate());

    return Scaffold(
      backgroundColor: lwhite,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 430,
                width: MediaQuery.of(context).size.width,
                child: _entry.imageUrl.isNotEmpty
                    ? Image.network(
                        _entry.imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[200],
                        width: double.infinity,
                        height: 200,
                        child: const Center(
                          child: Text(
                            'No Image',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/about-icon.png'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'About ${_entry.title}',
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      _entry.description,
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: lsecfontcolor),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 380,
            left: 23.5,
            child: Container(
              width: 380,
              height: 110,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27),
                color: lwhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.17),
                    offset: const Offset(0.0, 3.0),
                    blurRadius: 24.0,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _entry.title,
                    style: GoogleFonts.poppins(
                        fontSize: 27, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        '$formattedDate at $formattedTime',
                        style: GoogleFonts.poppins(
                            fontSize: 18, color: llightgray),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                height: 28,
                width: 28,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/icons8-back-100.png'),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 70,
            right: 20,
            child: GestureDetector(
              onTap: () {
                showEditModal(context);
              },
              child: const Icon(
                Icons.edit,
                color: lwhite,
                size: 28,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: _entry.location != null
                ? GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _entry.location!.latitude,
                        _entry.location!.longitude,
                      ),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('entry-location'),
                        position: LatLng(
                          _entry.location!.latitude,
                          _entry.location!.longitude,
                        ),
                      ),
                    },
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Text(
                        'No Location',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
