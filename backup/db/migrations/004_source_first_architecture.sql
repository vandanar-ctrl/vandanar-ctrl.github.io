-- Migration 004: Source-first architecture persistence

CREATE TABLE IF NOT EXISTS source_artifacts (
    artifact_id TEXT PRIMARY KEY,
    exam TEXT NOT NULL,
    source_type TEXT NOT NULL,
    source_ref TEXT NOT NULL,
    content_hash TEXT NOT NULL,
    status TEXT NOT NULL,
    failure_reason TEXT,
    accepted_failure INTEGER DEFAULT 0,
    discovered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    UNIQUE (exam, source_type, source_ref)
);

CREATE INDEX IF NOT EXISTS idx_source_artifacts_exam_status
ON source_artifacts(exam, status);

CREATE TABLE IF NOT EXISTS source_units (
    unit_id TEXT PRIMARY KEY,
    artifact_id TEXT NOT NULL,
    exam TEXT NOT NULL,
    subject TEXT,
    topic TEXT,
    source_location TEXT,
    content_summary TEXT,
    supporting_excerpt TEXT,
    content_hash TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (artifact_id, content_hash),
    FOREIGN KEY (artifact_id) REFERENCES source_artifacts(artifact_id)
);

CREATE INDEX IF NOT EXISTS idx_source_units_exam_status
ON source_units(exam, status);

CREATE INDEX IF NOT EXISTS idx_source_units_exam_topic
ON source_units(exam, subject, topic);

CREATE TABLE IF NOT EXISTS curriculum_learning_objectives (
    objective_id TEXT PRIMARY KEY,
    exam TEXT NOT NULL,
    subject TEXT NOT NULL,
    topic_id TEXT NOT NULL,
    topic TEXT NOT NULL,
    statement TEXT NOT NULL,
    dimension TEXT NOT NULL,
    desired_depth TEXT NOT NULL,
    career_level TEXT,
    prerequisite_objective_ids TEXT DEFAULT '[]',
    active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (exam, objective_id)
);

CREATE INDEX IF NOT EXISTS idx_objectives_exam_topic
ON curriculum_learning_objectives(exam, subject, topic);

CREATE TABLE IF NOT EXISTS coverage_items (
    coverage_id TEXT PRIMARY KEY,
    exam TEXT NOT NULL,
    subject TEXT,
    topic TEXT,
    source_kind TEXT NOT NULL,
    source_artifact_id TEXT,
    source_unit_id TEXT,
    source_ref TEXT,
    source_location TEXT,
    concept TEXT,
    learning_angle TEXT,
    depth TEXT,
    summary TEXT,
    supporting_excerpt TEXT,
    quality TEXT NOT NULL,
    confidence REAL DEFAULT 0.0,
    objective_hint TEXT,
    status TEXT NOT NULL,
    content_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (exam, source_kind, content_hash)
);

CREATE INDEX IF NOT EXISTS idx_coverage_exam_topic
ON coverage_items(exam, subject, topic);

CREATE INDEX IF NOT EXISTS idx_coverage_exam_status
ON coverage_items(exam, status);

CREATE TABLE IF NOT EXISTS generation_objectives (
    generation_objective_id TEXT PRIMARY KEY,
    objective_id TEXT NOT NULL,
    exam TEXT NOT NULL,
    subject TEXT NOT NULL,
    topic TEXT NOT NULL,
    missing_understanding TEXT NOT NULL,
    missing_learning_angle TEXT,
    desired_depth TEXT,
    career_level TEXT,
    coverage_status TEXT NOT NULL,
    generation_reason TEXT NOT NULL,
    evidence_inspected TEXT DEFAULT '[]',
    complementary_evidence TEXT DEFAULT '[]',
    recommended_card_style TEXT,
    status TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (exam, objective_id, missing_understanding)
);

CREATE INDEX IF NOT EXISTS idx_generation_objectives_exam_status
ON generation_objectives(exam, status);

ALTER TABLE card_stems ADD COLUMN generation_objective_id TEXT;
ALTER TABLE card_stems ADD COLUMN objective_id TEXT;
ALTER TABLE card_stems ADD COLUMN workflow_state TEXT DEFAULT 'DRAFT';
ALTER TABLE card_stems ADD COLUMN frozen_question TEXT;
ALTER TABLE card_stems ADD COLUMN planned_card_style TEXT;
ALTER TABLE card_stems ADD COLUMN evidence_bundle_ref TEXT;

CREATE TABLE IF NOT EXISTS stem_reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    stem_id INTEGER NOT NULL,
    verdict TEXT NOT NULL,
    reason TEXT,
    reviewer_type TEXT NOT NULL,
    reviewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stem_id) REFERENCES card_stems(id)
);

ALTER TABLE cards ADD COLUMN generation_objective_id TEXT;
ALTER TABLE cards ADD COLUMN objective_id TEXT;
ALTER TABLE cards ADD COLUMN evidence_bundle_ref TEXT;

ALTER TABLE removed_cards ADD COLUMN generation_objective_id TEXT;
ALTER TABLE removed_cards ADD COLUMN objective_id TEXT;
ALTER TABLE removed_cards ADD COLUMN evidence_bundle_ref TEXT;

CREATE TABLE IF NOT EXISTS card_evidence_links (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    card_id TEXT NOT NULL,
    generation_objective_id TEXT,
    evidence_id TEXT NOT NULL,
    provenance_stage TEXT NOT NULL,
    used_in_generation INTEGER DEFAULT 0,
    usage_role TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (card_id, evidence_id, provenance_stage, usage_role)
);

CREATE INDEX IF NOT EXISTS idx_card_evidence_links_card
ON card_evidence_links(card_id);