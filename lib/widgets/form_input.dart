import 'package:flutter/material.dart';

class FormInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;

  const FormInput({
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onSaved,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(icon, color: Color(0xFF65a30d)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}