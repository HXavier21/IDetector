import 'package:file_picker/file_picker.dart';

class PickImageUtil {
  static final PickImageUtil _instance = PickImageUtil._internal();
  factory PickImageUtil() {
    return _instance;
  }
  PickImageUtil._internal();

  Future<void> pickImage({
    required Function(PlatformFile file) onFilePicked,
    required Function(String error) onError,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        onFilePicked(file);
      } else {
        onError('No file selected');
      }
    } catch (e) {
      onError('Error while picking file: $e');
    }
  }
}
