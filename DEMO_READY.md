# UnityHub: DEMO_READY

Welcome Judges! This guide outlines the 3 specific steps to experience the "Magic" of our AI-verified Impact tracking system: KYC -> Photo -> Token.

### Step 1: NGO Task Acceptance & Identity (KYC)
- As a volunteer, log in to the UnityHub app using your secure digital identity (e.g., DigiLocker PKCE integration). 
- Open the map or task list and **Accept a Task** (e.g., "Beach Cleanup"). This binds your verified identity to the selected task.

### Step 2: Agentic Verification (Photo)
- Complete the physical task and tap **"Verify Impact"**.
- Upload or capture a photo of the completed work.
- Our custom **Gemini 3.1 Pro + Embeddings AI Pipeline** analyzes the image in "Forensic Mode." It cross-checks for AI artifacts/fraud, then compares the semantic meaning of the image against the actual task requirements.
- *Wait a few seconds for Gemini to confirm a confidence score > 90%.*

### Step 3: Cryptographic Minting (Token)
- Once Gemini verifies your impact, the backend generates an **EIP-712 Cryptographic Signature**.
- You will immediately see a success screen displaying your newly minted **VIT (Volunteer Impact Tokens)**.
- The Polygon Amoy transaction hash will appear on the screen, proving your real-world impact is securely and transparently logged on the blockchain!

> **Note:** For this demo, a placeholder has been set for the Polygon Amoy contract. The underlying workflow and signature generation logic is fully functional and ready for mainnet!
