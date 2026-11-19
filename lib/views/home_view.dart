import 'package:flutter/material.dart';

import '../models/article_model.dart';
import '../services/news_api_service.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';
import 'detail_view.dart';
import 'search_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final NewsApiService _apiService = NewsApiService();

  final List<String> _categories = [
    'technology',
    'business',
    'sports',
    'science',
    'health',
  ];

  final Map<String, Future<List<ArticleModel>>> _categoryFutures = {};

  String _selectedCategory = 'technology';

  @override
  void initState() {
    super.initState();
    _loadCategory(_selectedCategory);
  }

  void _loadCategory(String category) {
    if (!_categoryFutures.containsKey(category)) {
      _categoryFutures[category] = _apiService.getTopHeadlines(
        category: category,
      );
    }
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _loadCategory(category);
    });
  }

  void _refreshNews() {
    setState(() {
      _categoryFutures[_selectedCategory] = _apiService.getTopHeadlines(
        category: _selectedCategory,
      );
    });
  }

  Future<void> _refreshIndicator() async {
    _refreshNews();
    await _categoryFutures[_selectedCategory];
  }

  void _showSearchDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cari Berita'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Masukkan kata kunci...',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                Navigator.pop(context);
                _openSearchPage(value.trim());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final keyword = controller.text.trim();

                if (keyword.isNotEmpty) {
                  Navigator.pop(context);
                  _openSearchPage(keyword);
                }
              },
              child: const Text('Cari'),
            ),
          ],
        );
      },
    ).then((_) {
      controller.dispose();
    });
  }

  void _openSearchPage(String keyword) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchView(keyword: keyword)),
    );
  }

  String _categoryName(String category) {
    switch (category) {
      case 'technology':
        return 'Teknologi';
      case 'business':
        return 'Bisnis';
      case 'sports':
        return 'Olahraga';
      case 'science':
        return 'Sains';
      case 'health':
        return 'Kesehatan';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'TeknoNews ID',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search, color: Color(0xFF1E293B)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Berita Terkini',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Temukan informasi terbaru setiap hari',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(_categoryName(category)),
                    selected: selected,
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      _selectCategory(category);
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ArticleModel>>(
              future: _categoryFutures[_selectedCategory],
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: _refreshNews,
                  );
                }

                final articles = snapshot.data ?? [];

                if (articles.isEmpty) {
                  return const Center(
                    child: Text('Belum ada berita tersedia.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshIndicator,
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
          ),
        ],
      ),
    );
  }
}
