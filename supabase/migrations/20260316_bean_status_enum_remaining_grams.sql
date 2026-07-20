-- Convert beans.status from a CHECK constraint to a real Postgres ENUM
-- (CLAUDE.md type-safety rule: migrate CHECK-based categoricals to ENUM
-- before expanding them), and add per-user remaining_grams inventory tracking.
--
-- Canonical status value set (unchanged from 20260222): the 5 values below.
-- remaining_grams lives on `beans` (per-user inventory), not `beans_catalog`
-- (the shared curated catalog) — it is how much of an individual user's bag
-- is left.

-- 1. Create the enum type with the canonical value set
CREATE TYPE public.bean_status AS ENUM
  ('active', 'frozen', 'defrosted', 'archived', 'depleted');

-- 2. Drop the column default before retyping (cannot cast with a default in place)
ALTER TABLE public.beans ALTER COLUMN status DROP DEFAULT;

-- 3. Drop the inline CHECK constraint created in 20260222
ALTER TABLE public.beans DROP CONSTRAINT IF EXISTS beans_status_check;

-- 4. Retype the column; existing values map 1:1 so the cast is lossless
ALTER TABLE public.beans
  ALTER COLUMN status TYPE public.bean_status
  USING status::public.bean_status;

-- 5. Restore the default (NOT NULL is preserved across the retype)
ALTER TABLE public.beans ALTER COLUMN status SET DEFAULT 'active';

-- 6. Add per-user remaining inventory (nullable = unknown)
ALTER TABLE public.beans
  ADD COLUMN IF NOT EXISTS remaining_grams NUMERIC(6,1);
