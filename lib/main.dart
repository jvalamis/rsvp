import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/reader_screen.dart';

void main() {
  runApp(const RsvpReaderApp());
}

class RsvpReaderApp extends StatelessWidget {
  const RsvpReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSVP Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF268bd2),
          background: const Color(0xFFfdf6e3),
        ),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2aa198),
          background: const Color(0xFF002b36),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const ReaderScreen(),
    );
  }
} 