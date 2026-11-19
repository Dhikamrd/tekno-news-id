import 'package:dio/dio.dart';

import '../config/env.dart';
import '../models/article_model.dart';
import '../models/news_response_model.dart';
import 'api_exception.dart';

class NewsApiService {
  late final Dio _dio;

  NewsApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.gnewsBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }

  Future<List<ArticleModel>> getTopHeadlines({
    String category = 'technology',
  }) async {
    try {
      final response = await _dio.get(
        '/top-headlines',
        queryParameters: {
          'category': category,
          'lang': 'id',
          'country': 'id',
          'max': 10,
          'apikey': Env.gnewsApiKey,
        },
      );

      final result = NewsResponseModel.fromJson(response.data);
      return result.articles;
    } on DioException catch (e) {
      throw _handleError(e);
    } on TypeError {
      throw ApiException('Struktur data dari server berbeda dari model.');
    }
  }

  Future<List<ArticleModel>> searchNews(String keyword) async {
    if (keyword.trim().isEmpty) {
      throw ApiException('Kata kunci pencarian tidak boleh kosong.');
    }

    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': keyword,
          'lang': 'id',
          'country': 'id',
          'max': 10,
          'apikey': Env.gnewsApiKey,
        },
      );

      final result = NewsResponseModel.fromJson(response.data);
      return result.articles;
    } on DioException catch (e) {
      throw _handleError(e);
    } on TypeError {
      throw ApiException('Struktur data dari server berbeda dari model.');
    }
  }

  ApiException _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException(
        'Koneksi lambat. Server tidak merespons tepat waktu.',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    }

    final statusCode = e.response?.statusCode;

    if (statusCode == 400) {
      return ApiException(
        'Permintaan tidak valid. ${e.response?.data?['errors'] ?? ''}',
      );
    }

    if (statusCode == 401) {
      return ApiException('API key salah atau tidak terdaftar.');
    }

    if (statusCode == 403) {
      return ApiException(
        'Kuota harian habis atau email akun belum diverifikasi.',
      );
    }

    if (statusCode == 404) {
      return ApiException('Alamat endpoint tidak ditemukan.');
    }

    if (statusCode == 429) {
      return ApiException(
        'Terlalu cepat. Paket gratis hanya 1 request per detik.',
      );
    }

    return ApiException('Terjadi kesalahan. Silakan coba lagi.');
  }
}
