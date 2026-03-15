-- Add status and remaining_grams to beans table
ALTER TABLE public.beans
  ADD COLUMN IF NOT EXISTS status TEXT
    CHECK (status IN ('active', 'frozen', 'pantry', 'depleted'))
    DEFAULT 'active' NOT NULL,
  ADD COLUMN IF NOT EXISTS remaining_grams NUMERIC(6,1);
