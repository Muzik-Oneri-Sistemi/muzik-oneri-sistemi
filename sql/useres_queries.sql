USE muzik_db;
GO

-- 1) Kullanıcı 1'in takip ettikleri
SELECT u.user_id, u.username
FROM follows f
JOIN users u ON u.user_id = f.followed_id
WHERE f.follower_id = 1;

-- 2) Kullanıcı 1'in takipçileri
SELECT u.user_id, u.username
FROM follows f
JOIN users u ON u.user_id = f.follower_id
WHERE f.followed_id = 1;

-- 3) En çok takipçisi olan 10 kullanıcı
SELECT TOP 10 u.user_id, u.username, COUNT(f.follower_id) AS takipci_sayisi
FROM users u
LEFT JOIN follows f ON f.followed_id = u.user_id
GROUP BY u.user_id, u.username
ORDER BY takipci_sayisi DESC;

-- 4) Kullanıcı 1 ve 2'nin ortak takip ettikleri
SELECT u.user_id, u.username
FROM follows f1
JOIN follows f2 ON f1.followed_id = f2.followed_id
JOIN users u ON u.user_id = f1.followed_id
WHERE f1.follower_id = 1 AND f2.follower_id = 2;

-- 5) Arkadaşımın arkadaşı önerisi (kullanıcı 1 için)
SELECT u.user_id, u.username, COUNT(*) AS kac_arkadasim_takip_ediyor
FROM follows f1
JOIN follows f2 ON f2.follower_id = f1.followed_id
JOIN users u ON u.user_id = f2.followed_id
WHERE f1.follower_id = 1
  AND f2.followed_id <> 1
  AND NOT EXISTS (
      SELECT 1 FROM follows f3
      WHERE f3.follower_id = 1 AND f3.followed_id = f2.followed_id
  )
GROUP BY u.user_id, u.username
ORDER BY kac_arkadasim_takip_ediyor DESC;

-- 6) Karşılıklı takip eden çiftler
SELECT a.follower_id AS kisi1, a.followed_id AS kisi2
FROM follows a
JOIN follows b ON a.follower_id = b.followed_id
              AND a.followed_id = b.follower_id
WHERE a.follower_id < a.followed_id;

-- 7) Hiç takipçisi olmayan kullanıcılar
SELECT u.user_id, u.username
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM follows f WHERE f.followed_id = u.user_id);

-- 8) Ülkeye göre kullanıcı sayısı
SELECT country, COUNT(*) AS kullanici_sayisi
FROM users
GROUP BY country
ORDER BY kullanici_sayisi DESC;

-- 9) ALT SORGULU: Ortalamadan fazla kişiyi takip edenler
SELECT follower_id, COUNT(*) AS takip_sayisi
FROM follows
GROUP BY follower_id
HAVING COUNT(*) > (
    SELECT AVG(CAST(x AS FLOAT))
    FROM (SELECT COUNT(*) AS x FROM follows GROUP BY follower_id) t
)
ORDER BY takip_sayisi DESC;

-- 10) En çok yorum yapan 10 kullanıcı
SELECT TOP 10 u.user_id, u.username, COUNT(c.comment_id) AS yorum_sayisi
FROM users u
JOIN comments c ON c.user_id = u.user_id
GROUP BY u.user_id, u.username
ORDER BY yorum_sayisi DESC;

-- 11) En çok yorum alan şarkılar
SELECT TOP 10 s.song_id, s.title, COUNT(c.comment_id) AS yorum_sayisi
FROM songs s
JOIN comments c ON c.song_id = s.song_id
GROUP BY s.song_id, s.title
ORDER BY yorum_sayisi DESC;