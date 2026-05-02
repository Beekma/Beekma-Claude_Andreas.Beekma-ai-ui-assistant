-- AI UI Assistant - Database schema (MariaDB)
-- Status: Draft, will be implemented in the database setup phase.

CREATE DATABASE IF NOT EXISTS ai_assistant
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ai_assistant;

-- Versioned system prompts
CREATE TABLE prompts (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  version       VARCHAR(20)  NOT NULL,
  content       TEXT         NOT NULL,
  is_active     TINYINT(1)   NOT NULL DEFAULT 0,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by    VARCHAR(100) NOT NULL,
  comment       VARCHAR(500)
);

-- Logs: every request and response
CREATE TABLE logs (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  ip_hash         VARCHAR(64)  NOT NULL,
  question        TEXT         NOT NULL,
  answer          TEXT,
  prompt_version  VARCHAR(20),
  tokens_input    INT,
  tokens_output   INT,
  cost_usd        DECIMAL(10,6),
  cache_hit       TINYINT(1)   NOT NULL DEFAULT 0,
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Cache: question hash to answer
CREATE TABLE cache (
  question_hash   VARCHAR(64)  PRIMARY KEY,
  question        TEXT         NOT NULL,
  answer          TEXT         NOT NULL,
  hit_count       INT          NOT NULL DEFAULT 1,
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_hit_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Rate limits per IP and time window
CREATE TABLE rate_limits (
  ip_hash         VARCHAR(64)  NOT NULL,
  window_start    DATETIME     NOT NULL,
  request_count   INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (ip_hash, window_start)
);
