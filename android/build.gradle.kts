import com.android.build.api.dsl.ApplicationExtension
import com.android.build.api.dsl.LibraryExtension

plugins {
    // Only puts the Android Gradle plugin (version declared in settings.gradle.kts) on this
    // script's classpath, so the `namespace` workaround below can use the public Android DSL.
    id("com.android.application") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

/**
 * Reads the deprecated `package` attribute out of the module's manifest, if there is one.
 */
fun Project.namespaceFromManifest(): String? {
    val manifest = file("src/main/AndroidManifest.xml")
    if (!manifest.exists()) {
        return null
    }
    return Regex("""package\s*=\s*"([^"]+)"""")
        .find(manifest.readText())
        ?.groupValues
        ?.get(1)
}

subprojects {
    // `:app` is already evaluated by the `evaluationDependsOn(":app")` block above, and
    // Gradle 9 rejects `afterEvaluate` for projects that have been evaluated.
    if (state.executed) {
        return@subprojects
    }
    afterEvaluate {
        // AGP 9 makes `namespace` mandatory and no longer falls back to the `package`
        // attribute of AndroidManifest.xml. Plugins that still declare only the package
        // (e.g. isar_flutter_libs 3.1.0+1) fail to configure without this. Delete this
        // block once every plugin declares `namespace` in its own build file.
        val namespace = namespaceFromManifest() ?: return@afterEvaluate
        extensions.findByType(ApplicationExtension::class.java)?.let { extension ->
            if (extension.namespace == null) {
                extension.namespace = namespace
            }
        }
        extensions.findByType(LibraryExtension::class.java)?.let { extension ->
            if (extension.namespace == null) {
                extension.namespace = namespace
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
