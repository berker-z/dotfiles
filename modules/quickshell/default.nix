{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  hostName = osConfig.networking.hostName or "";
  enabled = hostName == "nixos";
  configName = "nord-pill";
  qs = "${pkgs.quickshell}/bin/qs";
  nordCliphistThumbs = pkgs.writeShellScriptBin "nord-cliphist-thumbs" ''
    set -euo pipefail

    cache="''${XDG_CACHE_HOME:-$HOME/.cache}/nord-pill/cliphist-thumbs"
    mkdir -p "$cache"
    chmod 700 "$cache"

    snapshot="$(cliphist list 2>/dev/null || true)"
    ids="$(printf '%s\n' "$snapshot" | cut -f1)"

    for f in "$cache"/*.png; do
      [[ -e "$f" ]] || continue
      fid="$(basename "$f" .png)"
      printf '%s\n' "$ids" | grep -qxF "$fid" || rm -f "$f"
    done

    printf '%s\n' "$snapshot" | while IFS= read -r line; do
      case "$line" in
        *"[[ binary data"*png*"]]"|*"[[ binary data"*jpg*"]]"|*"[[ binary data"*jpeg*"]]"|*"[[ binary data"*gif*"]]"|*"[[ binary data"*bmp*"]]"|*"[[ binary data"*webp*"]]")
          id="$(printf '%s' "$line" | cut -f1)"
          [[ -n "$id" ]] || continue
          thumb="$cache/$id.png"
          [[ -s "$thumb" ]] && continue

          raw="$cache/.raw.$id"
          tmp="$thumb.tmp"
          if printf '%s' "$id" | cliphist decode >"$raw" 2>/dev/null; then
            magick "''${raw}[0]" -auto-orient -thumbnail '160x120>' -strip "png:$tmp" 2>/dev/null || true
          fi
          if [[ -s "$tmp" ]]; then
            mv "$tmp" "$thumb"
          else
            rm -f "$tmp"
          fi
          rm -f "$raw"
          ;;
      esac
    done
  '';
  runtimePath = lib.makeBinPath [
    pkgs.bash
    pkgs.bluez
    pkgs.bluetuith
    pkgs.cliphist
    pkgs.coreutils
    pkgs.findutils
    pkgs.fuzzel
    pkgs.gnugrep
    pkgs.hyprland
    pkgs.imagemagick
    pkgs.jq
    pkgs.kitty
    pkgs.mako
    pkgs.networkmanager
    pkgs.networkmanagerapplet
    nordCliphistThumbs
    pkgs.pavucontrol
    pkgs.playerctl
    pkgs.procps
    pkgs.systemd
    pkgs.wireplumber
    pkgs.wiremix
    pkgs.wl-clipboard
    pkgs.wlogout
  ];
  nordPill = pkgs.writeShellScriptBin "nord-pill" ''
    set -euo pipefail

    export PATH="${runtimePath}:$PATH"

    config="${configName}"
    qs="${qs}"
    log_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/quickshell"
    log_file="$log_dir/$config.log"

    active_monitor() {
      hyprctl activeworkspace -j 2>/dev/null \
        | jq -r '.monitor // empty' 2>/dev/null \
        | head -n 1
    }

    fallback_monitor() {
      hyprctl monitors -j 2>/dev/null \
        | jq -r '.[0].name // empty' 2>/dev/null \
        | head -n 1
    }

    monitor_name() {
      local mon
      mon="$(active_monitor || true)"
      if [[ -z "$mon" ]]; then
        mon="$(fallback_monitor || true)"
      fi
      printf '%s\n' "$mon"
    }

    running() {
      "$qs" -c "$config" ipc show >/dev/null 2>&1
    }

    start() {
      mkdir -p "$log_dir"
      if ! running; then
        "$qs" -c "$config" --no-duplicate --daemonize >"$log_file" 2>&1 || true
        sleep 0.25
      fi
    }

    call() {
      local fn="$1"
      local surface="''${2:-}"
      local mon
      mon="$(monitor_name)"
      start
      if [[ -n "$surface" ]]; then
        "$qs" -c "$config" ipc call pill "$fn" "$mon" "$surface"
      else
        "$qs" -c "$config" ipc call pill "$fn" "$mon"
      fi
    }

    case "''${1:-toggle}" in
      start)
        start
        ;;
      stop)
        "$qs" -c "$config" kill >/dev/null 2>&1 || true
        ;;
      restart)
        "$qs" -c "$config" kill >/dev/null 2>&1 || true
        sleep 0.15
        start
        ;;
      hide)
        if running; then
          "$qs" -c "$config" ipc call pill hide
        fi
        ;;
      peek | toggle)
        call peek
        ;;
      calendar | media | links | power | clipboard)
        call toggle "$1"
        ;;
      mixer | audio | sound)
        call toggle media
        ;;
      connectivity | network | wifi | bluetooth)
        call toggle links
        ;;
      sidebar)
        call sidebar
        ;;
      apps | launcher)
        start
        fuzzel >/dev/null 2>&1 &
        ;;
      status)
        "$qs" -c "$config" list
        ;;
      *)
        cat <<'USAGE'
    usage: nord-pill [start|stop|restart|toggle|hide|calendar|media|audio|links|connectivity|power|clipboard|sidebar|apps|status]
    USAGE
        exit 2
        ;;
    esac
  '';
in {
  config = lib.mkIf enabled {
    home.packages = [
      pkgs.quickshell
      nordCliphistThumbs
      nordPill
    ];

    xdg.configFile."quickshell/${configName}".source = ./nord-pill;

    wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
      $nordPill = nord-pill

      bind = $mainMod ALT, P, exec, $nordPill toggle
      bind = $mainMod ALT SHIFT, P, exec, $nordPill restart
      bind = $mainMod ALT, C, exec, $nordPill calendar
      bind = $mainMod ALT, M, exec, $nordPill mixer
      bind = $mainMod ALT, V, exec, $nordPill clipboard
      bind = $mainMod ALT, S, exec, $nordPill sidebar
      bind = $mainMod ALT, O, exec, $nordPill power
    '';
  };
}
