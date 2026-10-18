# Müzik Öneri Sistemi

**Kullanıcı Etkileşim Verisine Dayalı Sosyal Müzik Öneri ve Analitik Sistemi**

Veritabanı Sistemleri dersi (3. sınıf) dönem projesi. Kullanıcıların dinleme, beğeni, puan, atlama ve takip verilerini Microsoft SQL Server'da tutan bir müzik platformu veritabanı. Bu verilerle üç ayrı yöntemle şarkı önerisi üretiliyor: sosyal (takip edilenlerin dinledikleri), içerik tabanlı (sevilen türlere benzer şarkılar) ve işbirlikçi filtreleme (benzer zevkteki kullanıcılar). Üç öneri sonunda tek bir hibrit öneride birleşiyor. Ayrıca yıllık dinleme özeti ve trend analizi var.

- **Veritabanı:** Microsoft SQL Server Express (T-SQL), SSMS ile
- **Süre:** yaklaşık 5 hafta

> **Önemli:** Tablo ve sütun adları, veri tipleri, silme kuralları, nesne adları ve dosya sırası gibi ortak kurallar [`ortak_sema_sozlesmesi.md`](ortak_sema_sozlesmesi.md) dosyasında. Kod yazmadan önce bu belgeyi okuyun. Buradaki isimler gruba haber verilmeden değiştirilmez; belge ile kod çelişirse belge geçerlidir.

## Ekip

| Kişi | Rol | Sorumlu olduğu tablolar |
| --- | --- | --- |
| Şeyma (Kişi A) | Kullanıcılar ve sosyal modül: takipler, yorumlar, yıllık dinleme özeti, sosyal öneri | `users`, `follows`, `comments` |
| Beyza (Kişi B) | Katalog ve çalma listeleri: sanatçılar, albümler, türler, şarkılar, içerik tabanlı öneri, transaction | `genres`, `artists`, `albums`, `songs`, `playlists`, `playlist_songs` |
| Sema (Kişi C) | Etkileşimler ve analitik: dinlemeler, beğeniler, puanlar, atlamalar, işbirlikçi filtreleme, trend analizi | `listens`, `likes`, `ratings`, `skips` |

## Dosyalar ve sahipleri

Her dosyayı yalnızca sahibi değiştirir.

| Sahibi | Dosya | Durum |
| --- | --- | --- |
| Şeyma (A) | `sql/01_users.sql` | beklemede |
| Şeyma (A) | `sql/04_comments.sql` | beklemede |
| Şeyma (A) | `sql/05_advanced_a.sql` | beklemede |
| Şeyma (A) | `sql/queries/users_queries.sql` | beklemede |
| Beyza (B) | `sql/02_catalog.sql` | hazır |
| Beyza (B) | `sql/05_advanced_b.sql` | beklemede |
| Beyza (B) | `sql/queries/catalog_queries.sql` | beklemede |
| Sema (C) | `sql/03_interactions.sql` | beklemede |
| Sema (C) | `sql/05_advanced_c.sql` | beklemede |
| Sema (C) | `sql/queries/interactions_queries.sql` | beklemede |
| Ortak | `sql/06_recommendations.sql` | beklemede |

Diğer klasörler: `data/` (veri dosyaları), `rapor/` (proje raporu), `sunum/` (sunum dosyaları).

Bir dosyayı eklediğinizde bu tablodaki durumunu "hazır" yapın.

## Kurulum

1. SSMS'i açın, SQL Server'a bağlanın, **New Query** ile yeni bir sorgu penceresi açıp şunu çalıştırın (F5):

   ```sql
   CREATE DATABASE muzik_db COLLATE Turkish_CI_AS;
   ```

   Veritabanının adı ve sıralaması (`Turkish_CI_AS`) herkeste aynı olmalı.

