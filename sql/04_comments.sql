USE muzik_db;
GO

CREATE TABLE comments (
    comment_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id    INT NOT NULL,
    song_id    INT NOT NULL,
    content    NVARCHAR(MAX) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_comments_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_comments_song FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE,
    CONSTRAINT CK_comments_notempty CHECK (LEN(LTRIM(RTRIM(content))) > 0)
);
GO

DECLARE @i INT = 1, @user INT, @song INT, @r INT;
WHILE @i <= 150
BEGIN
    SET @user = 1 + ABS(CHECKSUM(NEWID())) % 50;
    SET @song = (SELECT TOP 1 song_id FROM songs ORDER BY NEWID());
    SET @r    = 1 + ABS(CHECKSUM(NEWID())) % 8;

    INSERT INTO comments (user_id, song_id, content, created_at)
    VALUES (
        @user, @song,
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