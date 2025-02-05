import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/reader_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

const String kCurrentVersion = "1.0.41";  // Update this when deploying new version

void main() {
  runApp(const RsvpReaderApp());
}

class RsvpReaderApp extends StatefulWidget {
  const RsvpReaderApp({super.key});

  @override
  State<RsvpReaderApp> createState() => _RsvpReaderAppState();
}

class _RsvpReaderAppState extends State<RsvpReaderApp> {
  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    try {
      // Get the last checked version from preferences
      final prefs = await SharedPreferences.getInstance();
      final lastVersion = prefs.getString('lastVersion') ?? '';

      // Fetch current version from server with timeout
      final response = await http.get(
        Uri.parse('/version.json'),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('', 408),
      );

      if (response.statusCode == 200) {
        final versionInfo = json.decode(response.body);
        final serverVersion = versionInfo['version'];
        final forceRefresh = versionInfo['forceRefresh'] ?? false;

        if (serverVersion != lastVersion && forceRefresh) {
          await prefs.setString('lastVersion', serverVersion);
          // ignore: undefined_prefixed_name
          html.window.location.reload();
        }
      }
    } catch (e) {
      // Silently handle errors to not disrupt the user experience
      debugPrint('Version check failed: $e');
    }
  }

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