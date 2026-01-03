import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

enum AttachmentOpenResult {
  opened,
  missing,
  failed,
}

Future<Directory> _attachmentsDirectory() async {
  final appDir = await getApplicationDocumentsDirectory();
  final attachmentsDir =
      Directory('${appDir.path}${Platform.pathSeparator}attachments');
  if (!await attachmentsDir.exists()) {
    await attachmentsDir.create(recursive: true);
  }
  return attachmentsDir;
}

Future<String?> storeAttachmentFile(PlatformFile file) async {
  final attachmentsDir = await _attachmentsDirectory();

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

String _fileBaseName(String path) {
  final fileName = path.split(Platform.pathSeparator).last;
  final dotIndex = fileName.lastIndexOf('.');
  if (dotIndex == -1) {
    return fileName;
  }
  return fileName.substring(0, dotIndex);
}

Future<String?> createVideoThumbnail(String path) async {
  final sourceFile = File(path);
  if (!await sourceFile.exists()) {
    return null;
  }
  final attachmentsDir = await _attachmentsDirectory();
  final previewsDir =
      Directory('${attachmentsDir.path}${Platform.pathSeparator}previews');
  if (!await previewsDir.exists()) {
    await previewsDir.create(recursive: true);
  }
  final baseName = _fileBaseName(path);
  final previewPath =
      '${previewsDir.path}${Platform.pathSeparator}${baseName}_video.jpg';
  final previewFile = File(previewPath);
  if (await previewFile.exists()) {
    return previewPath;
  }
  final generated = await VideoThumbnail.thumbnailFile(
    video: path,
    thumbnailPath: previewsDir.path,
    imageFormat: ImageFormat.JPEG,
    maxHeight: 256,
    quality: 75,
  );
  if (generated == null) {
    return null;
  }
  final generatedFile = File(generated);
  if (!await generatedFile.exists()) {
    return null;
  }
  await generatedFile.copy(previewPath);
  return previewPath;
}

Future<String?> createPdfThumbnail(String path, {int maxSize = 256}) async {
  final sourceFile = File(path);
  if (!await sourceFile.exists()) {
    return null;
  }
  final attachmentsDir = await _attachmentsDirectory();
  final previewsDir =
      Directory('${attachmentsDir.path}${Platform.pathSeparator}previews');
  if (!await previewsDir.exists()) {
    await previewsDir.create(recursive: true);
  }
  final baseName = _fileBaseName(path);
  final previewPath =
      '${previewsDir.path}${Platform.pathSeparator}${baseName}_page1.png';
  final previewFile = File(previewPath);
  if (await previewFile.exists()) {
    return previewPath;
  }
  final document = await PdfDocument.openFile(path);
  PdfPage? page;
  try {
    page = await document.getPage(1);
    final longestSide = math.max(page.width, page.height);
    final scale = longestSide == 0 ? 1.0 : maxSize / longestSide;
    final targetWidth = (page.width * scale).toDouble();
    final targetHeight = (page.height * scale).toDouble();
    final pageImage = await page.render(
      width: targetWidth,
      height: targetHeight,
      format: PdfPageImageFormat.png,
    );
    if (pageImage == null) {
      return null;
    }
    await previewFile.writeAsBytes(pageImage.bytes, flush: true);
    return previewPath;
  } finally {
    if (page != null) {
      await page.close();
    }
    await document.close();
  }
}
