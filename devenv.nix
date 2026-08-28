{pkgs, ...}: {
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
