# HyperFrames CLI (HeyGen) — HTML compositions rendered to video.
#
# Not in nixpkgs. Upstream only ships an npm package with no lockfile, so
# package.json + package-lock.json here pin the full dependency tree
# (regenerate both with `npm install --package-lock-only` when bumping).
#
# Out of the box the CLI downloads chrome-headless-shell into ~/.cache and
# offers to `npm i -g` itself on update; neither works on NixOS. Instead the
# wrapper points it at nixpkgs's patched headless shell (Playwright's build,
# which keeps the fast BeginFrame capture path) and turns the self-updater
# off. Skills are managed by modules/agents/hyperframes.nix, so its own skill
# installer is disabled too.
{
  lib,
  buildNpmPackage,
  autoPatchelfHook,
  makeWrapper,
  stdenv,
  nodejs,
  ffmpeg,
  playwright-driver,
  # Interpreter for the CLI's Python features (local TTS etc.). Optional so
  # the package still builds on its own.
  python ? null,
}: let
  headlessShell = playwright-driver.components.chromium-headless-shell;
in
  buildNpmPackage {
    pname = "hyperframes";
    version = "0.8.140";

    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [./package.json ./package-lock.json];
    };

    npmDepsHash = "sha256-NuKeg7GPjchr4uR2V8QKsIV/lvDEmXCR4LXc8onZ70w=";
    dontNpmBuild = true;

    # sharp ships prebuilt glibc binaries that need libstdc++ resolved.
    nativeBuildInputs = [autoPatchelfHook makeWrapper];
    buildInputs = [stdenv.cc.cc.lib];
    # Musl variants of sharp come along as optional deps; never loaded here.
    autoPatchelfIgnoreMissingDeps = ["libc.musl-x86_64.so.1"];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib $out/bin
      cp -r node_modules $out/lib/

      # `init` cpSync's its starter templates out of the package dir, which
      # here is the read-only store, so the scaffold comes out r--r--r-- and
      # init fails writing into it. Make the copies writable right after.
      substituteInPlace $out/lib/node_modules/hyperframes/dist/init-*.js \
        --replace-fail \
          'cpSync(templateDir, destDir, { recursive: true });' \
          'cpSync(templateDir, destDir, { recursive: true }); { const fs = await import("fs"); for (const p of fs.readdirSync(destDir, { recursive: true })) { const f = join2(destDir, p); fs.chmodSync(f, fs.statSync(f).isDirectory() ? 0o755 : 0o644); } }' \
        --replace-fail \
          'copyFileSync(src, dest);' \
          'copyFileSync(src, dest); (await import("fs")).chmodSync(dest, 0o644);'

      for bin in hyperframes hyperframes-localize-fonts; do
        makeWrapper ${nodejs}/bin/node $out/bin/$bin \
          --add-flags $out/lib/node_modules/hyperframes/bin/$bin.mjs \
          --prefix PATH : ${lib.makeBinPath [ffmpeg]} \
          --set-default HYPERFRAMES_BROWSER_PATH ${headlessShell}/chrome-headless-shell-linux64/chrome-headless-shell \
          --set-default HYPERFRAMES_FFMPEG_PATH ${ffmpeg}/bin/ffmpeg \
          --set-default HYPERFRAMES_FFPROBE_PATH ${ffmpeg}/bin/ffprobe \
          --set-default HYPERFRAMES_NO_UPDATE_CHECK 1 \
          --set-default HYPERFRAMES_SKIP_SKILLS 1 \
          --set-default HYPERFRAMES_NO_TELEMETRY 1 \
          ${lib.optionalString (python != null) "--set-default HYPERFRAMES_PYTHON ${python}/bin/python3"}
      done
      runHook postInstall
    '';

    meta = {
      description = "Write HTML, render video";
      homepage = "https://github.com/heygen-com/hyperframes";
      license = lib.licenses.asl20;
      mainProgram = "hyperframes";
      platforms = ["x86_64-linux"];
    };
  }
