# PocketBizz Mobile (Flutter)

A Flutter app for PocketBizz with session-cookie auth and BCL.my subscription flow.

## Prerequisites
- Flutter SDK installed and on PATH
- Android Studio/Xcode for mobile targets

## Quick Setup (Windows PowerShell)

```powershell
# From this folder
cd .\pocketbizz_mobile

# 1) Create Flutter project structure
flutter create .

# 2) Add dependencies
flutter pub add dio dio_cookie_manager cookie_jar flutter_riverpod go_router url_launcher path_provider intl

# 3) Copy app scaffold files
# (Files are placed in .\scaffold\lib. Copy them into ./lib)
Copy-Item -Recurse -Force .\scaffold\lib\* .\lib\

# 4) Run the app (set your backend URL)
flutter run --dart-define=BASE_URL=https://mobile.pocketbizz.my
```

If testing against local backend, ensure your device/emulator can reach it. For Android emulator use http://10.0.2.2:5000. Add Android cleartext config if needed (see below).

## Android cleartext (optional for http)
Create `android/app/src/main/res/xml/network_security_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
  <domain-config cleartextTrafficPermitted="true">
    <domain includeSubdomains="true">10.0.2.2</domain>
    <domain includeSubdomains="true">localhost</domain>
  </domain-config>
</network-security-config>
```
Then reference it in `android/app/src/main/AndroidManifest.xml` in the `<application>` tag:
```xml
android:networkSecurityConfig="@xml/network_security_config"
```

## Environment
- BASE_URL via `--dart-define=BASE_URL=...` (defaults to https://mobile.pocketbizz.my)

## Modules
- Auth: login/register/me with session cookie
- Subscription: overview, limits, BCL redirect (1/3/6/12), polling activation

## Next Steps
- Implement additional modules (dashboard, products, stock, sales) following the same patterns.
