-- Kalin schema eka use karala already database eka hadagena thiyenawa nam,
-- meka run karanna aluth columns tika add karanna:
-- mysql -u root -p todo_app < migration.sql

USE todo_app;

ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
  ADD COLUMN IF NOT EXISTS due_date DATE NULL,
  ADD COLUMN IF NOT EXISTS category VARCHAR(50) DEFAULT 'General';

-- Adding notes field (run this if you already migrated priority/due_date/category)
ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS notes TEXT NULL;
