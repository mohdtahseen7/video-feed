import 'package:flutter/material.dart';
import 'package:video_feed/presentation/widget/videopalyer_widget.dart';
import '../../data/models/models.dart';

class FeedItem extends StatelessWidget {
  final Feed feed;
  final bool isPlaying;
  final VoidCallback onPlay;

  const FeedItem({
    Key? key,
    required this.feed,
    required this.isPlaying,
    required this.onPlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  backgroundImage: feed.user.profilePicture != null
                      ? NetworkImage(feed.user.profilePicture!)
                      : null,
                  child: feed.user.profilePicture == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feed.user.username ?? 'User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (feed.createdAt != null)
                        Text(
                          feed.createdAt!,
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
          ),

          // Video Player or Thumbnail
          AspectRatio(
            aspectRatio: 16 / 9,
            child: isPlaying
                ? VideoPlayerWidget(
                    videoUrl: feed.video,
                    onStop: () {},
                  )
                : GestureDetector(
                    onTap: onPlay,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          feed.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error, size: 48),
                            );
                          },
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              feed.description,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Categories
          if (feed.categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: feed.categories.map((category) {
                  return Chip(
                    label: Text(
                      category.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue[50],
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}