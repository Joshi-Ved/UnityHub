# 📝 THING TO DO — UnityHub Project Roadmap

This is the definitive list of tasks remaining to move the UnityHub platform from a static demo to a fully dynamic, production-ready ESG impact system.

## 🔴 CRITICAL: Make All Pages Dynamic
Currently, several screens still rely on hardcoded "sample data" logic. These must be wired to the backend APIs.
- [ ] **Task Management Screen**: 
    - [ ] Replace `_rows` hardcoded list with `AdminApi().fetchTasks()`.
    - [ ] Implement actual `createTask` logic to persist new tasks to NeonDB.
    - [ ] Wire the "Task Detail Panel" to fetch logs via `AdminApi().fetchTaskLogs()`.
- [ ] **Volunteer Directory**:
    - [ ] Ensure the "Recent Activity" feed shows real Cloudinary proof URLs and Gemini confidence scores.
- [ ] **Reports Screen**:
    - [ ] Implement real PDF generation logic in the backend (using a library like `fpdf` or `ReportLab`) that pulls actual stats from BigQuery.

## 🗺️ Map & UI Enhancements
- [ ] **Mapbox Polish**:
    - [ ] Add custom Mapbox styles (e.g., UnityHub Green theme).
    - [ ] Implement "Cluster" view for high-density task areas.
- [ ] **Global Search**: Implement a working global search across Tasks, Volunteers, and Impact Logs.

## 🏢 Infrastructure & Data (BigQuery)
- [ ] **Historical Data Migration**: Sync existing NeonDB records to BigQuery for a complete historical view.
- [ ] **Automated Daily Sync**: Set up a CRON job or cloud function to ensure NeonDB and BigQuery stay perfectly in sync.
- [ ] **Service Account Configuration**: Safely inject the GCP Service Account JSON into the environment for BigQuery access.

## 🛡️ Security & Identity
- [ ] **Full eKYC**: Replace the "Anonymous Auth" simulation with a real Aadhaar/DigiLocker verification flow.
- [ ] **On-chain Verification**: Deploy the `ImpactToken.sol` contract and update the backend to call the `verifyAndMint` function on Polygon Amoy.

## 🧪 Testing & Validation
- [ ] **Smoke Test Suite**: Complete the `smoke_test.py` to cover all new BigQuery and Mapbox endpoints.
- [ ] **Performance Benchmarking**: Verify the latency of Gemini-to-BigQuery sync under load.

---
*Created on 2026-04-28*
