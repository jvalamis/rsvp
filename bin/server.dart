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

  // Create a cascade handler that will try both paths
  final handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler((request) {
        if (isProduction) {
          // Production behavior - handle /rsvp path
          if (request.url.path.startsWith('rsvp')) {
            // Remove /rsvp from the path and serve the static content
            final newPath = request.url.path.replaceFirst('rsvp', '');
            final newUrl = request.url.replace(path: newPath);
            final newRequest = request.change(url: newUrl);
            return staticHandler(newRequest);
          }
          
          // Redirect root to /rsvp in production
          if (request.url.path.isEmpty || request.url.path == '/') {
            return shelf.Response.movedPermanently('/rsvp/');
          }
        }

        // Local development - serve everything at root
        return staticHandler(request);
      });

  final server = await io.serve(handler, '0.0.0.0', 3000);
  print('Serving at http://${server.address.host}:${server.port}');
} 