// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:state_change_demo/constants/constants.dart';
import 'package:state_change_demo/model/journal_entry.dart';

class CreateJournalEntryScreen extends StatefulWidget {
  static const String route = '/add_entry';
  static const String path = "/add_entry";
  static const String name = "Add Journal Entry";

  final LatLng location;
  final JournalEntry? entry;

  const CreateJournalEntryScreen(
      {required this.location, this.entry, super.key});

  @override
  _CreateJournalEntryScreenState createState() =>
      _CreateJournalEntryScreenState();
}

class _CreateJournalEntryScreenState extends State<CreateJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  XFile? _image;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _title = widget.entry!.title;
      _description = widget.entry!.description;
    }
  }

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
    setState(() {
      _isSubmitting = true;
    });

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        print('User not logged in');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      } else {
        imageUrl = widget.entry?.imageUrl;
      }

      try {
        if (widget.entry != null) {
          final docRef = FirebaseFirestore.instance
              .collection('journal_entries')
              .doc(widget.entry!.id);

          final docSnapshot = await docRef.get();
          if (docSnapshot.exists) {
            await docRef.update({
              'title': _title ?? '',
              'description': _description ?? '',
              'location': GeoPoint(
                widget.location.latitude,
                widget.location.longitude,
              ),
              'timestamp': Timestamp.now(),
              'userId': userId,
              'imageUrl': imageUrl,
            });
            print('Journal entry updated successfully');
          } else {
            print('Document does not exist');
          }
        } else {
          await FirebaseFirestore.instance.collection('journal_entries').add({
            'title': _title ?? '',
            'description': _description ?? '',
            'location': GeoPoint(
              widget.location.latitude,
              widget.location.longitude,
            ),
            'timestamp': Timestamp.now(),
            'userId': userId,
            'imageUrl': imageUrl,
          });
          print('Journal entry added successfully');
        }

        Navigator.of(context).pop(true);
      } catch (e) {
        print('Failed to save journal entry: $e');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      backgroundColor: lwhite,
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: ldarkblue,
                ),
                title: Text(
                  'Take a Photo',
                  style: GoogleFonts.poppins(
                    color: ldarkblue,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: ldarkblue,
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.poppins(
                    color: ldarkblue,
                  ),
                ),
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
      backgroundColor: lwhite,
      appBar: AppBar(
        backgroundColor: lwhite,
        title: Text(
          widget.entry == null ? 'Create Journal Entry' : 'Edit Journal Entry',
          style: GoogleFonts.poppins(
              color: ldarkblue, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _showImageSourceSelection,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 4,
                              offset: const Offset(3, 3),
                            ),
                          ],
                          color: lwhite,
                          borderRadius: BorderRadius.circular(12),
                          image: _image != null
                              ? DecorationImage(
                                  image: FileImage(File(_image!.path)),
                                  fit: BoxFit.cover,
                                )
                              : widget.entry?.imageUrl != null
                                  ? DecorationImage(
                                      image:
                                          NetworkImage(widget.entry!.imageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: _image == null && widget.entry?.imageUrl == null
                            ? Center(
                                child: Image.asset(
                                  'assets/images/image-icon.png',
                                  width: 50,
                                  height: 50,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color.fromARGB(179, 237, 236, 236),
                      ),
                      child: TextFormField(
                        initialValue: _title,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Title',
                            labelStyle: GoogleFonts.poppins(
                              color: ldarkblue,
                              fontSize: 16,
                            ),
                            counterText: ''),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a title' : null,
                        onSaved: (value) => _title = value,
                        maxLines: 1,
                        maxLength: 15,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color.fromARGB(179, 237, 236, 236),
                      ),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        initialValue: _description,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Description',
                          labelStyle: GoogleFonts.poppins(
                            color: ldarkblue,
                            fontSize: 16,
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter a description'
                            : null,
                        onSaved: (value) => _description = value,
                        maxLines: 3,
                        maxLength: 100,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      ),
                    ),
                    const SizedBox(height: 45),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        foregroundColor: Colors.white,
                        backgroundColor: lmainblue,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        textStyle: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(widget.entry == null ? 'Create' : 'Update'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
