import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

void main() async {
  final handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(createStaticHandler('build/web', 
          defaultDocument: 'index.html'));

  final server = await io.serve(handler, '0.0.0.0', 3000);
  print('Serving at http://${server.address.host}:${server.port}');
} 