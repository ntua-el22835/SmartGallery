plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

// Φόρτωση key.properties για release signing (Play Store)
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.ntua2026.smartgallery"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // Ρύθμιση release signing για Play Store (μόνο όταν υπάρχει key.properties)
    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"]!!.toString()
                keyPassword = keystoreProperties["keyPassword"]!!.toString()
                storeFile = rootProject.file(keystoreProperties["storeFile"]!!.toString())
                storePassword = keystoreProperties["storePassword"]!!.toString()
            }
        }
    }

    defaultConfig {
        applicationId = "com.ntua2026.smartgallery"
        // minSdk 21: απαιτείται για camera, image_picker, sqflite
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Χρήση release signing όταν υπάρχει key.properties, αλλιώς debug
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
