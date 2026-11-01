set shell := ["bash", "-uc"]

# Varsayılan: Mevcut tüm görevleri listele
default:
    @just --list

# Kod formatlama (Alejandra & shfmt)
fmt:
    nix fmt
    @command -v shfmt >/dev/null 2>&1 && shfmt -w . || true

# Enyxma Anayasası Madde 6: Kod Hijyeni ve Statik Analiz
check:
    nix flake check
    deadnix --fail modules hosts
    statix check

# Enyxma Anayasası Madde 5: Kriptografik Saflık ve Sızıntı Taraması
scan-secrets:
    @echo "=== Hassas veri ve gizli anahtar taraması yapılıyor ==="
    @rg -i 'password|secret_key|token|api_key|private_key' -g '*.nix' . | rg -v 'mkOption|mkEnableOption|#.*secret|#.*token' || true
    @echo "=== İstenmeyen ve geçici dosya kontrolü yapılıyor ==="
    @find . -maxdepth 3 -type f \( -name '*.env*' -o -name '*.key' -o -name '*.pem' -o -name '*.bak' -o -name '*.qcow2' -o -name '*.iso' \) 2>/dev/null | grep -v '\.git/' || true

# Derleme ve geçici çıktıları temizle
clean:
    rm -rf result result-* .cache
