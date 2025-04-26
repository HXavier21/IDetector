import 'package:ai_image_detector/data/history_item.dart';
import 'package:ai_image_detector/utils/network_util.dart';
import 'package:dio/dio.dart';

class ProcessControlUtil {
  static final ProcessControlUtil _instance = ProcessControlUtil._internal();
  factory ProcessControlUtil() {
    return _instance;
  }
  ProcessControlUtil._internal();

  bool _isProcessing = false;

  Future<void> onFileUpload({
    required MultipartFile? imageFile,
    Function(Response)? onPostResponse,
    Function(String)? onError,
  }) async {
    if (_isProcessing) {
      onError?.call('Processing is already in progress');
      return;
    }
    _isProcessing = true;
    if (imageFile == null) {
      onError?.call('Image file is null');
      _isProcessing = false;
      return;
    }
    final response = await NetworkUtil().post(
      '/detect',
      data: FormData.fromMap(
        {
          'image': imageFile,
        },
      ),
    );
    if (response.statusCode == 200) {
      onPostResponse?.call(response);
    } else {
      onError?.call(response.statusMessage ?? 'Unknown error');
    }
    _isProcessing = false;
  }

  Future<List<HistoryItem>> getHistory({
    Function(String)? onError,
  }) async {
    final response = await NetworkUtil().get('/history');
    if (response.statusCode == 200) {
      return (response.data['history'] as List)
          .map((item) => HistoryItem.fromJson(item))
          .toList();
    } else {
      onError?.call(response.statusMessage ?? 'Unknown error');
      return [];
    }
  }
}
