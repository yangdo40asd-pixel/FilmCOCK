class WatchProvider {
  final int providerId;
  final String providerName;
  final String logoPath;
  final String link;
  final String offerType;

  const WatchProvider({
    required this.providerId,
    required this.providerName,
    required this.logoPath,
    required this.link,
    required this.offerType,
  });

  factory WatchProvider.fromJson(
    Map<String, dynamic> json, {
    required String offerType,
    required String link,
  }) {
    return WatchProvider(
      providerId: json['provider_id'] as int? ?? 0,
      providerName: json['provider_name'] as String? ?? '',
      logoPath: json['logo_path'] as String? ?? '',
      link: link,
      offerType: offerType,
    );
  }

  String get fullLogoUrl =>
      logoPath.isEmpty ? '' : 'https://image.tmdb.org/t/p/w200$logoPath';
}
