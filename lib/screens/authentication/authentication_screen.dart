import 'package:flutter/material.dart';
import 'package:saasify_lite/constants/colors.dart';
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(
            AppDimensions.bodyPadding + AppDimensions.bodyPadding,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                Text(
                  widget.isSignUp ? 'Create Account' : 'Welcome Back',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  widget.isSignUp
                      ? 'Sign up to get started with Saasify'
                      : 'Sign in to continue with Saasify',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppDimensions.marginLarge * 1.5),

                if (widget.isSignUp) ...[
                  CustomTextField(
                    label: 'Name',
                    controller: _usernameController,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter your username'
                                : null,
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                ],

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
                const SizedBox(height: AppDimensions.marginMedium),

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

                const SizedBox(height: AppDimensions.marginLarge * 1.5),

                (_isLoading)
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                      width: double.infinity,
                      child: CustomElevatedButton(
                        text: widget.isSignUp ? 'Create Account' : 'Sign In',
                        onTap:
                            () => _authBloc.authenticate(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              isSignUp: widget.isSignUp,
                              context: context,
                              usernameController:
                                  widget.isSignUp ? _usernameController : null,
                              setLoading: _setLoading,
                            ),
                      ),
                    ),

                const SizedBox(height: AppDimensions.marginLarge),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  AuthScreen(isSignUp: !widget.isSignUp),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text:
                            widget.isSignUp
                                ? "Already have an account? "
                                : "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: widget.isSignUp ? "Sign in" : "Sign up",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryColor,
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
