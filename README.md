<div align="center">

<img src="docs/icon.png" width="120" alt="Tunora Logo">

# Tunora

**A glassy, standalone music player for Android.**
Seamlessly play songs on your device alongside JioSaavn, YouTube, Audius, live radio, podcasts, and spoken stories — all in one modern app.

[![CI](https://github.com/Snehal-Modi/music-media---tunora/actions/workflows/ci.yml/badge.svg)](https://github.com/Snehal-Modi/music-media---tunora/actions/workflows/ci.yml)
[![Latest release](https://img.shields.io/github/v/release/Snehal-Modi/music-media---tunora?label=latest&color=1DB954)](https://github.com/Snehal-Modi/music-media---tunora/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/Snehal-Modi/music-media---tunora/total?color=00C2FF)](https://github.com/Snehal-Modi/music-media---tunora/releases)
[![Android](https://img.shields.io/badge/Android-8.0%2B-green?logo=android&logoColor=white)](https://android.com)

<br/>

[![Download Tunora APK](https://img.shields.io/badge/Download-Tunora.apk-7C5CFF?style=for-the-badge&logo=android&logoColor=white)](https://github.com/Snehal-Modi/music-media---tunora/releases/latest/download/Tunora.apk)

<p>
  Direct Download:
  <a href="https://github.com/Snehal-Modi/music-media---tunora/releases/latest/download/Tunora.apk">
    <b>Tunora.apk (Latest Release)</b>
  </a>
</p>

</div>

---

## Table of Contents

- [Download & Installation](#download--installation)
- [Application Overview](#application-overview)
- [Key Features](#key-features)
- [Supported Android Versions](#supported-android-versions)
- [Permissions Explained](#permissions-explained)
- [Technology Stack](#technology-stack)
- [Release History](#release-history)
- [Changelog](#changelog)
- [Credits & Disclaimers](#credits--disclaimers)

---

## Download & Installation

1. **Download:** Tap the **[Download Tunora.apk](https://github.com/Snehal-Modi/music-media---tunora/releases/latest/download/Tunora.apk)** button above on your Android phone (or browse all builds on the [Releases page](https://github.com/Snehal-Modi/music-media---tunora/releases)).
2. **Install:** Open the downloaded APK. If prompted by Android, permit **Install unknown apps** for your browser or file manager.
3. **Launch & Permissions:**
   - **Music & Audio permission:** Required to find and display audio tracks stored on your device.
   - **Notification permission:** Required on Android 13+ to display media controls on the notification shade and lock screen.

> **Note:** Updates can be installed directly over existing versions without losing your playlists, favorites, or downloaded songs.

---

## Application Overview

Tunora is a client-side Flutter application for Android. It operates independently without requiring any backend server, cloud database, user account, or subscription. You have full privacy: your listening history and taste profile stay strictly on your device.

The app features an adaptive frosted-glass interface with dynamic mood lighting derived from the currently playing album artwork.

---

## Key Features

### 1. Smart Music Discovery & Taste Learning
- **Taste Profile:** Pick your preferred languages and favorite artists on first start.
- **Mixes & Autoplay:** Dynamic "Made for you" mixes and automated queue replenishment based on listening habits and favorites.
- **Language Charts:** Trending tracks and Top 50 charts for Hindi, English, Punjabi, Gujarati, Marathi, Tamil, Telugu, Kannada, Malayalam, Bengali, Bhojpuri, and more.

### 2. Multi-Source Streaming with Automatic Failover
- **On-Device Library:** Fast scanning of local files via Android's native `MediaStore`.
- **JioSaavn:** High-quality audio streaming (Data Saver 96 kbps, Balanced 160 kbps, High 320 kbps), artist stations, and album discovery.
- **YouTube:** Music streaming with backup routing racing against public Invidious and Piped mirrors.
- **Audius:** Community-powered streaming through the decentralized Audius network.
- **Live Internet Radio:** Thousands of global and Indian stations via the `radio-browser.info` community API.
- **Podcasts & Stories:** Search and subscribe to shows from the Apple Podcasts directory with direct RSS audio streaming.

### 3. The Playback Engine
- **Audio Effects:** Integrated 5-band hardware equalizer, loudness enhancer, and custom presets.
- **Karaoke Synced Lyrics:** Real-time synchronized LRC lyrics alongside plain text lyrics powered by LRCLIB.
- **Playback Controls:** Sleep timer (with "Stop at end of track"), variable playback speeds (0.8x to 2.0x), queue reordering, and 10-second forward/rewind skips.
- **Android Auto & Background Audio:** Full vehicle dashboard browsing (`MediaBrowserService`) and uninterrupted background audio with hardware media key support.
- **Offline Downloads:** Download online tracks directly to application storage for offline listening when disconnected.

---

## Supported Android Versions

| Spec | Requirement | Notes |
|---|---|---|
| **Minimum Android Version** | **Android 8.0 (Oreo)** | API Level 26 |
| **Target Android Version** | **Android 14 / 15** | API Level 34 / 35 |
| **Supported Architectures** | Universal (`arm64-v8a`, `armeabi-v7a`, `x86_64`) | Single optimized package |

---

## Permissions Explained

Tunora requests only permissions necessary for audio playback and storage:

| Permission | Purpose |
|---|---|
| `READ_MEDIA_AUDIO` | Reads local music files on Android 13+ (API 33+). |
| `READ_EXTERNAL_STORAGE` | Reads local audio files on Android 12 and below. |
| `POST_NOTIFICATIONS` | Displays media playback controls on the lock screen and notification shade (Android 13+). |
| `FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Keeps music playing when the screen is turned off or when switching apps. |
| `WAKE_LOCK` | Prevents the CPU from sleeping while streaming audio. |
| `INTERNET` & `ACCESS_NETWORK_STATE` | Streams online audio, checks network connectivity, and fetches lyrics. |
| `MODIFY_AUDIO_SETTINGS` | Applies hardware equalizer adjustments and loudness enhancement. |

---

## Technology Stack

- **Framework:** [Flutter](https://flutter.dev) (Channel: Stable)
- **Language:** Dart 3 & Kotlin
- **Audio Pipeline:** `just_audio`, `audio_service`, `audio_session`
- **Native Platform Bridge:** Android `MediaStore` ContentResolver via Kotlin `MethodChannel`
- **State Management:** `provider`
- **Theme & Visuals:** Custom Frosted Glass (`BackdropFilter`) & `palette_generator`
- **Persistent Storage:** `shared_preferences`

---

## Release History

All releases are compiled and cryptographically signed via automated GitHub Actions:

- **[Tunora v1.3.0](https://github.com/Snehal-Modi/music-media---tunora/releases)** — Artist and album pages, Spotify-style home chips, improved YouTube failover, enhanced queue suggestions.
- **[Tunora v1.2.0](https://github.com/Snehal-Modi/music-media---tunora/releases)** — Taste learning, language top charts, podcasts and stories, offline home auto-switching.
- **[Tunora v1.1.0](https://github.com/Snehal-Modi/music-media---tunora/releases)** — Initial release with local/online playback, equalizer, synced lyrics, and downloads.

---

## Changelog

Detailed notes on every release can be found in [CHANGELOG.md](CHANGELOG.md).

---

## Credits & Disclaimers

Tunora is a personal, open-source project. All streaming audio and metadata are provided through public community and third-party APIs:

- **JioSaavn** for Indian music streaming metadata and audio links.
- **YouTube** and Invidious/Piped mirrors for video-audio streaming.
- **Audius** for decentralized music tracks.
- **Radio Browser** for community-maintained live radio stations.
- **Apple iTunes Podcast Directory** for podcast discovery.
- **LRCLIB** for open synced lyrics.

*All trademarks, logos, and content are the property of their respective owners.*
