# Fartvagt

En Flutter-app til live fartmåling og vejledende dansk bødeberegning.

## Kom i gang

1. Installer Flutter SDK og kør `flutter doctor`.
2. Kør `flutter create .` i projektroden for at generere platformmapperne.
3. Kør `flutter pub get` i projektroden.
4. Kør `flutter run` på en fysisk telefon eller emulator med lokation aktiveret.

Appen bruger `geolocator` til GPS og omregner positionens hastighed fra m/s til km/t. Den finder automatisk vejens registrerede `maxspeed` via OpenStreetMap/Overpass, når GPS-positionen ændrer sig. Hvis vejen ikke har en registreret fartgrænse, tvinges 50 km/t som fallback. Brugeren kan vælge køretøjsprofil (bil, bil med trailer eller lastbil), hvor fartgrænse og bødeberegning justeres efter profil, og valget gemmes lokalt. Lydadvarsler kan slås til/fra i appens indstillinger. Bøderne er vejledende og må ikke bruges som juridisk rådgivning.

Vejopslag kræver internetforbindelse. OpenStreetMap-data kan mangle eller være forældede, så den viste grænse bør altid kontrolleres mod skiltningen på vejen.

## GitHub Pages

Projektet deployes automatisk som Flutter Web via GitHub Actions ved push til `main`.

Aktivér først Pages i repositoryets **Settings → Pages** og vælg **GitHub Actions** som source. Den offentlige adresse bliver normalt:

`https://cbjoed.github.io/SpeedTrap/`

GPS i browseren kræver HTTPS og brugerens tilladelse.

## Supabase-authentication

Opret et projekt på [supabase.com](https://supabase.com), og slå Email-provider til under Authentication → Providers. Webbygget læser legitimationsoplysninger som Dart-defines. GitHub Actions forventer dem som repository variables med navnene `SUPABASE_URL` og `SUPABASE_ANON_KEY`:

```powershell
flutter build web --release `
	--dart-define=SUPABASE_URL=https://<project-ref>.supabase.co `
	--dart-define=SUPABASE_ANON_KEY=<publishable-anon-key>
```

Brug kun Supabase-projektets publicerbare anon/publishable key i webbygget. Den hemmelige service role key må aldrig sendes til browseren. GitHub Pages-workflowet bruger repository variables til build arguments; værdierne kan ikke lægges sikkert i en offentlig fil.

## Leaderboard og profiler

Kør [supabase/schema.sql](supabase/schema.sql) én gang i Supabase Dashboard under **SQL Editor**. Scriptet opretter `profiles`, `drive_logs`, signup-triggeren og den offentlige `leaderboard`-view med RLS-politikker. Brugeren skal være logget ind for at gemme ture og ændre visningsnavn. Tryk **START TUR** før kørsel og **SLUT TUR OG GEM** bagefter for at gemme turens makshastighed, distance og estimerede undgåede bøder.

## Platformstilladelser

Android skal have `ACCESS_FINE_LOCATION` og `ACCESS_COARSE_LOCATION` i `android/app/src/main/AndroidManifest.xml`. iOS skal have `NSLocationWhenInUseUsageDescription` i `ios/Runner/Info.plist`.
