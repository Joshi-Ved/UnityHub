# Security Audit & Policies

## Overview
This document outlines the security posture, tools, and processes employed within the UnityHub repository. 

## Architectural Security Measures

### Backend (FastAPI)
1. **Input Validation**: All incoming requests are strictly validated using Pydantic schemas. 
2. **OWASP Middleware**: The API employs state-of-the-art OWASP 2026 recommended security middleware, including:
   - **CORS** (Cross-Origin Resource Sharing) strictly allowing only specified origins.
   - **HSTS** (HTTP Strict Transport Security).
   - **Content-Security-Policy (CSP)** and other Secure HTTP Headers.
   - **Rate Limiting** to prevent brute-force and DDoS attacks.
3. **Authentication/Authorization**: Endpoints enforcing business logic (like `/verify-impact`) require rigorous authentication.

### Smart Contracts (Solidity)
1. **Access Control**: The `verifyAndMint` function in `ImpactToken.sol` is restricted strictly to the verified AI Oracle wallet address using a custom modifier.
2. **Reentrancy Protection**: Standard reentrancy guards are deployed.
3. **ERC-1155 Standard**: Adhering strictly to OpenZeppelin's ERC-1155 implementation.

## Vulnerability Scanning
As mandated in `AGENTS.md`, all code pushed to this repository must undergo automated vulnerability scanning (SAST/DAST) prior to integration.

- **Python/Backend**: Scanned using tools like Bandit and Safety.
- **Solidity/Contracts**: Scanned using tools like Slither and Mythril.
