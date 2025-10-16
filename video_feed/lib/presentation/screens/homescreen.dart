import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_feed/presentation/providers/category_providor.dart';
import 'package:video_feed/presentation/providers/feed_providor.dart';
import 'package:video_feed/presentation/screens/addfeedscreen.dart';
import 'package:video_feed/presentation/screens/myfeedscreens.dart';
import 'package:video_feed/presentation/widget/category_list.dart';
import 'package:video_feed/presentation/widget/feedlist.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      context.read<FeedProvider>().fetchHomeFeeds();
    });
  }

  void _navigateToMyFeeds() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyFeedsScreen()),
    );
  }

  void _navigateToAddFeed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFeedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _navigateToAddFeed,
            tooltip: 'Add Feed',
          ),
          GestureDetector(
            onTap: _navigateToMyFeeds,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<FeedProvider>().fetchHomeFeeds(refresh: true);
        },
        child: Column(
          children: [
            const CategoryList(),
            Expanded(
              child: Consumer<FeedProvider>(
                builder: (context, feedProvider, _) {
                  if (feedProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (feedProvider.error != null) {
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
                              feedProvider.fetchHomeFeeds(refresh: true);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (feedProvider.feeds.isEmpty) {
                    return const Center(
                      child: Text('No feeds available'),
                    );
                  }

                  return FeedList(feeds: feedProvider.feeds);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}