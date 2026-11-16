import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Builds de release precisam da chave de upload. Sem ela, falha já na configuração
// com uma mensagem clara, em vez do erro genérico de assinatura no fim do build.
// Builds de debug (flutter run, flutter build apk --debug) não precisam da chave.
val requiredSigningKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val releaseSigningProblem: String? = when {
    !keystorePropertiesFile.exists() ->
        "o arquivo android/key.properties não existe"
    requiredSigningKeys.any { keystoreProperties.getProperty(it).isNullOrBlank() } ->
        "faltam campos no android/key.properties: " +
            requiredSigningKeys.filter { keystoreProperties.getProperty(it).isNullOrBlank() }
                .joinToString()
    !file(keystoreProperties.getProperty("storeFile")).exists() ->
        "o keystore ${file(keystoreProperties.getProperty("storeFile"))} não foi encontrado"
    else -> null
}
val isReleaseBuild = gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }
if (releaseSigningProblem != null && isReleaseBuild) {
    throw GradleException(
        """
        |Não dá para assinar o build de release: $releaseSigningProblem.
        |
        |Crie android/key.properties com a chave de upload do app:
        |  storeFile=/caminho/para/upload-keystore.jks
        |  storePassword=...
        |  keyAlias=...
        |  keyPassword=...
        |
        |Para rodar o app sem a chave, use um build de debug: flutter run ou flutter build apk --debug.
        """.trimMargin(),
    )
}

android {
    namespace = "br.com.rodrigosdk.realcalc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    
    signingConfigs {
        create("release") {
            if (releaseSigningProblem == null) {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "br.com.rodrigosdk.realcalc"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Associa a assinatura configurada no formato Kotlin DSL
            signingConfig = signingConfigs.getByName("release")
            
            // Ativa o R8/ProGuard usando atribuição direta
            isMinifyEnabled = true
            isShrinkResources = true        
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
