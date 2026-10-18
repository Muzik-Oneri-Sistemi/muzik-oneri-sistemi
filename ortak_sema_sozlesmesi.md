# Ortak Şema Sözleşmesi

Oct 14, 2026 · @beyza

Bu sayfadaki isimlere ve kurallara uyulduğu sürece A, B ve C birbirini beklemeden çalışabilir. Buradaki hiçbir isim, gruba haber verilmeden değiştirilmez.

## Genel kurallar

- Veritabanı: Microsoft SQL Server (2019 veya üstü, Express sürümü yeterli), araç: SSMS.
- Tablo adları küçük harf ve çoğul: `users`, `songs`.
- Sütun adları küçük harf, alt çizgili, Türkçe karaktersiz: `listened_at`.
- Tablo ve sütun adları kodun her yerinde küçük harfle yazılır. Veritabanı Türkçe sıralamayla (`Turkish_CI_AS`) kurulduğu için büyük `I` ile küçük `i` farklı harf sayılır: `USER_ID` yazılırsa `user_id` sütunu bulunamaz.
- Birincil anahtar `<tekil tablo>_id`, tip `INT IDENTITY(1,1)`. Ona bağlanan yabancı anahtar tip `INT`.
- Son ekler: zaman `_at` (`DATETIME2`, varsayılan `SYSDATETIME()`), tarih `_date` (`DATE`), yıl `_year` (`INT`), süre `_sec` (saniye, `INT`), evet/hayır `is_` (`BIT`, 1/0).
- Metin her zaman `NVARCHAR` ve değerler `N'...'` ile yazılır, yoksa Türkçe karakterler bozulur: `name` ve `username` `NVARCHAR(100)`, `title` `NVARCHAR(150)`, uzun metin `NVARCHAR(MAX)`.
- `TIMESTAMP` tipi SQL Server'da tarih değildir; kullanılmaz.

Herkes aynı adla ve Türkçe sıralamayla veritabanı kurar: `CREATE DATABASE muzik_db COLLATE Turkish_CI_AS;`

## Köprü anahtarlar

Modülleri birbirine bağlayan beş sütun bunlar. Adları ve tipleri herkes için sabittir.

| Anahtar | Tanımlayan | Kullananlar (yabancı anahtar olarak) |
| --- | --- | --- |
| `users.user_id` | A | A: `follows.follower_id`, `follows.followed_id`, `comments.user_id` · B: `playlists.owner_id` · C: `listens`, `likes`, `ratings`, `skips` içindeki `user_id` |
| `songs.song_id` | B | A: `comments.song_id` · B: `playlist_songs.song_id` · C: `listens`, `likes`, `ratings`, `skips` içindeki `song_id` |
| `genres.genre_id` | B | C: veri üretirken zevk grupları · B: içerik tabanlı öneri · A: yıllık özetteki favori tür |
| `playlists.playlist_id` | B | B: `playlist_songs.playlist_id` · A: profil özeti view'ı |
| `listens.listen_id` | C | C: `skips.listen_id` |

**Silme davranışı:** Kullanıcıya veya şarkıya bağlı kayıtlar onunla birlikte silinir; katalog ise bağlı kaydı varken silinemez.

| Yabancı anahtar | Kural |
| --- | --- |
| `follows.follower_id`, `comments.user_id`, `playlists.owner_id`, `listens.user_id`, `likes.user_id`, `ratings.user_id` | `ON DELETE CASCADE` |
| `comments`, `playlist_songs`, `listens`, `likes`, `ratings` içindeki `song_id` | `ON DELETE CASCADE` |
| `playlist_songs.playlist_id`, `skips.listen_id` | `ON DELETE CASCADE` |
| `follows.followed_id`, `skips.user_id`, `skips.song_id` | `ON DELETE NO ACTION` |
| `albums.artist_id`, `songs.album_id`, `songs.genre_id` | `ON DELETE NO ACTION` |

