# Supabase CLI Reference

A quick reference for day-to-day development.

---

# Installation

## NPM

```bash
npm install -g supabase
```

Verify:

```bash
supabase --version
```

---

# Authentication

Login:

```bash
supabase login
```

Logout:

```bash
supabase logout
```

---

# Project Setup

Initialize a project:

```bash
supabase init
```

This creates:

```text
supabase/
├── config.toml
├── migrations/
├── functions/
├── seed.sql
```

---

# Link Project

Find project reference:

Dashboard → Settings → General

Example:

```text
abcdefghijklmnop
```

Link:

```bash
supabase link --project-ref abcdefghijklmnop
```

---

# Database

## Pull Remote Schema

Generate migration from remote changes.

```bash
supabase db pull
```

---

## Push Local Migrations

Apply local migrations to remote database.

```bash
supabase db push
```

---

## Reset Local Database

WARNING: Deletes local data.

```bash
supabase db reset
```

---

## Start Local Database

```bash
supabase start
```

---

## Stop Local Database

```bash
supabase stop
```

---

## Check Status

```bash
supabase status
```

---

# Migrations

## Create Migration

```bash
supabase migration new create_profiles_table
```

Example:

```bash
supabase migration new create_initial_schema
```

Creates:

```text
supabase/migrations/
└── 20260609120000_create_initial_schema.sql
```

---

## Migration Workflow

Create migration:

```bash
supabase migration new add_plant_photos
```

Edit SQL file.

Push:

```bash
supabase db push
```

Commit:

```bash
git add .
git commit -m "feat: add plant photos"
```

---

## List Migrations

```bash
supabase migration list
```

---

# Edge Functions

## Create Function

```bash
supabase functions new sensor-data
```

Creates:

```text
supabase/functions/sensor-data/
└── index.ts
```

---

## Run Locally

```bash
supabase functions serve
```

Single function:

```bash
supabase functions serve sensor-data
```

---

## Deploy Function

```bash
supabase functions deploy sensor-data
```

---

## Deploy Without JWT

```bash
supabase functions deploy sensor-data --no-verify-jwt
```

Useful for ESP32 endpoints.

---

## Set Secrets

```bash
supabase secrets set API_KEY=123
```

Multiple:

```bash
supabase secrets set \
OPENAI_API_KEY=xxx \
WEATHER_API_KEY=yyy
```

---

## List Secrets

```bash
supabase secrets list
```

---

# Types

Generate TypeScript types:

```bash
supabase gen types typescript \
--linked > src/types/database.types.ts
```

Specific schema:

```bash
supabase gen types typescript \
--linked \
--schema public
```

---

# Storage

Storage buckets are usually managed through:

Dashboard → Storage

or SQL migrations.

Example bucket:

```text
profiles
plant-photos
```

---

# Local Development

Start local stack:

```bash
supabase start
```

Stop:

```bash
supabase stop
```

Reset:

```bash
supabase db reset
```

View Studio:

```text
http://localhost:54323
```

---

# Common Workflow

## New Table

Create migration:

```bash
supabase migration new create_growth_logs
```

Write SQL.

Push:

```bash
supabase db push
```

Generate types:

```bash
supabase gen types typescript \
--linked > src/types/database.types.ts
```

Commit:

```bash
git add .
git commit -m "feat: create growth logs"
```

---

## Existing Remote Project

Clone repo:

```bash
git clone <repo>
```

Install:

```bash
npm install
```

Link:

```bash
supabase link --project-ref PROJECT_REF
```

Pull:

```bash
supabase db pull
```

Generate types:

```bash
supabase gen types typescript \
--linked > src/types/database.types.ts
```

---

# Useful Commands

```bash
supabase login
supabase init
supabase start
supabase stop
supabase status

supabase link --project-ref PROJECT_REF

supabase db pull
supabase db push
supabase db reset

supabase migration new NAME
supabase migration list

supabase functions new NAME
supabase functions serve
supabase functions deploy NAME

supabase secrets set KEY=VALUE

supabase gen types typescript --linked
```

---

# Project Conventions

## Migration Names

Good:

```text
create_initial_schema
create_profiles_table
add_plant_photos
add_system_logs
add_rls_policies
```

Avoid:

```text
test
newmigration
temp
```

---

## Edge Function Names

Good:

```text
sensor-data
system-log
weather-sync
daily-summary
```

---

```bash
git checkout -b feat/plant-photos

supabase migration new add_plant_photos

supabase db push

git add .
git commit -m "feat: add plant photos"

git push