-- Migration 001: Initial schema with core tables
-- Created 2026-10-01
-- Establishes the foundational database schema for ANKI flashcard system

CREATE TABLE IF NOT EXISTS cards (
    id TEXT PRIMARY KEY,
    exam TEXT NOT NULL,
    subject TEXT NOT NULL,
    topic TEXT NOT NULL,
    subtopic TEXT,
    difficulty TEXT NOT NULL,
    card_type TEXT NOT NULL,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    explanation TEXT,
    shortcut TEXT,
    common_mistake TEXT,
    real_world_example TEXT,
    follow_up TEXT,
    follow_up_answer TEXT,
    interviewer_red_flag TEXT,
    source TEXT,
    source_url TEXT,
    tags TEXT,
    priority TEXT,
    stage TEXT,
    sequence_rank INTEGER,
    status TEXT DEFAULT 'generated',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    diagrams TEXT DEFAULT '[]',
    audio_path TEXT,
    image_path TEXT,
    career_level TEXT,
    diagrams_checked INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS generation_batches (
    id TEXT PRIMARY KEY,
    exam TEXT NOT NULL,
    subject TEXT NOT NULL,
    topic TEXT NOT NULL,
    requested_cards INTEGER,
    generated_cards INTEGER DEFAULT 0,
    status TEXT DEFAULT 'pending',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    error_message TEXT
);

CREATE TABLE IF NOT EXISTS api_usage (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    exam TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    model TEXT,
    input_tokens INTEGER,
    output_tokens INTEGER,
    purpose TEXT
);

CREATE TABLE IF NOT EXISTS deck_audits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    exam TEXT NOT NULL,
    result TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS removed_cards (
    id TEXT PRIMARY KEY,
    exam TEXT NOT NULL,
    subject TEXT,
    topic TEXT,
    subtopic TEXT,
    difficulty TEXT,
    card_type TEXT,
    question TEXT,
    answer TEXT,
    explanation TEXT,
    shortcut TEXT,
    common_mistake TEXT,
    real_world_example TEXT,
    follow_up TEXT,
    follow_up_answer TEXT,
    interviewer_red_flag TEXT,
    source TEXT,
    source_url TEXT,
    tags TEXT,
    priority TEXT,
    stage TEXT,
    status TEXT,
    diagrams TEXT,
    audio_path TEXT,
    image_path TEXT,
    career_level TEXT,
    diagrams_checked INTEGER DEFAULT 0,
    sequence_rank INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    removed_reason TEXT,
    removed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ignored_reels (
    reel_id TEXT NOT NULL,
    exam TEXT NOT NULL,
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (reel_id, exam)
);

CREATE TABLE IF NOT EXISTS curriculum_topics (
    topic_id TEXT NOT NULL,
    exam TEXT NOT NULL,
    subject TEXT NOT NULL,
    name TEXT NOT NULL,
    stage TEXT,
    priority TEXT,
    difficulty TEXT,
    career_level TEXT,
    prerequisites TEXT DEFAULT '[]',
    card_types TEXT DEFAULT '[]',
    estimated_cards INTEGER DEFAULT 0,
    synthesis_context TEXT,
    source TEXT DEFAULT 'json',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (exam, subject, topic_id)
);

CREATE TABLE IF NOT EXISTS card_stems (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    exam TEXT NOT NULL,
    subject TEXT NOT NULL,
    topic TEXT NOT NULL,
    question TEXT NOT NULL,
    item_key TEXT NOT NULL,
    card_type TEXT NOT NULL,
    needs_diagram_guess INTEGER DEFAULT 0,
    career_level TEXT,
    status TEXT DEFAULT 'pending',
    generated_card_id TEXT,
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit_recommendations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    audit_id INTEGER NOT NULL,
    exam TEXT NOT NULL,
    subject TEXT,
    field TEXT NOT NULL,
    item_key TEXT NOT NULL,
    item TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    attempts INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    FOREIGN KEY (audit_id) REFERENCES deck_audits(id)
);

CREATE TABLE IF NOT EXISTS sequence_failures (
    exam TEXT NOT NULL,
    subject TEXT NOT NULL,
    topic TEXT NOT NULL,
    attempts INTEGER DEFAULT 0,
    last_error TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (exam, subject, topic)
);

-- Core indexes for performance
CREATE INDEX IF NOT EXISTS idx_cards_exam ON cards(exam);
CREATE INDEX IF NOT EXISTS idx_cards_subject ON cards(subject);
CREATE INDEX IF NOT EXISTS idx_cards_topic ON cards(topic);
CREATE INDEX IF NOT EXISTS idx_cards_status ON cards(status);
CREATE INDEX IF NOT EXISTS idx_deck_audits_exam ON deck_audits(exam);
CREATE INDEX IF NOT EXISTS idx_removed_cards_exam ON removed_cards(exam);
CREATE INDEX IF NOT EXISTS idx_audit_recs_exam_status ON audit_recommendations(exam, status);
CREATE INDEX IF NOT EXISTS idx_audit_recs_subject ON audit_recommendations(exam, subject);
CREATE UNIQUE INDEX IF NOT EXISTS idx_card_stems_unique ON card_stems(exam, subject, topic, item_key);
CREATE INDEX IF NOT EXISTS idx_card_stems_status ON card_stems(exam, subject, status);
