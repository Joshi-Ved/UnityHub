# 📝 THINGS TO DO — UnityHub Project

This document tracks the remaining tasks and roadmap items to move from the current demo state to a production-ready platform.

## 🚀 High Priority (Post-Migration Cleanup)
- [ ] **Run `flutter pub get`**: Sync the newly added `mapbox_maps_flutter` and other dependencies in `frontend/mobile`.
- [ ] **Verify BigQuery Permissions**: Ensure the Google Cloud Service Account has `BigQuery Data Editor` and `BigQuery Job User` roles.
- [ ] **Test Mapbox on Real Device**: Verify that the Mapbox tiles render correctly on Android/iOS (may require additional native config in `AndroidManifest.xml` and `Info.plist`).

## 🛡️ Identity & Security (Trust Layer)
- [ ] **Aadhaar eKYC Integration**: Replace the current Anonymous Auth (simulated) with a real DigiLocker PKCE or Aadhaar OTP flow.
- [ ] **mTLS Implementation**: Disable `DEMO_MODE` and configure NGINX with Mutual TLS for secure Oracle-to-Backend communication.
- [ ] **PII Erasure Audit**: Perform a final audit to ensure no raw PII (like raw Aadhaar numbers) ever hits the logs or BigQuery.

## ⛓️ Blockchain & Smart Contracts
- [ ] **Amoy Contract Deployment**: Deploy `ImpactToken.sol` to the Polygon Amoy testnet.
- [ ] **Update Contract Address**: Set `UNITY_IMPACT_CONTRACT_ADDRESS` in `.env` once deployed.
- [ ] **Gas Optimization**: Review the `verifyAndMint` function for potential gas savings during bulk minting.
- [ ] **EIP-712 Domain Separator**: Update the `verifyingContract` address from the sentinel `0x0...1` to the actual deployed contract address.

## 📊 Analytics & Reporting
- [ ] **Expand BigQuery Schema**: Add more granular fields to `impact_logs` (e.g., location coordinates, category tags) for deeper ESG insights.
- [ ] **PDF Report Customization**: Finish the PDF generation logic in `backend/routes/admin.py` to use real dynamic data instead of the current summary.
- [ ] **Volunteer Analytics**: Create a BigQuery-backed view for volunteers to see their own impact trends in the mobile app.

## 🎨 UI/UX Polishing
- [ ] **Dark Mode Support**: Ensure all new Mapbox and BigQuery-wired components support the theme's dark mode.
- [ ] **Interactive Charts**: Make the BarChart in the Admin Dashboard interactive (tap to see details for each funnel stage).
- [ ] **Loading States**: Add skeleton loaders to all analytics cards to improve the "feel" during BigQuery query latency.

## 🧪 Testing & DevOps
- [ ] **Integration Tests**: Write end-to-end tests covering the flow from Photo Upload → Gemini Analysis → BigQuery Sync → On-chain Minting.
- [ ] **Load Testing**: Test BigQuery insertion rates and NeonDB connection pooling under simulated heavy load.
- [ ] **CI/CD Pipeline**: Set up GitHub Actions to run `pytest` and `flutter test` on every push.
