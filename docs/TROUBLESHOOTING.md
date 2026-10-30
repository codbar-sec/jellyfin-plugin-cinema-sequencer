# Troubleshooting

Start with the log: Dashboard > Logs, or `docker logs jellyfin`. The plugin's lines contain `CinemaSequencer`:

```sh
docker logs -f jellyfin 2>&1 | grep --line-buffered -i CinemaSequencer
```

**Before you paste a log anywhere, remove your TMDB key, any `api_key=` URL, cookies and paths you want private.**

## Nothing downloads

| Symptom | Cause | Fix |
|---|---|---|
| Task "Completed" in 0 minutes, log says `No download folder configured` | The task reports Completed even when it skips | Set the download folder in the plugin settings and run it again |
| Log says `No TMDB API key configured` | Key missing | Enter a TMDB key |
| `Permission denied` or nothing appears in the folder | Jellyfin cannot write there. In Docker, media mounts are often read-only | Give the trailers folder its own writable mount and the right owner |
| `No muxed streams available`, `VideoUnavailableException`, "YouTube bot protection" | The built-in downloader is blocked by YouTube and limited to 720p | Install yt-dlp (see [INSTALL.md](INSTALL.md)). A `cookies.txt` is a last resort |
| `yt-dlp exited with code 1 ... HTTP Error 403` for one trailer | YouTube refused that video | Usually fine. Other trailers are picked on later runs |
| Summary says `Downloaded 0 trailer(s)` but downloads were logged | Looks like a counting quirk | Check the folder contents, not that line |

## Nothing plays before the movie

Work through in order:

1. **Cinema Mode on for your user:** profile > Settings > Playback.
2. **Trailers folder added as a Movies library and scanned.** Intros are queued by library item, so unscanned files are invisible to the plugin. Log line: `No trailer items found in Jellyfin library under ...`.
3. **Plugin setting "Enable Cinema Mode" on, and Trailers per movie above 0.**
4. **Start the movie from the beginning.** Resuming usually skips intros.
5. **Your client.** The web client supports intros. Some TV and third-party apps ignore Cinema Mode. Test in the web client first.
6. **Age rating or genre filters.** If nothing is eligible for a given movie, nothing is queued. Try a different movie.

## The intro does not play

| Symptom | Cause | Fix |
|---|---|---|
| Log: `Intro '...' is not in any Jellyfin library` | The intro's folder is not a Movies library, or is not scanned, or the path is wrong | Add the folder as a Movies library, scan, and use the path exactly as Jellyfin sees it (inside the container, if you use Docker) |
| Trailers play, intro never does | `Custom intro` is empty | Set it in the plugin settings |
| Intro plays before the trailers, or trailers play twice | Another plugin is also supplying intros (the original Trailers4Jellyfin, or a pre-roll plugin) | Uninstall or disable the other plugin. Jellyfin merges all plugins' intro lists and has no setting for their order |

## Wrong-language trailers

The language filter defaults to English. Trailers downloaded earlier (or with an older plugin that allowed all languages) are not re-checked. Delete the files in the trailers folder, scan the library, and run the download task again. Check Allowed languages on the settings page.

## The plugin does not load after a Jellyfin upgrade

The plugin is built against the Jellyfin 10.11 API. If a major Jellyfin upgrade stops it loading, look for the error in the log at startup, then check the Releases page for a newer build or rebuild it (see [DEVELOPMENT.md](DEVELOPMENT.md)).

## Reporting a bug

Open an issue with your Jellyfin version, how you run it, the plugin version, and the relevant `CinemaSequencer` log lines with secrets removed. See [CONTRIBUTING.md](../CONTRIBUTING.md).
