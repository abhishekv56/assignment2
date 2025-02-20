import 'package:flutter/material.dart';

class CustomTextFormWidget extends StatelessWidget {

  final String lblText;
  final IconData prefixIcon;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final Function(String?) onSaved;
  final IconButton? suffixIcon;
  final bool isObscure;

  const CustomTextFormWidget({super.key,required this.lblText, required this.prefixIcon,required this.validator,required this.keyboardType,required this.onSaved, this.suffixIcon, this.isObscure=false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
          labelText: lblText,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(prefixIcon),
          suffixIcon: suffixIcon
      ),
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      obscureText: isObscure,
    );
  }
}