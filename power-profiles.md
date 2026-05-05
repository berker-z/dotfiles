# Laptop power profiles + fan curves (ASUS ROG, NixOS)

## Profiles and mapping

- Quiet: `asus-power-profile.sh set Quiet`
- Balanced: `asus-power-profile.sh set Balanced`
- Turbo: `asus-power-profile.sh set Performance`

`services.power-profiles-daemon` and `services.tlp` are disabled for the laptop.
`asusd` is the only daemon that should own `/sys/firmware/acpi/platform_profile`.
The helper script sets both `asusctl profile set --ac <profile>` and
`asusctl profile set --battery <profile>` so the profile does not flip when the
charger is connected or removed.

## Fan curve notes (opt-in behavior)

Custom fan curves are persistent once set. The Waybar toggle is wired so:

- **Quiet** disables custom Balanced/Performance curves so BIOS defaults are used.
- **Balanced/Performance** applies custom low-noise curves for those profiles.

If you want to opt out later, switch to **Quiet** once to disable custom curves,
then remove the Waybar module.

## Quiet-derived curve blending

Balanced and Performance are set to reuse the Quiet curve at low temperatures, then ramp harder at high temps.

Balanced (quiet until 66c):
- CPU: 45c:0,50c:15,53c:18,57c:28,61c:40,70c:70,82c:100,98c:142
- GPU: 45c:0,50c:20,53c:24,57c:34,61c:48,66c:80,70c:110,98c:147

Performance (quiet until 45c):
- CPU: 45c:0,48c:18,52c:22,56c:32,60c:45,64c:80,68c:120,98c:163
- GPU: 45c:0,48c:20,52c:26,56c:36,60c:52,64c:90,68c:130,98c:175

## Balanced max frequency cap

Balanced mode applies a CPU max frequency cap to keep boost spikes down:

- Balanced: `3200000` (3.2 GHz)
- Performance: `restore` (use `cpuinfo_max_freq`)
- Quiet: `3200000` (3.2 GHz)

Applied via systemd:

- `systemctl start cpu-max-freq@3200000.service`
- `systemctl start cpu-max-freq@restore.service`

NOPASSWD sudo rule allows `systemctl start cpu-max-freq@*.service` without a password.
