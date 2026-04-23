-- ============================================================
-- MERIDIAN ERP — Database Schema
-- MRD-DB-001 v1.0
-- Generated: April 2026
-- 
-- USAGE: Run this entire file in Supabase SQL Editor for a 
-- new client project BEFORE running meridian_rls.sql
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- HELPER FUNCTION: get_my_company_id()
-- Returns the company_id for the currently authenticated user.
-- Used by all RLS policies.
-- ============================================================
CREATE OR REPLACE FUNCTION get_my_company_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT company_id FROM user_profiles WHERE id = auth.uid() LIMIT 1;
$$;

-- ============================================================
-- TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS companies (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  plan text DEFAULT 'beta',
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_profiles (
  id uuid NOT NULL PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  full_name text,
  role text DEFAULT 'viewer',
  created_at timestamp with time zone DEFAULT now(),
  is_active boolean DEFAULT true,
  last_login timestamp with time zone,
  invited_by text,
  invited_at timestamp with time zone,
  company_id uuid REFERENCES companies(id)
);

CREATE TABLE IF NOT EXISTS app_settings (
  key text NOT NULL,
  value text,
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (key, company_id)
);

CREATE TABLE IF NOT EXISTS materials (
  id text NOT NULL,
  level text NOT NULL,
  name text NOT NULL,
  category text NOT NULL,
  uom text DEFAULT 'Each',
  opening_inv integer DEFAULT 0,
  inv_date date,
  safety_stock text,
  prod_lead_time text,
  transit_lead_time text,
  moq integer DEFAULT 1000,
  shelf_life text,
  confirmed_receipts text DEFAULT 'None',
  batch_yield integer,
  color text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  prod_lt_mo numeric,
  status text DEFAULT 'Active',
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS skus (
  id text NOT NULL,
  batch_yield integer,
  shelf_life text,
  moq integer,
  plt text,
  tlt text,
  status text DEFAULT 'Active',
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  unit_price numeric,
  currency text DEFAULT 'USD',
  tax_rate numeric DEFAULT 0,
  payment_terms text DEFAULT 'Net 30',
  prod_lt_mo numeric,
  unit_cost numeric,
  selling_price numeric,
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS bom_lines (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  parent_id text NOT NULL,
  child_id text NOT NULL,
  qty numeric DEFAULT 1,
  uom text DEFAULT 'Each',
  created_at timestamp with time zone DEFAULT now(),
  company_id uuid REFERENCES companies(id)
);

CREATE TABLE IF NOT EXISTS planning_config (
  sku_id text NOT NULL,
  bom_mult numeric DEFAULT 1,
  moq integer DEFAULT 1000,
  batch_yield integer DEFAULT 1000,
  prod_lt_mo numeric DEFAULT 2,
  ss_months integer DEFAULT 12,
  color_hex text,
  bom_label text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  ss_strategy text DEFAULT 'full',
  ss_reduction_factor numeric DEFAULT 1.0,
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (sku_id, company_id)
);

CREATE TABLE IF NOT EXISTS batches (
  id text NOT NULL,
  sku_id text NOT NULL,
  batch_no text NOT NULL,
  type text DEFAULT 'Opening Stock',
  qty integer DEFAULT 0,
  uom text DEFAULT 'Each',
  mfg_date date NOT NULL,
  exp_date date NOT NULL,
  location text,
  grn text,
  status text DEFAULT 'Released',
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  location_id text,
  coa_ref text,
  qc_status text,
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS storage_locations (
  id text NOT NULL,
  name text NOT NULL,
  type text DEFAULT 'Warehouse',
  site text,
  capacity integer,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS inventory_transfers (
  id text NOT NULL,
  batch_id text,
  sku_id text,
  from_location text,
  to_location text,
  qty integer NOT NULL,
  transferred_by text,
  transferred_at timestamp with time zone DEFAULT now(),
  notes text,
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS suppliers (
  id text NOT NULL,
  name text NOT NULL,
  category text,
  country text,
  contact_name text,
  contact_email text,
  materials_supplied text,
  lead_time text,
  moq integer DEFAULT 1000,
  terms text,
  last_audit date,
  audit_score integer DEFAULT 0,
  on_time_rate integer DEFAULT 0,
  quality_score integer DEFAULT 0,
  status text DEFAULT 'Approved',
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS customers (
  id text NOT NULL,
  name text NOT NULL,
  region text,
  country text,
  sku_id text,
  channel text,
  contracted_vol integer DEFAULT 0,
  terms text,
  account_manager text,
  status text DEFAULT 'Active',
  tier text DEFAULT 'Tier 2',
  contact_name text,
  contact_email text,
  since date,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS purchase_orders (
  id text NOT NULL,
  sku_id text,
  supplier_id text,
  description text,
  qty integer,
  amount numeric,
  ordered_date date,
  expected_date date,
  status text DEFAULT 'Draft',
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  need_by_date date,
  supplier_name text,
  wo_id text,
  unit_price numeric,
  tax_rate numeric DEFAULT 0,
  currency text DEFAULT 'USD',
  payment_terms text DEFAULT 'Net 30',
  submitted_by text,
  submitted_at timestamp with time zone,
  approved_by text,
  approved_at timestamp with time zone,
  rejected_by text,
  rejected_at timestamp with time zone,
  approval_notes text,
  qty_received integer DEFAULT 0,
  qty_remaining integer DEFAULT 0,
  company_id uuid REFERENCES companies(id),
  esig_confirmed boolean DEFAULT false,
  esig_by text,
  esig_at timestamp with time zone,
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS purchase_requisitions (
  id text NOT NULL,
  sku_id text,
  qty integer NOT NULL,
  need_by_date date,
  status text DEFAULT 'Open',
  created_at timestamp with time zone DEFAULT now(),
  converted_po text,
  notes text,
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS goods_receipts (
  id text NOT NULL,
  gr_type text NOT NULL,
  po_id text,
  wo_id text,
  sku_id text,
  qty_received integer NOT NULL,
  batch_no text NOT NULL,
  mfg_date date NOT NULL,
  exp_date date NOT NULL,
  location text,
  status text DEFAULT 'Posted',
  received_by text,
  received_date date NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  reversal_reason text,
  reversed_by text,
  reversed_date date,
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS gr_component_lines (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  gr_id text NOT NULL,
  sku_id text,
  batch_id text,
  qty_consumed integer NOT NULL,
  notes text,
  company_id uuid REFERENCES companies(id)
);

CREATE TABLE IF NOT EXISTS sales_orders (
  id text NOT NULL,
  customer_id text,
  sku_id text,
  status text DEFAULT 'Draft',
  ordered_qty integer DEFAULT 0,
  allocated_qty integer DEFAULT 0,
  shipped_qty integer DEFAULT 0,
  unit_price numeric,
  order_date date,
  req_ship_date date,
  batch_assigned text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  customer_po_id text,
  customer_po_ref text,
  fulfilled_qty integer DEFAULT 0,
  invoice_id text,
  invoice_date date,
  due_date date,
  payment_terms text DEFAULT 'Net 30',
  tax_rate numeric DEFAULT 0,
  invoiced_at timestamp with time zone,
  invoiced_by text,
  paid_at timestamp with time zone,
  paid_by text,
  invoice_notes text,
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS so_fulfilments (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  so_id text,
  batch_id text,
  batch_no text NOT NULL,
  qty_fulfilled integer NOT NULL,
  fulfilled_date date NOT NULL,
  fulfilled_by text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  company_id uuid REFERENCES companies(id)
);

CREATE TABLE IF NOT EXISTS customer_pos (
  id text NOT NULL,
  customer_id text,
  customer_po_ref text NOT NULL,
  sku_id text,
  ordered_qty integer NOT NULL,
  unit_price numeric,
  order_date date,
  requested_delivery date,
  status text DEFAULT 'Received',
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS work_orders (
  id text NOT NULL,
  sku_id text,
  qty_planned integer NOT NULL,
  batch_size integer,
  status text DEFAULT 'Planned',
  need_by_date date,
  start_date date,
  completion_date date,
  converted_po text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS planned_orders (
  id text NOT NULL,
  sku_id text,
  type text NOT NULL,
  status text DEFAULT 'Suggested',
  qty integer NOT NULL,
  need_by_date date,
  firmed_by text,
  firmed_at timestamp with time zone,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS demand_forecast (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  sku_id text NOT NULL,
  period_date date NOT NULL,
  demand_qty integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  version_id text,
  notes text,
  company_id uuid REFERENCES companies(id)
);

CREATE TABLE IF NOT EXISTS forecast_versions (
  id text NOT NULL,
  name text NOT NULL,
  status text DEFAULT 'Draft',
  created_by text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  is_active boolean DEFAULT false,
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS scenarios (
  id text NOT NULL,
  name text NOT NULL,
  description text,
  forecast_version_id text,
  forecast_adj numeric DEFAULT 0,
  ss_months_override jsonb,
  lt_override jsonb,
  moq_override jsonb,
  expiry_adj_days integer DEFAULT 0,
  created_by text,
  created_at timestamp with time zone DEFAULT now(),
  last_run_at timestamp with time zone,
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS qc_records (
  id text NOT NULL,
  batch_id text,
  batch_no text,
  sku_id text,
  action text NOT NULL,
  checklist jsonb,
  coa_ref text,
  decision_by text,
  decision_at timestamp with time zone DEFAULT now(),
  notes text,
  company_id uuid REFERENCES companies(id),
  esig_confirmed boolean DEFAULT false,
  esig_by text,
  esig_at timestamp with time zone,
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS clinical_trials (
  id text NOT NULL,
  name text NOT NULL,
  phase text,
  indication text,
  status text DEFAULT 'Draft',
  trial_design text,
  total_patients integer,
  enrolment_months integer,
  treatment_months integer,
  enrolment_curve text DEFAULT 's_curve',
  enrolment_start_date date,
  dropout_rate_pct numeric DEFAULT 10,
  sponsor text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS clinical_arms (
  id text NOT NULL,
  trial_id text NOT NULL,
  arm_name text,
  arm_type text DEFAULT 'active',
  randomisation_ratio numeric DEFAULT 1,
  sku_id text,
  dose_per_visit numeric,
  dose_unit text DEFAULT 'units',
  overage_pct numeric DEFAULT 25,
  cohort_size integer,
  dose_label text,
  notes text,
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS clinical_visits (
  id text NOT NULL,
  trial_id text NOT NULL,
  visit_name text,
  visit_day integer DEFAULT 0,
  drug_dispensed boolean DEFAULT true,
  arm_id text,
  notes text,
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

CREATE TABLE IF NOT EXISTS clinical_forecasts (
  id text NOT NULL,
  trial_id text NOT NULL,
  scenario_name text,
  forecast_version_id text,
  assumptions jsonb,
  generated_at timestamp with time zone DEFAULT now(),
  generated_by text,
  company_id uuid REFERENCES companies(id),
  PRIMARY KEY (id, company_id)
);

-- ── Audit & Access Log Tables ──────────────────────────────
CREATE TABLE IF NOT EXISTS audit_log (
  id text NOT NULL PRIMARY KEY,
  entity text NOT NULL,
  entity_id text,
  action text NOT NULL,
  old_value jsonb,
  new_value jsonb,
  changed_by text,
  changed_at timestamp with time zone DEFAULT now(),
  notes text,
  company_id uuid REFERENCES companies(id)
);

CREATE TABLE IF NOT EXISTS batch_audit_log (
  id text NOT NULL PRIMARY KEY,
  batch_id text,
  batch_no text,
  sku_id text,
  event_type text NOT NULL,
  field_changed text,
  old_value text,
  new_value text,
  qty_delta integer,
  changed_by text,
  changed_at timestamp with time zone DEFAULT now(),
  notes text,
  company_id uuid REFERENCES companies(id)
);

CREATE TABLE IF NOT EXISTS bom_audit_log (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  parent_id text NOT NULL,
  child_id text NOT NULL,
  old_qty numeric,
  new_qty numeric NOT NULL,
  reason text,
  changed_by text,
  changed_at timestamp with time zone DEFAULT now(),
  company_id uuid REFERENCES companies(id)
);

CREATE TABLE IF NOT EXISTS access_log (
  id text NOT NULL PRIMARY KEY,
  user_id uuid,
  email text,
  company_id uuid REFERENCES companies(id),
  event text NOT NULL,
  ip_address text,
  user_agent text,
  attempted_at timestamp with time zone DEFAULT now()
);

-- ============================================================
-- TRIGGER: Auto-create user_profiles row on signup
-- ============================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    'viewer'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- FUNCTION: log_access_event (called from frontend)
-- ============================================================
CREATE OR REPLACE FUNCTION log_access_event(
  p_user_id uuid,
  p_email text,
  p_company_id uuid,
  p_event text,
  p_user_agent text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO access_log (id, user_id, email, company_id, event, user_agent, attempted_at)
  VALUES (
    gen_random_uuid()::text,
    p_user_id,
    p_email,
    p_company_id,
    p_event,
    p_user_agent,
    now()
  );
EXCEPTION WHEN OTHERS THEN
  NULL; -- Never fail on logging
END;
$$;

-- ============================================================
-- END OF SCHEMA
-- Run meridian_rls.sql next to enable Row Level Security
-- ============================================================

