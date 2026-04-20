-- Bluewater Capacity Installation Tool - Saved Configurations
-- Run this in Supabase SQL Editor (after 001_initial_schema.sql)

-- ============================================
-- TABLE: capacity_configurations
-- ============================================

CREATE TABLE capacity_configurations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,               -- e.g. "Bluewater Spirit" or "Bluewater PRO 600CV-HR"
  brand TEXT NOT NULL DEFAULT 'Bluewater',
  model TEXT NOT NULL,               -- e.g. "Spirit", "Cleone Classic", "PRO 600CV-HR"
  flow_data JSONB NOT NULL,          -- mainPath (flow diagram)
  equipment_config JSONB NOT NULL,   -- eqCfg (equipment settings)
  timeline_data JSONB NOT NULL,      -- tl (1-hour timeline)
  notes TEXT DEFAULT '',             -- plumber/installation notes
  unit_system TEXT NOT NULL DEFAULT 'metric' CHECK (unit_system IN ('metric', 'imperial')),
  created_by TEXT,                   -- optional: who created it
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_capacity_config_title ON capacity_configurations(title);
CREATE INDEX idx_capacity_config_model ON capacity_configurations(model);
CREATE INDEX idx_capacity_config_created ON capacity_configurations(created_at DESC);

-- Auto-update updated_at
CREATE TRIGGER capacity_configurations_updated_at
  BEFORE UPDATE ON capacity_configurations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================
-- RLS: Open access for internal tool
-- ============================================

ALTER TABLE capacity_configurations ENABLE ROW LEVEL SECURITY;

-- Allow anon + authenticated to read all configs
CREATE POLICY "Anyone can view capacity configurations"
  ON capacity_configurations FOR SELECT
  TO anon, authenticated
  USING (true);

-- Allow anon + authenticated to insert configs
CREATE POLICY "Anyone can create capacity configurations"
  ON capacity_configurations FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Allow anon + authenticated to update configs
CREATE POLICY "Anyone can update capacity configurations"
  ON capacity_configurations FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Allow anon + authenticated to delete configs
CREATE POLICY "Anyone can delete capacity configurations"
  ON capacity_configurations FOR DELETE
  TO anon, authenticated
  USING (true);
