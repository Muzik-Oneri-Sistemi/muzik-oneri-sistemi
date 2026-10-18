-- 02_catalog.sql  |  Kişi B: Katalog ve Çalma Listesi Modülü  |  SQL Server (T-SQL)
-- Çalıştırma sırası: 01_users.sql (veya test için gecici_users.sql) -> bu dosya

USE muzik_db;
GO

-- =========================================================
-- 1. TABLOLAR (sıra önemli: her tablo bir öncekine bağlı)
-- =========================================================

CREATE TABLE genres (
    genre_id INT IDENTITY(1,1) PRIMARY KEY,
    name     NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE artists (
    artist_id  INT IDENTITY(1,1) PRIMARY KEY,
    name       NVARCHAR(100) NOT NULL,
    country    NVARCHAR(50),
    debut_year INT CHECK (debut_year > 1900)
);

CREATE TABLE albums (
    album_id     INT IDENTITY(1,1) PRIMARY KEY,
    artist_id    INT NOT NULL,
    title        NVARCHAR(150) NOT NULL,
    release_year INT CHECK (release_year > 1900),
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE NO ACTION
);

CREATE TABLE songs (
    song_id      INT IDENTITY(1,1) PRIMARY KEY,
    album_id     INT NOT NULL,
    genre_id     INT NOT NULL,
    title        NVARCHAR(150) NOT NULL,
    duration_sec INT NOT NULL CHECK (duration_sec > 0),
    FOREIGN KEY (album_id) REFERENCES albums(album_id) ON DELETE NO ACTION,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE NO ACTION
);

CREATE TABLE playlists (
    playlist_id INT IDENTITY(1,1) PRIMARY KEY,
    owner_id    INT NOT NULL,
    name        NVARCHAR(100) NOT NULL,
    is_public   BIT NOT NULL DEFAULT 1,
    created_at  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE playlist_songs (
    playlist_id INT NOT NULL,
    song_id     INT NOT NULL,
    added_at    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    position    INT NOT NULL CHECK (position > 0),
    PRIMARY KEY (playlist_id, song_id),
    FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id) ON DELETE CASCADE,
    FOREIGN KEY (song_id)     REFERENCES songs(song_id)         ON DELETE CASCADE
);
GO

-- =========================================================
-- 2. ÖRNEK VERİ (5'er satır; süre ve yıllar yaklaşık)
--    Türkçe karakterli metinlerin başında N olmalı: N'Dünya'
-- =========================================================

-- Türler: sözleşmedeki sıra, numaralar sabit (1 Pop ... 6 Jazz)
INSERT INTO genres (name) VALUES
    (N'Pop'), (N'Rock'), (N'Rap'), (N'Arabesk'), (N'Elektronik'), (N'Jazz');

INSERT INTO artists (name, country, debut_year) VALUES
    (N'Tarkan',       N'Türkiye', 1992),
    (N'mor ve ötesi', N'Türkiye', 1995),
    (N'Ezhel',        N'Türkiye', 2012),
    (N'Sezen Aksu',   N'Türkiye', 1975),
    (N'Duman',        N'Türkiye', 1999);

INSERT INTO albums (artist_id, title, release_year) VALUES
    (1, N'Karma',                2001),
    (2, N'Dünya Yalan Söylüyor', 2004),
    (3, N'Müptezhel',            2017),
    (4, N'Firuze',               1982),
    (5, N'Belki Alışman Lazım',  2002);

INSERT INTO songs (album_id, genre_id, title, duration_sec) VALUES
    (1, 1, N'Kuzu Kuzu',      215),
    (2, 2, N'Bir Derdim Var', 260),
    (3, 3, N'Geceler',        200),
    (4, 1, N'Firuze',         240),
    (5, 2, N'Bu Akşam',       250);

INSERT INTO playlists (owner_id, name, is_public) VALUES
    (1, N'Yol Şarkıları', 1),
    (2, N'Gece Listesi',  0);

INSERT INTO playlist_songs (playlist_id, song_id, position) VALUES
    (1, 1, 1), (1, 2, 2), (1, 5, 3),
    (2, 3, 1), (2, 4, 2);
GO

-- =========================================================
-- 3. KONTROL (çalıştırıp sonuçlara bak)
-- =========================================================

-- Her şarkı, sanatçısı ve türüyle
SELECT s.title AS sarki, ar.name AS sanatci, g.name AS tur
FROM songs s
JOIN albums  al ON s.album_id   = al.album_id
JOIN artists ar ON al.artist_id = ar.artist_id
JOIN genres  g  ON s.genre_id   = g.genre_id;

-- Kısıt testleri: aşağıdakilerin HER BİRİ hata vermeli.
-- Denemek için satırın başındaki -- işaretini sil, sadece o satırı seçip F5 bas.
-- INSERT INTO songs (album_id, genre_id, title, duration_sec) VALUES (1, 1, N'Hatalı', 0);   -- süre 0
-- INSERT INTO songs (album_id, genre_id, title, duration_sec) VALUES (99, 1, N'Hatalı', 100); -- olmayan albüm
-- INSERT INTO genres (name) VALUES (N'Pop');                                                  -- aynı tür
-- INSERT INTO playlist_songs (playlist_id, song_id, position) VALUES (1, 1, 4);               -- aynı şarkı aynı listede
