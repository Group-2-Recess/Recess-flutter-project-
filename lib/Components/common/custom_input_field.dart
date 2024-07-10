import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final bool isDense;
  final bool obscureText;
  final bool suffixIcon;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomInputField({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.isDense = false,
    this.obscureText = false,
    this.suffixIcon = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          isDense: isDense,
          suffixIcon: suffixIcon ? Icon(Icons.visibility) : null,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
