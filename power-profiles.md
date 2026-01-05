# Laptop power profiles + fan curves (ASUS ROG, NixOS)

## Profiles and mapping

- Quiet: `powerprofilesctl set power-saver` + `asusctl profile -P Quiet`
- Balanced: `powerprofilesctl set balanced` + `asusctl profile -P Balanced`
- Turbo: `powerprofilesctl set performance` + `asusctl profile -P Performance`

## Fan curve notes (opt-in behavior)

Custom fan curves are persistent once set. The Waybar toggle is wired so:

- **Quiet** resets Balanced/Performance curves back to ASUS defaults.
- **Balanced/Performance** applies custom low-noise curves for those profiles.

If you want to opt out later, switch to **Quiet** once to reset curves, then remove the Waybar module.

## Quiet-derived curve blending

Balanced and Performance are set to reuse the Quiet curve at low temperatures, then ramp harder at high temps.

Balanced (quiet until 66c):
- CPU: 47c:10,50c:20,53c:20,57c:35,61c:35,66c:51,70c:122,98c:142
- GPU: 47c:20,50c:30,53c:30,57c:45,61c:45,66c:68,70c:127,98c:147

Performance (quiet until 64c):
- CPU: 20c:10,48c:20,52c:20,56c:35,60c:35,64c:51,68c:153,98c:163
- GPU: 20c:20,48c:30,52c:30,56c:45,60c:45,64c:68,68c:160,98c:175
