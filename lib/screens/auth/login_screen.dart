import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:state_change_demo/constants/constants.dart';
import 'package:state_change_demo/controller/auth_controller.dart';
import 'package:state_change_demo/dialogs/waiting_dailog.dart';
import 'package:state_change_demo/routing/router.dart';
import 'package:state_change_demo/screens/auth/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String route = "/auth";
  static const String name = "Login Screen";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late GlobalKey<FormState> formKey;
  late TextEditingController username, password;
  late FocusNode usernameFn, passwordFn;

  bool obfuscate = true;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    username = TextEditingController(text: "");
    password = TextEditingController(text: "");
    usernameFn = FocusNode();
    passwordFn = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    username.dispose();
    password.dispose();
    usernameFn.dispose();
    passwordFn.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () {
                  GlobalRouter.I.router.go(RegistrationScreen.route);
                },
                child: RichText(
                  text: TextSpan(
                    text: "No account? ",
                    style: GoogleFonts.poppins(
                      color: ldarkblue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Sign Up",
                        style: GoogleFonts.poppins(
                          color: lmainblue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: lwhite,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 0,
            right: 25,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              color: lwhite,
              child:
                  Center(child: Image.asset('assets/images/Tap & Tell-2.png')),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.36,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: lwhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        color: llightgray,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(width: 2),
                              ),
                              prefixIcon: const Icon(Icons.person),
                              labelText: 'Username',
                            ),
                            focusNode: usernameFn,
                            controller: username,
                            onEditingComplete: () {
                              passwordFn.requestFocus();
                            },
                            validator: MultiValidator([
                              RequiredValidator(
                                  errorText: 'Please fill out the username'),
                              MaxLengthValidator(32,
                                  errorText:
                                      "Username cannot exceed 32 characters"),
                              EmailValidator(
                                  errorText: "Please input a valid email"),
                            ]).call,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: password,
                            obscureText: obfuscate,
                            onEditingComplete: () {
                              passwordFn.unfocus();
                              onSubmit();
                            },
                            keyboardType: TextInputType.visiblePassword,
                            validator: MultiValidator([
                              RequiredValidator(
                                  errorText: "Password is required"),
                              MinLengthValidator(
                                8,
                                errorText:
                                    "Password must be at least 8 characters long",
                              ),
                              PatternValidator(
                                r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+?\-=[\]{};':,.<>]).*$",
                                errorText:
                                    'Password must contain at least one symbol, one uppercase letter, one lowercase letter, and one number',
                              ),
                            ]).call,
                            focusNode: passwordFn,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(width: 2),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(obfuscate
                                    ? Icons.remove_red_eye_rounded
                                    : CupertinoIcons.eye_slash),
                                onPressed: () {
                                  setState(() {
                                    obfuscate = !obfuscate;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                foregroundColor: Colors.white,
                                backgroundColor: lmainblue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
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
                              onPressed: () {
                                onSubmit();
                              },
                              child: const Text('Login'),
                            ),
                          ),
                        ],
                      ),
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

  onSubmit() {
    if (formKey.currentState?.validate() ?? false) {
      WaitingDialog.show(context,
          future: AuthController.I
              .login(username.text.trim(), password.text.trim()));
    }
  }

  final OutlineInputBorder _baseBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.all(Radius.circular(4)),
  );

  InputDecoration get decoration => InputDecoration(
      // prefixIconColor: AppColors.primary.shade700,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      errorMaxLines: 3,
      disabledBorder: _baseBorder,
      enabledBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.black87, width: 1),
      ),
      focusedBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
      ),
      errorBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 1),
      )
      // errorStyle:
      // AppTypography.body.b5.copyWith(color: AppColors.highlight.shade900),
      // focusedErrorBorder: _baseBorder.copyWith(
      // borderSide: BorderSide(color: AppColors.highlight.shade900, width: 1),
      // ),
      // labelStyle: AppTypography.subheading.s1
      //     .copyWith(color: AppColors.secondary.shade2),
      // floatingLabelStyle: AppTypography.heading.h5
      //     .copyWith(color: AppColors.primary.shade400, fontSize: 18),
      // hintStyle: AppTypography.subheading.s1
      //     .copyWith(color: AppColors.secondary.shade2),
      );
}
