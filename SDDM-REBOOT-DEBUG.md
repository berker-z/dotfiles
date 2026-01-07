# SDDM Reboot Black-Screen Investigation (Laptop)

## Summary
Intermittent black screen after boot on the **laptop**. The issue appears more frequently on **reboot** than on cold boot, but it can also happen after poweroff/poweron. A **full power removal (AC unplug)** sometimes recovers the system, which suggests the dGPU state may not fully reset across boots.

This does **not** reproduce on the desktop host (`nixos`).

## Current Hypothesis
- The SDDM Wayland greeter process (`sddm-greeter-qt6`) **crashes intermittently** on the laptop.
- The crash manifests as `Auth::HELPER_AUTH_ERROR` in SDDM logs (not necessarily PAM-related).
- GPU ordering/pinning does not fully eliminate the issue. Greeter can be on AMD and still crash.
- AC removal fixing the issue suggests **NVIDIA/dGPU power state persistence** could be involved.

## What We Observed in Logs
From recent failed boots (example entries):
- SDDM starts, greeter launches, then:
  - `Error from greeter session: "Process crashed"`
  - `Auth: sddm-helper exited with 1`
  - `Greeter stopped. SDDM::Auth::HELPER_AUTH_ERROR`
- Kernel cmdline **identical** across good/bad boots:
  - `nvidia-drm.modeset=1 nvidia-drm.fbdev=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1`
- The greeter’s Wayland compositor (weston) can run on AMD (`/dev/dri/card1`) and still crash.

## What We Tried
1. **SDDM Wayland greeter GPU pinning**
   - Set `WLR_DRM_DEVICES` and `KWIN_DRM_DEVICES` to AMD by-path:
     - `/dev/dri/by-path/pci-0000:04:00.0-card`
   - Greeter still crashed intermittently.

2. **Theme changes**
   - Switched to `japanese_aesthetic` on laptop via `sddm.nix` host mapping.
   - Tried non-animated backgrounds (no MP4).
   - Greeter still crashed intermittently, so the MP4 alone is **not** the cause.

3. **X11 greeter test (earlier experiment)**
   - Forcing SDDM to X11 showed a different failure (greeter crash in that path too).
   - Not adopted as final solution.

## Current Logging (Laptop Only)
Added to `hosts/laptop/default.nix`:

- **Greeter environment**
  - `WLR_DRM_DEVICES=/dev/dri/by-path/pci-0000:04:00.0-card`
  - `KWIN_DRM_DEVICES=/dev/dri/by-path/pci-0000:04:00.0-card`
  - `QT_LOGGING_RULES=qt.qpa.*=true;qt.wayland.*=true;qt.quick.*=true`
  - `WAYLAND_DEBUG=1`

- **Coredumps**
  - `LimitCORE=infinity` on `display-manager` service

These changes are scoped to the laptop host only.

## How to Collect Data After a Failed Boot
Use the previous boot index (`-1`) if the last boot failed:

```bash
journalctl -b -1 -u display-manager --no-pager | tail -n 400
coredumpctl list | rg sddm-greeter
coredumpctl info sddm-greeter-qt6 | head -n 80
```

If you want to identify specific boots:

```bash
journalctl --list-boots
```

## Current Config Mapping for SDDM Theme
In `sddm.nix`:
- `laptop` -> `japanese_aesthetic`
- others -> `hyprland_kath`

## Open Questions / Next Steps (for outside help)
1. Why does `sddm-greeter-qt6` crash intermittently on the laptop only?
2. Is the NVIDIA driver state persistence (and related kernel params) causing greeter instability?
3. Would delaying NVIDIA DRM module load until after login stop the greeter crash?
4. Does switching greeter compositor (e.g., kwin_wayland vs weston) change stability?
5. If the coredump shows a Qt/GL/Wayland stack crash, should SDDM be forced to X11 with a stable theme?

