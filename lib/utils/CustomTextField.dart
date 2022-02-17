
import 'package:flutter/material.dart';
class CustomTextField extends StatelessWidget {
  final controller;
  final onChanged;

  const CustomTextField({
    Key? key,
    this.controller,
    this.onChanged
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        width: 100,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none
          ),
          keyboardType: TextInputType.number,
        )
    );
  }
}