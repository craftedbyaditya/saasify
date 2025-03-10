import 'package:flutter/material.dart';
import 'package:saasify_lite/constants/dimensions.dart';
import 'package:saasify_lite/widgets/custom_button.dart';
import 'package:saasify_lite/widgets/custom_textfield.dart';

import '../../bloc/authentication/authentication_bloc.dart';

class AuthScreen extends StatefulWidget {
  final bool isSignUp;
  const AuthScreen({super.key, this.isSignUp = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final AuthenticationBloc _authBloc = AuthenticationBloc();
  bool _isLoading = false;

  void _setLoading(bool value) {
    setState(() => _isLoading = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isSignUp
                      ? 'Hi, welcome to Saasify :)'
                      : 'Welcome back to Saasify!',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppDimensions.marginLarge),

                if (widget.isSignUp)
                  CustomTextField(
                    label: 'Username',
                    controller: _usernameController,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your username' : null,
                  ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.marginLarge),

                (_isLoading)
                    ? const Center(child: CircularProgressIndicator())
                    : CustomElevatedButton(
                  text: widget.isSignUp ? 'Register' : 'Sign In',
                  onTap: () => _authBloc.authenticate(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                    isSignUp: widget.isSignUp,
                    context: context,
                    usernameController: widget.isSignUp
                        ? _usernameController
                        : null,
                    setLoading: _setLoading,
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AuthScreen(isSignUp: !widget.isSignUp),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: widget.isSignUp
                            ? "Already have an account? "
                            : "Don't have an account? ",
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text: widget.isSignUp ? "Sign in" : "Sign up",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}