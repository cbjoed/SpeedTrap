# Fartvagt

En Flutter-app til live fartmåling og vejledende dansk bødeberegning.

## Kom i gang

1. Installer Flutter SDK og kør `flutter doctor`.
2. Kør `flutter create .` i projektroden for at generere platformmapperne.
3. Kør `flutter pub get` i projektroden.
4. Kør `flutter run` på en fysisk telefon eller emulator med lokation aktiveret.

Appen bruger `geolocator` til GPS og omregner positionens hastighed fra m/s til km/t. Bøderne er vejledende og må ikke bruges som juridisk rådgivning.

## Platformstilladelser

Android skal have `ACCESS_FINE_LOCATION` og `ACCESS_COARSE_LOCATION` i `android/app/src/main/AndroidManifest.xml`. iOS skal have `NSLocationWhenInUseUsageDescription` i `ios/Runner/Info.plist`.
