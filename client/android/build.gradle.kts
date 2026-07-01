allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Pin Android Build Tools for the Flutter plugin modules to an installed,
// healthy revision (36.1.0). Otherwise they use AGP's default (35.0.0),
// which is corrupted in this SDK. The :app module pins it directly in
// app/build.gradle.kts. Hooking the concrete "com.android.library" id (not
// "com.android.base") guarantees the `android` extension already exists.
subprojects {
    pluginManager.withPlugin("com.android.library") {
        val androidExtension = extensions.findByName("android")
        if (androidExtension != null) {
            runCatching {
                androidExtension.javaClass.methods
                    .firstOrNull { it.name == "setBuildToolsVersion" && it.parameterCount == 1 }
                    ?.invoke(androidExtension, "36.1.0")
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
