-- ============================================================
-- Auto-create a profile row whenever a new user signs up.
--
-- Works for all auth methods: OAuth (Google, Facebook),
-- phone OTP, and email/password.
--
-- Username derivation priority:
--   1. raw_user_meta_data->>'name'   (OAuth full name)
--   2. email local-part              (before the @)
--   3. 'user_' + first 8 chars of UUID  (last resort)
--
-- Sanitisation: lowercase, non-alphanumeric → '_',
--   collapsed underscores, trimmed, max 30 chars.
--   If the result collides, '_N' is appended until unique.
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER          -- runs as function owner (postgres), bypasses RLS
SET search_path = public
AS $$
DECLARE
  base_username  TEXT;
  final_username TEXT;
  counter        INT := 0;
BEGIN
  -- 1. Pick the best raw source
  base_username := COALESCE(
    NULLIF(TRIM(new.raw_user_meta_data->>'name'), ''),
    NULLIF(SPLIT_PART(new.email, '@', 1), ''),
    'user_' || LEFT(new.id::text, 8)
  );

  -- 2. Sanitise
  base_username := LOWER(REGEXP_REPLACE(base_username, '[^a-zA-Z0-9_]', '_', 'g'));
  base_username := TRIM(BOTH '_' FROM REGEXP_REPLACE(base_username, '_+', '_', 'g'));
  base_username := LEFT(base_username, 30);

  -- 3. Guarantee uniqueness
  final_username := base_username;
  LOOP
    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM public.profiles WHERE username = final_username
    );
    counter        := counter + 1;
    final_username := LEFT(base_username, 27) || '_' || counter;
  END LOOP;

  -- 4. Insert the profile
  INSERT INTO public.profiles (id, username, avatar_url)
  VALUES (
    new.id,
    final_username,
    new.raw_user_meta_data->>'avatar_url'
  );

  RETURN new;
END;
$$;

-- Fire after every new auth.users row (covers all sign-up methods)
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
