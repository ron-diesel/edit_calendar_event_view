plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android") version "2.1.0"
}

group = "dev.cwolf.editCalendarEventView.edit_calendar_event_view"
version = "1.0-SNAPSHOT"

android {
    namespace = "dev.cwolf.editCalendarEventView.edit_calendar_event_view"
    compileSdk = 31

    defaultConfig {
        minSdk = 16
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets["main"].java.srcDirs("src/main/kotlin")
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.1.0")
}
