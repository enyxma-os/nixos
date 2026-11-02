{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.enyxma.terminal;
in {
  options.enyxma.terminal = {
    enable = mkEnableOption "Enyxma Modern Terminal ve Kabuk Ortami";
  };

  config = mkIf cfg.enable {
    environment = {
      # Modern komut satiri araclari
      systemPackages = with pkgs; [
        kitty
        foot
        starship
        fastfetch
        eza
        bat
        zoxide
        fzf
        ripgrep
        fd
        yazi
      ];

      etc = {
        # Sistem genelinde Kitty terminal yapilandirmasi
        "xdg/kitty/kitty.conf".text = ''
          # Enyxma OS Kitty Ucbirim Yapilandirmasi
          font_family      JetBrainsMono Nerd Font
          bold_font        auto
          italic_font      auto
          font_size        11.5

          # Saydamlik ve ic bosluk
          background_opacity    0.85
          window_padding_width  14

          # Pencere ve ses davranislari
          confirm_os_window_close 0
          enable_audio_bell       no

          # Imlec ayarlari
          cursor_shape          beam
          cursor_blink_interval 0.5

          # Enyxma Koyu Teal Renk Paleti
          foreground            #c0caf5
          background            #0f141c
          selection_foreground  #c0caf5
          selection_background  #28344a
          url_color             #73daca
          cursor                #7dcfff
          cursor_text_color     #0f141c

          color0 #15161e
          color8 #414868

          color1 #f7768e
          color9 #f7768e

          color2  #9ece6a
          color10 #9ece6a

          color3  #e0af68
          color11 #e0af68

          color4  #7aa2f7
          color12 #7aa2f7

          color5  #bb9af7
          color13 #bb9af7

          color6  #7dcfff
          color14 #7dcfff

          color7  #a9b1d6
          color15 #c0caf5
        '';

        # Fastfetch karsilama yapilandirmasi
        "xdg/fastfetch/config.jsonc".text = ''
          {
            "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
            "logo": {
              "type": "small",
              "padding": {
                "top": 1,
                "left": 1
              }
            },
            "display": {
              "separator": " ❯ "
            },
            "modules": [
              "title",
              "separator",
              "os",
              "host",
              "kernel",
              "uptime",
              "packages",
              "shell",
              "wm",
              "terminal",
              "cpu",
              "memory",
              "break",
              "colors"
            ]
          }
        '';
      };
    };

    programs = {
      # Starship istemi yapilandirmasi
      starship = {
        enable = true;
        settings = {
          add_newline = false;
          format = "$username$hostname$directory$git_branch$git_status$cmd_duration$line_break$character";

          directory = {
            style = "bold #7aa2f7";
            truncation_length = 3;
            truncate_to_repo = true;
          };

          git_branch = {
            symbol = "git ";
            style = "bold #bb9af7";
          };

          git_status = {
            style = "bold #f7768e";
          };

          cmd_duration = {
            min_time = 2000;
            style = "bold #e0af68";
          };

          character = {
            success_symbol = "[❯](#7dcfff bold)";
            error_symbol = "[❯](#f7768e bold)";
          };
        };
      };

      # Akilli dizin yonlendirme araci
      zoxide = {
        enable = true;
      };

      # Hizli arama araci
      fzf = {
        fuzzyCompletion = true;
        keybindings = true;
      };

      # Kabuk kisayollari ve karsilama ekrani
      bash = {
        shellAliases = {
          ll = "eza -la --icons --group-directories-first";
          ls = "eza --icons --group-directories-first";
          la = "eza -a --icons --group-directories-first";
          tree = "eza --tree --icons";
          cat = "bat --paging=never --style=plain";
          grep = "rg";
          find = "fd";
        };

        interactiveShellInit = ''
          if [ -z "$FASTFETCH_SHOWN" ] && [ -n "$PS1" ]; then
            export FASTFETCH_SHOWN=1
            fastfetch
          fi
        '';
      };
    };
  };
}
