-- Add image URLs to catalog tables
ALTER TABLE public.beans    ADD COLUMN image_url TEXT;
ALTER TABLE public.machines ADD COLUMN image_url TEXT;

-- Pending user requests for new catalog items
CREATE TABLE public.catalog_requests (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  submitted_by  UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  item_type     TEXT NOT NULL CHECK (item_type IN ('bean', 'machine')),
  name          TEXT NOT NULL,
  manufacturer  TEXT NOT NULL,
  notes         TEXT,
  image_url     TEXT,
  status        TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.catalog_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own catalog requests"
  ON public.catalog_requests FOR INSERT
  WITH CHECK (auth.uid() = submitted_by);

CREATE POLICY "Users can view own catalog requests"
  ON public.catalog_requests FOR SELECT
  USING (auth.uid() = submitted_by);
