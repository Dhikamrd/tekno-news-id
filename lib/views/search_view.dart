import 'package:flutter/material.dart';

import '../models/article_model.dart';
import '../services/news_api_service.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';
import 'detail_view.dart';

class SearchView extends StatefulWidget {
  final String keyword;

  const SearchView({super.key, required this.keyword});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final NewsApiService _apiService = NewsApiService();

  late Future<List<ArticleModel>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _searchFuture = _apiService.searchNews(widget.keyword);
  }

  void _retrySearch() {
    setState(() {
      _searchFuture = _apiService.searchNews(widget.keyword);
    });
  }

  Future<void> _refreshSearch() async {
    _retrySearch();
    await _searchFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text('Hasil: ${widget.keyword}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: FutureBuilder<List<ArticleModel>>(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: _retrySearch,
            );
          }

          final articles = snapshot.data ?? [];

          if (articles.isEmpty) {
            return const Center(child: Text('Berita tidak ditemukan.'));
          }

          return RefreshIndicator(
            onRefresh: _refreshSearch,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return ArticleCard(
                  article: articles[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailView(article: articles[index]),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
