-- Add pilot approval status and Discord username tracking
ALTER TABLE public.pilots
ADD COLUMN IF NOT EXISTS approval_status public.application_status NOT NULL DEFAULT 'approved',
ADD COLUMN IF NOT EXISTS discord_username TEXT;

ALTER TABLE public.pilot_applications
ADD COLUMN IF NOT EXISTS discord_username TEXT;

-- Backfill discord usernames from auth metadata where possible
UPDATE public.pilot_applications pa
SET discord_username = COALESCE(
  au.raw_user_meta_data ->> 'preferred_username',
  au.raw_user_meta_data ->> 'global_name',
  au.raw_user_meta_data ->> 'full_name',
  au.raw_user_meta_data ->> 'name',
  au.raw_user_meta_data ->> 'user_name'
)
FROM auth.users au
WHERE pa.user_id = au.id
  AND pa.discord_username IS NULL;

UPDATE public.pilots p
SET discord_username = COALESCE(
  au.raw_user_meta_data ->> 'preferred_username',
  au.raw_user_meta_data ->> 'global_name',
  au.raw_user_meta_data ->> 'full_name',
  au.raw_user_meta_data ->> 'name',
  au.raw_user_meta_data ->> 'user_name'
)
FROM auth.users au
WHERE p.user_id = au.id
  AND p.discord_username IS NULL;

UPDATE public.pilots
SET approval_status = 'approved'
WHERE approval_status IS DISTINCT FROM 'approved';
