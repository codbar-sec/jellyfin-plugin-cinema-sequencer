# Contributing

Thanks for helping. Bug reports, fixes and ideas are welcome.

## Before you open an issue

- Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).
- Use the issue template and include your Jellyfin version, how you run Jellyfin (Docker, package, Windows), and the plugin version.

## Never post secrets

Issues, pull requests and discussions are public. Remove or replace before posting:

- Your TMDB API key or token, and any URL containing `api_key=`.
- The plugin settings file (`Jellyfin.Plugin.CinemaSequencer.xml`). It holds your TMDB key in plain text.
- Any `cookies.txt`. It is a login credential for the YouTube account it came from.
- Server paths, IP addresses, domain names and usernames you do not want public. Logs often contain them.

If you pasted a secret by mistake, treat it as leaked: revoke or regenerate it at the source (TMDB settings, sign out of the YouTube account), then edit or delete the post. Deleting alone is not enough because it may already have been copied.

## Pull requests

1. Fork the repository and branch from `main`.
2. Build locally (see [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)) and run the check script:
   ```sh
   bash scripts/check-no-secrets.sh
   ```
   To also check for your own name, domain or addresses without committing them, pass them as a pattern:
   ```sh
   EXTRA_PATTERNS='yourname|yourdomain\.com' bash scripts/check-no-secrets.sh
   ```
3. Keep changes focused. Explain the behaviour change and how you tested it.
4. Update `CHANGELOG.md` for anything user visible.
5. Use your GitHub noreply address for commits if you do not want your email public (GitHub > Settings > Emails).

## Code and licence

By contributing you agree your work is released under the project's [MIT licence](LICENSE). Keep the upstream attribution in [NOTICE.md](NOTICE.md) intact. Do not add code you cannot license this way, and do not commit TMDB's logo, API keys or any third-party binaries.
