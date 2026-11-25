USE MuzikDB;
GO

CREATE TABLE Users (
    user_id        INT IDENTITY(1,1) PRIMARY KEY,
    username       NVARCHAR(50)  NOT NULL UNIQUE,
    email          NVARCHAR(100) NOT NULL UNIQUE,
    password_hash  NVARCHAR(255) NOT NULL,
    birth_date     DATE NULL,
    country        NVARCHAR(50) NULL,
    created_at     DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    follower_count INT NOT NULL DEFAULT 0
);
GO

CREATE TABLE Follows (
    follower_id INT NOT NULL,
    followed_id INT NOT NULL,
    followed_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Follows PRIMARY KEY (follower_id, followed_id),
    CONSTRAINT FK_Follows_Follower FOREIGN KEY (follower_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Follows_Followed FOREIGN KEY (followed_id) REFERENCES Users(user_id),
    CONSTRAINT CK_Follows_NoSelf CHECK (follower_id <> followed_id)
);
GO