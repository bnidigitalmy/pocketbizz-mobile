# Bootstrap PocketBizz Flutter app
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host '==> Checking Flutter installation'
flutter --version | Out-Null

Write-Host '==> Creating Flutter project files'
flutter create .

Write-Host '==> Adding dependencies'
flutter pub add dio dio_cookie_manager cookie_jar flutter_riverpod go_router url_launcher path_provider intl

Write-Host '==> Copying app scaffold'
$scaffold = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'scaffold'
Copy-Item -Recurse -Force "$scaffold/lib/*" "$PSScriptRoot/../lib/"

Write-Host '==> Done. Run the app with:'
Write-Host '    flutter run --dart-define=BASE_URL=https://app.pocketbizz.my'