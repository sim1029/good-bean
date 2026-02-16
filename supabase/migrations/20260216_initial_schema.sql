-- 1. Create Tables
-- Profiles: Extends the built-in Supabase Auth users
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  equipment_setup JSONB, -- Store machine/grinder info
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Beans: The catalog of coffee
CREATE TABLE IF NOT EXISTS public.beans (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_by UUID REFERENCES public.profiles(id),
  roaster TEXT NOT NULL,
  name TEXT NOT NULL,
  roast_level TEXT CHECK (roast_level IN ('light', 'medium', 'dark')),
  roast_date DATE,
  is_public BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Shot Pulls: The granular espresso data
CREATE TABLE IF NOT EXISTS public.shot_pulls (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) NOT NULL,
  bean_id UUID REFERENCES public.beans(id) ON DELETE CASCADE,
  dose_grams NUMERIC(4,2) NOT NULL,
  yield_grams NUMERIC(4,2) NOT NULL,
  time_seconds INTEGER NOT NULL,
  temp_c INTEGER,
  pressure_profile JSONB, -- For those high-end machines
  rating INTEGER CHECK (rating >= 1 AND rating <= 10),
  is_public BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable Row Level Security (Manual)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.beans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shot_pulls ENABLE ROW LEVEL SECURITY;

-- 3. Define Policies

-- Profiles: Users can view all profiles (for social), but only edit their own.
CREATE POLICY "Public profiles are viewable by everyone" 
  ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" 
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Beans: 
-- 1. Anyone can see public beans.
-- 2. Users can see their own private beans.
-- 3. Only the creator can update/delete.
CREATE POLICY "Viewable beans" 
  ON public.beans FOR SELECT 
  USING (is_public = true OR auth.uid() = created_by);
CREATE POLICY "Users can insert their own beans" 
  ON public.beans FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Users can update own beans" 
  ON public.beans FOR UPDATE USING (auth.uid() = created_by);

-- Shot Pulls:
-- 1. Anyone can see public shots.
-- 2. Users can see their own private shots.
CREATE POLICY "Viewable shots" 
  ON public.shot_pulls FOR SELECT 
  USING (is_public = true OR auth.uid() = user_id);
CREATE POLICY "Users can insert their own shots" 
  ON public.shot_pulls FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own shots" 
  ON public.shot_pulls FOR UPDATE USING (auth.uid() = user_id);