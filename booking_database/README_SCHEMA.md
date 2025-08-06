# Booking Database PostgreSQL Schema

This schema supports:
- User authentication and admin role management
- Timeslot storage and availability
- Appointment bookings linking users and timeslots
- Audit logging for admin actions (optional)

## Setup Steps

1. **Ensure PostgreSQL is running and you have created the database & user as needed.**
   (See `startup.sh` for DB/container setup.)

2. **Apply the schema:**
   ```
   psql -h localhost -U <user> -d <database> -p <port> -f schema.sql
   ```

3. **Create an initial admin user:**
   Edit `schema.sql` to uncomment and insert a hashed password if you wish to seed an admin account.

## Table Summary

- **users** — Email/password, roles, is_admin boolean; unique email enforced.
- **timeslots** — Start/end timestamp, is_available; ensures no overlapping timeslots.
- **appointments** — Link user to timeslot, unique per user/timeslot pair, appointment status.
- **admin_logs** — Optional, logs actions performed by admin users.

## Foreign Keys & Constraints

- **Appointments** verify users & timeslots exist, cascade on delete (removes related bookings if timeslot/user deleted).
- **All date columns** use timezone-aware format for clarity.

## Triggers

- Automatically update `updated_at` on change for users, timeslots, appointments.

## Indexes

- Fast lookup via indexed columns for high-traffic/app queries.

## Compatibility

Intended for PostgreSQL 13+. Should work on versions >=11 with minimal changes.

---
