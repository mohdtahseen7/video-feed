import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_feed/presentation/providers/feed_providor.dart';
import 'package:video_feed/presentation/widget/feeditem.dart';
import '../../data/models/models.dart';


class FeedList extends StatefulWidget {
  final List<Feed> feeds;

  const FeedList({
    Key? key,
    required this.feeds,
  }) : super(key: key);

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  final ScrollController _scrollController = ScrollController();
  int _currentPlayingIndex = -1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final feedProvider = context.read<FeedProvider>();
      if (!feedProvider.isLoadingMore && feedProvider.hasMoreFeeds) {
        feedProvider.loadMoreHomeFeeds();
      }
    }
  }

  void _onVideoPlay(int index) {
    if (_currentPlayingIndex != index) {
      setState(() {
        _currentPlayingIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.feeds.length + 1,
      itemBuilder: (context, index) {
        if (index == widget.feeds.length) {
          return Consumer<FeedProvider>(
            builder: (context, feedProvider, _) {
              if (feedProvider.isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return const SizedBox.shrink();
            },
          );
        }

        final feed = widget.feeds[index];
        final isPlaying = _currentPlayingIndex == index;

        return FeedItem(
          feed: feed,
          isPlaying: isPlaying,
          onPlay: () => _onVideoPlay(index),
        );
      },
    );
  }
}