import 'package:flutter/foundation.dart';

/// Configuration supplied by the native host (Android / iOS).
@immutable
class SdkConfig {
  const SdkConfig({
    required this.environment,
    required this.userId,
    this.language = 'en',
    this.enableLogging = false,
  });

  factory SdkConfig.fromMap(Map<String, dynamic> map) {
    return SdkConfig(
      environment: map['environment'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      language: map['language'] as String? ?? 'en',
      enableLogging: map['enableLogging'] as bool? ?? false,
    );
  }

  final String environment;
  final String userId;
  final String language;
  final bool enableLogging;

  @override
  bool operator ==(Object other) =>
      other is SdkConfig &&
      other.environment == environment &&
      other.userId == userId &&
      other.language == language &&
      other.enableLogging == enableLogging;

  @override
  int get hashCode => Object.hash(environment, userId, language, enableLogging);

  @override
  String toString() => 'SdkConfig(environment: $environment, userId: $userId, '
      'language: $language, enableLogging: $enableLogging)';
}
