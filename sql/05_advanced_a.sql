USE muzik_db;
GO

-- Mevcut takipçi sayılarını hesapla
UPDATE users
SET follower_count = (SELECT COUNT(*) FROM follows WHERE followed_id = users.user_id);
GO

-- Trigger: follows'a ekleme/silme olunca follower_count güncellenir
CREATE OR ALTER TRIGGER trg_follower_count
ON follows
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE u
    SET u.follower_count = u.follower_count + d.degisim
    FROM users u
    JOIN (
        SELECT followed_id, SUM(delta) AS degisim
        FROM (
            SELECT followed_id,  1 AS delta FROM inserted
            UNION ALL
            SELECT followed_id, -1 AS delta FROM deleted
        ) z
        GROUP BY followed_id
    ) d ON d.followed_id = u.user_id;
END;
GO

-- View: kullanıcı profil özeti
CREATE OR ALTER VIEW user_profile_summary AS
SELECT
    u.user_id,
    u.username,
    u.follower_count                                                    AS takipci_sayisi,
    (SELECT COUNT(*) FROM follows   f WHERE f.follower_id = u.user_id) AS takip_sayisi,
    (SELECT COUNT(*) FROM playlists p WHERE p.owner_id    = u.user_id) AS playlist_sayisi,
    (SELECT COUNT(*) FROM comments  c WHERE c.user_id     = u.user_id) AS yorum_sayisi
FROM users u;
GO

-- Index: takipçi sorguları için
CREATE NONCLUSTERED INDEX idx_follows_followed ON follows (followed_id);
GO