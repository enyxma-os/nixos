# Enyxma OS Core

> **Language / Dil:** **English** | [Türkçe](./README.tr.md)

> **Sovereign, Declarative, and Zero-Entropy Operating System Core.**

Enyxma OS is a pure, declarative, and sovereign NixOS core distribution backbone free of desktop dotfile clutter.

System user interfaces, panels, and window manager integrations are managed as independent micro-repositories. The core repository (`enyxma/nixos`) orchestrates hardware abstractions, kernel and bootloader hardening, Btrfs subvolumes, a zero-entropy root filesystem, baseline network policies, and security rules.

---

## 🏛️ Architectural Principles — CONSTITUTION.md

All code and configuration in this repository are governed by [CONSTITUTION.md](./CONSTITUTION.md):

1. **Sovereign Distribution Base:** Not a dotfile or theme collection; an independent Linux operating system backbone.
2. **Zero-Trust:** `npm` and `npx` are strictly forbidden in the system and repository; all dependencies are sourced from the Nix Store with cryptographic hashes.
3. **Zero Entropy & Ephemeral Root:** The root filesystem holds no persistent state. Persistence is explicitly isolated under the `/persist` subvolume.
4. **Modular Namespace:** All system options are declaratively exposed under the `enyxma.*` namespace. Hardcoded user identities and arbitrary hardware paths are prohibited.
5. **Cryptographic Purity:** No plaintext secrets or tokens may be committed; all Git commits are signed with an authorized key.
6. **Code Hygiene:** Code that fails `deadnix`, `statix`, or `alejandra` checks is rejected.

---

## 🧩 Enyxma Lego Architecture

The core system composes external micro-repositories as modular Lego blocks via `flake.nix`:

* **Core Backbone:** `enyxma/nixos` — This repository
* **Window Manager:** `enyxma/hyprland` — Pure Lua Hyprland layer
* **Desktop Shell:** `enyxma/shell` — Quickshell-based dual-theme desktop shell & Settings 2.0
* **Cognitive Backbone:** `enyxma/thornhill` — Event-driven local system service

---

## ⚙️ Core Modules

| Module | Scope | Key Capabilities |
| :--- | :--- | :--- |
| `enyxma.core` | Base System | Flakes, zramSwap, automatic store optimization, configurable `timeZone` & `locale` with `mkDefault`, core CLI tools |
| `enyxma.security` | Zero-Trust | Sysctl kernel hardening, polkit, sudo, zero-trust `npm`/`npx` ban |
| `enyxma.network` | Network & Firewall | NetworkManager, TCP SYN cookies, strict firewall rules |
| `enyxma.audio` | Audio Stack | Low-latency PipeWire, WirePlumber, PulseAudio compatibility |
| `enyxma.persistence` | Native Impermanence | `/persist` Btrfs bind-mount directory and file management |
| `enyxma.desktop` | Graphics Stack | Hyprland, Wayland environment variables, XDG portals, fonts |

---

## 💾 Disk Architecture — Btrfs Subvolumes

Enyxma OS uses the following Btrfs subvolume hierarchy for zero entropy and state isolation:

```text
[Disk Partition]
├── ESP / FAT32    -> /boot    EFI System Partition
└── NIXOS / Btrfs
    ├── @root      -> /        Ephemeral root, wiped on every boot
    ├── @nix       -> /nix     Nix Store - zstd, noatime
    ├── @persist   -> /persist Persistent state - zstd, noatime, neededForBoot
    └── @home      -> /home    User profiles - zstd, noatime
```

---

## 🚀 Installation & Deployment

### 0. One-Command Starter Template

Initialize a clean starter configuration on any NixOS machine:

```bash
mkdir my-enyxma && cd my-enyxma
nix flake init -t git+https://codeberg.org/enyxma/nixos
```

### 1. Target Machine Configuration

Generate the hardware profile on the target system and wire it into `hosts/<hostname>.nix`:

```bash
# Generate hardware profile:
sudo nixos-generate-config --root /mnt
```

Enable the desired modules declaratively in `hosts/<hostname>.nix`:

```nix
{ ... }:
{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "my-machine";

  enyxma = {
    core = {
      enable = true;
      timeZone = "UTC";
      locale = "en_US.UTF-8";
    };
    security.enable = true;
    network.enable = true;
    audio.enable = true;
    persistence.enable = true;
    desktop.enable = true;
  };
}
```

### 2. Quick Desktop Integration

Attach `enyxma/hyprland` and `enyxma/shell` declaratively to your system or Home Manager layer:

```nix
enyxma.desktop.hyprland.enable = true;
enyxma.shell.enable = true;
```

### 3. Build and Activate

```bash
# Activate configuration:
sudo nixos-rebuild switch --flake .#my-machine
```

---

## 🛠️ Task Runner — Justfile

Implicit background hooks like `direnv` are not used. All tasks run deterministically via `just`:

```bash
just fmt          # Format code with Alejandra and shfmt
just check        # Run Flake, deadnix, and statix constitutional checks
just scan-secrets # Scan repository for leaked keys, tokens, or temp files
just clean        # Clean build artifacts and temporary files
```

---

## 📜 License

GPL-3.0-or-later — See [LICENSE](./LICENSE) for details. Copyright © 2026 Enyxma OS Contributors.
