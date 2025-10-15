class LoginResponse {
  final bool status;
  final String message;
  final String? access;
  final String? refresh;

  LoginResponse({
    required this.status,
    required this.message,
    this.access,
    this.refresh,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      access: json['access'],
      refresh: json['refresh'],
    );
  }
}

class Category {
  final int id;
  final String name;
  final String? image;

  Category({
    required this.id,
    required this.name,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'],
    );
  }
}

class User {
  final int id;
  final String? username;
  final String? profilePicture;
  final String? phone;

  User({
    required this.id,
    this.username,
    this.profilePicture,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? json['phone'],
      profilePicture: json['profile_picture'],
      phone: json['phone'],
    );
  }
}

class Feed {
  final int id;
  final String video;
  final String thumbnail;
  final String description;
  final List<Category> categories;
  final User user;
  final String? createdAt;

  Feed({
    required this.id,
    required this.video,
    required this.thumbnail,
    required this.description,
    required this.categories,
    required this.user,
    this.createdAt,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'],
      video: json['video'] ?? '',
      thumbnail: json['image'] ?? json['thumbnail'] ?? '',
      description: json['desc'] ?? json['description'] ?? '',
      categories: (json['category'] as List<dynamic>?)
              ?.map((c) => Category.fromJson(c))
              .toList() ??
          [],
      user: User.fromJson(json['user'] ?? {}),
      createdAt: json['created_at'],
    );
  }
}

class FeedResponse {
  final bool status;
  final String message;
  final List<Feed> feeds;
  final String? next;
  final String? previous;

  FeedResponse({
    required this.status,
    required this.message,
    required this.feeds,
    this.next,
    this.previous,
  });

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      feeds: (json['results'] as List<dynamic>?)
              ?.map((f) => Feed.fromJson(f))
              .toList() ??
          [],
      next: json['next'],
      previous: json['previous'],
    );
  }
}

class CategoryResponse {
  final bool status;
  final String message;
  final List<Category> categories;

  CategoryResponse({
    required this.status,
    required this.message,
    required this.categories,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      categories: (json['results'] as List<dynamic>?)
              ?.map((c) => Category.fromJson(c))
              .toList() ??
          [],
    );
  }
}