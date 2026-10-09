ALTER TABLE source_artifacts ADD COLUMN file_path TEXT;
ALTER TABLE source_artifacts ADD COLUMN platform TEXT;
ALTER TABLE source_artifacts ADD COLUMN origin_url TEXT;
ALTER TABLE source_artifacts ADD COLUMN duration_seconds REAL;
ALTER TABLE source_artifacts ADD COLUMN language TEXT;
ALTER TABLE source_artifacts ADD COLUMN transcript_text TEXT;
ALTER TABLE source_artifacts ADD COLUMN transcript_source TEXT;
ALTER TABLE source_artifacts ADD COLUMN processing_stage TEXT;
ALTER TABLE source_artifacts ADD COLUMN reason_code TEXT;
ALTER TABLE source_artifacts ADD COLUMN reason_text TEXT;
ALTER TABLE source_artifacts ADD COLUMN retryable INTEGER DEFAULT 0;
ALTER TABLE source_artifacts ADD COLUMN last_error TEXT;
ALTER TABLE source_artifacts ADD COLUMN updated_at TIMESTAMP;

UPDATE source_artifacts
SET updated_at = COALESCE(updated_at, discovered_at, CURRENT_TIMESTAMP)
WHERE updated_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_source_artifacts_exam_stage
ON source_artifacts(exam, processing_stage);

CREATE INDEX IF NOT EXISTS idx_source_artifacts_exam_reason
ON source_artifacts(exam, reason_code);

CREATE TABLE IF NOT EXISTS source_artifact_cards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    artifact_id TEXT NOT NULL,
    card_id TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (artifact_id, card_id),
    FOREIGN KEY (artifact_id) REFERENCES source_artifacts(artifact_id)
);

CREATE INDEX IF NOT EXISTS idx_source_artifact_cards_artifact
ON source_artifact_cards(artifact_id);

CREATE INDEX IF NOT EXISTS idx_source_artifact_cards_card
ON source_artifact_cards(card_id);