import 'package:flutter/material.dart';

class FicSectionLabel extends StatelessWidget {
  final String text;

  const FicSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: Colors.black54,
      ),
    );
  }
}
