import 'dart:async';

import 'package:flutter/services.dart';

class EmojiAvailability {
  static const MethodChannel _channel =
      const MethodChannel('emoji_availability');

  static Future<bool> checkEmojiAvailable(String emoji) async {
    return await _channel.invokeMethod('checkEmojiAvailable', emoji);
  }
}
