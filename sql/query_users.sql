SELECT u.user_id, u.username
FROM Follows f
JOIN Users u ON u.user_id = f.followed_id
WHERE f.follower_id = 1;

SELECT u.user_id, u.username
FROM Follows f
JOIN Users u ON u.user_id = f.follower_id
WHERE f.followed_id = 1;

SELECT TOP 10 u.user_id, u.username, COUNT(f.follower_id) AS takipci_sayisi
FROM Users u
LEFT JOIN Follows f ON f.followed_id = u.user_id
GROUP BY u.user_id, u.username
ORDER BY takipci_sayisi DESC;

SELECT u.user_id, u.username
FROM Follows f1
JOIN Follows f2 ON f1.followed_id = f2.followed_id
JOIN Users u ON u.user_id = f1.followed_id
WHERE f1.follower_id = 1 AND f2.follower_id = 2;

SELECT u.user_id, u.username, COUNT(*) AS kac_arkadasim_takip_ediyor
FROM Follows f1
JOIN Follows f2 ON f2.follower_id = f1.followed_id
JOIN Users u ON u.user_id = f2.followed_id
WHERE f1.follower_id = 1
  AND f2.followed_id <> 1
  AND NOT EXISTS (
      SELECT 1 FROM Follows f3
      WHERE f3.follower_id = 1 AND f3.followed_id = f2.followed_id
  )
GROUP BY u.user_id, u.username
ORDER BY kac_arkadasim_takip_ediyor DESC;

SELECT a.follower_id AS kisi1, a.followed_id AS kisi2
FROM Follows a
JOIN Follows b ON a.follower_id = b.followed_id
              AND a.followed_id = b.follower_id
WHERE a.follower_id < a.followed_id;

SELECT u.user_id, u.username
FROM Users u
WHERE NOT EXISTS (SELECT 1 FROM Follows f WHERE f.followed_id = u.user_id);

SELECT country, COUNT(*) AS kullanici_sayisi
FROM Users
GROUP BY country
ORDER BY kullanici_sayisi DESC;

SELECT follower_id, COUNT(*) AS takip_sayisi
FROM Follows
GROUP BY follower_id
HAVING COUNT(*) > (
    SELECT AVG(CAST(x AS FLOAT))
    FROM (SELECT COUNT(*) AS x FROM Follows GROUP BY follower_id) t
)
ORDER BY takip_sayisi DESC;

SELECT TOP 10 u.user_id, u.username, COUNT(c.comment_id) AS yorum_sayisi
FROM Users u
JOIN Comments c ON c.user_id = u.user_id
GROUP BY u.user_id, u.username
ORDER BY yorum_sayisi DESC;

SELECT TOP 10 s.song_id, s.title, COUNT(c.comment_id) AS yorum_sayisi
FROM songs s
JOIN Comments c ON c.song_id = s.song_id
GROUP BY s.song_id, s.title
ORDER BY yorum_sayisi DESC;