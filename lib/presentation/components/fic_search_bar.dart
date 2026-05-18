import 'package:flutter/material.dart';
import '../utility/color.dart';

class FicSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const FicSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.secondaryYellow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.text.withOpacity(0.6)),
          prefixIcon: const Icon(Icons.search, color: AppColors.text),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}