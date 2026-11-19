class Env {
  static const String gnewsBaseUrl = String.fromEnvironment(
    'GNEWS_BASE_URL',
    defaultValue: 'https://gnews.io/api/v4',
  );

  static const String gnewsApiKey = String.fromEnvironment('GNEWS_API_KEY');
}
