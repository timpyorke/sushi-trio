// Rebuild the opaque launcher master from the transparent sushi artwork.
// dart run tool/gen_app_icon.dart [new-foreground.png]
// dart run flutter_launcher_icons
import 'dart:io';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  final root = File.fromUri(Platform.script).parent.parent.path;
  final foregroundFile = File('$root/assets/icons/app_no_bg.png');
  final source = args.isEmpty ? foregroundFile : File(args.single);
  final decoded = img.decodeImage(source.readAsBytesSync());
  if (decoded == null) throw FormatException('Cannot decode ${source.path}');
  if (decoded.width != decoded.height || !decoded.hasAlpha) {
    throw const FormatException('Foreground must be square with transparency');
  }
  const size = 1024;
  final foreground = img.copyResize(decoded,
      width: size, height: size, interpolation: img.Interpolation.cubic);
  foregroundFile.writeAsBytesSync(img.encodePng(foreground));

  // Keep this color in sync with adaptive_icon_background in pubspec.yaml.
  final icon = img.Image(width: size, height: size, numChannels: 3);
  img.fill(icon, color: img.ColorRgb8(0x12, 0x3f, 0x45));
  const artworkSize = 880;
  final artwork = img.copyResize(foreground,
      width: artworkSize,
      height: artworkSize,
      interpolation: img.Interpolation.cubic);
  img.compositeImage(icon, artwork,
      dstX: (size - artworkSize) ~/ 2, dstY: (size - artworkSize) ~/ 2);
  File('$root/assets/icons/app.png').writeAsBytesSync(img.encodePng(icon));
  stdout.writeln('Wrote 1024px launcher masters to assets/icons/');
}
