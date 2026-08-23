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
            {
              foreground = "#FFE082";
              style = "plain";
              template = "@{{ .UserName }} ${icon "279c"}";
              type = "session";
            }
            {
              foreground = "#56B6C2";
              options = {
                style = "agnoster_short";
              };
              style = "plain";
              template = " {{ .Path }} ";
              type = "path";
            }
            {
              foreground = "#7FD5EA";
              style = "powerline";
              template = "(${icon "e626"}{{ if .Error }}{{ .Error }}{{ else }}{{ .Full }}{{ end }}) ";
              type = "go";
            }
            {
              foreground = "#9e7eff";
              style = "powerline";
              template = "(${icon "e235"} {{ if .Error }}{{ .Error }}{{ else }}{{ if .Venv }}{{ .Venv }} {{ end }}{{ .Full }}{{ end }}) ";
              type = "python";
            }
            {
              foreground = "#56B6C2";
              options = {
                branch_icon = "";
              };
              style = "plain";
              template = "<#E8CC97>git(</>{{ .HEAD }}<#E8CC97>) </>";
              type = "git";
            }
            {
              foreground = "#FFAB91";
              options = {
                always_enabled = false;
                style = "austin";
                threshold = 100;
              };
              style = "powerline";
              template = "{{ .FormattedMs }}";
              type = "executiontime";
            }
          ];
          type = "prompt";
        }
        {
          alignment = "left";
          newline = true;
          segments = [
            {
              foreground = "#193549";
              foreground_templates = [
                "{{if eq \"Charging\" .State.String}}#64B5F6{{end}}"
                "{{if eq \"Discharging\" .State.String}}#E36464{{end}}"
                "{{if eq \"Full\" .State.String}}#66BB6A{{end}}"
              ];
              options = {
                charged_icon = "${icon "e22f"} ";
                charging_icon = "${icon "e234"} ";
                discharging_icon = "${icon "e231"} ";
              };
              style = "powerline";
              template = "[{{ if not .Error }}{{ .Icon }}{{ .Percentage }}{{ end }}{{ .Error }}${icon "f295"}]";
              type = "battery";
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
