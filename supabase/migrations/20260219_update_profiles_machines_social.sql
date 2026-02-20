-- ============================================================
-- 1. Create machines table (before altering profiles FK)
-- ============================================================
CREATE TABLE public.machines (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_by  UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  brand       TEXT NOT NULL,
  model       TEXT NOT NULL,
  notes       TEXT,
  is_public   BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.machines ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Machines viewable if public or owner"
  ON public.machines FOR SELECT
  USING (is_public = true OR auth.uid() = created_by);
CREATE POLICY "Users can insert own machines"
  ON public.machines FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Users can update own machines"
  ON public.machines FOR UPDATE USING (auth.uid() = created_by);

-- ============================================================
-- 2. Add new profile columns
-- ============================================================
ALTER TABLE public.profiles
  ADD COLUMN avatar_url         TEXT,
  ADD COLUMN active_bean_id     UUID REFERENCES public.beans(id) ON DELETE SET NULL,
  ADD COLUMN active_machine_id  UUID REFERENCES public.machines(id) ON DELETE SET NULL;

-- ============================================================
-- 3. Migrate equipment_setup data → machines table, then drop
-- ============================================================

-- Create test user's machine first (needs to exist for FK)
INSERT INTO public.machines (id, created_by, brand, model, notes, is_public)
VALUES (
  'e0000001-0000-0000-0000-000000000001',
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  'Decent', 'DE1 Pro', 'Stock settings with pressure profiling.', true
) ON CONFLICT DO NOTHING;

-- Point test user to their machine
UPDATE public.profiles
SET active_machine_id = 'e0000001-0000-0000-0000-000000000001'
WHERE id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';

-- Now drop the old column
ALTER TABLE public.profiles DROP COLUMN equipment_setup;

-- ============================================================
-- 4. Backfill test user's active_bean_id (Geisha Reserve)
-- ============================================================
UPDATE public.profiles
SET active_bean_id = 'b0000001-0000-0000-0000-000000000001'
WHERE id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';

-- ============================================================
-- 5. Make test content public for feed display
-- ============================================================
UPDATE public.shot_pulls SET is_public = true
WHERE id IN (
  'c0000001-0000-0000-0000-000000000001',
  'c0000002-0000-0000-0000-000000000002',
  'c0000003-0000-0000-0000-000000000003'
);

UPDATE public.beans SET is_public = true
WHERE id IN (
  'b0000001-0000-0000-0000-000000000001',
  'b0000002-0000-0000-0000-000000000002'
);

-- ============================================================
-- 6. Social tables (separate FK tables per content type)
-- ============================================================
CREATE TABLE public.shot_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  shot_id UUID REFERENCES public.shot_pulls(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, shot_id)
);

CREATE TABLE public.bean_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  bean_id UUID REFERENCES public.beans(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, bean_id)
);

CREATE TABLE public.machine_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  machine_id UUID REFERENCES public.machines(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, machine_id)
);

CREATE TABLE public.shot_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  shot_id UUID REFERENCES public.shot_pulls(id) ON DELETE CASCADE NOT NULL,
  body TEXT NOT NULL CHECK (char_length(body) > 0),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.bean_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  bean_id UUID REFERENCES public.beans(id) ON DELETE CASCADE NOT NULL,
  body TEXT NOT NULL CHECK (char_length(body) > 0),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.machine_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  machine_id UUID REFERENCES public.machines(id) ON DELETE CASCADE NOT NULL,
  body TEXT NOT NULL CHECK (char_length(body) > 0),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 7. RLS on all social tables
-- ============================================================
ALTER TABLE public.shot_likes     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bean_likes     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.machine_likes  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shot_comments  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bean_comments  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.machine_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Shot likes viewable by everyone"     ON public.shot_likes     FOR SELECT USING (true);
CREATE POLICY "Users can like shots"                ON public.shot_likes     FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unlike shots"              ON public.shot_likes     FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Bean likes viewable by everyone"     ON public.bean_likes     FOR SELECT USING (true);
CREATE POLICY "Users can like beans"                ON public.bean_likes     FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unlike beans"              ON public.bean_likes     FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Machine likes viewable by everyone"  ON public.machine_likes  FOR SELECT USING (true);
CREATE POLICY "Users can like machines"             ON public.machine_likes  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unlike machines"           ON public.machine_likes  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Shot comments viewable by everyone"     ON public.shot_comments     FOR SELECT USING (true);
CREATE POLICY "Users can comment on shots"             ON public.shot_comments     FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own shot comments"     ON public.shot_comments     FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Bean comments viewable by everyone"     ON public.bean_comments     FOR SELECT USING (true);
CREATE POLICY "Users can comment on beans"             ON public.bean_comments     FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own bean comments"     ON public.bean_comments     FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Machine comments viewable by everyone"  ON public.machine_comments  FOR SELECT USING (true);
CREATE POLICY "Users can comment on machines"          ON public.machine_comments  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own machine comments"  ON public.machine_comments  FOR DELETE USING (auth.uid() = user_id);

-- ============================================================
-- 8. Seed test likes
-- ============================================================
INSERT INTO public.shot_likes (user_id, shot_id) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'c0000001-0000-0000-0000-000000000001'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'c0000003-0000-0000-0000-000000000003')
ON CONFLICT DO NOTHING;

INSERT INTO public.machine_likes (user_id, machine_id) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'e0000001-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;
