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

subprojects {
    pluginManager.withPlugin("com.android.library") {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.apply {
            compileSdkVersion(36)
        }
    }
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.datastore") {
                useVersion("1.2.1")
                because("Ensure 16 KB memory page size compatibility for libdatastore_shared_counter.so")
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
