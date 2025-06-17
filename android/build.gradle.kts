buildscript {
    dependencies {
        // Jika kamu butuh Kotlin plugin di buildscript (biasanya tidak dibutuhkan di Flutter)
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
    }

    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: Simpan versi Kotlin sebagai extra property (kalau memang dipakai di tempat lain)
extra["kotlin_version"] = "2.1.0"

// Set custom root build directory
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

// Set custom subproject build directories
subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(name)
    layout.buildDirectory.set(newSubprojectBuildDir)
}

// Ensure `:app` project is evaluated first
subprojects {
    evaluationDependsOn(":app")
}

// Define clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
 