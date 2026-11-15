# Publishing a New Tunora Release

Releases in Tunora are automated using GitHub Actions. Whenever a version tag is pushed (or the release workflow is manually triggered), GitHub automatically compiles `Tunora.apk` and publishes it to GitHub Releases.

---

## Standalone Android Application & Testing Build

- **Zero Infrastructure:** Tunora operates 100% on-device. No backend server, cloud database, user authentication, or paid services are required.
- **No GitHub Secrets Needed:** This testing build requires zero GitHub Actions repository secrets.
- **Debug-Signed for Direct Testing:** The APK is signed with Android's standard debug certificate. This is intended for direct sideloading and Android device testing, not for Google Play Store production distribution.
- **Updating:** Because subsequent builds will be signed with the same standard debug certificate, future updates can generally be installed directly over existing versions. If Android reports an "App not installed as package appears to be invalid" error during an update, uninstall the previous version first and reinstall.

---

## Step-by-Step Release Guide

### 1. Update Version Numbers

1. In `pubspec.yaml`, increment the version name and build number:
   ```yaml
   version: 1.4.0+5
   ```
   - `1.4.0` is the user-facing version.
   - `+5` is Android's internal `versionCode`.
2. In `lib/core/app_info.dart`, update `kAppVersion`:
   ```dart
   const String kAppVersion = '1.4.0';
   ```
3. In `CHANGELOG.md`, add notes for the new version.

### 2. Commit and Push to Main

```bash
git add pubspec.yaml lib/core/app_info.dart CHANGELOG.md
git commit -m "Bump version to 1.4.0"
git push origin main
```

### 3. Create and Push a Version Tag

Tag the commit with a `v` prefix matching your version:

```bash
git tag v1.4.0
git push origin v1.4.0
```

### 4. Automated Build & Release

1. Navigate to the **Actions** tab on GitHub to see the **Build and Release Tunora APK** workflow running.
2. The workflow will:
   - Check out code and set up Java 17 + Flutter 3.50.0.
   - Run dependency installation, code analysis, and unit tests.
   - Compile the Android release APK (`Tunora.apk`).
   - Verify the APK file integrity and cryptographic signature.
   - Create a GitHub Release titled **Tunora v1.4.0** with auto-generated release notes.
   - Upload `Tunora.apk` as the primary release asset.
3. The latest download URL automatically points to the new release:
   `https://github.com/Snehal-Modi/music-media---tunora/releases/latest/download/Tunora.apk`

---

## Alternative: Manual Release via GitHub Actions

You can also trigger a release manually without creating a local tag first:

1. Open your repository on GitHub.
2. Navigate to **Actions** > **Build and Release Tunora APK**.
3. Click **Run workflow**.
4. Provide the target tag (e.g., `v1.3.0`).
5. Click **Run workflow**.
6. The workflow will automatically create the Git tag and publish the GitHub release with `Tunora.apk`.