2. `sql/` klasöründeki dosyaları **bu sırayla** açıp (File > Open > File) F5 ile çalıştırın. Sıra yabancı anahtar bağımlılıklarından gelir; bir dosya, kendinden önceki dosyaların tablolarını kullanır.

   1. `01_users.sql` (A): `users`, `follows`
   2. `02_catalog.sql` (B): `genres`, `artists`, `albums`, `songs`, `playlists`, `playlist_songs`
   3. `03_interactions.sql` (C): `listens`, `likes`, `ratings`, `skips`
   4. `04_comments.sql` (A): `comments`
   5. `05_advanced_a.sql`, `05_advanced_b.sql`, `05_advanced_c.sql`: view, trigger, procedure, index ve öneri fonksiyonları
   6. `06_recommendations.sql` (ortak): `get_recommendations`

3. Sorgular `sql/queries/` klasöründe; tablolar kurulduktan sonra istediğiniz sırayla çalıştırılabilir.

Başkasının dosyası henüz yüklenmediyse, sözleşmedeki örnekteki gibi kendi bilgisayarınızda `gecici_` ile başlayan bir test dosyası (ör. `gecici_users.sql`) kullanın. Bu dosyalar `.gitignore` sayesinde GitHub'a yüklenmez.

## Çalışma kuralları

- **Herkes yalnızca kendi dosyasını değiştirir.** Başkasının dosyasında bir sorun görürseniz ona haber verin.
- **Çalışmayan kod yüklenmez.** Yüklemeden önce dosyanızı SSMS'te temiz bir veritabanında baştan sona çalıştırıp test edin.
- **İşe başlamadan önce son hali çekin:** `git pull`
- **Commit mesajları kişi harfiyle başlar:** `[A]`, `[B]` veya `[C]`. Örnek: `[C] listens tablosuna örnek veri eklendi`
- **Geçici test dosyaları yüklenmez** (`gecici_*.sql`).
- **Dal (branch) kullanılmaz;** herkes doğrudan `main` dalına yükler.

## Ekip üyeleri için başlangıç rehberi

### 1. Bir kez yapılacaklar

1. **Git'i kurun:** <https://git-scm.com/download/win> adresinden indirip varsayılan seçeneklerle kurun.
2. **Daveti kabul edin:** Ekibe davet edildiğinizde e-postanıza bir davet gelir. Bağlantıya tıklayıp **Accept invitation** deyin (ya da <https://github.com/notifications> sayfasından kabul edin).
3. **Git'e kim olduğunuzu söyleyin.** Başlat menüsünden **Git Bash**'i (veya PowerShell'i) açıp kendi bilgilerinizle çalıştırın. E-posta, GitHub hesabınızdaki e-postayla aynı olmalı:

   ```bash
   git config --global user.name "Adınız Soyadınız"
   git config --global user.email "github-epostaniz@ornek.com"
   git config --global pull.rebase false
   ```

   Son satır, `git pull` sırasında iki kişinin değişikliğinin otomatik birleştirilmesini sağlar.

4. **Repoyu bilgisayarınıza indirin (clone).** Repo sayfasındaki yeşil **Code** düğmesinden HTTPS bağlantısını kopyalayın. Sonra hangi klasöre indirmek istiyorsanız oraya geçip çalıştırın:

   ```bash
   cd ~/Documents
   git clone <kopyaladiginiz-baglanti>
   cd muzik-oneri-sistemi
   ```

   İlk seferde tarayıcıda GitHub girişi açılır; giriş yapıp izin verin.

### 2. Her çalışmada

```bash
git pull                          # 1. Önce son hali çek
# 2. Dosyanızı düzenleyin, SSMS'te test edin
git status                        # 3. Neyin değiştiğine bakın
git add sql/03_interactions.sql   # 4. Yalnızca kendi dosyanızı ekleyin
git commit -m "[C] listens tablosu eklendi"   # 5. Kaydedin
git push                          # 6. GitHub'a gönderin
```

`git push` "rejected" hatası verirse, siz çalışırken başkası bir şey yüklemiş demektir. Önce `git pull`, sonra tekrar `git push` yapın. Herkes yalnızca kendi dosyasını değiştirdiği sürece çakışma (conflict) çıkmaz; çıkarsa grupta yazın.
