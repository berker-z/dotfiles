## Workarounds

- 2026-08-18: Pin `agent-browser@0.34.0` via `packages/agent-browser.nix` (added to `home.packages` in `profiles/home/workstation.nix` through `pkgs.callPackage`, no overlay) so Hermes can attach to the live Helium browser over CDP (`browser.cdp_url = http://127.0.0.1:9222`) and use Helium's real sessions/cookies. Hermes pins `agent-browser@^0.26.0` in `tools/browser_tool.py` (`AGENT_BROWSER_NPX_SPEC`, a semver range that can never select ≥0.27), and nixpkgs's own `agent-browser` (0.27.0, Rust build) has the same bug: it sends `Page.enable` on the browser-level websocket instead of attaching a page target first, so CDP attach to a real browser times out. The fix landed in `0.34.0`. The npm tarball ships prebuilt native binaries, so the package is a pure extraction of the `linux-x64` binary (no Rust compile, no lockfile). NOTE: a pin is mandatory in Nix (a derivation needs a fixed URL + hash; there is no declarative unpinned `npm install -g`), and 0.34 is simply "latest known-good". Remove this file + the `home.packages` line once Hermes bumps `AGENT_BROWSER_NPX_SPEC` past `^0.26.0` (check upstream `main`) or nixpkgs ships a fixed `agent-browser`.
- 2026-03-02: Pin LibreOffice to nixpkgs `nixos-24.05` (`libreoffice-still`) because nixos-unstable had a noto-fonts-subset build failure. Remove the overlay in `flake.nix` once nixos-unstable includes the upstream fix for that regression.
- 2026-05-01: Comment out `yt-dlp` in `packages/graphical.nix` because the current `nixpkgs` revision pulls in `deno` for `yt-dlp`, which pulls in `rusty-v8`, and that V8 build is currently crashing under `clang` during rebuilds. Revert by uncommenting `yt-dlp` there once the upstream `deno`/`rusty-v8` build issue on this nixpkgs line is fixed.

## TODO

- 2026-03-08: Investigate broken IPv6 on laptop Wi-Fi (no global IPv6 route; IPv6 connections fail). Check router/ISP IPv6 config and consider proper IPv6 enablement or disabling IPv6 advertisement if upstream is broken.
- 2026-06-19: ? Investigate whether `org/gnome/desktop/interface.document-font-name` should be managed at all; it may be redundant with `font-name` or affect app/browser font behavior unexpectedly.
- 2026-08-18: Give the laptop its own SSH key for `wired`. Add only the laptop's public key to `wired`'s authorized keys, keep the private key on the laptop, and make the laptop's `wired` SSH entry use that key instead of the desktop-only `~/.ssh/id_ed25519_wired`. Tailscale currently supplies the private network path; ordinary OpenSSH keys still authenticate the login because Tailscale SSH is disabled.

## Reference

- 2026-08-18: The `~/job-watch/` app (LinkedIn job collector) is served by a
  **systemd user service** `job-watch.service` (declared in `profiles/home/workstation.nix`)
  on `http://127.0.0.1:8791`, loopback-only, enabled + auto-restart. Do NOT start it as a
  stray background process — it's managed by systemd (the linked `linkedin-job-watch`
  Hermes skill fills `~/job-watch/jobs.json`, which the service renders as HTML).
- 2026-08-06: `hermes-agent` is back in `flake.nix` and the independent
  `packages/{graphical,server}.nix` lists without an explicit revision in its input URL. The old
  2026-06-17 pin (`a35b370284ec62b2851c26c23aed526a2c4d50a7`) is no longer needed:
  upstream moved `nix/lib.nix` to `importNpmLock`, which reads integrity hashes out of
  `package-lock.json` instead of a hand-maintained `npmDepsHash`, so the stale-hash
  failure for `hermes-desktop-renderer`/`hermes-tui` cannot recur. Verified by building
  `default`, `tui`, and `desktop` against this flake's locked `nixpkgs`.
  The committed `flake.lock` still pins deployed builds; updating that lock advances the input from upstream `main`.
- 2026-08-06: Hermes Desktop *remote gateway* support is deliberately NOT restored.
  Commit `d003ab6` removed two pieces from `home.nix` that would be needed to bring it
  back: the `~/.local/bin/hermes-desktop-remote` wrapper (reads
  `$XDG_CONFIG_HOME/hermes-desktop/remote.env` for `HERMES_DESKTOP_REMOTE_URL` and
  `HERMES_DESKTOP_REMOTE_TOKEN`, probes the gateway, falls back to the local backend on
  404) plus its `remote.env.example`, and the matching
  `xdg.desktopEntries.hermes-desktop-remote` launcher entry. Recover with
  `git show d003ab6^:home.nix`. Before reusing it, re-check the wrapper's hardcoded
  `/api/profiles/sessions` probe path — it was written against Hermes Desktop 0.x in
  July 2026, so the endpoint may have moved in the currently locked build.
