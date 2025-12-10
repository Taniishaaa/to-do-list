This repository contains the completed deliverables for the Technical Assessment, covering Database Design, Security (RLS), Server-side Logic (Edge Functions), Frontend Development, and Payment Integration.

# Repository Structure

```text
.
├── my-app/                  # Section 4: Next.js Frontend Dashboard
├── sql/
│   ├── sec1-schema.sql      # Section 1: Schema (Leads, Applications, Tasks)
│   └── sec2-rls.sql         # Section 2: RLS Policies & Team Structure
├── section3.txt             # Section 3: Supabase Edge Function Source Code
└── section5.txt             # Section 5: Stripe Integration Strategy

```

# Follow these steps to set up the project locally.

Prerequisites: Node.js & npm installed and A Supabase project created.

### 1. Database Setup (Sections 1 & 2)
Go to your Supabase Dashboard -> SQL Editor.

Open sql/sec1-schema.sql from this repo and run the entire script. This sets up the tables (leads, applications, tasks) along with triggers and indexes.

Open sql/sec2-rls.sql and run it. This enables Row Level Security (RLS) and sets up the strict access policies for Admins vs. Counselors.

### 2. Edge Function Logic (Section 3)
The code for the secure "Create Task" server-side logic is located in section3.txt. To deploy this:

Create a new Edge Function in your Supabase Dashboard named create-task.

Paste the TypeScript code from sec3.txt into the editor.

Save and Deploy.

Note: Save the Endpoint URL (e.g., https://[project].supabase.co/functions/v1/create-task) if you plan to connect it to the frontend later.

### 3. Running the Frontend (Section 4)
The frontend is a Next.js application located in the my-app folder.

Navigate to the frontend directory:

```Bash

cd my-app
```

Install dependencies:

```Bash

npm install
```

Configure Environment Variables: Create a .env.local file in my-app/ and add your Supabase credentials:

Code snippet

NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
Run the development server:

```Bash

npm run dev
```

Open http://localhost:3000. The app is configured to automatically redirect you to the dashboard at /dashboard/today.

### 4. Payment Integration (Section 5)
A detailed explanation of the Stripe implementation strategy (including Checkout Sessions, Webhooks, and Security verification) can be found in section5.txt.

# Tech Stack
Database: PostgreSQL (Supabase)

Backend: Supabase Edge Functions (Deno/TypeScript)

Frontend: Next.js (App Router), Tailwind CSS

Lang: TypeScript

