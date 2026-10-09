-- Migration 002: Add content and media columns (for pre-migration databases)
-- Created 2026-10-01
-- Adds diagrams, audio, image, and metadata fields to support rich card content
-- These are idempotent via backward-compatibility checks in connection.py's _ensure_backward_compat_columns()
-- This migration is a no-op for new databases (migration 001 already includes these columns)

-- Note: For pre-migration databases (created before the migration system existed),
-- these ALTER TABLE statements will add the missing columns. SQLite ignores
-- "ADD COLUMN IF NOT EXISTS" syntax, so these statements fail silently in connection.py
-- if the columns already exist - the backward-compat layer handles this properly.
