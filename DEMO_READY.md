# UnityHub: DEMO_READY

Welcome Judges! This guide outlines the 3 specific steps to experience the "Magic" of our AI-verified Impact tracking system: KYC → Photo → Token.

### Step 1: NGO Task Acceptance & Identity (KYC)
- As a volunteer, log in to the UnityHub app using your secure digital identity (e.g., DigiLocker PKCE integration). 
- Open the map or task list and **Accept a Task** (e.g., "Beach Cleanup"). This binds your verified identity to the selected task.
- Hit `GET /api-setu/status` to see the **✅ Identity Verified badge** — no mTLS infra needed in demo mode.

### Step 2: Agentic Verification (Photo)
- Complete the physical task and tap **"Verify Impact"**.
- Upload or capture a photo of the completed work.
- Our custom **Gemini Vision AI + Embeddings Pipeline** analyzes the image in "Forensic Mode." It cross-checks for AI artifacts/fraud, then compares the semantic meaning of the image against the actual task requirements.
- *Wait a few seconds for Gemini to confirm a confidence score > 90%.*

### Step 3: Cryptographic Minting (Token)
- Once Gemini verifies your impact, the backend generates an **EIP-712 Cryptographic Signature** with a live on-chain nonce fetched from the `UnityImpact.sol` contract.
- You will immediately see a success screen displaying your newly minted **VIT (Volunteer Impact Tokens)**.
- The Polygon Amoy transaction hash will appear on the screen, proving your real-world impact is securely and transparently logged on the blockchain!

---

### Environment & Security Notes

| Item | Status |
|---|---|
| `backend/.env` in `.gitignore` | ✅ Line 1 of `.gitignore` — not committed |
| EIP-712 private key | ✅ Loaded from `.env` / GCP Secret Manager |
| Nonce replay protection | ✅ `nonces[to]++` in `UnityImpact.sol` + live fetch in `gemini_oracle.py` |
| Demo mode (mTLS bypass) | ✅ Set `DEMO_MODE=false` in `.env` before production |
| `seed.dart` in release builds | ✅ Gated behind `kDebugMode` — cannot run in production |
| Wallet integration | ✅ Real `web3dart` calls wired — `AppConstants.polygonAmoyContractAddress` needs real deployed address |
| Analytics data | ⚠️ Sample data — labelled in UI. Will pull from on-chain events post-demo |
