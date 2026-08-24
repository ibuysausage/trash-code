{
  description = "A rust development enviroment flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    icon = code: builtins.fromJSON ''"\u${code}"'';
    myTheme = pkgs.writeText "mytheme.omp.json" (builtins.toJSON {
      blocks = [
        {
          alignment = "left";
          segments = [
            # user
            {
              type = "session";
              style = "powerline";
              powerline_symbol = icon "e0b0";
              foreground = "#241b26"; # base00
              background = "#DF00FF"; # base0D
              template = " ${icon "f007"} {{ .UserName }} ";
            }
            # path
            {
              type = "path";
              style = "powerline";
              powerline_symbol = icon "e0b0";
              foreground = "#241b26"; # base00
              background = "#78a38f"; # base0E
              options = {
                style = "full";
                folder_icon = icon "f07b";
                home_icon = icon "f015";
                folder_separator_icon = " ${icon "e0b1"} ";
              };
              template = " {{ .Path }} ";
            }
            # git — branch, ahead/behind, staged/working, stash, and the
            # upstream icon auto-detects GitHub/GitLab/Bitbucket from the remote
            {
              type = "git";
              style = "powerline";
              powerline_symbol = icon "e0b0";
              foreground = "#241b26"; # base00
              background = "#c965bf"; # base0B
              background_templates = [
                "{{ if or (.Working.Changed) (.Staging.Changed) }}#a84a73{{ end }}" # base0A
                "{{ if gt .Ahead 0 }}#9c5fce{{ end }}" # base0C
                "{{ if gt .Behind 0 }}#877bb6{{ end }}" # base08
              ];
              options = {
                branch_icon = "${icon "e725"} ";
                fetch_status = true;
                fetch_stash_count = true;
                fetch_upstream_icon = true;
                fetch_worktree_count = true;
              };
              template = " {{ .UpstreamIcon }}{{ .HEAD }}{{ .BranchStatus }}{{ if .Working.Changed }} ${icon "f044"}{{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }} ${icon "f046"}{{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }} ${icon "f692"} {{ .StashCount }}{{ end }} ";
            }
            # rust — version/toolchain, only shows in a Cargo/rust dir
            {
              type = "rust";
              style = "powerline";
              powerline_symbol = icon "e0b0";
              foreground = "#241b26"; # base00
              background = "#a3a079"; # base0F
              template = " ${icon "e7a8"} {{ if .Error }}{{ .Error }}{{ else }}{{ .Full }}{{ end }} ";
            }
            # execution time — only shows past the threshold, no clutter on fast commands
            {
              type = "executiontime";
              style = "powerline";
              powerline_symbol = icon "e0b0";
              foreground = "#eed5d9"; # base05
              background = "#46354a"; # base02
              options = {
                threshold = 500;
                style = "round";
              };
              template = " ${icon "f017"} {{ .FormattedMs }} ";
            }
            # last exit code — hidden unless the previous command failed
            {
              type = "status";
              style = "powerline";
              powerline_symbol = icon "e0b0";
              foreground = "#241b26"; # base00
              background = "#de5b44"; # base09
              options = {
                always_enabled = false;
              };
              template = " ${icon "f00d"} {{ .Code }} ";
            }
          ];
          type = "prompt";
        }
        # second line: clean prompt char, green on success / red after a failure
        {
          alignment = "left";
          newline = true;
          segments = [
            {
              type = "text";
              style = "plain";
              foreground = "#78a38f"; # base0E
              foreground_templates = [
                "{{ if gt .Code 0 }}#de5b44{{ end }}" # base09
              ];
              template = "${icon "276f"} ";
            }
          ];
          type = "prompt";
        }
      ];
      final_space = true;
      version = 4;
    });
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        zsh
        oh-my-posh
      ];
      buildInputs = with pkgs; [
        rustc
        rustfmt
        rust-analyzer
        cargo
        clippy
      ];
      env.RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
      shellHook = ''
        export POSH_THEME="${myTheme}"
        tmp_zdotdir=$(mktemp -d)
        trap 'rm -rf "$tmp_zdotdir"' EXIT
        cat > "$tmp_zdotdir/.zshrc" <<EOF
          source "$HOME/.zshrc"
          eval "\$(oh-my-posh init zsh --config "$POSH_THEME")"
        EOF
        ZDOTDIR="$tmp_zdotdir" zsh
        exit
      '';
    };
  };
}
