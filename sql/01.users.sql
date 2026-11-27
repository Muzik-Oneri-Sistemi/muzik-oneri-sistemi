USE muzik_db;
GO

CREATE TABLE users (
    user_id        INT IDENTITY(1,1) PRIMARY KEY,
    username       NVARCHAR(100) NOT NULL UNIQUE,
    email          NVARCHAR(100) NOT NULL UNIQUE,
    password_hash  NVARCHAR(255) NOT NULL,
    birth_date     DATE NULL,
    country        NVARCHAR(50) NULL,
    created_at     DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    follower_count INT NOT NULL DEFAULT 0
);
GO

CREATE TABLE follows (
    follower_id INT NOT NULL,
    followed_id INT NOT NULL,
    followed_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_follows PRIMARY KEY (follower_id, followed_id),
    CONSTRAINT FK_follows_follower FOREIGN KEY (follower_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_follows_followed FOREIGN KEY (followed_id) REFERENCES users(user_id) ON DELETE NO ACTION,
    CONSTRAINT CK_follows_noself CHECK (follower_id <> followed_id)
);
GO

-- 50 örnek kullanıcı
DECLARE @i INT = 1, @r INT;
WHILE @i <= 50
BEGIN
    SET @r = 1 + ABS(CHECKSUM(NEWID())) % 5;
    INSERT INTO users (username, email, password_hash, birth_date, country)
    VALUES (
        CONCAT(N'kullanici', @i),
        CONCAT(N'kullanici', @i, N'@mail.com'),
        N'sahte_hash_abc123',
        DATEADD(DAY, -(7000 + ABS(CHECKSUM(NEWID())) % 6000), CAST(GETDATE() AS DATE)),
        CHOOSE(@r, N'Türkiye', N'Almanya', N'ABD', N'Fransa', N'Japonya')
    );
    SET @i += 1;
END;
GO

-- Herkes rastgele 7 kişiyi takip etsin
INSERT INTO follows (follower_id, followed_id)
SELECT u.user_id, t.user_id
FROM users u
CROSS APPLY (
    SELECT TOP (7) x.user_id
    FROM users x
    WHERE x.user_id <> u.user_id
    ORDER BY NEWID()
) t;
GO

-- 1, 2, 3 numaralılar popüler olsun
INSERT INTO follows (follower_id, followed_id)
SELECT u.user_id, p.user_id
FROM users u
CROSS JOIN (SELECT user_id FROM users WHERE user_id IN (1, 2, 3)) p
WHERE u.user_id <> p.user_id
  AND u.user_id % 2 = 0
  AND NOT EXISTS (
      SELECT 1 FROM follows f
      WHERE f.follower_id = u.user_id AND f.followed_id = p.user_id
  );
GO