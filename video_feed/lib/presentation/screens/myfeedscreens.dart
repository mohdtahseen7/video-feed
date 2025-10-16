import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_feed/presentation/providers/feed_providor.dart';


class MyFeedsScreen extends StatefulWidget {
  const MyFeedsScreen({Key? key}) : super(key: key);

  @override
  State<MyFeedsScreen> createState() => _MyFeedsScreenState();
}

class _MyFeedsScreenState extends State<MyFeedsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().fetchMyFeeds();
    });

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
      if (!feedProvider.isLoadingMyFeeds && feedProvider.hasMoreMyFeeds) {
        feedProvider.loadMoreMyFeeds();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Feeds'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<FeedProvider>().fetchMyFeeds(refresh: true);
        },
        child: Consumer<FeedProvider>(
          builder: (context, feedProvider, _) {
            if (feedProvider.isLoadingMyFeeds && feedProvider.myFeeds.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (feedProvider.error != null && feedProvider.myFeeds.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(feedProvider.error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        feedProvider.fetchMyFeeds(refresh: true);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (feedProvider.myFeeds.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No feeds yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Upload your first video!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: feedProvider.myFeeds.length +
                  (feedProvider.hasMoreMyFeeds ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == feedProvider.myFeeds.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final feed = feedProvider.myFeeds[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          feed.thumbnail,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feed.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${feed.categories.length} categories',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}