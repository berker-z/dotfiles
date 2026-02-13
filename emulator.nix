# Android Emulator configuration for React Native development
{
  config,
  pkgs,
  ...
}: let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = ["34" "36"];
    buildToolsVersions = ["34.0.0" "36.0.0"];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = ["google_apis_playstore"];
    abiVersions = ["x86_64"];
    includeNDK = true;
    ndkVersions = ["27.1.12297006"];
    extraLicenses = [
      "android-sdk-license"
      "android-sdk-preview-license"
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };
  androidSdk = androidComposition.androidsdk;
in {
  # Accept Android SDK license
  nixpkgs.config.android_sdk.accept_license = true;

  # Android SDK and emulator packages
  environment.systemPackages = with pkgs; [
    androidSdk
    jdk17
    watchman
    android-tools # adb, fastboot
    # Graphics libraries for better emulator performance
    libGL
    libglvnd
    vulkan-loader
    vulkan-tools
    mesa
    # Qt dependencies for emulator UI
    qt6.qtwayland
    libsForQt5.qt5.qtwayland
  ];

  # Environment variables for Android development
  environment.variables = {
    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    # Force emulator to use system libraries for better compatibility
    ANDROID_EMULATOR_USE_SYSTEM_LIBS = "1";
    # Force AMD RADV driver for hardware acceleration
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
  };

  # Add Android tools to PATH
  environment.sessionVariables = {
    PATH = [
      "${androidSdk}/libexec/android-sdk/emulator"
      "${androidSdk}/libexec/android-sdk/platform-tools"
      "${androidSdk}/libexec/android-sdk/tools"
      "${androidSdk}/libexec/android-sdk/tools/bin"
    ];
    # Qt platform plugin path for Wayland support
    QT_QPA_PLATFORM = "wayland";
  };

  # Enable hardware graphics acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # RADV (AMD Vulkan driver) is enabled by default for AMD GPUs
  };

  # KVM virtualization for fast Android emulation
  virtualisation.libvirtd.enable = true;
  boot.kernelModules = ["kvm-intel" "kvm-amd"]; # Load both, system will use the right one

  # Enable nix-ld for running non-NixOS binaries (Android emulator needs this)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add common libraries that Android emulator might need
    stdenv.cc.cc.lib
    libGL
    libglvnd
    vulkan-loader
    libx11
    libxext
    libxcb
    pulseaudio
    alsa-lib
  ];

  # Add user to required groups
  users.users.berkerz.extraGroups = ["kvm" "libvirtd" "adbusers"];
}
