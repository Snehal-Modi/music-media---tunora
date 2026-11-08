# Publishing a New Tunora Release

Releases in Tunora are automated using GitHub Actions. Whenever a version tag is pushed (or the release workflow is manually triggered), GitHub automatically compiles a signed release APK and attaches `Tunora.apk` to a GitHub Release.

---

## Step-by-Step Release Guide

### 1. Update Version Numbers

1. In `pubspec.yaml`, increment the version name and build number:
   ```yaml
   version: 1.4.0+5
   ```
   - `1.4.0` is the user-facing version.
   - `+5` is Android's internal `versionCode`. It must strictly increment for Android to accept updates.
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

1. Opening the **Actions** tab on GitHub will show the **Build and Release Tunora APK** workflow running.
2. The workflow will:
   - Check out code and set up Java 17 + Flutter stable.
   - Securely decode the Android release signing key from repository secrets.
   - Compile the signed release APK (`Tunora.apk`).
   - Create a GitHub Release titled **Tunora v1.4.0** with auto-generated release notes.
   - Upload `Tunora.apk` as the primary release asset.
3. The latest download URL automatically updates to point to this new release:
   `https://github.com/Snehal-Modi/music-media---tunora/releases/latest/download/Tunora.apk`

---

## Alternative: Manual Release via GitHub Actions

You can also trigger a release manually without creating a local tag:

1. Open your repository on GitHub.
2. Navigate to **Actions** > **Build and Release Tunora APK**.
3. Click **Run workflow**.
4. (Optional) Provide a custom tag (e.g., `v1.4.0`). If left blank, the workflow reads the version from `pubspec.yaml`.
5. Click the green **Run workflow** button.

---

## Required GitHub Actions Secrets

For signed production releases, ensure the following repository secrets are configured under **Settings > Secrets and variables > Actions**:

| Secret Name | Description |
|---|---|
| `KEYSTORE_BASE64` | Base64-encoded string of your Android `.jks` release keystore. |
| `KEYSTORE_PASSWORD` | Password for the keystore file. |
| `KEY_ALIAS` | Key alias (e.g. `tunora`). |
| `KEY_PASSWORD` | Password for the specific key alias. |

*Never commit keystore files or passwords directly to the repository.*
