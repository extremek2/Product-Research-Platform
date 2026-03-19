INSERT INTO wholesale_source (name, country, crawler_type)
VALUES ('도매매', 'KR', 'API')
ON CONFLICT DO NOTHING;
