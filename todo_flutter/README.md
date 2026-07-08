# Todo App - Flutter Frontend

Node.js backend eka (`todo-backend`) ekka use karana simple Flutter app eka.

## Setup

1. Flutter project ekak already thiyenawa nam, `pubspec.yaml` eke dependencies tika copy karala, `lib/` folder eke files okkoma danna.
   Nathi nam:
   ```bash
   flutter create todo_flutter
   ```
   Ithin meke `lib/` folder eka replace karala, `pubspec.yaml` eke dependencies (`http`, `shared_preferences`) add karanna.

2. Dependencies install karanna:
   ```bash
   flutter pub get
   ```

3. Backend eka run karala thiyenawada balanna (`node server.js` - port 5000).

4. **Base URL eka check karanna** - `lib/services/api_service.dart` eke:
   - **Android emulator** eken run karanawa nam: `http://10.0.2.2:5000/api` (default widihata dala thiyenne meka)
   - **iOS simulator** eken nam: `http://localhost:5000/api`
   - **Real device** eken nam (phone eka + computer eka same WiFi eke thiyenna one): `http://<computer-eke-IP>:5000/api` (e.g. `192.168.1.5`)

5. Run karanna:
   ```bash
   flutter run
   ```

## Folder structure

```
lib/
  main.dart              - app entry, auto-login check (AuthGate)
  models/
    task.dart             - Task data model
  services/
    api_service.dart      - okkoma backend API calls + token storage
  screens/
    login_screen.dart
    register_screen.dart
    home_screen.dart      - task list, add/toggle/delete
```

## Flow eka

1. App eka open karana gaman `AuthGate` eka `shared_preferences` eke token ekak save wela thiyenawada balanawa
2. Token eka thiyenawa nam → direct HomeScreen ekata (auto-login)
3. Naha nam → LoginScreen eka penenawa
4. Login/Register success una nam → token eka save karala HomeScreen ekata navigate wenawa
5. HomeScreen eke tasks load wenawa (GET request + Authorization header eka), add/toggle/delete okkoma backend ekata call karanawa

## Notes

- Real device walin test karanna kalin, computer eke firewall eka port 5000 allow karanawada check karanna
- Backend eka restart una gaman `data.json` file eka delete kara nathi nam data okkoma persist wenawa
