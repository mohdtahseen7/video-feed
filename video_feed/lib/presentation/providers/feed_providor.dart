import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../data/models/models.dart';

class FeedProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  
  List<Feed> _feeds = [];
  List<Feed> _myFeeds = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingMyFeeds = false;
  String? _error;
  String? _nextPage;
  String? _myFeedsNextPage;

  FeedProvider(this._apiClient);

  List<Feed> get feeds => _feeds;
  List<Feed> get myFeeds => _myFeeds;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingMyFeeds => _isLoadingMyFeeds;
  String? get error => _error;
  bool get hasMoreFeeds => _nextPage != null;
  bool get hasMoreMyFeeds => _myFeedsNextPage != null;

  Future<void> fetchHomeFeeds({bool refresh = false}) async {
    if (refresh) {
      _feeds = [];
      _nextPage = null;
    }

    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('home');
      final feedResponse = FeedResponse.fromJson(response);

      if (feedResponse.status) {
        _feeds = feedResponse.feeds;
        _nextPage = feedResponse.next;
      } else {
        _error = feedResponse.message;
      }
    } catch (e) {
      _error = 'Failed to load feeds: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreHomeFeeds() async {
    if (_nextPage == null || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final uri = Uri.parse(_nextPage!);
      final response = await _apiClient.get(uri.path.replaceFirst('/api/', '') + '?' + (uri.query));
      final feedResponse = FeedResponse.fromJson(response);

      if (feedResponse.status) {
        _feeds.addAll(feedResponse.feeds);
        _nextPage = feedResponse.next;
      }
    } catch (e) {
      _error = 'Failed to load more feeds: ${e.toString()}';
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> fetchMyFeeds({bool refresh = false}) async {
    if (refresh) {
      _myFeeds = [];
      _myFeedsNextPage = null;
    }

    if (_isLoadingMyFeeds) return;

    _isLoadingMyFeeds = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('my_feed');
      final feedResponse = FeedResponse.fromJson(response);

      if (feedResponse.status) {
        _myFeeds = feedResponse.feeds;
        _myFeedsNextPage = feedResponse.next;
      } else {
        _error = feedResponse.message;
      }
    } catch (e) {
      _error = 'Failed to load my feeds: ${e.toString()}';
    }

    _isLoadingMyFeeds = false;
    notifyListeners();
  }

  Future<void> loadMoreMyFeeds() async {
    if (_myFeedsNextPage == null || _isLoadingMyFeeds) return;

    _isLoadingMyFeeds = true;
    notifyListeners();

    try {
      final uri = Uri.parse(_myFeedsNextPage!);
      final response = await _apiClient.get(uri.path.replaceFirst('/api/', '') + '?' + (uri.query));
      final feedResponse = FeedResponse.fromJson(response);

      if (feedResponse.status) {
        _myFeeds.addAll(feedResponse.feeds);
        _myFeedsNextPage = feedResponse.next;
      }
    } catch (e) {
      _error = 'Failed to load more feeds: ${e.toString()}';
    }

    _isLoadingMyFeeds = false;
    notifyListeners();
  }

  void addNewFeed(Feed feed) {
    _myFeeds.insert(0, feed);
    notifyListeners();
  }
}