import 'package:flutter/material.dart';
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
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                WaitingDialog.show(context, future: AuthController.I.logout());
              },
              child: const Text("Sign out"),
            ),
          ),
        ),
        body: SafeArea(child: const Center(child: Text("Profile"))));
  }
}
