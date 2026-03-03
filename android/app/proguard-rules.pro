# just_audio and ExoPlayer (Media3) rules to prevent release build crashes
-keep class com.ryanheise.just_audio.** { *; }
-keep class androidx.media3.** { *; }
-keep class androidx.media3.exoplayer.** { *; }
-keep class androidx.media3.common.** { *; }

# Keep audio extractors so they aren't stripped
-keep class androidx.media3.extractor.** { *; }