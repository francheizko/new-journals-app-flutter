import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:state_change_demo/constants/constants.dart';
import 'package:state_change_demo/controller/auth_controller.dart';
import 'package:state_change_demo/dialogs/waiting_dailog.dart';

class ProfileScreen extends StatelessWidget {
  static const String route = '/profile';
  static const String path = "/profile";
  static const String name = "Profile Screen";

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lwhite,
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: lmainblue,
              padding: const EdgeInsets.symmetric(vertical: 20),
              textStyle: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            onPressed: () {
              WaitingDialog.show(context, future: AuthController.I.logout());
            },
            child: const Text('Sign out'),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    Image.asset('assets/images/Tap & Tell-3.png', height: 150),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Trails App',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Trails App is your ultimate companion for discovering and exploring nature\'s wonders. Whether you\'re a seasoned hiker, a casual walker, or someone who loves outdoor adventures, our app is designed to help you find, track, and enjoy trails all around you.\n\n'
                      'Our Mission\n'
                      'At Trails App, our mission is to inspire people to connect with nature and explore the great outdoors. We believe that every trail tells a story, and our goal is to make those stories accessible to everyone. From hidden gems to popular paths, we aim to provide comprehensive information and a seamless experience for outdoor enthusiasts of all levels.',
                      style: GoogleFonts.poppins(color: ldarkblue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
