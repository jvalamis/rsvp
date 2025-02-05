import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

void main() async {
  // Create static handler for web files
  final staticHandler = createStaticHandler('build/web',
      defaultDocument: 'index.html');

  // Check if we're in production
  final isProduction = Platform.environment['FLUTTER_ENV'] == 'production';
  print('Running in ${isProduction ? 'production' : 'development'} mode');

  // Create a cascade handler that will try both paths
  final handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler((request) async {
        // Log full request details
        print('Full request URL: ${request.requestedUri}');
        print('Headers: ${request.headers}');
        print('Incoming request: ${request.method} ${request.url.path}');
        
        if (isProduction) {
          print('Handling in production mode');
          
          // Handle both /rsvp and rsvp paths
          final path = request.url.path;
          if (path.startsWith('rsvp') || path.startsWith('/rsvp')) {
            print('Handling /rsvp request');
            // Create absolute URL for the new request
            final newPath = path.replaceFirst(RegExp(r'^/?rsvp/?'), '');
            final newUri = Uri.parse('http://${request.requestedUri.authority}/$newPath');
            
            print('Serving file from path: $newPath');
            final response = await staticHandler(
              shelf.Request(
                request.method,
                newUri,
                headers: request.headers,
              ),
            );
            print('Response status: ${response.statusCode}');
            return response;
          }
          
          // Redirect root to /rsvp in production
          if (path.isEmpty || path == '/') {
            print('Redirecting to /rsvp/');
            return shelf.Response.movedPermanently('/rsvp/');
          }
        }

        print('Serving static file');
        return staticHandler(request);
      });

  final server = await io.serve(handler, '0.0.0.0', 3000);
  print('Serving at http://${server.address.host}:${server.port} in ${isProduction ? 'production' : 'development'} mode');
} 