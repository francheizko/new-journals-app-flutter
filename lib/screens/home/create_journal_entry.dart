import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateJournalEntryScreen extends StatefulWidget {
  static const String route = '/add_entry';
  static const String path = "/add_entry";
  static const String name = "Add Journal Entry";

  final LatLng location;

  const CreateJournalEntryScreen({required this.location, super.key});

  @override
  _CreateJournalEntryScreenState createState() =>
      _CreateJournalEntryScreenState();
}

class _CreateJournalEntryScreenState extends State<CreateJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  Future<String?> _uploadImage(XFile image) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('User not logged in');
      return null;
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
    final storageRef =
        FirebaseStorage.instance.ref().child('journal_images').child(fileName);

    try {
      await storageRef.putFile(File(image.path));
      final downloadUrl = await storageRef.getDownloadURL();
      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        print('User not logged in');
        return;
      }

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      } else {
        print('No image selected');
      }

      try {
        await FirebaseFirestore.instance.collection('journal_entries').add({
          'title': _title ?? '',
          'description': _description ?? '',
          'location': GeoPoint(
            widget.location.latitude,
            widget.location.longitude,
          ),
          'timestamp': Timestamp.now(),
          'userId': userId,
          'imageUrl': imageUrl ?? '', // Include image URL if available
        });
        print('Journal entry added successfully');
        Navigator.of(context).pop();
      } catch (e) {
        print('Error adding journal entry: $e');
      }
    }
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Journal Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
                onSaved: (value) => _description = value,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showImageSourceSelection,
                child: const Text('Pick Image'),
              ),
              if (_image != null) ...[
                const SizedBox(height: 20),
                Image.file(File(_image!.path), width: 100, height: 100),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
