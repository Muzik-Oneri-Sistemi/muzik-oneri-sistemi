UPDATE Users
SET country = CASE user_id % 5
    WHEN 0 THEN N'Türkiye'
    WHEN 1 THEN N'Almanya'
    WHEN 2 THEN N'ABD'
    WHEN 3 THEN N'Fransa'
    ELSE N'Japonya'
END
WHERE country IS NULL;