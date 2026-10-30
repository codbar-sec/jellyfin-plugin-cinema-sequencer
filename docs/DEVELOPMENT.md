# Development

## Layout

```
Jellyfin.Plugin.CinemaSequencer/
  Plugin.cs                         plugin entry, settings page registration
  PluginServiceRegistrator.cs       registers services, the scheduled task and the intro provider
  Configuration/                    PluginConfiguration.cs and config.html (the settings page)
  ScheduledTasks/                   DownloadTrailersTask (daily and at startup)
  Services/
    TmdbService.cs                  TMDB queries
    TrailerDownloadService.cs       yt-dlp and built-in YouTube download
    TrailerIntroProvider.cs         IIntroProvider: picks trailers, then appends the custom intro
scripts/
  package.sh                        build and zip the release archive
  update_manifest.py                add a version entry to manifest.json
  check-no-secrets.sh               scan for secrets and personal data
.github/workflows/                  build.yml (CI), release.yml (tag to GitHub release and manifest)
```

## Build

Requires the .NET 9 SDK.

```sh
dotnet build Jellyfin.Plugin.CinemaSequencer.sln -c Release
```

The project references the Jellyfin 10.11.0 packages (the same API generation as upstream). Override with `-p:JellyfinVersion=<version> -p:TFM=<tfm>` if you build for another server version. If the build complains about the `User` type, the namespace differs between server versions (`Jellyfin.Database.Implementations.Entities` in 10.11 and later, `Jellyfin.Data.Entities` earlier).

## Package

```sh
bash scripts/package.sh 2.0.0.0 dist
```

This publishes the project, keeps the plugin DLL and its non-Jellyfin dependencies, and writes `dist/cinema-sequencer_2.0.0.0.zip`. Do **not** put `Jellyfin.*`, `MediaBrowser.*`, `Emby.*`, `Microsoft.*` or `System.*` DLLs in the zip: a second copy of the server's own assemblies breaks type matching and Jellyfin will not recognise the intro provider.

## Test by hand

Copy the DLLs into `<jellyfin config>/plugins/CinemaSequencer_<version>/`, restart Jellyfin, and check for `Loaded plugin: Cinema Sequencer` in the log. Then run the download task, scan the trailers library, and play a movie with Cinema Mode on. There are no automated tests yet. A good first contribution would be unit tests for the selection and path logic in `TrailerIntroProvider`.

## Release

1. Update `CHANGELOG.md` with a section `## [x.y.z]`.
2. Commit, then tag: `git tag vx.y.z && git push origin vx.y.z`.
3. The `release` workflow builds the zip, creates a GitHub release, and adds the version (with its MD5 checksum) to `manifest.json` on `main`.

The workflow pushes to `main`. If you protect that branch, allow the Actions bot to push, or update `manifest.json` through a pull request instead.

## Before you commit

```sh
bash scripts/check-no-secrets.sh
EXTRA_PATTERNS='yourname|yourdomain\.com' bash scripts/check-no-secrets.sh
```

The second form checks for your own identifying strings without writing them into the repository.
