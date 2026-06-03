import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBarForms extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarForms({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: const Color(0xFF0B1422),
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF1E94F6)),
      title: Text(
        title,
        style: GoogleFonts.manrope(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
