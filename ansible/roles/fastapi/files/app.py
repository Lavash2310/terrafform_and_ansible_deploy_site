import os
import socket
import boto3
from uuid import uuid4
from fastapi import FastAPI, Request, Form, File, UploadFile
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from datetime import date
import logging
import watchtower
import pymysql
from contextlib import contextmanager

app = FastAPI()
templates = Jinja2Templates(directory="templates")
boto3_client = boto3.client('logs', region_name='us-west-1')

logger = logging.getLogger(__name__)
logger.addHandler(watchtower.CloudWatchLogHandler(log_group='logging-group', boto3_client=boto3_client))
logger.setLevel(logging.INFO)

DB_CONFIG = {
    'user': 'db_user',
    'password': os.getenv('DB_PASSWORD'),
    'database': 'employee_db',
    'host': 'localhost',
    'cursorclass': pymysql.cursors.DictCursor
}

BUCKET_NAME = 'my-project-s3-2026'
s3 = boto3.client('s3', region_name='us-west-1')

dynamodb = boto3.resource('dynamodb', region_name='us-west-1')
table = dynamodb.Table('employee_table')

@contextmanager
def get_db():
    conn = pymysql.connect(**DB_CONFIG)
    try:
        yield conn
    finally:
        conn.close()

@app.get("/")
async def main():
    return RedirectResponse(url="/employees")

@app.get("/employees", response_class=HTMLResponse)
async def employees(request: Request):
    with get_db() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM employees ORDER BY hire_date DESC;")
            rows = cursor.fetchall()
    
    server_ip = socket.gethostbyname(socket.gethostname())
    return templates.TemplateResponse("index.html", {"request": request, "rows": rows, "server_ip": server_ip})

@app.post("/employees/add")
async def add_employee(full_name: str = Form(), position: str = Form(), salary: float = Form(), photo: UploadFile = File(...)):
    logger.info(f"Adding employee: {full_name}")
    if not photo or not photo.filename:
        return RedirectResponse(url="/employees?error=photo_required", status_code=303)
    
    today = date.today().strftime("%Y-%m-%d")
    
    ext = photo.filename.split('.')[-1]
    filename = f"{uuid4()}.{ext}"
    
    try:
        s3.upload_fileobj(photo.file, BUCKET_NAME, filename, ExtraArgs={"ContentType": photo.content_type, "ACL": "public-read"})
        photo_url = f"https://{BUCKET_NAME}.s3.us-west-1.amazonaws.com/{filename}"
        logger.info(f"Photo uploaded to S3: {photo_url}")
    except Exception as e:
        logger.warning(f"Failed to upload photo to S3: {e}")
        return RedirectResponse(url="/employees?error=upload_failed", status_code=303)
    
    try:
        table.put_item(Item={
            "full_name": full_name,
            "photo_url": photo_url,
            "upload_date": today
        })
        logger.info(f"Item inserted into DynamoDB: {full_name}")
    except Exception as e:
        logger.warning(f"Failed to insert item into DynamoDB: {e}")

    with get_db() as conn:
        with conn.cursor() as cursor:
            cursor.execute("INSERT INTO employees (full_name, position, salary, hire_date, photo_url) VALUES (%s, %s, %s, %s, %s)", 
                         (full_name, position, salary, today, photo_url))
            conn.commit()
    
    return RedirectResponse(url="/employees", status_code=303)

@app.get("/employees/update/{id}", response_class=HTMLResponse)
async def get_update_employee(id: int, request: Request):
    with get_db() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM employees WHERE id = %s", (id,))
            row = cursor.fetchone()
    
    if row:
        return templates.TemplateResponse("edit.html", {"request": request, "row": row})
    return RedirectResponse(url="/employees")

@app.post("/employees/update/{id}")
async def update_employee(id: int, full_name: str = Form(), position: str = Form(), salary: float = Form(), photo: UploadFile = File(None)):

    new_photo_url = ""

    if photo and photo.filename:
        ext = photo.filename.split('.')[-1]
        filename = f"{uuid4()}.{ext}"
        
        try:
            s3.upload_fileobj(photo.file, BUCKET_NAME, filename, ExtraArgs={"ContentType": photo.content_type, "ACL": "public-read"})
            new_photo_url = f"https://{BUCKET_NAME}.s3.us-west-1.amazonaws.com/{filename}"
            logger.info(f"Photo uploaded to S3: {new_photo_url}")
        except Exception as e:
            logger.warning(f"Failed to upload photo to S3: {e}")
            return RedirectResponse(url="/employees?error=upload_failed", status_code=303)

    with get_db() as conn:
        with conn.cursor() as cursor:
            if new_photo_url:
                cursor.execute("UPDATE employees SET full_name = %s, position = %s, salary = %s, photo_url = %s WHERE id = %s", 
                         (full_name, position, salary, id))
                conn.commit()
            else:
                cursor.execute("UPDATE employees SET full_name = %s, position = %s, salary = %s WHERE id = %s", 
                         (full_name, position, salary, id))
                conn.commit()
    
    return RedirectResponse(url="/employees", status_code=303)

@app.get("/employees/delete/{id}")
async def delete_employee(id: int):
    with get_db() as conn:
        with conn.cursor() as cursor:
            cursor.execute("DELETE FROM employees WHERE id = %s", (id,))
            conn.commit()
    
    return RedirectResponse(url="/employees", status_code=303)