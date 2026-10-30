# Cinema Sequencer

A Jellyfin plugin that gives your server a home-cinema opening: it downloads current movie trailers, then plays **a few trailers followed by your own intro** before each movie, always in that order.

> **Status: early release.** The trailer downloading, matching and rotation come from an upstream plugin (see [Credits](#credits-and-licence)). The part this project adds, the custom intro that plays after the trailers, is new code. The author has tested it on one setup, Jellyfin 12.3.0 in Docker, where trailers play first and then the intro. Other Jellyfin versions and client apps are untested, so please report what you find. See [Known limitations](#known-limitations).

## Features

- Downloads trailers for upcoming and now-playing movies (TMDB as the source, YouTube as the video host) into a folder on your server.
- Plays N trailers before each movie, matched to the movie's genre where possible and capped to the movie's age rating.
- **Plays your own intro video after the trailers**, in a fixed order, from the same plugin. No second plugin, no duplicate trailers.
- English-only trailers by default, with a language picker (and an "English only" button).
- Automatic rotation: a cap on how many trailers are kept, optional deletion of watched ones.
- Uses [yt-dlp](https://github.com/yt-dlp/yt-dlp) when it is installed (recommended, more reliable against YouTube blocking), with a built-in 720p fallback.

## How it works

Jellyfin's Cinema Mode asks the server for "intros" when a movie starts. This plugin answers with a list: first N trailers picked from your trailers folder, then your intro file. A scheduled task (daily, and at startup) keeps the trailers folder stocked.

Jellyfin merges the intro lists from all plugins and has no setting for their order. That is why trailers and a custom intro come from one plugin here: the order is guaranteed.

## Requirements

- Jellyfin 10.11 or newer (built against the 10.11 API, tested on 12.3.0).
- A free [TMDB](https://www.themoviedb.org/settings/api) API key.
- Recommended: `yt-dlp` and `ffmpeg` reachable by the Jellyfin process (Jellyfin's own `jellyfin-ffmpeg` works).
- A folder Jellyfin can write to for trailers, and (optionally) a folder with your intro video. Both have to be added as Jellyfin **Movies** libraries.

## Install

**From the plugin catalog (recommended)**

1. In Jellyfin: Dashboard > Plugins > Repositories > add
   `https://raw.githubusercontent.com/codbar-sec/jellyfin-plugin-cinema-sequencer/main/manifest.json`
2. Dashboard > Plugins > Catalog > General > **Cinema Sequencer** > Install.
3. Restart Jellyfin.

**Manual**

Download the zip from the [Releases](../../releases) page, unzip it into `<jellyfin config>/plugins/CinemaSequencer_<version>/`, restart Jellyfin. Details and Docker notes are in [docs/INSTALL.md](docs/INSTALL.md).

## Quick start

1. Dashboard > Plugins > Cinema Sequencer. Enter your TMDB key, a **download folder** that Jellyfin can write to (for example `/media/trailers`), and check that languages are what you want. Save.
2. Add the download folder as a **Movies** library (Dashboard > Libraries) and scan it.
3. Dashboard > Scheduled Tasks > **Download TMDB Trailers** > Run. Wait for it to finish, then scan the trailers library again.
4. Optional intro: put a video file in its own folder, add that folder as a Movies library, scan it, then enter the file's full path in **Custom intro** (as Jellyfin sees it, for example `/preroll/intro.mp4`).
5. Turn on Cinema Mode for each user: profile > Settings > Playback > Cinema Mode.
6. Start a movie from the beginning. You should get the trailers, then your intro, then the movie.

If something does not play, see [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md). All settings are in [docs/CONFIGURATION.md](docs/CONFIGURATION.md).

## Docker

The media folders are often mounted read-only in the Jellyfin container. Trailers need their own **writable** mount, and yt-dlp is not in the Jellyfin image, so it has to be mounted in. A generic example is in [docs/docker-compose.example.yml](docs/docker-compose.example.yml).

## Security and privacy

- **TMDB key.** Use the **Read Access Token** (the long one starting with `eyJ`). It is sent in a request header. The short v3 key is sent as part of the request URL, which is easier to leak through logs and proxies.
- Your key is stored in plain text in the plugin's settings file on the server (`<jellyfin config>/plugins/configurations/Jellyfin.Plugin.CinemaSequencer.xml`). Never post that file.
- **YouTube cookies.** The optional `cookies.txt` setting lets anyone holding that file act as that YouTube login. Use a throwaway account, keep the file private, never attach it to an issue.
- The plugin makes requests to TMDB and YouTube only. It has no telemetry and sends nothing to the author.
- When reporting a bug, redact keys and URLs containing `api_key=` from logs. See [SECURITY.md](SECURITY.md).

## Known limitations

- Intros depend on the client app. The Jellyfin web client supports them. Some TV and third-party apps ignore Cinema Mode entirely.
- Resuming a movie partway normally skips intros (a Jellyfin client behaviour).
- Trailers are only picked from videos already scanned into the trailers library, so run a scan after downloads.
- Downloaded trailers are not re-checked when you change the language setting. Clear the folder and run the download task again.
- The built-in downloader is limited to 720p and is often blocked by YouTube. Use yt-dlp.

## Legal notes

- This plugin downloads videos from YouTube, usually with yt-dlp. You are responsible for following YouTube's terms of service and the laws where you live. The author provides the software as is and gives no legal advice.
- This product uses the TMDB API but is not endorsed or certified by TMDB.
- Not affiliated with or endorsed by Jellyfin, YouTube, TMDB or yt-dlp.

## Credits and licence

Cinema Sequencer is a fork of [**Trailers4Jellyfin**](https://github.com/robadieNZ/Trailers4Jellyfin) by **robadieNZ** (v1.0.18.0 when forked). The TMDB and YouTube downloading, genre and rating matching, rotation and the settings page are theirs. What this fork changes is listed in [CHANGELOG.md](CHANGELOG.md).

Source code is under the **MIT licence** (see [LICENSE](LICENSE)), the same licence the upstream project states. Third-party components and their licences are listed in [NOTICE.md](NOTICE.md). Note that the compiled plugin links against Jellyfin's GPL-licensed packages: Jellyfin's plugin guidance says the resulting binary is effectively GPLv3 even when the source is under a permissive licence.

## Contributing

Issues and pull requests are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) first, and never paste secrets into an issue.
