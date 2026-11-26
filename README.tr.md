# Enyxma OS Core

> **Dil / Language:** [English](./README.md) | **Türkçe**

> **Sovereign, Declarative, and Zero-Entropy Operating System Core.**

Enyxma OS; masaüstü dotfile kirliliğinden arındırılmış, saf, deklaratif ve egemen bir NixOS çekirdek dağıtım omurgasıdır.

Sistem kullanıcı arayüzleri, paneller ve pencere yöneticisi entegrasyonları bağımsız mikro depolar halinde yönetilir. Çekirdek depo olan `enyxma/nixos`; donanım soyutlamalarını, çekirdek ve önyükleyici sertleştirmesini, Btrfs alt hacimlerini, sıfır entropi dosya sistemini, temel ağ politikalarını ve güvenlik kurallarını orkestre eder.

---

## 🏛️ Mimari İlkeler — CONSTITUTION.md

Bu depodaki tüm kod ve yapılandırmalar [CONSTITUTION.md](./CONSTITUTION.md) hükümlerine tabidir:

1. **Egemen Dağıtım Tabanı:** Bir dotfile veya tema koleksiyonu değildir; bağımsız bir Linux işletim sistemi omurgasıdır.
2. **Sıfır Güven — Zero-Trust:** Sistemde ve depoda `npm` ve `npx` kullanımı kesinlikle yasaktır; tüm bağımlılıklar Nix Store ve kriptografik hash ile temin edilir.
3. **Sıfır Entropi ve Geçici Kök:** Kök dosya sistemi kalıcı durum barındırmaz. Kalıcılık yalnızca `/persist` alt hacminde sağlanır.
4. **Modüler İsim Uzayı:** Tüm sistem seçenekleri `enyxma.*` isim uzayı altında deklaratif olarak sunulur. Sabit kodlanmış kimlikler ve keyfi donanım yolları barındırılamaz.
5. **Kriptografik Saflık:** Düz metin sır veya token eklenemez, tüm Git işlemleri yetkili anahtar ile imzalanır.
6. **Kod Hijyeni:** `deadnix`, `statix` ve `alejandra` denetimlerinden geçmeyen kod depoya kabul edilmez.

---

## 🧩 Enyxma Lego Mimarisi

Çekirdek sistem, harici mikro arayüz repolarını `flake.nix` üzerinden modüler Lego parçaları olarak sisteme bağlar:

* **Çekirdek Omurga:** `enyxma/nixos` — Bu depo
* **Pencere Yöneticisi:** `enyxma/hyprland` — Saf Lua Hyprland katmanı
* **Masaüstü Kabuğu:** `enyxma/shell` — Quickshell tabanlı çift temalı masaüstü kabuğu ve Ayarlar 2.0
* **Bilişsel Omurga:** `enyxma/thornhill` — Olay tabanlı yerel sistem servisi

---

## ⚙️ Çekirdek Modüller

| Modül | Tanım | Temel Yetenekler |
| :--- | :--- | :--- |
| `enyxma.core` | Taban Sistem | Flakes, zramSwap, otomatik store optimizasyonu, temel CLI araçları |
| `enyxma.security` | Sıfır Güven | Sysctl çekirdek sertleştirme, polkit, sudo, zero-trust npm/npx yasağı |
| `enyxma.network` | Ağ ve Güvenlik Duvarı | NetworkManager, TCP SYN cookies, sıkı firewall kuralları |
| `enyxma.audio` | Ses Yığını | Düşük gecikmeli PipeWire, WirePlumber, PulseAudio uyumluluğu |
| `enyxma.persistence` | Yerel Impermanence | `/persist` Btrfs bind-mount dizin ve dosya yönetimi |
| `enyxma.desktop` | Grafik Altyapısı | Hyprland, Wayland ortam değişkenleri, XDG portalları, fontlar |

---

## 💾 Disk Mimarisi — Btrfs Alt Hacimleri

Enyxma OS, sıfır entropi ve veri yalıtımı için aşağıdaki Btrfs alt hacim hiyerarşisini kullanır:

```text
[Disk Bölümü]
├── ESP / FAT32    -> /boot    EFI Sistem Bölümü
└── NIXOS / Btrfs
    ├── @root      -> /        Geçici kök, her açılışta sıfırlanır
    ├── @nix       -> /nix     Nix Store - zstd, noatime
    ├── @persist   -> /persist Kalıcı veriler - zstd, noatime, neededForBoot
    └── @home      -> /home    Kullanıcı profilleri - zstd, noatime
```

---

## 🚀 Kurulum ve Dağıtım

### 0. Tek Komutla Başlangıç Şablonu

Mevcut bir NixOS makinesinde temiz başlangıç iskeleti oluşturmak için:

```bash
mkdir my-enyxma && cd my-enyxma
nix flake init -t git+https://codeberg.org/enyxma/nixos
```

### 1. Hedef Makine Yapılandırması
Hedef sistemde donanım yapılandırması üretilir ve `hosts/<makine-adi>.nix` içine bağlanır:

```bash
# Donanım profilini oluşturun:
sudo nixos-generate-config --root /mnt
```

`hosts/<makine-adi>.nix` dosyası ilgili modülleri deklaratif olarak etkinleştirir:

```nix
{ modulesPath, ... }:
{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "makine-adi";

  enyxma = {
    core.enable = true;
    security.enable = true;
    network.enable = true;
    audio.enable = true;
    persistence.enable = true;
    desktop.enable = true;
  };
}
```

### 2. Hızlı Masaüstü Entegrasyonu

`enyxma/hyprland` ve `enyxma/shell` modüllerini sisteme veya Home Manager katmanına deklaratif olarak eklemek için:

```nix
enyxma.desktop.hyprland.enable = true;
enyxma.shell.enable = true;
```

### 3. Sistemi Derleme ve Aktif Etme

```bash
# Yeni yapılandırmayı devreye alma:
sudo nixos-rebuild switch --flake .#<makine-adi>
```

---

## 🛠️ Görev Yöneticisi — Justfile

Sistemde gizli ve örtük arka plan araçları kullanılmaz. Tüm işlemler deterministik `just` hedefleriyle yürütülür:

```bash
just fmt          # Kodu standart Alejandra ve shfmt kurallarına göre biçimlendir
just check        # Flake, deadnix ve statix anayasa denetimlerini çalıştır
just scan-secrets # Depoda sızdırılmış anahtar, token veya geçici dosya taraması yap
just clean        # Derleme çıktılarını ve geçici dosyaları temizle
```

---

## 📜 Lisans

GPL-3.0-or-later — Ayrıntılar için [LICENSE](./LICENSE) dosyasına bakın. Telif Hakkı © 2026 Enyxma OS Contributors.
