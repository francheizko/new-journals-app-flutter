import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

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
    target: LatLng(10.2950, 123.8713), // USJR Basak Campus
    zoom: 15,
  );

  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('journal_entries').get();
      final markers = <Marker>{}; // Create a new set for markers
      for (var doc in snapshot.docs) {
        final geoPoint = doc['location'] as GeoPoint;
        markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(geoPoint.latitude, geoPoint.longitude),
            infoWindow: InfoWindow(
              title: doc['title'],
              snippet: doc['description'],
            ),
          ),
        );
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

  void _addJournalEntry(LatLng position) {
    context.push('/add_entry', extra: position);
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

  @override
  void dispose() {
    _mapController.dispose(); // Dispose of the map controller
    super.dispose();
  }
}
