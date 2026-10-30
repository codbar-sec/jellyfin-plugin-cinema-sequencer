# Notices and third-party components

## Upstream project

Cinema Sequencer is a fork of **Trailers4Jellyfin** by robadieNZ.

- Repository: https://github.com/robadieNZ/Trailers4Jellyfin
- Forked from: v1.0.18.0
- Licence stated by upstream: MIT. (Upstream's repository has no separate LICENSE file; its README states "MIT". This fork follows that and keeps the attribution in [LICENSE](LICENSE).)

Substantial parts of this repository's source code (TMDB and YouTube downloading, yt-dlp handling, rating and genre matching, trailer rotation, the settings page and the plugin logo) are the upstream author's work, used under that licence.

What this fork changes is listed in [CHANGELOG.md](CHANGELOG.md).

## Components shipped in the release zip

The release zip contains the plugin DLL and the following non-Jellyfin dependencies, as built from the NuGet packages named in the project file. Each package carries its own licence; check the package page on nuget.org before redistributing.

| Component | Author | Licence | Notes |
|---|---|---|---|
| YoutubeExplode | Tyrrrz | LGPL-3.0 (per the package's published licence; verify on nuget.org) | Shipped unmodified as a separate DLL so it can be replaced. Source: https://github.com/Tyrrrz/YoutubeExplode |
| BitFaster.Caching, Polly, Polly.Core, ICU4N, ICU4N.Transliterator, J2N, Diacritics, NEbml.Core | various | see each package | Transitive dependencies pulled in by the Jellyfin and YoutubeExplode packages |

Jellyfin's own assemblies (`Jellyfin.*`, `MediaBrowser.*`, `Emby.*`) and the .NET runtime are **not** shipped; the server provides them.

## Jellyfin

The plugin is built against the Jellyfin NuGet packages (`Jellyfin.Controller`, `Jellyfin.Model`). Jellyfin's plugin template documents that plugins link against GPLv3-licensed packages and that a distributed plugin binary is therefore effectively GPLv3, while the source may carry a permissive licence that is compatible with it. This project's source is MIT.

## External tools (not included)

- **yt-dlp** (https://github.com/yt-dlp/yt-dlp) is an optional external program the plugin can call. It is not bundled or redistributed here. Its own licence applies to your installation of it.
- **ffmpeg** is used through the copy Jellyfin already ships (`jellyfin-ffmpeg`) or one you install. Not bundled.

## TMDB

This product uses the TMDB API but is not endorsed or certified by TMDB.

TMDB's terms ask applications to display TMDB's approved logo with this notice. This repository does not include the TMDB logo. If you redistribute a build, add one of TMDB's approved logos from https://www.themoviedb.org/about/logos-attribution and check their current API terms.

## Trademarks

Jellyfin, YouTube, TMDB and yt-dlp are the property of their respective owners. This project is not affiliated with or endorsed by any of them.
