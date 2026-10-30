# ENYXMA ÇEKİRDEK İŞLETİM SİSTEMİ ANAYASASI

STATÜ: YÜRÜRLÜKTE  
KAPSAM: enyxma/nixos ve tüm alt modülleri  
OTORİTE: Enyxma Architecture Council

---

## MADDE 1: KİMLİK VE EGEMENLİK

1. enyxma/nixos bir dotfile koleksiyonu, tema paketi veya masaüstü pirinç deposu değildir.
2. Bu depo; donanım soyutlamaları, çekirdek ve önyükleyici sertleştirme, disk yönetimi, sıfır entropi dosya sistemi, temel ağ politikaları, güvenlik kuralları ve sistem kimliklerini yöneten egemen Linux işletim sistemi omurgasıdır.
3. Kullanıcı arayüzleri, paneller ve pencere yöneticisi temaları bağımsız mikro depolar olarak geliştirilir. Çekirdek depo bu bileşenleri yalnızca harici modül olarak bağlar.

---

## MADDE 2: SIFIR GÜVEN VE PAKET SAFLIĞI

1. Depoda ve bu repo tarafından yapılandırılan sistemde npm ve npx kullanımı kesinlikle yasaktır.
2. Tüm Node.js paket yönetimi izole pnpm ile yürütülür.
3. Ağ üzerinden teyit edilmemiş harici yürütme betikleri çalıştırılamaz. Tüm bağımlılıklar Nix Store üzerinden kriptografik hash doğrulamasıyla temin edilir.
4. Nix motoru saf ve deterministik değerlendirme modunda çalıştırılır.

---

## MADDE 3: SIFIR ENTROPİ VE GEÇİCİ KÖK DİZİN

1. Kök dosya sistemi kalıcı durum barındıramaz. Bellek üzerinde tmpfs veya her açılışta boş bir snapshot kopyasına sıfırlanan Btrfs alt hacmi olmak zorundadır.
2. Kalıcılık yalnızca bilinçli olarak seçilmiş durumlar için /persist altında sağlanır.
3. /persist bağlama noktası initrd aşamasında neededForBoot bayrağı ile sisteme dahil edilir.

---

## MADDE 4: İSİM UZAYI VE MODÜLER YALITIM

1. Çekirdek repoya eklenen hiçbir özel ayar NixOS global ad alanını kirletemez.
2. Tüm sistem modülleri enyxma isim uzayı altında deklaratif seçenekler sunar.
3. Sabit kodlanmış kullanıcı adları, keyfi donanım yolları veya geçici test değişkenleri modüllere gömülemez. Modüller parametrik ve taşınabilir olmak zorundadır.

---

## MADDE 5: KRİPTOGRAFİK SAFLIK VE SIR YÖNETİMİ

1. Depoya hiçbir özel anahtar veya düz metin parola ve token eklenemez.
2. Sır yönetimi asimetrik şifreli dosyalar üzerinden yürütülür.
3. Depodaki tüm Git işlemleri yetkili GPG anahtarı ile imzalanmak zorundadır. İmzasız işlemler geçersiz kabul edilir.

---

## MADDE 6: KOD HİJYENİ VE ÖLÜ KOD YASAĞI

1. Yorum satırına alınmış eski kod blokları, terk edilmiş masaüstü artıkları veya tarihi çöplükler depoda barındırılamaz.
2. deadnix ve statix kontrollerinden geçmeyen hiçbir kod depoya kabul edilmez.
3. Tüm kodlar standart alejandra ve shfmt kurallarına tam uyumlu olmalıdır.
