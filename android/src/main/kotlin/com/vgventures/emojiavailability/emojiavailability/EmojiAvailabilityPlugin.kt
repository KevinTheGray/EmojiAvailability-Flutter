package com.vgventures.emojiavailability.emojiavailability

import android.graphics.Paint
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class EmojiAvailabilityPlugin(): MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "emoji_availability")
      channel.setMethodCallHandler(EmojiAvailabilityPlugin())
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "checkEmojiAvailable") {
      val emoji: String? = call.arguments as? String
      if (emoji != null) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
          val paint = Paint()
          result.success(paint.hasGlyph(emoji))
        } else {
          result.success(true)
        }
      } else {
        result.error("600", "Invalid Parameter: Must be a String", "Invalid Parameter: Must be a String")
      }
    } else {
      result.notImplemented()
    }
  }
}
