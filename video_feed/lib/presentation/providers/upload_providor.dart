import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/api/api_client.dart';

class UploadProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;

  UploadProvider(this._apiClient);

  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;

  Future<bool> validateVideo(File videoFile) async {
    try {
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      
      final duration = controller.value.duration;
      controller.dispose();
      
      if (duration.inMinutes > 5) {
        _error = 'Video duration must not exceed 5 minutes';
        notifyListeners();
        return false;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to validate video: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadFeed({
    required File video,
    required File thumbnail,
    required String description,
    required List<int> categories,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      // Validate video
      final isValid = await validateVideo(video);
      if (!isValid) {
        _isUploading = false;
        notifyListeners();
        return false;
      }

      final response = await _apiClient.postFormData(
        'my_feed',
        {
          'desc': description,
          'category': categories,
        },
        files: {
          'video': video,
          'image': thumbnail,
        },
        onProgress: (sent, total) {
          _uploadProgress = sent / total;
          notifyListeners();
        },
      );

      if (response['status'] == true) {
        _isUploading = false;
        _uploadProgress = 1.0;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Upload failed';
        _isUploading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Upload failed: ${e.toString()}';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}