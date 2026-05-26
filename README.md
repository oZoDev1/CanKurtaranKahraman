# CanKurtaranKahraman

CanKurtaranKahraman, interaktif bir bilgi yarışması (Quiz) mobil uygulamasıdır. Kullanıcıların kendilerini test edebilecekleri, çoktan seçmeli, doğru-yanlış ve sıralama gibi farklı soru tiplerini barındıran modern bir yapıya sahiptir.

## 🚀 Kullanılan Teknolojiler

Proje, güncel mobil uygulama geliştirme standartlarına uygun olarak inşa edilmiştir:

*   **[Flutter](https://flutter.dev/) & Dart:** Çapraz platform (Cross-platform) mobil uygulama geliştirme altyapısı. Uygulama hem iOS hem de Android için tek bir kod tabanından derlenmektedir.
*   **[Riverpod](https://riverpod.dev/):** Güvenli, reaktif ve performanslı State Management (Durum Yönetimi) çözümü. Bağımlılıkların dışarıdan enjekte edilmesini kolaylaştırır ve esnek bir yapı sunar.
*   **[SQLite (sqflite)](https://pub.dev/packages/sqflite):** Yerel (Local) veritabanı çözümü. Soruların, cevapların ve kullanıcı ilerlemesinin cihaz üzerinde çevrimdışı (offline) olarak güvenli ve hızlı bir şekilde saklanması için kullanılmıştır.
*   **[Equatable](https://pub.dev/packages/equatable):** Model sınıflarında nesne karşılaştırmalarını (Value Equality) kolaylaştırıp, Riverpod ile entegre çalışarak gereksiz ekran yenilemelerini (rebuild) önler.
*   **[Confetti](https://pub.dev/packages/confetti):** Kullanıcı deneyimini (UX) zenginleştirmek ve oyunlaştırma (gamification) hissiyatını artırmak amacıyla başarı durumlarında gösterilen animasyon kütüphanesidir.

## 🏗️ Mimari Yaklaşım

Projede **Katmanlı Mimari (Layered / Clean Architecture)** prensipleri benimsenmiş olup, "Separation of Concerns" (Sorumlulukların Ayrılığı) kuralına titizlikle uyulmuştur. Bu sayede kod tabanı temiz, test edilebilir, bakımı kolay ve yeni özellikler eklemeye son derece müsaittir. Bellek şişkinliğinden (memory bloat) kaçınılmış, modüler yapı tercih edilmiştir.

Projenin `lib/` dizin yapısı 3 ana katmandan oluşmaktadır:

*   **`core/` (Çekirdek Katmanı):**
    *   Uygulamanın genelinde kullanılan tasarım sabitleri (renk paletleri, temalar), yardımcı fonksiyonlar (utils) ve merkezi konfigürasyon dosyalarını barındırır.
*   **`data/` (Veri Katmanı):**
    *   **Models:** Veri modelleri (Soru yapısı, seçenekler, sıralama öğeleri vb.) burada tanımlanır.
    *   **Database:** `database_helper.dart` üzerinden SQLite bağlantısı sağlanır ve `seed_data.dart` ile uygulamanın ilk açılışındaki varsayılan veriler ayağa kaldırılır. Veri saklama ve çekme işlemlerinin (CRUD) tamamı buradadır.
*   **`presentation/` (Sunum Katmanı):**
    *   Kullanıcı arayüzünün ve görselliğin bulunduğu yerdir. State manager (Riverpod) aracılığıyla veriyi UI'a bağlar.
    *   **Screens:** Sayfalar (`home_screen.dart`, `quiz_screen.dart` vb.).
    *   **Widgets:** Modüler, yeniden kullanılabilir UI bileşenleri (Soru tipine özel widget'lar, ilerleme çubukları, animasyonlar).
    *   **Providers:** Uygulamanın iş mantığının (Business Logic) ve State'in yönetildiği sınıflardır. Riverpod ile UI katmanını doğrudan dinleyebilir yapıdadır.

## ✨ Öne Çıkan Özellikler

*   Farklı soru tipleri için dinamik Widget yönetimi (Test, Doğru/Yanlış, Sıralama).
*   Riverpod ile izole edilmiş ve bellek kullanımına optimize edilmiş state yönetimi.
*   Local DB (SQLite) sayesinde internet bağlantısı gerektirmeyen kesintisiz deneyim.
*   SOLID prensiplerine, modern UI/UX tasarım ve Clean Architecture standartlarına uygun geliştirme.

---
*Geliştirici:* [oZoDev1](https://github.com/oZoDev1)
