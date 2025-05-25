import 'package:flutter/services.dart';

class FacebookAnalyticsService {
  static const MethodChannel _channel = MethodChannel('facebook_analytics');

  /// Log a custom event to Facebook Analytics
  static Future<void> logEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      await _channel.invokeMethod('logEvent', {
        'eventName': eventName,
        'parameters': parameters,
      });
    } catch (e) {
      print('Error logging Facebook event: $e');
    }
  }

  /// Log compass usage event
  static Future<void> logCompassUsage() async {
    try {
      await _channel.invokeMethod('logCompassUsage');
    } catch (e) {
      print('Error logging compass usage: $e');
    }
  }

  /// Log screen view event
  static Future<void> logScreenView(String screenName) async {
    try {
      await _channel.invokeMethod('logScreenView', {
        'screenName': screenName,
      });
    } catch (e) {
      print('Error logging screen view: $e');
    }
  }

  /// Log app install event (call this on first app launch)
  static Future<void> logAppInstall() async {
    try {
      await logEvent('app_install', {
        'platform': 'android',
        'app_version': '2.2.1',
        'install_timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error logging app install: $e');
    }
  }

  /// Log user engagement events
  static Future<void> logUserEngagement(String action, {Map<String, dynamic>? additionalParams}) async {
    try {
      final params = {
        'action': action,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalParams,
      };
      await logEvent('user_engagement', params);
    } catch (e) {
      print('Error logging user engagement: $e');
    }
  }

  /// Log compass direction change
  static Future<void> logCompassDirection(double direction) async {
    try {
      await logEvent('compass_direction_change', {
        'direction': direction.round(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error logging compass direction: $e');
    }
  }

  /// Log app feature usage
  static Future<void> logFeatureUsage(String featureName, {Map<String, dynamic>? additionalParams}) async {
    try {
      final params = {
        'feature_name': featureName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalParams,
      };
      await logEvent('feature_usage', params);
    } catch (e) {
      print('Error logging feature usage: $e');
    }
  }

  /// Log app session duration
  static Future<void> logSessionDuration(int durationInSeconds) async {
    try {
      await logEvent('session_duration', {
        'duration_seconds': durationInSeconds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error logging session duration: $e');
    }
  }
}
