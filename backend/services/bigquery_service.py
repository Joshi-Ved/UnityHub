import os
from google.cloud import bigquery
from google.api_core.exceptions import NotFound
from datetime import datetime
import uuid

class BigQueryService:
    def __init__(self):
        self.project_id = os.environ.get("GOOGLE_CLOUD_PROJECT", "unityhub-afd87")
        self.dataset_id = "impact_analytics"
        self.table_id = "impact_logs"
        self.client = bigquery.Client(project=self.project_id)
        self._ensure_dataset_and_table()

    def _ensure_dataset_and_table(self):
        """Ensures the dataset and table exist in BigQuery."""
        dataset_ref = bigquery.DatasetReference(self.project_id, self.dataset_id)
        try:
            self.client.get_dataset(dataset_ref)
        except NotFound:
            dataset = bigquery.Dataset(dataset_ref)
            dataset.location = "US"
            self.client.create_dataset(dataset)
            print(f"Created dataset {self.dataset_id}")

        table_ref = dataset_ref.table(self.table_id)
        try:
            self.client.get_table(table_ref)
        except NotFound:
            schema = [
                bigquery.SchemaField("id", "STRING", mode="REQUIRED"),
                bigquery.SchemaField("user_address", "STRING", mode="REQUIRED"),
                bigquery.SchemaField("task_id", "STRING", mode="NULLABLE"),
                bigquery.SchemaField("task_title", "STRING", mode="NULLABLE"),
                bigquery.SchemaField("status", "STRING", mode="REQUIRED"),
                bigquery.SchemaField("confidence_score", "FLOAT", mode="NULLABLE"),
                bigquery.SchemaField("token_reward", "INTEGER", mode="NULLABLE"),
                bigquery.SchemaField("created_at", "TIMESTAMP", mode="REQUIRED"),
            ]
            table = bigquery.Table(table_ref, schema=schema)
            self.client.create_table(table)
            print(f"Created table {self.table_id}")

    def insert_impact_log(self, log_data: dict):
        """
        Inserts a log entry into BigQuery.
        log_data: {id, user_address, task_id, task_title, status, confidence_score, token_reward, created_at}
        """
        table_ref = self.client.dataset(self.dataset_id).table(self.table_id)
        
        # Ensure created_at is in ISO format or datetime
        if isinstance(log_data.get("created_at"), datetime):
            log_data["created_at"] = log_data["created_at"].isoformat()
        elif not log_data.get("created_at"):
            log_data["created_at"] = datetime.utcnow().isoformat()

        errors = self.client.insert_rows_json(table_ref, [log_data])
        if errors:
            print(f"BigQuery insertion errors: {errors}")
            return False
        return True

    def get_funnel_metrics(self):
        """
        Queries BigQuery for funnel metrics.
        Returns a dict: {submitted, processed, approved, minted}
        """
        query = f"""
            SELECT 
                COUNT(*) as submitted,
                COUNTIF(status != 'failed') as processed,
                COUNTIF(status IN ('verified', 'minted')) as approved,
                COUNTIF(status = 'minted') as minted
            FROM `{self.project_id}.{self.dataset_id}.{self.table_id}`
        """
        try:
            query_job = self.client.query(query)
            results = query_job.result()
            for row in results:
                return {
                    "submitted": row.submitted or 0,
                    "processed": row.processed or 0,
                    "approved": row.approved or 0,
                    "minted": row.minted or 0
                }
        except Exception as e:
            print(f"BigQuery query error: {e}")
            # Fallback to simulated data if query fails (e.g. no data yet)
            return {"submitted": 0, "processed": 0, "approved": 0, "minted": 0}
        
        return {"submitted": 0, "processed": 0, "approved": 0, "minted": 0}

# Singleton instance
bigquery_service = BigQueryService()
