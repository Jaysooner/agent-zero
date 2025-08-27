# Agent Zero on RunPod — /workspace-first with Compatibility (v3)

Purpose: make Agent Zero always run from a stable directory (default `/workspace`) without
breaking older scripts that assume `/a0` or `/app`. This adds a small compatibility layer
and safe defaults for common env vars.

## What this does
- Default run dir is `/workspace` (`WORKDIR /workspace`).
- You can override via environment variable: `A0_WORKDIR=/some/path`.
- Creates symlinks:
  - `/a0 -> /workspace`
  - `/app -> /workspace`
  (Only if those paths do not already exist.)
- Exposes env defaults if you haven’t set them:
  - `A0_HOME=/workspace/.a0`
  - `A0_DATA_DIR=/workspace`
  - `A0_LOG_DIR=/workspace/logs`
- Optional runtime `chown` (disabled by default). Enable only if you know you need it.

## Why this avoids “directory confusion”
- Any code using **relative paths** still runs in the same place (the working dir).
- Any code hardcoding `/a0` or `/app` resolves to `/workspace` via symlinks.
- Your data and logs stay under `/workspace` by default, easy to persist on RunPod volumes.

## Use on RunPod
1. Build and push this image, or let RunPod build from your repo with this Dockerfile.
2. Mount a persistent volume to `/workspace`.
3. Optionally set env vars to customize (see docker-compose example).

## Local quick test
```bash
cd docker/run
docker compose -f docker-compose.override.yml up --build
```

## Notes
- No baked-in `chown`. Mounts generally dictate permissions.
- If you override `A0_WORKDIR`, the symlinks still point to that run dir.
