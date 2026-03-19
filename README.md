# Task Manager

Flutter + Supabase · Clean Architecture

## Setup

```bash
flutter pub get
```

Crea `.env` en la raíz del proyecto:

```env
SUPABASE_URL=https://<tu-proyecto>.supabase.co
SUPABASE_ANON_KEY=<tu-anon-key>
```

> **Settings → API** en tu dashboard de Supabase.

Ejecuta en **Supabase → SQL Editor**:

```sql
CREATE TABLE IF NOT EXISTS tasks (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  title            TEXT        NOT NULL,
  description      TEXT,
  scheduled_at     TIMESTAMPTZ,
  is_completed     BOOLEAN     NOT NULL DEFAULT FALSE,
  category         TEXT        NOT NULL DEFAULT 'Personal',
  attachment_urls  TEXT[]      NOT NULL DEFAULT '{}',
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tasks_scheduled_at      ON tasks (scheduled_at);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at        ON tasks (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tasks_created_completed ON tasks (created_at DESC, is_completed);

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tasks_updated_at
  BEFORE UPDATE ON tasks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_select" ON tasks FOR SELECT TO anon USING (true);
CREATE POLICY "anon_insert" ON tasks FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_update" ON tasks FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_delete" ON tasks FOR DELETE TO anon USING (true);

GRANT ALL ON TABLE tasks TO anon;
GRANT USAGE ON SCHEMA public TO anon;

INSERT INTO storage.buckets (id, name, public)
VALUES ('task-attachments', 'task-attachments', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "storage_select" ON storage.objects FOR SELECT TO anon USING (bucket_id = 'task-attachments');
CREATE POLICY "storage_insert" ON storage.objects FOR INSERT TO anon WITH CHECK (bucket_id = 'task-attachments');
CREATE POLICY "storage_update" ON storage.objects FOR UPDATE TO anon USING (bucket_id = 'task-attachments');
CREATE POLICY "storage_delete" ON storage.objects FOR DELETE TO anon USING (bucket_id = 'task-attachments');

INSERT INTO tasks (title, description, category, scheduled_at, is_completed) VALUES
  ('Morning Workout',  'Run 5km + stretching',       'Healthy',   NOW()::date + interval  '6 hours', true),
  ('Eating Breakfast', NULL,                          'Healthy',   NOW()::date + interval  '8 hours', true),
  ('Reading Book',     'Clean Code — chapter 4',      'Education', NOW()::date + interval '10 hours', false),
  ('Job Tasks',        'Finish sprint review slides', 'Job',       NOW()::date + interval '11 hours', false),
  ('Team Meeting',     NULL,                          'Job',       NOW()::date + interval '14 hours', false),
  ('Evening Run',      '30 min easy pace',            'Sport',     NOW()::date + interval '18 hours', false);
```

```sql
CREATE TABLE IF NOT EXISTS notes (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT        NOT NULL DEFAULT '',
  content     TEXT        NOT NULL DEFAULT '',
  color_value INTEGER     NOT NULL DEFAULT 4289200882,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER notes_updated_at
  BEFORE UPDATE ON notes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notes_select" ON notes FOR SELECT TO anon USING (true);
CREATE POLICY "notes_insert" ON notes FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "notes_update" ON notes FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "notes_delete" ON notes FOR DELETE TO anon USING (true);

GRANT ALL ON TABLE notes TO anon;
```

```bash
flutter run
```
