# PocketBizz Mobile - Firebase Distribution Script
# Usage: .\scripts\distribute.ps1 -Platform android -ReleaseNotes "Your release notes"

param(
  [Parameter(Mandatory = $false)]
  [ValidateSet("android", "ios", "both")]
  [string]$Platform = "android",
    
  [Parameter(Mandatory = $false)]
  [string]$ReleaseNotes = "Beta release - Auth & Subscription modules",
    
  [Parameter(Mandatory = $false)]
  [string]$Groups = "beta-testers"
)

Write-Host "🚀 PocketBizz Mobile - Firebase Distribution" -ForegroundColor Cyan
Write-Host "Platform: $Platform" -ForegroundColor Yellow
Write-Host "Release Notes: $ReleaseNotes" -ForegroundColor Yellow
Write-Host ""

# Check if Firebase CLI is installed
$firebaseInstalled = Get-Command firebase -ErrorAction SilentlyContinue
if (-not $firebaseInstalled) {
  Write-Host "❌ Firebase CLI not found!" -ForegroundColor Red
  Write-Host "Install with: npm install -g firebase-tools" -ForegroundColor Yellow
  exit 1
}

# Build and distribute Android
if ($Platform -eq "android" -or $Platform -eq "both") {
  Write-Host "📱 Building Android APK..." -ForegroundColor Green
    
  flutter build apk --release `
    --dart-define=BASE_URL=https://mobile.pocketbizz.my `
    --dart-define=ENVIRONMENT=production
    
  if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Android APK built successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📤 Uploading to Firebase App Distribution..." -ForegroundColor Green
        
    # Get Firebase App ID from user if not set
    if (-not $env:FIREBASE_APP_ID_ANDROID) {
      $appId = Read-Host "Enter Firebase Android App ID (format: 1:xxx:android:xxx)"
      $env:FIREBASE_APP_ID_ANDROID = $appId
    }
        
    firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk `
      --app $env:FIREBASE_APP_ID_ANDROID `
      --groups $Groups `
      --release-notes "$ReleaseNotes"
        
    if ($LASTEXITCODE -eq 0) {
      Write-Host "✅ Android APK distributed successfully!" -ForegroundColor Green
    }
    else {
      Write-Host "❌ Failed to distribute Android APK" -ForegroundColor Red
      exit 1
    }
  }
  else {
    Write-Host "❌ Failed to build Android APK" -ForegroundColor Red
    exit 1
  }
}

# Build and distribute iOS
if ($Platform -eq "ios" -or $Platform -eq "both") {
  Write-Host ""
  Write-Host "🍎 Building iOS IPA..." -ForegroundColor Green
  Write-Host "⚠️  iOS build requires macOS" -ForegroundColor Yellow
    
  if ($IsMacOS) {
    flutter build ipa --release `
      --dart-define=BASE_URL=https://mobile.pocketbizz.my `
      --dart-define=ENVIRONMENT=production
        
    if ($LASTEXITCODE -eq 0) {
      Write-Host "✅ iOS IPA built successfully!" -ForegroundColor Green
      Write-Host ""
      Write-Host "📤 Uploading to Firebase App Distribution..." -ForegroundColor Green
            
      # Get Firebase App ID from user if not set
      if (-not $env:FIREBASE_APP_ID_IOS) {
        $appId = Read-Host "Enter Firebase iOS App ID (format: 1:xxx:ios:xxx)"
        $env:FIREBASE_APP_ID_IOS = $appId
      }
            
      firebase appdistribution:distribute build/ios/ipa/*.ipa `
        --app $env:FIREBASE_APP_ID_IOS `
        --groups $Groups `
        --release-notes "$ReleaseNotes"
            
      if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ iOS IPA distributed successfully!" -ForegroundColor Green
      }
      else {
        Write-Host "❌ Failed to distribute iOS IPA" -ForegroundColor Red
        exit 1
      }
    }
    else {
      Write-Host "❌ Failed to build iOS IPA" -ForegroundColor Red
      exit 1
    }
  }
  else {
    Write-Host "⚠️  Skipping iOS build (not on macOS)" -ForegroundColor Yellow
  }
}

Write-Host ""
Write-Host "🎉 Distribution complete!" -ForegroundColor Green
Write-Host "Testers in group '$Groups' will receive email notification." -ForegroundColor Cyan
