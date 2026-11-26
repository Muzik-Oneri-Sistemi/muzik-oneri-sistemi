USE muzik_db;
GO

-- 1) Mevcut takipçi sayılarını Follows tablosuna göre hesapla
UPDATE Users
SET follower_count = (SELECT COUNT(*) FROM Follows WHERE followed_id = Users.user_id);
GO

-- 2) Trigger: Follows'a ekleme/silme olunca follower_count otomatik güncellenir
CREATE OR ALTER TRIGGER trg_Follows_FollowerCount
ON Follows
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE u
    SET u.follower_count = u.follower_count + d.degisim
    FROM Users u
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