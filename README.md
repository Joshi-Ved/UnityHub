# UnityHub — Verified Impact Protocol

UnityHub is a mobile-first volunteer impact platform where real-world social work is:
- **Verified with AI** (Gemini 1.5 Pro forensic + semantic checks via Cloudinary URLs),
- **Linked to identity/KYC** (Firebase Auth → DigiLocker-style Aadhaar hashing),
- **Recorded as on-chain reward claims** (EIP-712 signed VIT minting via Polygon Amoy),
- **Persisted in a live database** (NeonDB PostgreSQL — immutable ImpactLog audit trail).

---

## Final Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        UNITYHUB TRUST LAYER                         │
│                                                                     │
│  Flutter (Mobile / Web)                                             │
│  ├── Firebase Auth ──────────────────────── Identity (UID)          │
│  ├── DigiLocker PKCE ─────► SHA-256 ImpactID ─► Zero PII           │
│  ├── Camera / ImagePicker ──► Cloudinary Upload                     │
│  └── web3dart ──────────────► Polygon Amoy Mint                     │
│            │                                                        │
│            │ HTTPS / multipart                                      │
│            ▼                                                        │
│  FastAPI Backend (Uvicorn)                                          │
│  ├── /verify-impact                                                 │
│  │   ├── 1. Cloudinary Upload → secure_url                          │
│  │   ├── 2. Gemini 1.5 Pro Forensic Analysis (via Cloudinary URL)   │
│  │   ├── 3. Gemini Embeddings Cosine Similarity (≥ 0.90)            │
│  │   ├── 4. Pinata IPFS metadata pin                                │
│  │   ├── 5. EIP-712 Signature Generation                            │
│  │   └── 6. ImpactLog → NeonDB (persistent, tamper-evident)        │
│  ├── /api/analytics/dashboard → live NeonDB SQL aggregates          │
│  ├── /api/tasks → NeonDB Task table                                 │
│  └── /api-setu/* → PKCE + mTLS DigiLocker flow                     │
│            │                                                        │
│            ▼                                                        │
│  NeonDB (PostgreSQL)                                                │
│  ├── tasks          – NGO task registry                             │
│  ├── users          – Firebase UID + ImpactID (no PII)              │
│  └── impact_logs    – Cloudinary URL + IPFS URI + EIP-712 sig       │
│            │                                                        │
│  Polygon Amoy                                                       │
│  └── ImpactToken.sol (ERC-1155) – onlyOracle mint + nonce replay   │
│            │                                                        │
│  External Services                                                  │
│  ├── Cloudinary    – Proof image hosting                            │
│  ├── Pinata IPFS   – Immutable metadata storage                     │
│  └── Google Cloud  – Gemini API + Secret Manager                    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

### Frontend (`frontend/mobile`)
- Flutter + Dart
- Firebase Auth (anonymous for volunteers, Google OAuth for NGO)
- Riverpod (state management)
- GoRouter (routing)
- Google Maps + Camera/Image Picker
- FL Chart, DataTable2, Printing
- web3dart for on-chain interactions

### Backend (`backend`)
- FastAPI + Uvicorn
- Gemini 1.5 Pro (`google-genai`) — forensic analysis + embedding similarity
- Cloudinary — async proof image upload (SHA-1 signed REST API)
- Pinata — IPFS metadata pinning
- Web3 + eth-account — EIP-712 nonce/signature flow
- SQLAlchemy + NeonDB (PostgreSQL) — ImpactLog + Task + User persistence
- SlowAPI rate-limiting

### Blockchain (`contracts`)
- Hardhat + Solidity
- ImpactToken.sol (ERC-1155) with `onlyOracle` mint gate + nonce replay protection

---

## Key Features

1. **Identity / KYC flow**
   - Firebase Auth for session management
   - DigiLocker-style endpoints under `/api-setu/*`
   - Aadhaar → SHA-256 ImpactID (zero PII stored anywhere)

2. **AI-powered verification**
   - Cloudinary URL passed directly to Gemini (no base64 overhead)
   - Fraud/screenshot forensic detection
   - Task-photo semantic similarity scoring (cosine, threshold 0.90)
   - Duplicate image detection (SHA-256 in-memory hash set)

3. **Reward mint pipeline**
   - Backend returns EIP-712 cryptographic signature
   - Frontend submits `verifyAndMint` transaction via web3dart
   - Nonce-based replay protection (on-chain + in-memory)
   - Success screen with clickable Polygonscan link

4. **Admin / NGO tools**
   - Live KPI dashboard backed by NeonDB SQL aggregates
   - Task creation with DB persistence
   - Verification logs with full audit trail
   - ESG report export with real VIT totals

5. **Security (OWASP 2026)**
   - CORS + TrustedHost middleware
   - HSTS, CSP, X-Frame-Options, X-Content-Type-Options headers
   - mTLS for DigiLocker endpoints (bypassed in DEMO_MODE only)
   - GCP Secret Manager for private key (env var fallback)

---

## Setup

### 1) Backend

```bash
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1   # Windows PowerShell
pip install -r requirements.txt
```

Create `backend/.env` (root `.env` is also supported):

```env
DEMO_MODE=true
Gemini_Api_key=your_gemini_key
SIMILARITY_THRESHOLD=0.90
POLYGON_AMOY_RPC_URL=https://rpc-amoy.polygon.technology/
CONTRACT_ADDRESS=0x...
BACKEND_PRIVATE_KEY=0x...
PINATA_JWT=eyJ...
Neon_db=postgresql://user:pass@host/db?sslmode=require
CLOUDINARY_URL=cloudinary://api_key:api_secret@cloud_name
```

Run backend:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 2) Flutter App

```bash
cd frontend/mobile
flutter pub get
flutter run
```

### 3) Smart Contracts

```bash
cd contracts
npm install
npx hardhat test
```

---

## API Error Contract

```json
{
  "error": {
    "code": "string_code",
    "message": "User-safe message",
    "retryable": false
  }
}
```

| Code | HTTP | Meaning |
|---|---|---|
| `invalid_address` | 400 | Bad EVM address |
| `fraud_detected` | 403 | Gemini forensic rejection |
| `duplicate_submission` | 409 | Same photo hash reused |
| `task_mismatch` | 422 | Cosine similarity < 0.90 |
| `invalid_image` | 422 | Corrupted image bytes |
| `db_error` | 500 | Retryable NeonDB failure |

---

## Demo Flow

See `DEMO_READY.md` for judge script:
1. **KYC Badge** — `GET /api-setu/status`
2. **Photo Verification** — Gemini forensic + semantic check
3. **Token Mint** — EIP-712 signature + Polygon Amoy + Polygonscan link

---

## Security Notes

- Raw Aadhaar is NEVER stored. Only SHA-256 ImpactID reaches the database.
- `DEMO_MODE=true` bypasses mTLS. Set to `false` for production.
- Private key is fetched from GCP Secret Manager; env var is the fallback.
- All ImpactLog rows are immutable once committed to NeonDB.