{pkgs, ...}: let
  # Python for the skills' scripts, e.g. music-to-video's beat analyzer
  # (librosa). Also handed to the CLI as HYPERFRAMES_PYTHON so the CLI and
  # the skills use the same interpreter.
  python = pkgs.python3.withPackages (ps: [ps.librosa ps.numpy ps.soundfile]);

  hyperframes = pkgs.callPackage ../../packages/hyperframes {inherit python;};

  # The agent skills live in the upstream repo, not the npm package. Pinned
  # to the tag matching the CLI so skills and CLI never disagree; bump both
  # together. Stands in for `npx skills add heygen-com/hyperframes`.
  skillsSrc = pkgs.fetchFromGitHub {
    owner = "heygen-com";
    repo = "hyperframes";
    rev = "v${hyperframes.version}";
    sparseCheckout = ["skills"];
    hash = "sha256-uHQtkggBJIobIdsX+/kxLOZ+o2/CdDcOQYE4DKwKUV0=";
  };

  # Skill directories only; the repo also keeps a stray test file at the top.
  skills = pkgs.runCommand "hyperframes-skills-${hyperframes.version}" {} ''
    mkdir -p $out
    for d in ${skillsSrc}/skills/*/; do cp -r "$d" $out/; done
  '';
in {
  home.packages = [hyperframes python];

  # recursive links file by file, so ~/.claude/skills stays a real directory
  # and the hand-managed skills next to these are left alone.
  home.file.".claude/skills" = {
    source = skills;
    recursive = true;
  };
}
