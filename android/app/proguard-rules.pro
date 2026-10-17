# Each plugin below ships its own consumer-rules.pro that R8 applies
# automatically; these are extra safety keeps for reflection-heavy paths
# that have been known to need them.

# Google Sign-In / Credential Manager
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.libraries.identity.googleid.** { *; }

# ML Kit barcode scanning (mobile_scanner)
-keep class com.google.mlkit.vision.barcode.** { *; }
-keep class com.google.mlkit.vision.common.** { *; }

# Play Core (referenced by the Flutter engine's deferred-components hooks,
# even though this app doesn't use split installs)
-dontwarn com.google.android.play.core.**
