ALTER TABLE wholesale_product
    ADD COLUMN IF NOT EXISTS source_product_id TEXT;

CREATE INDEX IF NOT EXISTS idx_wholesale_source_product_id
    ON wholesale_product(source_id, source_product_id);