SQL Server aynı tabloya iki farklı yoldan silme zincirine izin vermez ("multiple cascade paths" hatası). Bu yüzden `skips` yalnızca `listens` üzerinden silinir; `follows.followed_id` ise `NO ACTION` olduğundan, takip edilen bir kullanıcı silinmeden önce Kişi A onun takip kayıtlarını siler (trigger veya silme procedure'ü ile).

## Tüm tablolar

Projede 13 tablo var. Her tablonun tek sahibi vardır; sütun eklemek serbest, buradaki sütunları silmek ya da yeniden adlandırmak yasak.

| Sahibi | Tablo | Sütunlar |
| --- | --- | --- |
| A | `users` | `user_id`, `username`, `email`, `password_hash`, `birth_date`, `country`, `created_at`, `follower_count` |
| A | `follows` | `follower_id`, `followed_id`, `followed_at` |
| A | `comments` | `comment_id`, `user_id`, `song_id`, `content`, `created_at` |
| B | `genres` | `genre_id`, `name` |
| B | `artists` | `artist_id`, `name`, `country`, `debut_year` |
| B | `albums` | `album_id`, `artist_id`, `title`, `release_year` |
| B | `songs` | `song_id`, `album_id`, `genre_id`, `title`, `duration_sec` |
| B | `playlists` | `playlist_id`, `owner_id`, `name`, `is_public`, `created_at` |
| B | `playlist_songs` | `playlist_id`, `song_id`, `added_at`, `position` |
| C | `listens` | `listen_id`, `user_id`, `song_id`, `listened_at`, `duration_listened_sec` |
| C | `likes` | `user_id`, `song_id`, `liked_at` |
| C | `ratings` | `user_id`, `song_id`, `rating`, `rated_at` |
| C | `skips` | `skip_id`, `listen_id`, `user_id`, `song_id`, `skipped_at`, `skipped_at_sec` |

`songs` tablosunda `release_date` yok; çıkış yılı yalnızca `albums.release_year` içinde tutulur.

## Başkasının tablosundan okunanlar

Herkes, sorgularında başka modüllerin şu sütunlarını kullanacak. Bu sütunlar sahibinin dosyasında mutlaka bu adla bulunmalı.

| Kim okuyor | Ne için | Okuduğu sütunlar |
| --- | --- | --- |
| A | Sosyal öneri, yıllık özet | `listens`: `user_id`, `song_id`, `listened_at`, `duration_listened_sec` · `songs`: `song_id`, `title`, `album_id`, `genre_id` · `albums`: `artist_id` · `artists`: `name` · `genres`: `name` |
| A | Profil özeti view'ı | `playlists`: `owner_id` |
| B | İçerik tabanlı öneri | `listens`: `user_id`, `song_id` |
| B | Açık liste sayısı sorgusu | `users`: `user_id`, `username` |
| C | İşbirlikçi filtreleme, trend | `songs`: `song_id`, `title`, `genre_id` · `users`: `user_id` |

## Ortak sabitler ve örnek veri

| Konu | Karar |
| --- | --- |
| Türler | 6 tür, bu sırayla eklenir: 1 Pop, 2 Rock, 3 Rap, 4 Arabesk, 5 Elektronik, 6 Jazz |
| Atlama eşiği | 30 saniyeden kısa dinleme = atlama |
| Puan aralığı | 1–5 |
| Dinleme tarihleri | 2026 yılı içinde; dinlemelerin en az %20'si son 14 güne düşer (trend analizi için) |
| Yıllık özet yılı | 2026 |
| Örnek veri numaraları | A: `user_id` 1–5 · B: `song_id` 1–5, `playlist_id` 1–2 (sahipleri kullanıcı 1 ve 2) · C: yalnızca kullanıcı 1–5 ve şarkı 1–5'i kullanır |

Başkasının tablosu henüz hazır değilse, sadece gereken sütunlarla geçici bir tablo kurup bu numaralarla doldur. Örneğin C için:

```sql
CREATE TABLE users (user_id INT IDENTITY(1,1) PRIMARY KEY);
GO
INSERT INTO users DEFAULT VALUES;
GO 5   -- yalnızca INSERT satırını 5 kez çalıştırır: 1–5

CREATE TABLE songs (song_id INT IDENTITY(1,1) PRIMARY KEY, title NVARCHAR(150), genre_id INT);
INSERT INTO songs (title, genre_id) VALUES
  (N'Test 1', 1), (N'Test 2', 2), (N'Test 3', 3), (N'Test 4', 1), (N'Test 5', 2);
```

Asıl tablolar gelince geçici olanlar silinir; sorgular değişmeden çalışır.

## Nesne adları ve öneri çıktısı

| Sahibi | Tür | Ad |
| --- | --- | --- |
| A | View | `user_profile_summary` |
| A | Trigger | `trg_follower_count` |
| A | Procedure | `yearly_wrapped @user_id, @year` |
| A | Öneri fonksiyonu | `rec_social(@user_id)` |
| A | Index | `idx_follows_followed` |
| B | Procedure | `add_song_to_playlist @playlist_id, @song_id` |
| B | Transaction (procedure) | `create_playlist_with_songs @owner_id, @name, @song_ids` (`@song_ids` virgüllü metin, `STRING_SPLIT` ile ayrılır) |
| B | Öneri fonksiyonu | `rec_content(@user_id)` |
| B | Index | `idx_songs_title` |
| C | Trigger | `trg_auto_skip` |
| C | View | `trending_songs` |
| C | Öneri fonksiyonu | `rec_collaborative(@user_id)` |
| C | Index | `idx_listens_user_time` |
| Ortak | Hibrit öneri | `get_recommendations(@user_id)` |

Üç öneri, tablo döndüren fonksiyon (inline table-valued function) olarak yazılır ve aynı üç sütunu döndürür; böylece 4. haftada `UNION ALL` ile hiç değişiklik yapmadan birleşir:

| Sütun | Tip | Anlamı |
| --- | --- | --- |
| `song_id` | `INT` | Önerilen şarkı |
| `score` | `DECIMAL(5,4)` | 0 ile 1 arası öneri gücü (ör. 0.8500) |
| `source` | `NVARCHAR(20)` | `N'sosyal'`, `N'icerik'` veya `N'isbirlikci'` |

Her fonksiyon kullanıcının daha önce dinlediği şarkıları dışarıda bırakır ve `TOP 20` ile en fazla 20 satır döndürür.

**Hibrit ağırlıklar:** `get_recommendations` her skoru yönteminin ağırlığıyla çarpar: sosyal 0,3 · içerik 0,3 · işbirlikçi 0,4. Aynı şarkı birden fazla yöntemden gelirse ağırlıklı skorları toplanır ve tek satırda gösterilir.

## Dosyalar ve çalıştırma sırası

Dosyalar numara sırasıyla çalıştırılır; bu sıra yabancı anahtar bağımlılıklarından gelir.

1. `01_users.sql` (A): `users`, `follows`
2. `02_catalog.sql` (B): `genres`, `artists`, `albums`, `songs`, `playlists`, `playlist_songs`
3. `03_interactions.sql` (C): `listens`, `likes`, `ratings`, `skips`
4. `04_comments.sql` (A): `comments`
5. `05_advanced_a.sql`, `05_advanced_b.sql`, `05_advanced_c.sql`: view, trigger, procedure, index ve öneri fonksiyonları
6. `06_recommendations.sql` (ortak): `get_recommendations`

Sorgular `queries/` klasöründe: `users_queries.sql`, `catalog_queries.sql`, `interactions_queries.sql`.

**Değişiklik kuralı:** Bu sayfadaki bir isim değişecekse önce grupta yazılır, iki kişi onaylar, sonra bu sayfa güncellenir. Sayfa ile kod çelişirse sayfa geçerlidir.
