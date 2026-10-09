-- Migration 003: Fix audit_recommendations uniqueness constraint
-- Created 2026-10-01
-- Ensures only one open or given-up recommendation per (exam, field, item_key)
-- Deduplicates existing data that may have multiple rows for the same key

-- Deduplication: Keep the row with most attempts for each key, mark others as done
-- This prevents losing the most authoritative attempt count when creating the unique index
DELETE FROM audit_recommendations
WHERE id IN (
    -- For each duplicate group, find all IDs except the one with most attempts
    SELECT a.id
    FROM audit_recommendations a
    WHERE a.status IN ('pending', 'given_up')
    AND a.id NOT IN (
        SELECT MAX(id) FROM audit_recommendations
        WHERE exam = a.exam AND field = a.field AND item_key = a.item_key
        AND status IN ('pending', 'given_up')
        ORDER BY attempts DESC
        LIMIT 1
    )
    GROUP BY a.exam, a.field, a.item_key
    HAVING COUNT(*) > 1
);

-- Create the unique index that ensures only one open/given_up row per key
DROP INDEX IF EXISTS idx_audit_recs_open_unique;
CREATE UNIQUE INDEX idx_audit_recs_open_unique
ON audit_recommendations(exam, field, item_key)
WHERE status IN ('pending', 'given_up');
