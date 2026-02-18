-- Seed a test user for development/simulator use.
-- UUID: a1b2c3d4-e5f6-7890-abcd-ef1234567890
-- Email: testuser@goodbean.dev
-- Password: testpassword123

-- Insert test user into auth.users
INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  confirmation_token,
  recovery_token
) VALUES (
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'testuser@goodbean.dev',
  crypt('testpassword123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

-- Insert matching identity row (required for Supabase email auth to work)
INSERT INTO auth.identities (
  id,
  user_id,
  provider_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
) VALUES (
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  'testuser@goodbean.dev',
  jsonb_build_object('sub', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'email', 'testuser@goodbean.dev'),
  'email',
  NOW(),
  NOW(),
  NOW()
) ON CONFLICT DO NOTHING;

-- Insert profile
INSERT INTO public.profiles (id, username, equipment_setup) VALUES (
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  'test_nerd',
  '{"grinder": "Niche Zero", "machine": "Decent DE1", "tamper": "Normcore V4"}'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- Seed beans
INSERT INTO public.beans (id, created_by, roaster, name, roast_level, roast_date, is_public, notes) VALUES
  ('b0000001-0000-0000-0000-000000000001', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
   'Onyx Coffee Lab', 'Geisha Reserve', 'light', '2026-02-10', false,
   'Floral jasmine, stone fruit sweetness. Competition lot.'),
  ('b0000002-0000-0000-0000-000000000002', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
   'Counter Culture', 'Nightcap Blend', 'dark', '2026-02-05', false,
   'Chocolatey, full body. Good for milk drinks too.')
ON CONFLICT (id) DO NOTHING;

-- Seed shot pulls
INSERT INTO public.shot_pulls (id, user_id, bean_id, dose_grams, yield_grams, time_seconds, temp_c, pressure_profile, rating, is_public) VALUES
  ('c0000001-0000-0000-0000-000000000001',
   'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
   'b0000001-0000-0000-0000-000000000001',
   18.00, 36.00, 28, 93,
   '{"stages": [{"pressure": 3, "seconds": 5}, {"pressure": 9, "seconds": 20}, {"pressure": 6, "seconds": 3}]}'::jsonb,
   8, false),
  ('c0000002-0000-0000-0000-000000000002',
   'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
   'b0000001-0000-0000-0000-000000000001',
   18.50, 40.00, 32, 94,
   '{"stages": [{"pressure": 3, "seconds": 5}, {"pressure": 9, "seconds": 24}, {"pressure": 6, "seconds": 3}]}'::jsonb,
   6, false),
  ('c0000003-0000-0000-0000-000000000003',
   'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
   'b0000002-0000-0000-0000-000000000002',
   20.00, 42.00, 30, 92,
   '{"stages": [{"pressure": 4, "seconds": 6}, {"pressure": 9, "seconds": 21}, {"pressure": 5, "seconds": 3}]}'::jsonb,
   7, false)
ON CONFLICT (id) DO NOTHING;
