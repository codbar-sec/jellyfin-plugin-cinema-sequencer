# Installation

Requirements: Jellyfin 10.11 or newer, a free TMDB API key, and a writable folder for trailers. yt-dlp is strongly recommended.

## 1. Install the plugin

### Through the plugin catalog

1. Dashboard > Plugins > Repositories > add `https://raw.githubusercontent.com/codbar-sec/jellyfin-plugin-cinema-sequencer/main/manifest.json`.
2. Dashboard > Plugins > Catalog > General > **Cinema Sequencer** > Install.
3. Restart Jellyfin.

### Manually

1. Download `cinema-sequencer_<version>.zip` from the Releases page.
2. Unzip it into a new folder named `CinemaSequencer_<version>` inside the `plugins` folder of your Jellyfin data directory. Typical locations: `/var/lib/jellyfin/plugins` (Linux package), `/config/plugins` (Docker), `%ProgramData%\Jellyfin\Server\plugins` (Windows).
3. Make sure the Jellyfin user can read the folder. Restart Jellyfin.

If you previously used Trailers4Jellyfin, **uninstall it first**. Both plugins would each queue trailers and you would get duplicates. You can copy its settings across: the setting names are identical, only the file name differs (`Jellyfin.Plugin.Trailers4Jellyfin.xml` to `Jellyfin.Plugin.CinemaSequencer.xml`). Do that with Jellyfin stopped, and check `AllowedLanguages` afterwards, because this plugin defaults to English only.

## 2. Create the trailers folder

Create a folder Jellyfin can **write** to, for example `/media/trailers`. In Docker this must be its own writable mount (see below). Do not put it inside a read-only media mount.

## 3. Install yt-dlp (recommended)

The built-in downloader is limited to 720p and is often blocked by YouTube. yt-dlp is far more reliable.

- Linux, outside Docker: install `yt-dlp` somewhere on the PATH of the Jellyfin user, for example `/usr/local/bin/yt-dlp`.
- Docker: the Jellyfin image does not include yt-dlp. Download the standalone `yt-dlp_linux` binary from the yt-dlp releases page, make it executable, and mount it into the container (see the compose example).
- The plugin finds yt-dlp automatically on the PATH and in common locations. You can also set the path explicitly under Advanced.

yt-dlp needs ffmpeg to merge video and audio. Jellyfin's bundled ffmpeg works: set the **ffmpeg path** to `/usr/lib/jellyfin-ffmpeg/ffmpeg` (the usual location in the official image and Linux packages).

## 4. Configure

Follow the [Quick start in the README](../README.md#quick-start), and see [CONFIGURATION.md](CONFIGURATION.md) for every setting.

## Docker

See [docker-compose.example.yml](docker-compose.example.yml). The points that matter:

- A **writable** mount for the trailers folder.
- yt-dlp mounted read-only into a folder on the PATH (for example `/usr/local/bin/yt-dlp`).
- Optionally a read-only mount for the intro folder.
- The container user needs write access to the trailers folder on the host (set ownership to the same UID and GID Jellyfin runs as).

Check from the host:

```sh
docker exec jellyfin sh -c 'touch /trailers/.w && rm /trailers/.w && echo writable'
docker exec jellyfin /usr/local/bin/yt-dlp --version
```

## Verify

Dashboard > Scheduled Tasks > Download TMDB Trailers > Run, then watch the Jellyfin log. Downloads show as `Downloading ... via yt-dlp ...`. Then scan the trailers library and play a movie with Cinema Mode on.
