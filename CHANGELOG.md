# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.0.0]

First release of Cinema Sequencer, forked from [Trailers4Jellyfin](https://github.com/robadieNZ/Trailers4Jellyfin) v1.0.18.0 by robadieNZ.

### Added
- **Custom intro** setting (`IntroPath`). The intro plays after the trailers, from the same intro provider, so the order is always trailers first and intro last. The intro's folder must be a Jellyfin Movies library.
- "English only" button on the settings page.
- An About section on the settings page with the upstream credit and the TMDB attribution notice.
- Intros are never queued in front of the trailers or the intro file itself.
- Release tooling: packaging script, manifest updater, build and release workflows, and a script that checks the repository for secrets and personal data.

### Changed
- Language filter now defaults to English (`en`). Upstream defaults to all languages.
- Renamed the plugin, namespace and GUID so it can replace or run beside the original. Do not run both at once: each would queue its own trailers.
- Settings page wording: recommends the TMDB Read Access Token (sent in a header) over the v3 key (sent in the URL), and warns that the YouTube cookies file is a credential.
- Build properties `JellyfinVersion` and `TFM` can be overridden on the command line.

### Unchanged from upstream
TMDB and YouTube downloading, yt-dlp and built-in downloader handling, genre and rating matching, rotation and caps.
