from datetime import datetime
from typing import Optional

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field


router = APIRouter(prefix="/api", tags=["Admin"])


class DashboardQuery(BaseModel):
    org_id: str
    range: str


class CreateTaskRequest(BaseModel):
    title: str = Field(min_length=3)
    description: str = Field(min_length=3)
    token_reward: int = Field(gt=0)
    verification_criteria: str = Field(min_length=5)
    ngo_name: Optional[str] = "UnityHub NGO"


_TASKS = [
    {
        "id": "t_101",
        "title": "Beach Cleanup Drive",
        "description": "Collect and sort plastic waste from the north shoreline.",
        "ngo_name": "Ocean Savers",
        "status": "available",
        "token_reward": 15,
        "verification_criteria": "Photo must show filled trash bags and shoreline section.",
        "created_at": "2026-04-24T09:30:00Z",
    },
    {
        "id": "t_102",
        "title": "Tree Plantation",
        "description": "Plant native saplings in the ward 14 green belt.",
        "ngo_name": "Green Earth",
        "status": "in-progress",
        "token_reward": 20,
        "verification_criteria": "Photo must show newly planted sapling with volunteer.",
        "created_at": "2026-04-24T14:00:00Z",
    },
]

_TASK_LOGS = {
    "t_101": [
        "2026-04-25T08:00:00Z: Task published by Ocean Savers",
        "2026-04-25T10:15:00Z: 3 volunteers accepted the task",
        "2026-04-25T12:00:00Z: 2 submissions received for verification",
    ],
    "t_102": [
        "2026-04-25T09:00:00Z: Task published by Green Earth",
        "2026-04-25T13:40:00Z: 1 submission approved and minted",
    ],
}

_ACTIVITY = [
    {"volunteer_name": "Rahul M.", "task_name": "Beach Cleanup", "vit_minted": 15},
    {"volunteer_name": "Sneha P.", "task_name": "Tree Plantation", "vit_minted": 20},
    {"volunteer_name": "Aman K.", "task_name": "Food Distribution", "vit_minted": 30},
]


@router.get("/analytics/dashboard")
async def analytics_dashboard(org_id: str = "demo-org", range: str = "30d"):
    _ = DashboardQuery(org_id=org_id, range=range)
    return {
        "kpi": {
            "verified_hours": 1250,
            "active_volunteers": 85,
            "tasks_completed": 420,
            "vit_minted": 15400,
        },
        "leaderboard": [
            {"name": "Sneha P.", "tasks": 45, "vit": 1200, "score": 98},
            {"name": "Rahul M.", "tasks": 38, "vit": 950, "score": 92},
            {"name": "Priya S.", "tasks": 32, "vit": 800, "score": 89},
        ],
    }


@router.get("/analytics/activity")
async def analytics_activity(org_id: str = "demo-org"):
    _ = org_id
    return {"activity": _ACTIVITY}


@router.get("/tasks")
async def list_tasks(org_id: str = "demo-org"):
    _ = org_id
    return {"tasks": _TASKS}


@router.post("/tasks/create")
async def create_task(payload: CreateTaskRequest):
    new_id = f"t_{100 + len(_TASKS) + 1}"
    task = {
        "id": new_id,
        "title": payload.title,
        "description": payload.description,
        "ngo_name": payload.ngo_name or "UnityHub NGO",
        "status": "available",
        "token_reward": payload.token_reward,
        "verification_criteria": payload.verification_criteria,
        "created_at": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
    }
    _TASKS.append(task)
    _TASK_LOGS[new_id] = [f"{task['created_at']}: Task created via admin portal"]
    return {"status": "success", "message": "Task created", "task": task}


@router.get("/tasks/{task_id}/logs")
async def task_logs(task_id: str):
    logs = _TASK_LOGS.get(task_id)
    if logs is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return {"task_id": task_id, "logs": logs}


@router.get("/reports/export")
async def export_report(org_id: str, from_date: str, to_date: str):
    report_id = f"rpt_{org_id}_{from_date}_{to_date}".replace("-", "")
    return {
        "status": "success",
        "report_id": report_id,
        "message": "Report generation started",
        "download_url": f"https://unityhub.app/reports/{report_id}.pdf",
    }