DELETE FROM Users WHERE username = N'ali';
DBCC CHECKIDENT ('Users', RESEED, 0);