SELECT COUNT(*) AS yorum_sayisi FROM Comments;
SELECT COUNT(*) AS bos_icerik FROM Comments WHERE content IS NULL;
SELECT TOP 5 * FROM Comments;