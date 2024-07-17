// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:state_change_demo/constants/constants.dart';
import 'package:state_change_demo/constants/journal_entries_notifier.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

import 'package:state_change_demo/model/journal_entry.dart';
import 'package:state_change_demo/screens/home/journal_details_screen.dart';

class MapScreen extends StatefulWidget {
  static const String route = '/map';
  static const String path = "/map";
  static const String name = "Map Screen";

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(10.289563, 123.861947),
    zoom: 15,
  );

  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  BitmapDescriptor? _customIcon;
  JournalEntriesNotifier? _journalEntriesNotifier;
  final TextEditingController _placeController = TextEditingController();
  List<JournalEntry> _journalEntries = [];

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
    _loadCustomMarkerIcon();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _journalEntriesNotifier?.addListener(_onEntriesChanged);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _journalEntriesNotifier = context.read<JournalEntriesNotifier>();
    _journalEntriesNotifier?.addListener(_onEntriesChanged);
  }

  @override
  void dispose() {
    _journalEntriesNotifier?.removeListener(_onEntriesChanged);
    _mapController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  void _onEntriesChanged() {
    if (_journalEntriesNotifier?.hasNewEntry == true) {
      _loadJournalEntries();
      _journalEntriesNotifier?.setNewEntry(false);
    }
  }

  Future<void> _loadCustomMarkerIcon() async {
    final BitmapDescriptor customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/home_icon.png',
    );

    setState(() {
      _customIcon = customIcon;

      _markers.add(
        Marker(
          markerId: const MarkerId('initial_position'),
          position: _initialCameraPosition.target,
          icon: _customIcon!,
          infoWindow: const InfoWindow(
            title: 'Initial Position',
            snippet: 'This is the initial camera position',
          ),
        ),
      );
    });
  }

  Future<void> _loadJournalEntries() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('User is not logged in.');
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('journal_entries')
          .where('userId', isEqualTo: userId)
          .get();

      final markers = <Marker>{};
      final entries = <JournalEntry>[];

      if (snapshot.docs.isEmpty) {
        print('No journal entries found for user $userId.');
      } else {
        print(
            'Found ${snapshot.docs.length} journal entries for user $userId.');
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final geoPoint = data['location'] as GeoPoint?;
        if (geoPoint != null) {
          final title = data['title'] as String?;
          final description = data['description'] as String?;

          print(
              'Creating marker for entry ${doc.id} at (${geoPoint.latitude}, ${geoPoint.longitude})');

          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(geoPoint.latitude, geoPoint.longitude),
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                title: title ?? 'No Title',
                snippet: description ?? 'No Description',
                onTap: () {
                  _onMarkerTapped(doc.id);
                },
              ),
            ),
          );

          final journalEntry = JournalEntry.fromMap(data)..id = doc.id;
          entries.add(journalEntry);
        } else {
          print('Invalid location data for document ${doc.id}.');
        }
      }

      if (mounted) {
        setState(() {
          _markers.addAll(markers);
          _journalEntries = entries;
        });
      }
    } catch (e) {
      print('Error loading journal entries: $e');
    }
  }

  void _onMarkerTapped(String entryId) {
    final entry = _journalEntries.firstWhere(
      (e) => e.id == entryId,
      orElse: () {
        print('Journal entry not found for ID: $entryId');
        throw StateError('Journal entry not found for ID: $entryId');
      },
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(entry: entry),
      ),
    );
  }

  void _addJournalEntry(LatLng position) async {
    final result = await context.push('/add_entry', extra: position);
    if (result == true) {
      _loadJournalEntries();
    }
  }

  void _showInstructions() {
    showModalBottomSheet(
      backgroundColor: lwhite,
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions for Adding Journal Entries',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'To add a journal entry, follow these steps:',
                    style: GoogleFonts.poppins(color: ldarkblue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Long-press on the map where you want to add a journal entry.',
                    style: GoogleFonts.poppins(color: ldarkblue),
                  ),
                  Text(
                    '2. A form will appear where you can enter details about the journal entry.',
                    style: GoogleFonts.poppins(color: ldarkblue),
                  ),
                  Text(
                    '3. Fill in the details and save your entry.',
                    style: GoogleFonts.poppins(color: ldarkblue),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Positioned(
              top: -5,
              left: MediaQuery.of(context).size.width / 2 - 25,
              child: IconButton(
                iconSize: 50,
                icon: const Icon(
                  Icons.horizontal_rule_rounded,
                  color: llightgray,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Map Screen',
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
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              iconSize: 30,
              icon: const Icon(Icons.question_mark_rounded, color: llightgray),
              onPressed: _showInstructions,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (controller) => _mapController = controller,
            onLongPress: _addJournalEntry,
            markers: _markers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: lwhite,
        onPressed: () => _mapController.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
        child: const Icon(
          Icons.center_focus_strong,
          color: ldarkblue,
        ),
      ),
    );
  }
}
