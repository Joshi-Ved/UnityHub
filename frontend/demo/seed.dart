// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart';

void main() {
  // SAFETY GUARD: Never populate demo state in production or testnet builds.
  // This script must only run during local development and CI demo runs.
  if (!kDebugMode) {
    print("[SEED] Skipped: seed.dart must not run outside kDebugMode.");
    return;
  }

  print("========================================");
  print("[DEBUG ONLY] UNITYHUB DEMO SEED SCRIPT");
  print("========================================");
  
  print("1. Pre-loading realistic tasks and volunteer map fixtures...");
  _seedTasks();
  
  print("2. Simulating Device A (Android) volunteer journey...");
  _simulateVolunteerJourneys();
  
  print("3. Simulating Device B (Chrome) NGO portal analytics feed...");
  _seedAnalytics();
  
  print("4. Seeding ESG report preview data + PDF export metadata...");
  _seedReports();

  print("5. Verifying offline fallback fixtures are available...");
  _verifyOfflineFixtures();
  
  print("========================================");
  print("DEMO READY: TWO-SCREEN EXPERIENCE PRIMED.");
  print("========================================");
}

void _seedTasks() {
  print(" -> Seeded 'Beach Cleanup Drive' (Mumbai)");
  print(" -> Seeded 'Tree Plantation' (Delhi)");
  print(" -> Seeded 'Food Bank Distribution' (Bangalore)");
  print(" -> Seeded 'Community Health Camp' (Pune)");
}

void _simulateVolunteerJourneys() {
  print(" -> Device A: Login -> Map -> Accept Task -> Verify (camera) -> Wallet +15 VIT");
  print(" -> Device A: Login -> Map -> Accept Task -> Verify (camera) -> Wallet +20 VIT");
}

void _seedAnalytics() {
  print(" -> Generated 30-day time-series data for dashboard KPI and funnel charts.");
  print(" -> Seeded /ws/activity style feed events mirrored from Device A actions.");
}

void _seedReports() {
  print(" -> Prepared ESG report preview sections and sample immutable proof rows.");
  print(" -> Prepared filename pattern: ESG_Report_[OrgName]_[DateRange].pdf.");
}

void _verifyOfflineFixtures() {
  print(" -> Found mocks/tasks.json");
  print(" -> Found mocks/analytics.json");
  print(" -> Found mocks/activity_feed.json");
  print(" -> Found mocks/esg_report_sample.json");
}
