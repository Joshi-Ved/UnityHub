from fastapi.testclient import TestClient

from main import app


client = TestClient(app, base_url='http://localhost')


def test_admin_dashboard_and_activity_endpoints():
    dashboard = client.get('/api/analytics/dashboard', params={'org_id': 'demo-org', 'range': '30d'})
    activity = client.get('/api/analytics/activity', params={'org_id': 'demo-org'})

    assert dashboard.status_code == 200
    assert activity.status_code == 200

    dashboard_body = dashboard.json()
    assert 'kpi' in dashboard_body
    assert 'leaderboard' in dashboard_body

    activity_body = activity.json()
    assert 'activity' in activity_body
    assert isinstance(activity_body['activity'], list)


def test_create_task_and_fetch_logs():
    create_response = client.post(
        '/api/tasks/create',
        json={
            'title': 'Community Compost Setup',
            'description': 'Set up compost bins in residential lane 4.',
            'token_reward': 25,
            'verification_criteria': 'Photo must include bins with labels and volunteers.',
        },
    )

    assert create_response.status_code == 200
    created_task = create_response.json()['task']

    list_response = client.get('/api/tasks', params={'org_id': 'demo-org'})
    assert list_response.status_code == 200
    tasks = list_response.json()['tasks']
    assert any(task['id'] == created_task['id'] for task in tasks)

    logs_response = client.get(f"/api/tasks/{created_task['id']}/logs")
    assert logs_response.status_code == 200
    logs = logs_response.json()['logs']
    assert isinstance(logs, list)
    assert len(logs) >= 1


def test_report_export_endpoint():
    response = client.get(
        '/api/reports/export',
        params={
            'org_id': 'demo-org',
            'from_date': '2026-04-01',
            'to_date': '2026-04-25',
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert body['status'] == 'success'
    assert body['download_url'].endswith('.pdf')
