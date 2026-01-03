import 'dart:io';

import 'package:flutter/material.dart';

import '../data/attachment_storage.dart';

const _imageExtensions = <String>{
  'jpg',
  'jpeg',
  'png',
  'gif',
  'bmp',
  'webp',
  'heic',
  'heif',
};

const _videoExtensions = <String>{
  'mp4',
  'mov',
  'avi',
  'mkv',
  'webm',
  'm4v',
};

const _pdfExtensions = <String>{
  'pdf',
};

class AttachmentPreview extends StatelessWidget {
  const AttachmentPreview({
    super.key,
    required this.path,
    this.size = 56,
  });

  final String path;
  final double size;

  String _extension(String value) {
    final fileName = value.split(Platform.pathSeparator).last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final extension = _extension(path);
    if (_imageExtensions.contains(extension)) {
      return _PreviewFrame(
        size: size,
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          width: size,
          height: size,
        ),
      );
    }
    if (_videoExtensions.contains(extension)) {
      return _AsyncPreviewFrame(
        size: size,
        future: createVideoThumbnail(path),
        fallbackIcon: Icons.videocam,
      );
    }
    if (_pdfExtensions.contains(extension)) {
      return _AsyncPreviewFrame(
        size: size,
        future: createPdfThumbnail(path),
        fallbackIcon: Icons.description,
      );
    }
    return _PreviewFrame(
      size: size,
      child: const Icon(Icons.insert_drive_file),
    );
  }
}

class _AsyncPreviewFrame extends StatefulWidget {
  const _AsyncPreviewFrame({
    required this.size,
    required this.future,
    required this.fallbackIcon,
  });

  final double size;
  final Future<String?> future;
  final IconData fallbackIcon;

  @override
  State<_AsyncPreviewFrame> createState() => _AsyncPreviewFrameState();
}

class _AsyncPreviewFrameState extends State<_AsyncPreviewFrame> {
  late final Future<String?> _future = widget.future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _future,
      builder: (context, snapshot) {
        final path = snapshot.data;
        if (path == null ||
            snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError) {
          return _PreviewFrame(
            size: widget.size,
            child: Icon(widget.fallbackIcon),
          );
        }
        return _PreviewFrame(
          size: widget.size,
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            width: widget.size,
            height: widget.size,
          ),
        );
      },
    );
  }
}

class _PreviewFrame extends StatelessWidget {
  const _PreviewFrame({
    required this.size,
    required this.child,
  });

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size,
        height: size,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
