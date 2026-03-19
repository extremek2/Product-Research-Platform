ALTER TABLE wholesale_product ADD COLUMN IF NOT EXISTS search_keyword TEXT;
ALTER TABLE retail_product    ADD COLUMN IF NOT EXISTS search_keyword TEXT;
ALTER TABLE source_product    ADD COLUMN IF NOT EXISTS search_keyword TEXT;

CREATE INDEX IF NOT EXISTS idx_wholesale_search_keyword ON wholesale_product(search_keyword);
CREATE INDEX IF NOT EXISTS idx_retail_search_keyword    ON retail_product(search_keyword);
