-- NAVER Shopping product search API ended on 2026-07-31.
-- Keep historical product rows, but prevent this source from being selected.
UPDATE retail_source
SET is_active = FALSE
WHERE source_key = 'naver_shopping';
