# -----------------------------------------------------------------------------
# ProGuard / R8 Rules for Sheekh Xuseen Cali Jabuuti App
# -----------------------------------------------------------------------------

# General optimization attributes
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod,SourceFile,LineNumberTable

# -----------------------------------------------------------------------------
# Flutter Engine & Embeddings
# -----------------------------------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# MainActivity & App Classes
-keep class com.sheekhxuseen.app.sheekh_xuseen_cali_jabuuti.** { *; }
-keep class com.sheekhxuseencalijabuuti.** { *; }

# -----------------------------------------------------------------------------
# Kotlin Coroutines & package:jni runtime classes
# Used by shared_preferences_android and path_provider_android via Dart FFI / JNI
# -----------------------------------------------------------------------------
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }
-keep class kotlin.coroutines.jvm.internal.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlin.coroutines.**
-dontwarn kotlinx.coroutines.**

-keep class com.github.dart_lang.jni.** { *; }
-dontwarn com.github.dart_lang.jni.**

# -----------------------------------------------------------------------------
# AudioService & JustAudio (Ryan Heise)
# -----------------------------------------------------------------------------
-keep class com.ryanheise.audioservice.AudioServiceActivity { *; }
-keep class com.ryanheise.audioservice.AudioServiceFragmentActivity { *; }
-keep class com.ryanheise.audioservice.AudioService { *; }
-keep class com.ryanheise.audioservice.MediaButtonReceiver { *; }
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audio_session.** { *; }
-dontwarn com.ryanheise.**

# AndroidX Media & Media3 / ExoPlayer
-keep class androidx.media.** { *; }
-keep class android.support.v4.media.** { *; }
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**
-dontwarn androidx.media.**
-dontwarn android.support.v4.media.**

# -----------------------------------------------------------------------------
# Audioplayers
# -----------------------------------------------------------------------------
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# -----------------------------------------------------------------------------
# Google Mobile Ads (AdMob)
# -----------------------------------------------------------------------------
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**
-keep class com.google.ads.** { *; }
-dontwarn com.google.ads.**
-keep class com.google.ads.mediation.admob.AdMobAdapter { *; }
-keep class com.google.ads.mediation.AdUrlAdapter { *; }

# -----------------------------------------------------------------------------
# SQLite, Webview, URL Launcher, Share Plus & Permissions
# -----------------------------------------------------------------------------
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**
-keep class io.flutter.plugins.urllauncher.** { *; }
-keep class io.flutter.plugins.webviewflutter.** { *; }
-keep class dev.fluttercommunity.plus.share.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }
