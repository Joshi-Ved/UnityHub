# UnityHub API Contracts

This document defines the interface between the Flutter Frontend and the FastAPI Backend for the UnityHub Hackathon project. All REST endpoints use JSON.

## Authentication
All authenticated endpoints require a Bearer token in the Authorization header.
`Authorization: Bearer <JWT_TOKEN>`

---

## 1. Map & Tasks (Volunteer)

### `GET /api/tasks/nearby`
Fetch tasks near the volunteer's current location.
- **Query Params**:
  - `lat` (float): Latitude
  - `lng` (float): Longitude
  - `radius` (float): Radius in km
- **Response** (200 OK):
  ```json
  {
    "tasks": [
      {
        "id": "t_123",
        "title": "Beach Cleanup Drive",
        "ngo_name": "Ocean Savers",
        "distance_km": 2.5,
        "skills": ["Physical Labor"],
        "token_reward": 15,
        "location": {"lat": 19.0760, "lng": 72.8777},
        "status": "available"
      }
    ]
  }
  ```

### `POST /api/tasks/accept`
Volunteer accepts a task.
- **Body**:
  ```json
  {
    "task_id": "t_123",
    "volunteer_id": "v_456"
  }
  ```
- **Response** (200 OK):
  ```json
  {"status": "success", "message": "Task accepted"}
  ```

### `POST /api/verify/task`
Submit proof of work to Gemini via the gateway.
- **Body** (multipart/form-data or Base64 JSON):
  ```json
  {
    "task_id": "t_123",
    "photo_b64": "iVBORw0KGgo...",
    "gps": {"lat": 19.0760, "lng": 72.8777, "accuracy": 4.5}
  }
  ```
- **Response** (200 OK):
  ```json
  {
    "verified": true,
    "vit_minted": 15,
    "tx_hash": "0xabc123def456",
    "gemini_reason": "Proof criteria met: Garbage bags visible and GPS match."
  }
  ```

---

## 2. Wallet & Profile (Volunteer)

### `GET /api/wallet/:volunteer_id`
Fetch volunteer's token balance and transaction history.
- **Response** (200 OK):
  ```json
  {
    "total_vit": 450,
    "impact_score": 0.75,
    "badges": ["b_1", "b_2"],
    "transactions": [
      {
        "task_name": "Beach Cleanup",
        "date": "2026-04-25T10:00:00Z",
        "vit_earned": 15,
        "tx_hash": "0xabc123def456"
      }
    ]
  }
  ```

---

## 3. Analytics & Management (NGO Admin)

### `GET /api/analytics/dashboard`
Fetch NGO KPIs and Leaderboard.
- **Query Params**:
  - `org_id` (string)
  - `range` (string) e.g., '7d', '30d'
- **Response** (200 OK):
  ```json
  {
    "kpi": {
      "verified_hours": 1250,
      "active_volunteers": 85,
      "tasks_completed": 420,
      "vit_minted": 15400
    },
    "leaderboard": [
      {"name": "Sneha P.", "tasks": 45, "vit": 1200}
    ]
  }
  ```

### `POST /api/tasks/create`
Create a new volunteer task.
- **Body**:
  ```json
  {
    "title": "Tree Plantation",
    "description": "Plant 100 saplings in the local park.",
    "location": {"lat": 19.0800, "lng": 72.8800},
    "token_reward": 20,
    "verification_criteria": "Photo must show newly planted sapling with volunteer."
  }
  ```

### `GET /api/reports/export`
Trigger PDF generation for ESG Report.
- **Query Params**: `org_id`, `from_date`, `to_date`
- **Response** (200 OK): Returns a binary PDF blob or a temporary S3 download link.

---

## 4. WebSockets (Real-time)

### `WS /ws/tasks`
Streams updates when new tasks are created or status changes.

### `WS /ws/activity`
Streams live activity logs for the NGO dashboard.
```json
{
  "type": "VERIFICATION_SUCCESS",
  "volunteer_name": "Rahul M.",
  "task_name": "Beach Cleanup",
  "vit_minted": 15
}
```
