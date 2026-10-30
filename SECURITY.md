# Security policy

## Reporting a vulnerability

Please do **not** open a public issue for a security problem. Use GitHub's private vulnerability reporting for this repository (Security tab > Report a vulnerability). Include what you found, how to reproduce it, and the plugin and Jellyfin versions.

You can expect an acknowledgement, but this is a small volunteer project, so there is no guaranteed response time.

## What the plugin handles

| Item | Where it lives | Notes |
|---|---|---|
| TMDB API key or token | Plugin settings file on the server, plain text | Use the Read Access Token: it is sent in a request header. A v3 key is sent in the URL. |
| YouTube cookies (optional) | A `cookies.txt` file you provide | A credential for that YouTube account. Use a throwaway account. |
| Downloaded trailers | The download folder you choose | Public promotional videos. |

The plugin contacts TMDB and YouTube only, through Jellyfin's server process. It has no telemetry. None of the plugin's own log lines include your TMDB key (checked by reading the code), but Jellyfin or other tools in front of it may log request URLs, which is one more reason to use the header-based Read Access Token and to redact logs before sharing them.

## Hardening tips

- Run Jellyfin and yt-dlp as an unprivileged user.
- Give the trailers folder its own mount so the plugin cannot write elsewhere.
- Keep yt-dlp updated, and mount it read-only in containers.
- Restrict who can open Dashboard > Plugins: anyone who can read the plugin configuration can see the stored TMDB key.
- Never share the settings file or `cookies.txt` when asking for help.

## Supported versions

Only the latest release is supported.
