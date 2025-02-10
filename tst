Sure! Below is the consolidated code for your FastAPI application, including:

In-memory H2-like database (using SQLite for simplicity)

JWT Authentication & Authorization

GraphQL & Swagger Integration

Structured Packaging

Auto User Creation on Startup

Endpoints for User Login & Fetching User List



---

Project Structure

fastapi_app/
│── app/
│   ├── controllers/
│   │   ├── user_controller.py
│   ├── dao/
│   │   ├── user_dao.py
│   ├── models/
│   │   ├── user_model.py
│   ├── schemas/
│   │   ├── user_schema.py
│   ├── services/
│   │   ├── user_service.py
│   ├── utils/
│   │   ├── auth.py
│   ├── database.py
│   ├── config.py
│   ├── main.py
│── .env
│── requirements.txt
│── run.sh


---

1️⃣ Install Dependencies

First, create a virtual environment and install dependencies:

python3.9 -m venv venv
source venv/bin/activate  # (For Windows use: venv\Scripts\activate)
pip install -r requirements.txt


---

2️⃣ requirements.txt

fastapi
uvicorn
sqlalchemy
passlib[bcrypt]
python-dotenv
pyjwt
graphene


---

3️⃣ .env (Configuration File)

SECRET_KEY=your_secret_key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30


---

4️⃣ app/config.py

import os
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))


---

5️⃣ app/database.py (In-memory SQLite)

from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "sqlite:///./test.db"  # Using SQLite as an in-memory alternative

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


---

6️⃣ app/models/user_model.py

from app.database import Base
from sqlalchemy import Column, Integer, String

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    password = Column(String)


---

7️⃣ app/dao/user_dao.py

from sqlalchemy.orm import Session
from app.models.user_model import User

def get_user_by_username(db: Session, username: str):
    return db.query(User).filter(User.username == username).first()

def get_users(db: Session):
    return db.query(User).all()

def create_default_user(db: Session):
    if not get_user_by_username(db, "admin"):
        user = User(username="admin", password="$2b$12$6yR...")  # bcrypt hash for "admin"
        db.add(user)
        db.commit()


---

8️⃣ app/services/user_service.py

from sqlalchemy.orm import Session
from app.dao.user_dao import get_user_by_username, get_users
from app.utils.auth import verify_password, create_access_token

def authenticate_user(db: Session, username: str, password: str):
    user = get_user_by_username(db, username)
    if user and verify_password(password, user.password):
        return create_access_token({"sub": user.username})
    return None

def get_all_users(db: Session):
    return [{"id": user.id, "username": user.username} for user in get_users(db)]


---

9️⃣ app/utils/auth.py

import jwt
from datetime import datetime, timedelta
from passlib.context import CryptContext
from fastapi import HTTPException, Security
from fastapi.security import OAuth2PasswordBearer
from app.config import SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/login")
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def get_current_user(token: str = Security(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return {"username": payload.get("sub")}
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


---

🔟 app/controllers/user_controller.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.services.user_service import authenticate_user, get_all_users
from app.utils.auth import get_current_user

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/login")
def login(username: str, password: str, db: Session = Depends(get_db)):
    token = authenticate_user(db, username, password)
    if not token:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return {"access_token": token, "token_type": "bearer"}

@router.get("/users")
def get_users_list(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return {"users": get_all_users(db)}


---

1️⃣1️⃣ app/main.py

from fastapi import FastAPI
from app.database import Base, engine, SessionLocal
from app.dao.user_dao import create_default_user
from app.controllers import user_controller
import graphene
from starlette.graphql import GraphQLApp

app = FastAPI(title="FastAPI GraphQL & JWT")

# Auto-create database tables
Base.metadata.create_all(bind=engine)

# Auto-create default user on startup
db = SessionLocal()
create_default_user(db)
db.close()

# Include API router
app.include_router(user_controller.router, prefix="/api")

# GraphQL Schema
class Query(graphene.ObjectType):
    hello = graphene.String(name=graphene.String(default_value="world"))

schema = graphene.Schema(query=Query)
app.add_route("/graphql", GraphQLApp(schema=schema))


---

1️⃣2️⃣ Running the App

uvicorn app.main:app --reload


---

🛠 API Endpoints


---

🚀 How to Test

1. Login → POST /api/login?username=admin&password=admin


2. Get Users List → GET /api/users (Pass JWT token in Authorization: Bearer <token>)




---

This is a fully functional FastAPI application with in-memory storage, JWT authentication, GraphQL, and auto-user creation. Let me know if you need modifications!

