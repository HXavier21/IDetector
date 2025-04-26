import 'package:ai_image_detector/utils/process_control_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class DropZone extends StatelessWidget {
  const DropZone({
    super.key,
    this.onCreated,
    this.getFile,
    this.onPostResponse,
    this.onError,
  });
  final Function(DropzoneViewController)? onCreated;
  final Future<MultipartFile?> Function(DropzoneFileInterface)? getFile;
  final Function(Response)? onPostResponse;
  final Function(String)? onError;

  @override
  Widget build(BuildContext context) {
    return DropzoneView(
      onCreated: onCreated,
      onDropFile: (file) async {
        final imageFile = await getFile?.call(file);
        await ProcessControlUtil().onFileUpload(
          imageFile: imageFile,
          onPostResponse: onPostResponse,
          onError: onError,
        );
      },
      onDropInvalid: (reason) {
        onError?.call('Invalid file: $reason');
      },
    );
  }
}
