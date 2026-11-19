class ArticleModel {
  final String title;
  final String description;
  final String content;
  final String url;
  final String image;
  final String publishedAt;
  final String source;

  ArticleModel({
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.image,
    required this.publishedAt,
    required this.source,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      url: json['url'] ?? '',
      image: json['image'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      source: json['source']?['name'] ?? '',
    );
  }
}
