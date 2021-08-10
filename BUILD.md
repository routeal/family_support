o Add this to IDE in the Additional run args of the Edit Configurations

--no-sound-null-safety

o Command line build

- % flutter pub get

- % flutter run

o Flutter Native Splash

Place

flutter_native_splash.yaml

Run this:

% flutter pub run flutter_native_splash:create --path=./flutter_native_splash.yaml

O Cloud Firestore

Add this to android/app/build.gradle

    defaultConfig {
        ...
        multiDexEnabled true
    }

o Image picker

Add the permissons

    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"/>

o Image cropper

Add this:
