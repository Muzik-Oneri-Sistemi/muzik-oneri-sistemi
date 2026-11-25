USE MuzikDB;
GO

DECLARE @i INT = 1;
WHILE @i <= 50
BEGIN
    INSERT INTO Users (username, email, password_hash, birth_date, country)
    VALUES (
        CONCAT('kullanici', @i),
        CONCAT('kullanici', @i, '@mail.com'),
        'sahte_hash_abc123',
        DATEADD(DAY, -(7000 + ABS(CHECKSUM(NEWID())) % 6000), CAST(GETDATE() AS DATE)),
        CHOOSE(1 + ABS(CHECKSUM(NEWID())) % 5, N'Türkiye', N'Almanya', N'ABD', N'Fransa', N'Japonya')
    );
    SET @i += 1;
END;
GO

-- Herkes rastgele 7 kişiyi takip etsin
INSERT INTO Follows (follower_id, followed_id)
SELECT u.user_id, t.user_id
FROM Users u
CROSS APPLY (
    SELECT TOP (7) x.user_id
    FROM Users x
    WHERE x.user_id <> u.user_id
    ORDER BY NEWID()
) t;
GO

-- 1, 2, 3 numaralılar popüler olsun (çift numaralı herkes onları takip eder)
INSERT INTO Follows (follower_id, followed_id)
SELECT u.user_id, p.user_id
FROM Users u
CROSS JOIN (SELECT user_id FROM Users WHERE user_id IN (1, 2, 3)) p
WHERE u.user_id <> p.user_id
  AND u.user_id % 2 = 0
  AND NOT EXISTS (
      SELECT 1 FROM Follows f
      WHERE f.follower_id = u.user_id AND f.followed_id = p.user_id
  );
GO

SELECT COUNT(*) AS kullanici_sayisi FROM Users;
SELECT COUNT(*) AS takip_sayisi FROM Follows;
SELECT TOP 5 * FROM Users;

-- En popüler kullanıcılar (1, 2, 3 başta olmalı)
SELECT TOP 5 followed_id, COUNT(*) AS takipci
FROM Follows
GROUP BY followed_id
ORDER BY takipci DESC;