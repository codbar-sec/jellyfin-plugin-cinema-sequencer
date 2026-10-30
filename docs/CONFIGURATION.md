# Configuration

Settings live in Dashboard > Plugins > Cinema Sequencer. They are stored in `<jellyfin config>/plugins/configurations/Jellyfin.Plugin.CinemaSequencer.xml`. That file contains your TMDB key in plain text: never share it.

Defaults below are the ones in the code.

## TMDB

| Setting | Default | Meaning |
|---|---|---|
| TMDB API key | empty | A TMDB **Read Access Token** (starts with `eyJ`, sent in a header, recommended) or a v3 API key (sent in the request URL). Required. |

## Sources and date range

| Setting | Default | Meaning |
|---|---|---|
| Now playing | on | Include movies currently in cinemas |
| Upcoming | on | Include upcoming releases |
| Popular | off | Include popular movies |
| Top rated | off | Include top rated movies |
| Only include movies released within | Last 6 months | Choices: last 3 months, 6 months, 1 year, 2 years, or all time. Applies to every source. |

## Cinema Mode

| Setting | Default | Meaning |
|---|---|---|
| Enable Cinema Mode (play trailers before movies) | on | Queue trailers (and the intro) before movies. Cinema Mode must also be on for each Jellyfin user. |
| Trailers per movie | 2 | How many trailers to play first |
| Match trailers to movie genre | on | Prefer trailers sharing a genre with the movie. Falls back to random if there are not enough matches. Trailers are also limited to the movie's age rating or lower. |
| **Custom intro** | empty | Full path of an intro video as Jellyfin sees it, for example `/preroll/intro.mp4`. It plays **after** the trailers. Its folder must be a Jellyfin Movies library that has been scanned. Empty means no intro. |

## Languages

| Setting | Default | Meaning |
|---|---|---|
| Allowed languages | `en` | Comma-separated ISO 639-1 codes. Only trailers in these languages are downloaded. Empty means all languages. The settings page has an "English only" button. Already downloaded trailers are not re-checked. |

## Download

| Setting | Default | Meaning |
|---|---|---|
| Download folder | empty | Where trailers are saved, as Jellyfin sees the path. Required. Must be writable and added as a Movies library. |
| Max trailers per run | 20 | Upper limit of new downloads each time the task runs |
| Pages per source | 3 | How many TMDB result pages to read per source |
| Video quality | 720p | Choices: 480p, 720p, 1080p. 480p and 720p work with the built-in downloader. 1080p needs yt-dlp and ffmpeg. |
| Skip trailers already downloaded | on | Do not download a trailer twice |
| Skip movies already in my Jellyfin library | on | Do not fetch trailers for movies you already own |

## Rotation

| Setting | Default | Meaning |
|---|---|---|
| Max trailers to keep | 50 | Cap on trailers kept on disk. Oldest are deleted first. 0 is unlimited. |
| Delete watched trailers | off | Remove trailers any user has watched, to make room for fresh ones |

## Advanced

| Setting | Default | Meaning |
|---|---|---|
| yt-dlp path | empty | Leave blank to auto-detect from the PATH and common locations |
| ffmpeg path | empty | Passed to yt-dlp for merging. Leave blank if ffmpeg is on the PATH. In Jellyfin's image use `/usr/lib/jellyfin-ffmpeg/ffmpeg`. |
| YouTube cookies file | empty | Path to a `cookies.txt` (Netscape format). Only needed if YouTube blocks the server. **A credential:** use a throwaway account, keep it private. |

## The scheduled task

**Download TMDB Trailers** runs daily and at startup. You can run it from Dashboard > Scheduled Tasks at any time. The task can report "Completed" when it skipped its work (for example no folder or key set), so read the log, not just the status.
