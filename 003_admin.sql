-- Track every user who logs in (upserted on each sign-in)
CREATE TABLE IF NOT EXISTS app_users (
  email     TEXT PRIMARY KEY,
  user_id   UUID REFERENCES auth.users(id),
  last_seen TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;

-- Any authenticated user can read the list (internal tool with controlled access)
CREATE POLICY "read_app_users" ON app_users
  FOR SELECT USING (auth.role() = 'authenticated');

-- Each user can upsert their own record
CREATE POLICY "insert_own_app_user" ON app_users
  FOR INSERT WITH CHECK (auth.email() = email);

CREATE POLICY "update_own_app_user" ON app_users
  FOR UPDATE USING (auth.email() = email) WITH CHECK (auth.email() = email);


-- Admin-managed block list; checked on every login and every 60 s
CREATE TABLE IF NOT EXISTS banned_users (
  email      TEXT PRIMARY KEY,
  banned_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE banned_users ENABLE ROW LEVEL SECURITY;

-- Any authenticated user can read (needed for self-check)
CREATE POLICY "read_banned_users" ON banned_users
  FOR SELECT USING (auth.role() = 'authenticated');

-- Only the admin can insert or delete rows
CREATE POLICY "admin_insert_banned" ON banned_users
  FOR INSERT WITH CHECK (auth.email() = 'maximillian.lundin@bluewatergroup.com');

CREATE POLICY "admin_delete_banned" ON banned_users
  FOR DELETE USING (auth.email() = 'maximillian.lundin@bluewatergroup.com');
