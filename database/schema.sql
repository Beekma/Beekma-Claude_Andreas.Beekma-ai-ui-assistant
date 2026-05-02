-- AI UI Assistant - Database schema (MariaDB)
-- Idempotent: kann mehrfach importiert werden (DROP + CREATE).
-- Alle Tabellen werden explizit mit utf8mb4 / utf8mb4_unicode_ci erstellt.
-- Ausfuehren als app_user via phpMyAdmin (kein CREATE DATABASE Recht noetig).

DROP TABLE IF EXISTS rate_limits;
DROP TABLE IF EXISTS cache;
DROP TABLE IF EXISTS logs;
DROP TABLE IF EXISTS prompts;

-- Versioned system prompts
CREATE TABLE prompts (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  version       VARCHAR(20)  NOT NULL,
  content       TEXT         NOT NULL,
  is_active     TINYINT(1)   NOT NULL DEFAULT 0,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by    VARCHAR(100) NOT NULL,
  comment       VARCHAR(500)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Cache: question hash to answer
CREATE TABLE cache (
  question_hash   VARCHAR(64)  PRIMARY KEY,
  question        TEXT         NOT NULL,
  answer          TEXT         NOT NULL,
  hit_count       INT          NOT NULL DEFAULT 1,
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_hit_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rate limits per IP and time window
CREATE TABLE rate_limits (
  ip_hash         VARCHAR(64)  NOT NULL,
  window_start    DATETIME     NOT NULL,
  request_count   INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (ip_hash, window_start)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
