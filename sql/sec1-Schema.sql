-- Enable uuid extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Helper for explicit realtime notification
CREATE OR REPLACE FUNCTION notify_task_created(payload JSON)
RETURNS VOID AS $$
BEGIN
  PERFORM pg_notify('task.created', payload::text);
END;
$$ LANGUAGE plpgsql;


-- Leads Table

CREATE TABLE IF NOT EXISTS leads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL,
  owner_id UUID,           
  team_id UUID,             
  stage TEXT,               -- e.g., "new", "contacted", "qualified"
  full_name TEXT,
  email TEXT,
  phone TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

--Fetch leads by owner, stage, created_at
CREATE INDEX IF NOT EXISTS idx_leads
  ON leads(owner_id, stage, created_at DESC);

-- trigger to update 'updated_at' automatically
CREATE TRIGGER trg_leads_set_updated_at
BEFORE UPDATE ON leads
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();


-- Applications table

CREATE TABLE IF NOT EXISTS applications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL,
  lead_id UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  status TEXT,              -- e.g., "draft", "submitted", "accepted"
  appl_fee_amount numeric(10,2) DEFAULT 0,
  payment_status TEXT,    
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Fetch applications by lead
CREATE INDEX IF NOT EXISTS idx_appl_lead_id
  ON applications(lead_id);

-- trigger for updated_at
CREATE TRIGGER trg_appl_set_updated_at
BEFORE UPDATE ON applications
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();


--Tasks Table

CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL,
  related_id UUID NOT NULL,   
  type TEXT NOT NULL,          -- must be 'call' or 'email' or 'review'
  title TEXT,
  status TEXT NOT NULL DEFAULT 'open',  -- can be 'open', 'complete', etc.
  due_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT fk_tasks_related_appl FOREIGN KEY (related_id)
    REFERENCES applications(id) ON DELETE CASCADE,

  CONSTRAINT tasks_type_check CHECK (type IN ('call', 'email', 'review')),

  -- Ensure due_at is not earlier than created_at
  CONSTRAINT tasks_due_after_created CHECK (due_at >= created_at)
);

-- Fetch tasks by due_at (range queries)
CREATE INDEX IF NOT EXISTS idx_tasks_due_at ON tasks(due_at);

-- partial index for open tasks (no expression)
CREATE INDEX IF NOT EXISTS idx_tasks_due_at_open ON tasks(due_at)
  WHERE status = 'open';

-- trigger for updated_at
CREATE TRIGGER trg_tasks_set_updated_at
BEFORE UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
