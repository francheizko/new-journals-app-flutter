import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:state_change_demo/constants/journal_entries_notifier.dart';

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
    target: LatLng(10.289563, 123.861947), // USJR Basak Campus
    zoom: 15,
  );

  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  BitmapDescriptor? _customIcon;
  JournalEntriesNotifier? _journalEntriesNotifier;

  @override
  void initState() {
    super.initState();
    _loadJournalEntries(); // Ensure this is called on initialization

    // Load custom icon
    _loadCustomMarkerIcon();

    // Add a listener to the notifier
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
    _mapController.dispose(); // Dispose of the map controller
    super.dispose();
  }

  void _onEntriesChanged() {
    if (_journalEntriesNotifier?.hasNewEntry == true) {
      _loadJournalEntries(); // Refresh the markers
      _journalEntriesNotifier?.setNewEntry(false); // Reset the flag
    }
  }

  Future<void> _loadCustomMarkerIcon() async {
    final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/home_icon.png',
    );

    setState(() {
      _customIcon = customIcon;

      // Add initial marker for the initial camera position
      _markers.add(
        Marker(
          markerId: MarkerId('initial_position'),
          position: _initialCameraPosition.target,
          icon: _customIcon!,
          infoWindow: InfoWindow(
            title: 'Initial Position',
            snippet: 'This is the initial camera position',
          ),
        ),
      );
    });
  }

  Future<void> _loadJournalEntries() async {
    try {
      // Get the current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        // Handle case when user is not logged in
        print('User is not logged in.');
        return;
      }

      // Query to get journal entries for the current user
      final snapshot = await FirebaseFirestore.instance
          .collection('journal_entries')
          .where('userId',
              isEqualTo:
                  userId) // Ensure 'userId' matches your Firestore field name
          .get();

      final markers = <Marker>{}; // Create a new set for markers

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
          final imageUrl = data['imageUrl'] as String?;

          print(
              'Creating marker for entry ${doc.id} at (${geoPoint.latitude}, ${geoPoint.longitude})');

          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(geoPoint.latitude, geoPoint.longitude),
              // Use default icon for journal entries
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                title: title ?? 'No Title',
                snippet: description ?? 'No Description',
                // You can optionally add an image or other details here
              ),
            ),
          );
        } else {
          print('Invalid location data for document ${doc.id}.');
        }
      }

      if (mounted) {
        setState(() {
          _markers.addAll(markers); // Update the markers set
        });
      }
    } catch (e) {
      print('Error loading journal entries: $e');
    }
  }

  void _addJournalEntry(LatLng position) async {
    final result = await context.push('/add_entry', extra: position);
    if (result == true) {
      _loadJournalEntries(); // Refresh the markers when returning from the add entry screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Screen')),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: (controller) => _mapController = controller,
        onLongPress: _addJournalEntry,
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mapController.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
