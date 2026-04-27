from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import uuid

from database import get_db
from models import Task
from schemas import TaskCreateRequest, TaskResponse

router = APIRouter(prefix="/tasks", tags=["Tasks"])


def _task_to_response(task: Task) -> TaskResponse:
    skills = [s for s in (task.skills_csv or "").split(",") if s]
    return TaskResponse(
        id=task.id,
        title=task.title,
        ngo_name=task.ngo_name,
        distance_km=task.distance_km,
        skills=skills,
        token_reward=task.token_reward,
        lat=task.lat,
        lng=task.lng,
        status=task.status,
    )


@router.get("", response_model=list[TaskResponse])
async def list_tasks(status: str = "available", db: Session = Depends(get_db)):
    query = db.query(Task)
    if status:
        query = query.filter(Task.status == status)
    tasks = query.order_by(Task.created_at.desc()).all()
    return [_task_to_response(t) for t in tasks]


@router.post("", response_model=TaskResponse)
async def create_task(payload: TaskCreateRequest, db: Session = Depends(get_db)):
    if not payload.title.strip():
        raise HTTPException(
            status_code=400,
            detail={"code": "invalid_task_title", "message": "Task title is required.", "retryable": False},
        )
    task = Task(
        id=f"task_{uuid.uuid4().hex[:12]}",
        title=payload.title.strip(),
        ngo_name=payload.ngo_name.strip() or "Admin Created",
        description=payload.description or "",
        status="available",
        token_reward=payload.token_reward,
        distance_km=0.0,
        lat=payload.lat,
        lng=payload.lng,
        skills_csv=",".join(payload.skills),
        verification_criteria=payload.verification_criteria or "",
    )
    db.add(task)
    db.commit()
    db.refresh(task)
    return _task_to_response(task)
