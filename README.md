# Enyxma OS Core

Sovereign, Immutable, and Zero-Entropy Operating System Core.

Enyxma OS; masaüstü görselleri ve dotfile kirliliğinden arındırılmış, saf, deklaratif ve egemen bir NixOS çekirdek dağıtım tabanıdır.

Sistem kullanıcı arayüzleri, paneller ve pencere yöneticisi entegrasyonları bağımsız mikro depolar halinde yönetilir. Bu depo yalnızca donanım, çekirdek, güvenlik, dosya sistemi ve sistem servislerini orkestre eder.

---

## Anayasa ve Temel Kurallar

Bu depoda çalışan her geliştirici ve sistem, [CONSTITUTION.md](./CONSTITUTION.md) içinde ilan edilen kurallara uymakla yükümlüdür:

1. Dotfile Değildir: Arayüz temaları bu depoda barındırılmaz.
2. Sıfır Güven: npm ve npx kullanımı yasaktır, yalnızca izole pnpm kullanılır.
3. Sıfır Entropi: Kök dosya sistemi geçicidir. Yalnızca /persist kalıcıdır.
4. Modüler İsim Uzayı: Tüm seçenekler enyxma ad alanı altındadır.
5. Kriptografik Güvenlik: Sırlar asimetrik şifrelenir, tüm işlemler GPG imzalıdır.
6. Sıfır Ölü Kod: deadnix ve statix ile denetlenmeyen kod repoya giremez.

---

## Geliştirme Ortamı

Ortama giriş:

```bash
direnv allow
# veya
nix develop
```

Komutlar:

```bash
just fmt     # Kod formatlama
just check   # Linter ve Flake doğrulama
just vm      # Test sanal makinesini başlat
```
