# agent-browser@0.34.0 pinned for Hermes CDP attach to a live browser.
#
# WHY: Hermes Agent pins agent-browser@^0.26.0 (semver-locked below 0.27),
# which has a CDP bug: it sends `Page.enable` on the browser-level websocket
# instead of attaching a page target first, so `browser.cdp_url` attach to a
# real browser (e.g. Helium) times out. The fix landed in 0.34.0. nixpkgs's
# own agent-browser (0.27.0, a Rust build) is ALSO affected, so we pin the
# npm 0.34.0 package. Hermes's discovery checks PATH first, so this version
# on PATH wins over its buggy npx fallback.
#
# The npm tarball ships prebuilt native binaries for all platforms (the
# postinstall just picks the right one), so this is a pure Nix derivation:
# extract the tarball and expose the linux-x64 native binary as `agent-browser`.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "agent-browser";
  version = "0.34.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/agent-browser/-/agent-browser-${finalAttrs.version}.tgz";
    hash = "sha256-pHRPsYnlmEZ6vPs6zd4HEY2eXLQ9w7MXJ/hpr0651Zg=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/agent-browser
    # Native binary for linux-x64 (musl variants included too).
    cp bin/agent-browser-linux-x64 $out/bin/agent-browser
    chmod +x $out/bin/agent-browser
    # Ship skills/skill-data next to the binary (the CLI reads these at runtime).
    cp -r skills skill-data $out/share/agent-browser/ 2>/dev/null || true
    runHook postInstall
  '';

  meta = {
    description = "Fast browser automation CLI for AI agents (pinned 0.34.0 for Hermes CDP attach)";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    mainProgram = "agent-browser";
  };
})
