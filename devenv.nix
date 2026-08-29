{pkgs, ...}: {
  env.DEVSHELL_NAME = "🦀 projects/#de5b44";
  packages = with pkgs; [
    git
  ];

  languages.rust = {
    channel = "nightly";
  };

  enterShell = ''
    cargo update
    cargo --version
    rustc --version
  '';
}
