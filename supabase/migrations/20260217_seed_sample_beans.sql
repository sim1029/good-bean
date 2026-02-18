-- Insert sample public beans (no auth user required since created_by is nullable)
-- These are visible to all users via RLS because is_public = true
INSERT INTO public.beans (roaster, name, roast_level, roast_date, is_public, notes) VALUES
  ('Counter Culture', 'Hologram', 'medium', '2026-02-01', true, 'Chocolate, caramel, silky body'),
  ('Onyx Coffee Lab', 'Monarch', 'medium', '2026-02-05', true, 'Rich, sweet, dark chocolate'),
  ('George Howell', 'Tailor Made Espresso', 'light', '2026-01-28', true, 'Bright citrus, floral notes'),
  ('Intelligentsia', 'Black Cat Classic', 'dark', '2026-02-10', true, 'Smoky, bold, nutty finish'),
  ('Stumptown', 'Hair Bender', 'medium', '2026-01-20', true, 'Citrus, dark chocolate, complex');
