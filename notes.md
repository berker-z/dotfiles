## Workarounds

- 2026-03-02: Pin LibreOffice to nixpkgs `nixos-24.05` (`libreoffice-still`) because nixos-unstable had a noto-fonts-subset build failure. Remove the overlay in `flake.nix` once nixos-unstable includes the upstream fix for that regression.
- 2026-05-01: Comment out `yt-dlp` in `packages.nix` because the current `nixpkgs` revision pulls in `deno` for `yt-dlp`, which pulls in `rusty-v8`, and that V8 build is currently crashing under `clang` during rebuilds. Revert by uncommenting `yt-dlp` in `packages.nix` once the upstream `deno`/`rusty-v8` build issue on this nixpkgs line is fixed.

## TODO

- 2026-03-08: Investigate broken IPv6 on laptop Wi-Fi (no global IPv6 route; IPv6 connections fail). Check router/ISP IPv6 config and consider proper IPv6 enablement or disabling IPv6 advertisement if upstream is broken.
