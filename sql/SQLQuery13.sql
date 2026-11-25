DECLARE @i INT = 1;
DECLARE @user INT, @song INT, @r INT;

WHILE @i <= 150
BEGIN
    SET @user = 1 + ABS(CHECKSUM(NEWID())) % 50;
    SET @song = (SELECT TOP 1 song_id FROM songs ORDER BY NEWID());
    SET @r    = 1 + ABS(CHECKSUM(NEWID())) % 8;

    INSERT INTO Comments (user_id, song_id, content, created_at)
    VALUES (
        @user,
        @song,
        CHOOSE(@r,
            N'Harika bir şarkı!', N'Bunu günde 10 kere dinliyorum.',
            N'Nakaratı çok güzel.', N'Eski günleri hatırlattı.',
            N'Sözleri çok anlamlı.', N'Bu sanatçıya bayıldım.',
            N'Yolculukta dinlemelik.', N'Bence biraz abartılmış.'),
        DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 365), SYSDATETIME())
    );
    SET @i += 1;
END;
GO