-- booking_database: PostgreSQL schema for appointment scheduling

-- =============================
-- USERS TABLE
-- =============================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_admin BOOLEAN DEFAULT FALSE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);

-- =============================
-- TIMESLOTS TABLE
-- =============================
CREATE TABLE timeslots (
    id SERIAL PRIMARY KEY,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_timeslot CHECK (start_time < end_time)
);

CREATE UNIQUE INDEX idx_timeslots_unique ON timeslots(start_time, end_time);

-- =============================
-- APPOINTMENTS TABLE
-- =============================
CREATE TABLE appointments (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    timeslot_id INTEGER NOT NULL REFERENCES timeslots(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'booked', -- booked/cancelled/completed
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_timeslot UNIQUE (user_id, timeslot_id)
);

CREATE INDEX idx_appointments_user ON appointments(user_id);
CREATE INDEX idx_appointments_timeslot ON appointments(timeslot_id);
CREATE INDEX idx_appointments_status ON appointments(status);

-- =============================
-- ADMIN ACTIONS LOG (Optional: Audit Trail for admin ops)
-- =============================
CREATE TABLE admin_logs (
    id SERIAL PRIMARY KEY,
    admin_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(100) NOT NULL,
    details TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================
-- GENERAL: Trigger/Function for updated_at timestamp
-- =============================
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers for updated_at
CREATE TRIGGER trg_users_updated BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_timeslots_updated BEFORE UPDATE ON timeslots
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_appointments_updated BEFORE UPDATE ON appointments
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- =============================
-- DEMO ADMIN SEED (for local/dev)
-- =============================
-- (Uncomment next block to seed an example admin user. Use hashed password from backend setup!)
-- INSERT INTO users (email, password_hash, first_name, last_name, is_admin)
-- VALUES ('admin@example.com', '<bcrypt_hash_here>', 'Admin', 'User', TRUE);

-- =============================
-- END OF SCHEMA
-- =============================
