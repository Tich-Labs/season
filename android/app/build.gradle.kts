plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.seasonapp.android"
    compileSdk = 35

    defaultConfig {
        val ciVersionCode = (project.findProperty("ciVersionCode") as String?)?.toIntOrNull()
        val ciVersionName = project.findProperty("ciVersionName") as String?
        val webBaseUrl = (project.findProperty("webBaseUrl") as String?)
            ?.trim()
            ?.removeSuffix("/")
            ?: "https://seasonv2.onrender.com"

        applicationId = "com.onrender.seasonv2.rubynative"
        minSdk = 28
        targetSdk = 34
        versionCode = ciVersionCode ?: 1
        versionName = ciVersionName ?: "1.0"
        buildConfigField("String", "WEB_BASE_URL", "\"$webBaseUrl\"")
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        buildConfig = true
    }

    packaging {
        resources {
            excludes += "META-INF/versions/9/OSGI-INF/MANIFEST.MF"
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.activity:activity-ktx:1.9.3")
    implementation("dev.hotwire:core:1.3.2")
    implementation("dev.hotwire:navigation-fragments:1.3.2")
}
