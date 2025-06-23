# Capacitor

## Android

Create jks

```bash
keytool -genkeypair -v \
  -keystore mmascorecard.keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias mmascorecard
```

Create a `capacitor/android/key.properties` file with configs of the jks

```conf
storePassword=
keyPassword=
keyAlias=
storeFile=
```

In the `capacitor/android/app/build.gradle` read previous created file and sing the app

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
...
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            ...
            signingConfig = signingConfigs.release
        }
    }
}
```
