-- ============================================================
-- Introduce beans_catalog and machines_catalog.
-- Convert beans + machines tables to user inventory.
--
-- beans_catalog: curated public catalog of known coffees
-- machines_catalog: curated public catalog of known machines
-- beans: user's personal bag inventory (FK → beans_catalog)
-- machines: user's personal machine inventory (FK → machines_catalog)
-- ============================================================

-- ============================================================
-- 1. Create catalog tables
-- ============================================================

CREATE TABLE public.beans_catalog (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT NOT NULL,
  roaster     TEXT NOT NULL,
  roast_level TEXT CHECK (roast_level IN ('light', 'medium', 'dark')),
  description TEXT,
  image_url   TEXT,
  is_verified BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.machines_catalog (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  brand       TEXT NOT NULL,
  model       TEXT NOT NULL,
  description TEXT,
  image_url   TEXT,
  is_verified BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.beans_catalog    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.machines_catalog ENABLE ROW LEVEL SECURITY;

-- Catalog is read-only for all authenticated users; writes are admin-only (service role)
CREATE POLICY "Beans catalog readable by all"
  ON public.beans_catalog FOR SELECT USING (true);
CREATE POLICY "Machines catalog readable by all"
  ON public.machines_catalog FOR SELECT USING (true);

-- ============================================================
-- 2. Seed catalog from existing data (stable UUIDs for backfill)
-- ============================================================

INSERT INTO public.beans_catalog (id, name, roaster, roast_level, description, is_verified) VALUES
  ('bc000001-0000-0000-0000-000000000001', 'Hologram',             'Counter Culture', 'medium', 'Chocolate, caramel, silky body',               true),
  ('bc000001-0000-0000-0000-000000000002', 'Monarch',              'Onyx Coffee Lab', 'medium', 'Rich, sweet, dark chocolate',                   true),
  ('bc000001-0000-0000-0000-000000000003', 'Tailor Made Espresso', 'George Howell',   'light',  'Bright citrus, floral notes',                   true),
  ('bc000001-0000-0000-0000-000000000004', 'Black Cat Classic',    'Intelligentsia',  'dark',   'Smoky, bold, nutty finish',                     true),
  ('bc000001-0000-0000-0000-000000000005', 'Hair Bender',          'Stumptown',       'medium', 'Citrus, dark chocolate, complex',               true),
  ('bc000001-0000-0000-0000-000000000006', 'Geisha Reserve',       'Onyx Coffee Lab', 'light',  'Floral jasmine, stone fruit. Competition lot.', true),
  ('bc000001-0000-0000-0000-000000000007', 'Nightcap Blend',       'Counter Culture', 'dark',   'Chocolatey, full body. Good for milk drinks.',  true)
ON CONFLICT DO NOTHING;

INSERT INTO public.machines_catalog (id, brand, model, is_verified) VALUES
  ('cafe0001-0000-0000-0000-000000000001', 'Decent', 'DE1 Pro', true)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 3. Alter beans → user inventory
-- ============================================================

ALTER TABLE public.beans
  ADD COLUMN catalog_id UUID REFERENCES public.beans_catalog(id) ON DELETE SET NULL,
  ADD COLUMN status     TEXT NOT NULL DEFAULT 'active'
                          CHECK (status IN ('active', 'frozen', 'defrosted', 'archived', 'depleted'));

-- Backfill catalog_id by matching name + roaster
UPDATE public.beans b
SET catalog_id = bc.id
FROM public.beans_catalog bc
WHERE LOWER(b.name) = LOWER(bc.name)
  AND LOWER(b.roaster) = LOWER(bc.roaster);

-- Remove the 5 anonymous public sample rows — they now live in beans_catalog only
DELETE FROM public.beans WHERE created_by IS NULL;

-- Drop catalog-level columns; keep roast_date, notes (user personal), is_public
ALTER TABLE public.beans
  DROP COLUMN name,
  DROP COLUMN roaster,
  DROP COLUMN roast_level,
  DROP COLUMN image_url;

-- Allow users to remove beans from their inventory
CREATE POLICY "Users can delete own beans"
  ON public.beans FOR DELETE USING (auth.uid() = created_by);

-- ============================================================
-- 4. Alter machines → user inventory
-- ============================================================

ALTER TABLE public.machines
  ADD COLUMN catalog_id UUID REFERENCES public.machines_catalog(id) ON DELETE SET NULL;

-- Backfill catalog_id by matching brand + model
UPDATE public.machines m
SET catalog_id = mc.id
FROM public.machines_catalog mc
WHERE LOWER(m.brand) = LOWER(mc.brand)
  AND LOWER(m.model) = LOWER(mc.model);

-- Drop catalog-level columns; keep notes (user personal), is_public
ALTER TABLE public.machines
  DROP COLUMN brand,
  DROP COLUMN model,
  DROP COLUMN image_url;

-- Allow users to remove machines from their inventory
CREATE POLICY "Users can delete own machines"
  ON public.machines FOR DELETE USING (auth.uid() = created_by);
