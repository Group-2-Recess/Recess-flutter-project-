import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:signup_and_login/Components/common/custom_form_button.dart';
import 'package:signup_and_login/Components/common/page_header.dart';
import 'package:signup_and_login/Components/common/page_heading.dart';
import 'package:signup_and_login/Components/common/custom_input_field.dart';
import 'Login.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _forgetPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: Column(
          children: [
            const PageHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _forgetPasswordFormKey,
                    child: Column(
                      children: [
                        const PageHeading(title: 'Forgot password'),
                        CustomInputField(
                          labelText: 'Email',
                          hintText: 'Your email id',
                          isDense: true,
                          controller: _emailController,
                          validator: (textValue) {
                            if (textValue == null || textValue.isEmpty) {
                              return 'Email is required!';
                            }
                            if (!EmailValidator.validate(textValue)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomFormButton(
                          innerText: 'Submit',
                          onPressed: _handleForgetPassword,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              'Back to login',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xff939393),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleForgetPassword() {
    if (_forgetPasswordFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting data..')),
      );
    }
  }
}
