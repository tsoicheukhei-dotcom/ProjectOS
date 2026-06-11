# ProjectOS Architecture

## Overview

ProjectOS is a custom Android shell with iPadOS 15-inspired design, featuring:
- Custom app store with version management
- Phone number-based account system
- Built-in dialer
- Settings with wallpaper customization
- Device auto-detection

## Components

### 1. Shell (ShellActivity)
- Main launcher interface
- App grid display (4-column layout similar to iPadOS)
- Dock at bottom (like iPad dock)
- Wallpaper management
- Home screen customization

### 2. Account System (AccountManager, AccountSetupActivity)
- Phone number registration
- SMS verification
- User ID generation
- Persistent storage

### 3. App Store (AppStore, GooglePlayApi)
- Search functionality
- Version selection and download
- Installation management
- Installed apps tracking via Room database

### 4. Dialer (DialerActivity)
- Numeric dial pad
- Phone number input display
- Direct calling functionality
- Permission management

### 5. Settings (SettingsActivity, SettingsFragment)
- Wallpaper selection
- Display preferences
- Account information
- About information

### 6. Device Detection (DeviceDetectionService)
- Automatic device info detection
- API level compatibility check
- Model and manufacturer detection

## Database Schema

### InstalledApp
- packageName (PRIMARY KEY)
- versionCode
- versionName
- installTime
- lastUpdated

## API Integration

### Google Play Store
- Search apps endpoint
- Version information
- APK download
- App metadata retrieval

## Permissions

### Required
- INTERNET
- CALL_PHONE
- READ_PHONE_STATE
- READ_CONTACTS, WRITE_CONTACTS
- READ/WRITE_EXTERNAL_STORAGE
- INSTALL_PACKAGES
- DELETE_PACKAGES

## Minimum Requirements

- API Level 21 (Android 5.0)
- Target API 33 (Android 13)
- 2GB RAM (minimum)
- 500MB storage (for apps)

## Build & Deploy

```bash
./gradlew build
./gradlew installDebug
./gradlew bundleRelease
```

## Future Enhancements

1. Multi-user support
2. Cloud sync
3. Backup/restore
4. Custom themes
5. Widget support
6. Split-screen multitasking
7. iPad OS 16/17 features
