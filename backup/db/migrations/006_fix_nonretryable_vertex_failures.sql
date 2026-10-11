-- Migration 006: mark non-retryable Vertex video input failures as accepted source failures
-- These rows are not valid retry candidates: the underlying video exceeds the 20MB inline limit
-- for Vertex multimodal upload and the system cannot recover by retrying without a different source
-- or a different provider/transport strategy.

UPDATE source_artifacts
SET status = 'FAILED_ACCEPTED',
    accepted_failure = 1,
    processing_stage = 'accepted_failure',
    updated_at = CURRENT_TIMESTAMP,
    processed_at = COALESCE(processed_at, CURRENT_TIMESTAMP)
WHERE status = 'FAILED_UNRESOLVED'
  AND retryable = 0
  AND accepted_failure = 0
  AND reason_code IN ('visual_file_too_large_for_vertex', 'visual_input_invalid');
