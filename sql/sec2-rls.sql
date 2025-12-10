--Teams Table
CREATE TABLE IF NOT EXISTS teams (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

--Create User_Teams Mapping Table
CREATE TABLE IF NOT EXISTS user_teams (
  user_id UUID NOT NULL,    -- This matches the auth.users id
  team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, team_id)
);

-- Enable RLS on Leads
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

-- RLS Policy: SELECT (Read Access)
-- Admins see all. Counselors see their own OR their team's leads.
CREATE POLICY "leads_select" 
ON leads
FOR SELECT
USING (
  (auth.jwt() ->> 'role') = 'admin'  -- Check for admin role in JWT
  OR
  owner_id = auth.uid()              -- User is the direct owner
  OR 
  EXISTS (                           -- User is in the same team as the lead
    SELECT 1 FROM user_teams ut    
    WHERE ut.user_id = auth.uid()
      AND ut.team_id = leads.team_id
  )
);

-- RLS Policy: INSERT (Write Access)
-- Logic: Admins insert anything. Counselors can only insert if they assign it to themselves.
CREATE POLICY "leads_insert"
ON leads
FOR INSERT
WITH CHECK (
  (auth.jwt() ->> 'role') = 'admin'
  OR
  owner_id = auth.uid()
);