import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../data/models/models.dart';

class CategoryProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoryProvider(this._apiClient);

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    if (_categories.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('category_list', includeAuth: false);
      final categoryResponse = CategoryResponse.fromJson(response);

      if (categoryResponse.status) {
        _categories = categoryResponse.categories;
      } else {
        _error = categoryResponse.message;
      }
    } catch (e) {
      _error = 'Failed to load categories: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}