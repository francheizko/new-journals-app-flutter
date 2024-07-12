import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:state_change_demo/constants/constants.dart';
import 'package:state_change_demo/controller/auth_controller.dart';
import 'package:state_change_demo/dialogs/waiting_dailog.dart';
import 'package:state_change_demo/routing/router.dart';
import 'package:state_change_demo/screens/auth/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static const String route = "/register";
  static const String name = "Registration Screen";
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late GlobalKey<FormState> formKey;
  late TextEditingController username, password, password2;
  late FocusNode usernameFn, passwordFn, passwordFn2;

  bool obfuscate = true;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    username = TextEditingController();
    password = TextEditingController();
    usernameFn = FocusNode();
    passwordFn = FocusNode();
    passwordFn2 = FocusNode();
    password2 = TextEditingController();
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
      backgroundColor: lwhite,
      appBar: AppBar(
        backgroundColor: lwhite,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 180),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    onSubmit();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: lmainblue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Register"),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  GlobalRouter.I.router.go(LoginScreen.route);
                },
                child: RichText(
                  text: TextSpan(
                    text: "Go back to ",
                    style: GoogleFonts.poppins(
                      color: ldarkblue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Login Screen",
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
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sign Up',
                  style: GoogleFonts.poppins(
                    color: llightgray,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Flexible(
                  child: TextFormField(
                    decoration: decoration.copyWith(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.person)),
                    focusNode: usernameFn,
                    controller: username,
                    onEditingComplete: () {
                      passwordFn.requestFocus();
                    },
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Please fill out the email'),
                      EmailValidator(errorText: "Please input a valid email"),
                    ]).call,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Flexible(
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: obfuscate,
                    decoration: decoration.copyWith(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.password),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obfuscate = !obfuscate;
                              });
                            },
                            icon: Icon(obfuscate
                                ? Icons.remove_red_eye_rounded
                                : CupertinoIcons.eye_slash))),
                    focusNode: passwordFn,
                    controller: password,
                    onEditingComplete: () {
                      passwordFn2.requestFocus();
                    },
                    validator: MultiValidator([
                      RequiredValidator(errorText: "Password is required"),
                      MinLengthValidator(12,
                          errorText:
                              "Password must be at least 12 characters long"),
                      MaxLengthValidator(128,
                          errorText: "Password cannot exceed 72 characters"),
                      PatternValidator(
                          r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+?\-=[\]{};':,.<>]).*$",
                          errorText:
                              'Password must contain at least one symbol, one uppercase letter, one lowercase letter, and one number.')
                    ]).call,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Flexible(
                  child: TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: obfuscate,
                      decoration: decoration.copyWith(
                          labelText: "Confirm Password",
                          prefixIcon: const Icon(Icons.password),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obfuscate = !obfuscate;
                                });
                              },
                              icon: Icon(obfuscate
                                  ? Icons.remove_red_eye_rounded
                                  : CupertinoIcons.eye_slash))),
                      focusNode: passwordFn2,
                      controller: password2,
                      onEditingComplete: () {
                        passwordFn2.unfocus();
                      },
                      validator: (v) {
                        String? doestMatchPasswords =
                            password.text == password2.text
                                ? null
                                : "Passwords doesn't match";
                        if (doestMatchPasswords != null) {
                          return doestMatchPasswords;
                        } else {
                          return MultiValidator([
                            RequiredValidator(
                                errorText: "Password is required"),
                            MinLengthValidator(12,
                                errorText:
                                    "Password must be at least 12 characters long"),
                            MaxLengthValidator(128,
                                errorText:
                                    "Password cannot exceed 72 characters"),
                            PatternValidator(
                                r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+?\-=[\]{};':,.<>]).*$",
                                errorText:
                                    'Password must contain at least one symbol, one uppercase letter, one lowercase letter, and one number.'),
                          ]).call(v);
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  onSubmit() {
    if (formKey.currentState?.validate() ?? false) {
      WaitingDialog.show(context,
          future: AuthController.I
              .register(username.text.trim(), password.text.trim()));
    }
  }

  final OutlineInputBorder _baseBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  InputDecoration get decoration => InputDecoration(
      // prefixIconColor: AppColors.primary.shade700,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      errorMaxLines: 3,
      disabledBorder: _baseBorder,
      enabledBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: ldarkblue, width: 1),
      ),
      focusedBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: lmainblue, width: 1),
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
