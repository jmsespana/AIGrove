plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.aigrove"
    compileSdk = 36  // I-update gikan 35 ngadto sa 36

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.aigrove"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36  // I-update pud ni
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // Para dili ma-compress ang .tflite files
    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
        resources {
            excludes += listOf("META-INF/LICENSE.md", "META-INF/NOTICE.md")
            // Modern way to prevent compression of .tflite files
            pickFirsts += listOf()
            merges += listOf()
        }
    }
    
    // Use androidResources instead of deprecated aaptOptions
    androidResources {
        noCompress += listOf("tflite")
    }
}

flutter {
    source = "../.."
}
