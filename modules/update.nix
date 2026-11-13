{pkgs, ...}: let
  enyxmaUpdate = pkgs.writeShellScriptBin "enyxma-update" ''
    set -euo pipefail

    BOLD="\033[1m"
    CYAN="\033[1;36m"
    GREEN="\033[1;32m"
    YELLOW="\033[1;33m"
    RED="\033[1;31m"
    RESET="\033[0m"

    find_flake_dir() {
      if [ -d "$HOME/enyxma/.git" ]; then
        echo "$HOME/enyxma"
      elif [ -d "/persist/enyxma/.git" ]; then
        echo "/persist/enyxma"
      elif [ -f "./flake.nix" ]; then
        pwd
      else
        echo "$HOME/enyxma"
      fi
    }

    FLAKE_DIR=$(find_flake_dir)
    TARGET_HOST=$(hostname 2>/dev/null || echo "test-enyxma")

    show_header() {
      echo -e "''${CYAN}✦ Enyxma OS Guncelleme Yoneticisi''${RESET}"
      echo -e "''${CYAN}─────────────────────────────────────────────────────''${RESET}"
    }

    ensure_repo_ownership() {
      if [ -d "$FLAKE_DIR" ]; then
        if [ -n "$(find "$FLAKE_DIR" ! -user "$(id -u)" -print -quit 2>/dev/null)" ]; then
          echo -e "''${YELLOW}Depo dosya sahipligi onariliyor...''${RESET}"
          sudo chown -R "$(id -u):$(id -g)" "$FLAKE_DIR"
        fi
      fi
    }

    check_updates() {
      show_header
      echo -e "''${BOLD}Hedef Dizin:''${RESET} $FLAKE_DIR"
      echo -e "''${BOLD}Sunucu:''${RESET} Codeberg origin/main kontrol ediliyor..."
      echo ""

      if [ ! -d "$FLAKE_DIR/.git" ]; then
        echo -e "''${YELLOW}Yerel git deposu bulunamadi.''${RESET}"
        return 0
      fi

      ensure_repo_ownership
      if ! git -C "$FLAKE_DIR" fetch origin main --quiet; then
        echo -e "''${RED}HATA: Uzak depo bilgisi alinamadi. Ag baglantinizi veya depo izinlerini kontrol edin.''${RESET}"
        exit 1
      fi
      BEHIND=$(git -C "$FLAKE_DIR" rev-list --count HEAD..origin/main 2>/dev/null || echo "0")

      if [ "$BEHIND" -gt 0 ]; then
        echo -e "''${GREEN}Yeni guncelleme mevcut!''${RESET} ''${BOLD}$BEHIND yeni commit''${RESET}"
        echo ""
        echo -e "''${YELLOW}Gelen Degisiklikler:''${RESET}"
        git -C "$FLAKE_DIR" log --oneline --color=always HEAD..origin/main
        echo ""
        echo -e "Guncellemeyi uygulamak icin: ''${CYAN}enyxma update''${RESET}"
        return 0
      else
        echo -e "''${GREEN}Sisteminiz en guncel Enyxma surumundedir.''${RESET}"
        return 0
      fi
    }

    do_update() {
      show_header
      echo -e "''${BOLD}Hedef Dizin:''${RESET} $FLAKE_DIR"
      echo -e "''${BOLD}Hedef Makine:''${RESET} $TARGET_HOST"
      echo ""

      OLD_SYSTEM=$(readlink -f /run/current-system 2>/dev/null || echo "")

      if [ -d "$FLAKE_DIR/.git" ]; then
        ensure_repo_ownership
        echo -e "Codeberg uzak deposu denetleniyor..."
        if ! git -C "$FLAKE_DIR" fetch origin main --quiet; then
          echo -e "''${RED}HATA: Uzak depo bilgisi alinamadi. Ag baglantinizi veya depo izinlerini kontrol edin.''${RESET}"
          exit 1
        fi
        BEHIND=$(git -C "$FLAKE_DIR" rev-list --count HEAD..origin/main 2>/dev/null || echo "0")

        if [ "$BEHIND" -gt 0 ]; then
          echo -e "''${YELLOW}Yeni degisiklikler tespit edildi:''${RESET}"
          git -C "$FLAKE_DIR" log --oneline --color=always HEAD..origin/main
          echo ""

          if [ -t 0 ]; then
            read -r -p "Guncellemeler cekilip sistem derlensin mi? [E/h]: " CONFIRM
            CONFIRM=''${CONFIRM:-E}
            if [[ ! "$CONFIRM" =~ ^[EeYy]$ ]]; then
              echo -e "''${YELLOW}Guncelleme iptal edildi.''${RESET}"
              exit 0
            fi
          fi

          echo -e "Depo origin/main ile esitleniyor..."
          git -C "$FLAKE_DIR" reset --hard origin/main --quiet
        else
          echo -e "''${GREEN}Depo zaten son commit ile guncel.''${RESET}"
        fi
      fi

      echo ""
      echo -e "''${CYAN}✦ Sistem derleniyor ve yeni nesle gecis yapiliyor...''${RESET}"

      if command -v nh >/dev/null 2>&1; then
        nh os switch "$FLAKE_DIR" --hostname "$TARGET_HOST"
      else
        sudo nixos-rebuild switch --flake "$FLAKE_DIR#$TARGET_HOST"
      fi

      NEW_SYSTEM=$(readlink -f /run/current-system 2>/dev/null || echo "")

      if [ -n "$OLD_SYSTEM" ] && [ -n "$NEW_SYSTEM" ] && [ "$OLD_SYSTEM" != "$NEW_SYSTEM" ]; then
        echo ""
        echo -e "''${CYAN}✦ Enyxma OS Paket ve Surum Degisiklikleri:''${RESET}"
        if command -v nvd >/dev/null 2>&1; then
          nvd --color=always diff "$OLD_SYSTEM" "$NEW_SYSTEM" || true
        fi

        if command -v hyprctl >/dev/null 2>&1 && [ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
          hyprctl reload >/dev/null 2>&1 || true
        fi

        if command -v notify-send >/dev/null 2>&1; then
          notify-send "✦ Enyxma OS Guncellendi" "Sistem basariyla yeni nesle yukseltildi." -t 4000 2>/dev/null || true
        fi
      else
        echo -e "''${GREEN}Sistem degisiklik olmadan basariyla yenilendi.''${RESET}"
      fi
    }

    do_rollback() {
      show_header
      echo -e "''${YELLOW}Geri alma islemi baslatiliyor...''${RESET}"
      sudo nixos-rebuild switch --rollback
      echo -e "''${GREEN}Bir onceki Enyxma nesline basariyla donuldu.''${RESET}"
    }

    ACTION=''${1:-update}

    case "$ACTION" in
      check|--check|-c)
        check_updates
        ;;
      switch|update|--update)
        do_update
        ;;
      rollback|--rollback|-r)
        do_rollback
        ;;
      *)
        show_header
        echo "Kullanim: enyxma update [check|switch|rollback]"
        echo ""
        echo "Komutlar:"
        echo "  check     Uzak depodaki yeni guncellemeleri denetler"
        echo "  switch    Guncellemeleri cekip sistemi yeni nesle yukseltir"
        echo "  rollback  Bir onceki calisan Enyxma nesline geri doner"
        ;;
    esac
  '';

  enyxmaCli = pkgs.writeShellScriptBin "enyxma" ''
    set -euo pipefail
    SUB=''${1:-help}
    shift || true

    case "$SUB" in
      update|up)
        exec enyxma-update "$@"
        ;;
      check)
        exec enyxma-update check "$@"
        ;;
      rollback)
        exec enyxma-update rollback "$@"
        ;;
      *)
        echo "Enyxma OS Yonetim Komutlari"
        echo ""
        echo "Kullanim: enyxma <komut>"
        echo ""
        echo "Komutlar:"
        echo "  update    Sistem guncellemelerini denetler ve uygular"
        echo "  check     Yeni surum ve commitleri kontrol eder"
        echo "  rollback  Onceki nesle geri doner"
        ;;
    esac
  '';
in {
  # Modern Nix Helper yapilandirmasi
  programs.nh = {
    enable = true;
  };

  # Egitici surum farki ve yardimci araclar
  environment.systemPackages = [
    pkgs.nvd
    pkgs.nix-output-monitor
    enyxmaUpdate
    enyxmaCli
  ];
}
