import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Cubit/authentication/auth_cubit.dart';
import 'package:sa7el/Cubit/authentication/auth_state.dart';
import 'package:sa7el/views/Authentication/widgets/custom_snackBar.dart';
import 'package:sa7el/views/Authentication/widgets/custom_textFormField.dart';
import 'package:sa7el/views/Home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return BlocConsumer<AuthenticationCubit, AuthenticationStates>(
      listener: (context, state) {
        if (state is AuthenticationLoginStatesuccess) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else if (state is AuthenticationLoginStateFailed) {
          customSnackBar(context: context, message: state.errMessage);
        }
      },
      builder: (context, state) {
        if (state is AuthenticationLoginStateLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: WegoColors.mainColor),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                "Login",
                style: TextStyle(
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(width * 0.04),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: height * 0.03),
                      Row(
                        children: [
                          Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: width * 0.06,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.01),
                      Row(
                        children: [
                          Text(
                            "Login into your Account",
                            style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF7C7C7C),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.03),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: WegoColors.mainColor),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: WegoColors.mainColor),
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password" + ' is required';
                          }
                          // Add more email validation if needed
                          return null;
                        },
                      ),
                      SizedBox(height: height * 0.025),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: WegoColors.mainColor),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: WegoColors.mainColor),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: height * 0.03),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            BlocProvider.of<AuthenticationCubit>(
                              context,
                            ).adminLogin(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WegoColors.mainColor,
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.018,
                            horizontal: width * 0.37,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: width * 0.045,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
