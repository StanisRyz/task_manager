import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

enum AttachmentOpenResult {
  opened,
  missing,
  failed,
}

Future<String?> storeAttachmentFile(PlatformFile file) async {
  final appDir = await getApplicationDocumentsDirectory();
  final attachmentsDir =
      Directory('${appDir.path}${Platform.pathSeparator}attachments');
  if (!await attachmentsDir.exists()) {
    await attachmentsDir.create(recursive: true);
  }

  final safeName = file.name.isEmpty
      ? 'attachment'
      : file.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  final fileName = '${const Uuid().v4()}_$safeName';
  final targetPath =
      '${attachmentsDir.path}${Platform.pathSeparator}$fileName';

  final sourcePath = file.path;
  if (sourcePath != null && sourcePath.isNotEmpty) {
    final sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(targetPath);
      return targetPath;
    }
  }

  final bytes = file.bytes;
  if (bytes == null) {
    return null;
  }

  final targetFile = File(targetPath);
  await targetFile.writeAsBytes(bytes, flush: true);
  return targetPath;
}

Future<AttachmentOpenResult> openAttachmentFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return AttachmentOpenResult.missing;
  }
  final result = await OpenFilex.open(path);
  return result.type == ResultType.done
      ? AttachmentOpenResult.opened
      : AttachmentOpenResult.failed;
}
