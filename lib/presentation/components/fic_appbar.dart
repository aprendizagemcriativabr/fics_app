import 'package:flutter/material.dart';
import '../utility/color.dart';

class FicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const FicAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryYellow,
      elevation: 0,
      centerTitle: true, 
      toolbarHeight: 100,
      leading: IconButton(
        padding: const EdgeInsets.only(top: 10),
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text),
        onPressed: () => Navigator.pop(context),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            height: 1.1,
          ),
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(20),
        child: SizedBox(height: 20),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}