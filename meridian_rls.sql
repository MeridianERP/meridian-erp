-- ============================================================
-- MERIDIAN ERP — Row Level Security Policies
-- MRD-DB-002 v1.0
-- Generated: April 2026
--
-- USAGE: Run this file AFTER meridian_schema.sql
-- This enables RLS on all tables and creates company-isolation
-- policies so each client can only access their own data.
-- ============================================================

-- ── Enable RLS on all tables ──────────────────────────────
ALTER TABLE companies             ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles         ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings          ENABLE ROW LEVEL SECURITY;
ALTER TABLE materials             ENABLE ROW LEVEL SECURITY;
ALTER TABLE skus                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE bom_lines             ENABLE ROW LEVEL SECURITY;
ALTER TABLE bom_audit_log         ENABLE ROW LEVEL SECURITY;
ALTER TABLE planning_config       ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches               ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage_locations     ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_transfers   ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers             ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers             ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders       ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_requisitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE goods_receipts        ENABLE ROW LEVEL SECURITY;
ALTER TABLE gr_component_lines    ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_orders          ENABLE ROW LEVEL SECURITY;
ALTER TABLE so_fulfilments        ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_pos          ENABLE ROW LEVEL SECURITY;
ALTER TABLE work_orders           ENABLE ROW LEVEL SECURITY;
ALTER TABLE planned_orders        ENABLE ROW LEVEL SECURITY;
ALTER TABLE demand_forecast       ENABLE ROW LEVEL SECURITY;
ALTER TABLE forecast_versions     ENABLE ROW LEVEL SECURITY;
ALTER TABLE scenarios             ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_records            ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinical_trials       ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinical_arms         ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinical_visits       ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinical_forecasts    ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log             ENABLE ROW LEVEL SECURITY;
ALTER TABLE batch_audit_log       ENABLE ROW LEVEL SECURITY;
ALTER TABLE access_log            ENABLE ROW LEVEL SECURITY;

-- ── RLS Policies ──────────────────────────────────────────
-- All policies use get_my_company_id() which returns the
-- company_id from user_profiles for the current auth.uid()

CREATE POLICY "own_company" ON companies
  FOR ALL USING (id = get_my_company_id());

CREATE POLICY "company_isolation" ON user_profiles
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

-- Admin read-all policy — allows admins to see all user profiles
-- in their company (required for User Management module)
CREATE POLICY "admin_read_all_profiles" ON user_profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
      AND company_id = get_my_company_id()
    )
  );

CREATE POLICY "company_isolation" ON app_settings
  FOR ALL USING (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON materials
  FOR ALL USING (company_id = get_my_company_id() AND get_my_company_id() IS NOT NULL)
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON skus
  FOR ALL USING (company_id = get_my_company_id() AND get_my_company_id() IS NOT NULL)
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON bom_lines
  FOR ALL USING (company_id = get_my_company_id() AND get_my_company_id() IS NOT NULL)
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON bom_audit_log
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON planning_config
  FOR ALL USING (company_id = get_my_company_id() AND get_my_company_id() IS NOT NULL)
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON batches
  FOR ALL USING (company_id = get_my_company_id() AND get_my_company_id() IS NOT NULL)
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON storage_locations
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON inventory_transfers
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON suppliers
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON customers
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON purchase_orders
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON purchase_requisitions
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON goods_receipts
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON gr_component_lines
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON sales_orders
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON so_fulfilments
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON customer_pos
  FOR ALL USING (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON work_orders
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON planned_orders
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON demand_forecast
  FOR ALL USING (company_id = get_my_company_id() AND get_my_company_id() IS NOT NULL)
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON forecast_versions
  FOR ALL USING (company_id = get_my_company_id() AND get_my_company_id() IS NOT NULL)
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON scenarios
  FOR ALL USING (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON qc_records
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON clinical_trials
  FOR ALL USING (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON clinical_arms
  FOR ALL USING (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON clinical_visits
  FOR ALL USING (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON clinical_forecasts
  FOR ALL USING (company_id = get_my_company_id());

CREATE POLICY "audit_log_select" ON audit_log
  FOR SELECT USING (company_id = get_my_company_id());

CREATE POLICY "company_isolation" ON batch_audit_log
  FOR ALL USING (company_id = get_my_company_id())
  WITH CHECK (company_id = get_my_company_id());

CREATE POLICY "access_log_select" ON access_log
  FOR SELECT USING (company_id = get_my_company_id());

-- Allow the log_access_event function to insert (SECURITY DEFINER bypasses RLS)
-- No INSERT policy needed on access_log — the function handles it

-- ============================================================
-- VERIFICATION QUERY
-- Run this after applying policies to confirm all tables
-- have RLS enabled:
--
-- SELECT tablename, rowsecurity 
-- FROM pg_tables 
-- WHERE schemaname = 'public' 
-- ORDER BY tablename;
--
-- All rows should show rowsecurity = true
-- ============================================================

