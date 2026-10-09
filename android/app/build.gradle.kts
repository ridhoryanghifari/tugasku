```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```
(Jika file Anda `build.gradle` bergaya Groovy: `coreLibraryDesugaringEnabled true` di `compileOptions`
dan `coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'` di `dependencies`.)
Pastikan `minSdk` minimal 21.

**b. `android/app/src/main/AndroidManifest.xml`** — tambahkan di atas `<application>`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```
dan di dalam `<application>` (sebelum `</application>`):
```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

### 5. Konfigurasi iOS (jika dipakai)
- `ios/Podfile`: `platform :ios, '15.5'` (syarat ML Kit)
- `ios/Runner/Info.plist`, tambahkan:
```xml
<key>NSCameraUsageDescription</key>
<string>Kamera digunakan untuk memotret jadwal kuliah.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Galeri digunakan untuk memilih foto jadwal kuliah.</string>