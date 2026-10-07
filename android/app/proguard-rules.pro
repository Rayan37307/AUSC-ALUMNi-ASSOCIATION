# ProGuard/R8 rules for the AUSC Alumni app.
#
# Flutter's engine reaches Dart code through JNI and reflection, so the
# embedding classes must survive shrinking. Flutter ships its own consumer
# rules with the engine AAR, so most of this is already handled; these are the
# project-specific additions.

# Keep the Flutter embedding entry points.
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# GeneratedPluginRegistrant is created at build time and referenced by name.
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Dart entry point used by the engine on startup.
-keep class com.ausc.alumni.** { *; }

# Keep annotations so Supabase / Dart metadata survive shrinking.
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod

# Supabase + PostgREST + GoTrue rely on reflection for JSON mapping and auth
# state, so silence their noisy warnings rather than disabling R8.
-dontwarn io.supabase.**
-dontwarn com.supabase.**
-dontwarn org.apache.http.**
-dontwarn org.jetbrains.annotations.**

# okio/okhttp optional platform classes that never exist on Android.
-dontwarn okhttp3.internal.platform.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Flutter's embedding references Play Core for deferred components (dynamic
# feature delivery), which this app does not use. The classes are never reached
# at runtime, so silence the missing-class warnings.
-dontwarn com.google.android.play.core.**
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }