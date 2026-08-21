{
  pkgs,
  primaryUser,
  ...
}: let
  androidSdk = "/home/${primaryUser}/Android/Sdk";
in {
  # programs.adb is gone on this nixpkgs pin (systemd 258 handles device
  # access via uaccess), so android-tools goes in directly and only the kvm
  # group is still meaningful.
  environment.systemPackages = [pkgs.android-tools];

  users.users.${primaryUser}.extraGroups = ["kvm"];

  # Google's prebuilt SDK binaries (emulator, adb, aapt2, ...) run through
  # nix-ld (enabled in profiles/system/base.nix). The emulator bundles most
  # of its own libraries in emulator/lib64; these cover what it loads from
  # the host at runtime (GL, audio, X/xkb, fonts).
  #
  # The headless renderer needs far less than the *windowed* qemu binary
  # (emulator/qemu/linux-x86_64/qemu-system-x86_64). Running with a visible
  # window additionally pulls in dbus, libdrm, the NSS/NSPR stack, libpng and
  # the xcb/xkbfile X libraries — enumerated from `ldd` on that binary. They
  # are listed here so `emulator -avd ...` (no -no-window) works declaratively,
  # not via a runtime LD_LIBRARY_PATH override.
  programs.nix-ld.libraries = with pkgs; [
    alsa-lib
    dbus
    expat
    fontconfig
    freetype
    libGL
    libbsd
    libdrm
    libpng
    libpulseaudio
    libuuid
    libxkbcommon
    libx11
    libxcursor
    libxext
    libxi
    libxrandr
    libxcb
    libxkbfile
    ncurses
    nspr
    nss
    zlib
  ];

  environment.sessionVariables = {
    ANDROID_HOME = androidSdk;
    ANDROID_SDK_ROOT = androidSdk;
  };

  # emulator must come before platform-tools per Google's ordering advice.
  programs.fish.shellInit = ''
    fish_add_path --global --path ${androidSdk}/emulator ${androidSdk}/platform-tools ${androidSdk}/cmdline-tools/latest/bin
  '';
}
