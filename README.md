# UnityHub - Verified Impact Protocol

UnityHub is a mobile-first volunteer impact platform where real-world social work is:
- verified with AI (Gemini forensic + semantic checks),
- linked to identity/KYC (DigiLocker-style flow in demo),
- and recorded as on-chain reward claims (VIT minting flow).

The app has two primary experiences:
- **Volunteer app (mobile):** discover tasks, submit proof, verify impact, track wallet.
- **Admin/NGO app (mobile-adaptive):** manage tasks, view analytics, review verification logs, generate reports.

---

## Current Scope

- Flutter app is optimized for **mobile usability** (including compact admin layouts).
- Web is not treated as a primary target surface.
- Backend is FastAPI with consistent structured error responses.

---

## Tech Stack

### Frontend (`frontend/mobile`)
- Flutter + Dart
- Riverpod (state management)
- GoRouter (routing)
- Google Maps + Camera/Image Picker
- FL Chart, DataTable2, Printing
- web3dart for on-chain interactions

### Backend (`backend`)
- FastAPI + Uvicorn
- Gemini (`google-genai`) for analysis/embeddings
- Web3 + eth-account for nonce/signature flow
- SlowAPI rate-limiting
- httpx for external HTTP calls (IPFS/Pinata flow)

---

## Key Features

1. **Identity/KYC flow (demo-capable)**
   - DigiLocker-style endpoints under `/api-setu/*`
   - Demo mode supports no-mTLS local testing

2. **AI-powered verification**
   - Fraud/screenshot checks (forensic mode)
   - Task-photo semantic similarity scoring
   - Duplicate image detection

3. **Reward mint pipeline**
   - Backend returns cryptographic signature
   - Frontend submits mint transaction (VIT)
   - Nonce-based replay protection

4. **Admin tools**
   - Task management
   - Verification logs review
   - Analytics dashboard
   - ESG report preview/export flow

---

## Monorepo Structure

```text
UnityHub/
  backend/                 # FastAPI services and routes
  frontend/mobile/         # Flutter mobile app (volunteer + admin)
  DEMO_READY.md            # Demo walkthrough for judges
```

---

## Setup

## 1) Backend

From repo root:

```bash
cd backend
python -m venv .venv
# Windows PowerShell
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Create `backend/.env` (example values):

```env
DEMO_MODE=true
GEMINI_API_KEY=your_key
SIMILARITY_THRESHOLD=0.90
POLYGON_RPC_URL=https://rpc-amoy.polygon.technology/
CONTRACT_ADDRESS=0x...
BACKEND_PRIVATE_KEY=0x...
PINATA_JWT=...
GOOGLE_CLOUD_PROJECT=...
```

Run backend:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## 2) Flutter mobile app

```bash
cd frontend/mobile
flutter pub get
flutter run
```

Set API base URL in config/constants to match backend host if needed.

---

## API Error Contract (standardized)

All handled errors now use a consistent envelope:

```json
{
  "error": {
    "code": "string_code",
    "message": "User-safe message",
    "retryable": false
  }
}
```

Validation errors include optional `details`.

Examples:
- `400` invalid address
- `401/403` auth/mTLS failures
- `409` duplicate submission
- `422` invalid image/task mismatch
- `5xx` upstream/service failures

---

## Frontend Quality Improvements Implemented

- Typed route constants via `core/router/app_routes.dart`
- Shared state widgets:
  - `AppLoadingState`
  - `AppErrorState`
  - `AppEmptyState`
- Mobile fallbacks for table-heavy screens
- Centralized theme tokens and removal of hardcoded color usage
- Compact admin navigation for smaller devices

---

## Demo Flow

Use `DEMO_READY.md` for judge/demo script:
1. Identity/KYC badge flow
2. Photo verification with Gemini
3. Signature + token mint confirmation

---

## Security Notes

- Do not commit secrets (`.env` stays local).
- `DEMO_MODE=true` is only for demos/local testing.
- Set `DEMO_MODE=false` and enforce real auth/mTLS for production.
- Private key should come from secure secret manager in production.

---

## Troubleshooting

- **Backend import/test issues:** run tests from `backend/` and ensure dependencies are installed in the active venv.
- **Flutter can’t reach backend:** confirm API base URL and local network/port.
- **Verification failures:** inspect backend response `error.code` and `error.message` for clear client handling.