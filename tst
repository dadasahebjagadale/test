from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.services.user_service import UserService
from app.database import SessionLocal
from app.schema import UserCreate, UserResponse

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=UserResponse)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    return UserService.create_user(db, user)




from sqlalchemy.orm import Session
from app.dao.user_dao import UserDAO
from app.schema import UserCreate
from app.security import hash_password

class UserService:
    @staticmethod
    def create_user(db: Session, user: UserCreate):
        user.password = hash_password(user.password)
        return UserDAO.create_user(db, user)

    @staticmethod
    def get_all_users(db: Session):
        return UserDAO.get_all_users(db)





from sqlalchemy.orm import Session
from app.models import User
from app.schema import UserCreate

class UserDAO:
    @staticmethod
    def create_user(db: Session, user: UserCreate):
        new_user = User(username=user.username, password_hash=user.password)
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        return new_user

    @staticmethod
    def get_all_users(db: Session):
        return db.query(User).all()






import jwt
from fastapi import HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.config import config

security = HTTPBearer()

def verify_jwt(credentials: HTTPAuthorizationCredentials = Security(security)):
    try:
        payload = jwt.decode(credentials.credentials, config.JWT_SECRET, algorithms=[config.JWT_ALGORITHM])
        return payload
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid token")







from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_create_user():
    response = client.post("/api/users/", json={"username": "testuser", "password": "testpass"})
    assert response.status_code == 200
    assert response.json()["username"] == "testuser"
