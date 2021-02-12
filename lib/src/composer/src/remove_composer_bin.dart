import 'package:path/path.dart' as p;
import 'dart:io';

Future<void> removeComposerBinPlugin(Directory projectLocation) async {
  projectLocation.list();
  var vendorBinDir = Directory(p.join(projectLocation.path, 'vendor-bin'));
  await vendorBinDir.delete(recursive: true);
  await _removeBrokenSymLinks(projectLocation);
}

Future<void> _removeBrokenSymLinks(Directory projectLocation) async {
  var vendorBinDirectory =
      Directory(p.join(projectLocation.path, 'vendor', 'bin'));
  await for (var entity in vendorBinDirectory.list()) {
    if (entity is Link) {
      try {
        entity.resolveSymbolicLinksSync();
      } on FileSystemException {
        // broken link
        entity.deleteSync();
      }
    }
  }
}
