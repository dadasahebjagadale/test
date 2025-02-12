I'll provide a structured FastAPI project with Role-Based Access Control (RBAC) for both REST and GraphQL APIs, including User and Todo CRUD operations.


---

Project Structure

fastapi_rbac_project/
│── main.py
│── config.py
│── database.py
│── models.py
│── schemas.py
│── dependencies.py
│── routers/
│   │── auth.py
│   │── users.py
│   │── todos.py
│   │── graphql.py
│── services/
│   │── user_service.py
│   │── todo_service.py
│── utils/
│   │── security.py
│── tests/
│   │── test_users.py
│   │── test_todos.py


---

Features

✅ JWT-based authentication
✅ Role-based authorization (Admin, User)
✅ Separate REST & GraphQL routes
✅ User CRUD (Admin: full control, User: view only)
✅ Todo CRUD (Admin: full control, User: view only)
✅ Secure password hashing
✅ Swagger UI with authentication


---

I will now generate the required files for your setup.



1. config.py (Configuration Settings)

import os
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


---

2. database.py (Database Connection)

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "sqlite:///./test.db"  # Change this for production

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


---

3. models.py (User & Todo Models)

from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    role = Column(String, default="user")  # admin or user

class Todo(Base):
    __tablename__ = "todos"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    description = Column(String)
    owner_id = Column(Integer, ForeignKey("users.id"))

    owner = relationship("User")


---

4. schemas.py (Pydantic Schemas)

from pydantic import BaseModel
from typing import Optional

class UserCreate(BaseModel):
    username: str
    password: str
    role: Optional[str] = "user"

class UserResponse(BaseModel):
    id: int
    username: str
    role: str

class TodoCreate(BaseModel):
    title: str
    description: str

class TodoResponse(TodoCreate):
    id: int
    owner_id: int


---

5. utils/security.py (Password Hashing & JWT)

from passlib.context import CryptContext
from datetime import datetime, timedelta
from jose import JWTError, jwt
from ..config import SECRET_KEY, ALGORITHM

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: timedelta):
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


---

6. dependencies.py (Dependency Injection)

from fastapi import Depends, HTTPException, status
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from .database import SessionLocal
from .models import User
from .utils.security import SECRET_KEY, ALGORITHM

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_current_user(token: str, db: Session = Depends(get_db)):
    credentials_exception = HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise credentials_exception
    return user


---

7. routers/auth.py (Authentication Routes)

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import timedelta
from ..database import get_db
from ..models import User
from ..schemas import UserCreate
from ..utils.security import hash_password, verify_password, create_access_token
from ..config import ACCESS_TOKEN_EXPIRE_MINUTES

router = APIRouter(prefix="/api", tags=["Auth"])

@router.post("/login")
def login(username: str, password: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == username).first()
    if not user or not verify_password(password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Invalid credentials")

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token({"sub": user.username}, access_token_expires)

    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    hashed_password = hash_password(user.password)
    db_user = User(username=user.username, hashed_password=hashed_password, role=user.role)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


---

8. routers/users.py (User CRUD)

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import User
from ..schemas import UserResponse
from ..dependencies import get_current_user

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/", response_model=list[UserResponse])
def get_users(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(User).all()

@router.delete("/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    db.delete(user)
    db.commit()
    return {"message": "User deleted"}


---

9. routers/todos.py (Todo CRUD)

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Todo
from ..schemas import TodoCreate, TodoResponse
from ..dependencies import get_current_user

router = APIRouter(prefix="/todos", tags=["Todos"])

@router.get("/", response_model=list[TodoResponse])
def get_todos(db: Session = Depends(get_db), current_user: User



= Depends(get_current_user)): return db.query(Todo).all()

@router.post("/") def create_todo(todo: TodoCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)): if current_user.role != "admin": raise HTTPException(status_code=403, detail="Not authorized")

db_todo = Todo(**todo.dict(), owner_id=current_user.id)
db.add(db_todo)
db.commit()
db.refresh(db_todo)
return db_todo

@router.delete("/{todo_id}") def delete_todo(todo_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)): if current_user.role != "admin": raise HTTPException(status_code=403, detail="Not authorized")

todo = db.query(Todo).filter(Todo.id == todo_id).first()
if not todo:
    raise HTTPException(status_code=404, detail="Todo not found")

db.delete(todo)
db.commit()
return {"message": "Todo deleted"}

---

### **10. `routers/graphql.py` (GraphQL API)**
```python
from fastapi import APIRouter, Depends
from strawberry.fastapi import GraphQLRouter
import strawberry
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import User, Todo
from ..dependencies import get_current_user

@strawberry.type
class Query:
    @strawberry.field
    def users(self, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
        return db.query(User).all()

    @strawberry.field
    def todos(self, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
        return db.query(Todo).all()

schema = strawberry.Schema(query=Query)
router = APIRouter(prefix="/graphql")
graphql_app = GraphQLRouter(schema)
router.include_router(graphql_app)


---

11. main.py (Application Entry Point)

from fastapi import FastAPI
from .database import Base, engine
from .routers import auth, users, todos, graphql

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(todos.router)
app.include_router(graphql.router)


---

Next Steps

1. Install dependencies:

pip install fastapi[all] sqlalchemy passlib[bcrypt] jose python-dotenv strawberry


2. Run the FastAPI server:

uvicorn main:app --reload


3. Access:

Swagger UI: http://127.0.0.1:8000/docs

GraphQL UI: http://127.0.0.1:8000/graphql




Let me know if you need further modifications!



☕



Yes, we can split models and schemas into separate files based on operations (User and Todo). Here’s how the updated project structure will look:

/your_project
│── main.py
│── config.py
│── database.py
│── dependencies.py
│── .env
│── /models
│   │── __init__.py
│   │── user.py
│   │── todo.py
│── /schemas
│   │── __init__.py
│   │── user.py
│   │── todo.py
│── /routers
│   │── __init__.py
│   │── auth.py
│   │── users.py
│   │── todos.py
│   │── graphql.py
│── /utils
│   │── __init__.py
│   │── security.py


---

1. /models/user.py (User Model)

from sqlalchemy import Column, Integer, String
from ..database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    role = Column(String, default="user")  # admin or user


---

2. /models/todo.py (Todo Model)

from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from ..database import Base

class Todo(Base):
    __tablename__ = "todos"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    description = Column(String)
    owner_id = Column(Integer, ForeignKey("users.id"))

    owner = relationship("User")


---

3. /schemas/user.py (User Schemas)

from pydantic import BaseModel
from typing import Optional

class UserCreate(BaseModel):
    username: str
    password: str
    role: Optional[str] = "user"

class UserResponse(BaseModel):
    id: int
    username: str
    role: str


---

4. /schemas/todo.py (Todo Schemas)

from pydantic import BaseModel

class TodoCreate(BaseModel):
    title: str
    description: str

class TodoResponse(TodoCreate):
    id: int
    owner_id: int


---

5. Update /routers/auth.py

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import timedelta
from ..database import get_db
from ..models.user import User
from ..schemas.user import UserCreate
from ..utils.security import hash_password, verify_password, create_access_token
from ..config import ACCESS_TOKEN_EXPIRE_MINUTES

router = APIRouter(prefix="/api", tags=["Auth"])

@router.post("/login")
def login(username: str, password: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == username).first()
    if not user or not verify_password(password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Invalid credentials")

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token({"sub": user.username}, access_token_expires)

    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    hashed_password = hash_password(user.password)
    db_user = User(username=user.username, hashed_password=hashed_password, role=user.role)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


---

6. Update /routers/users.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.user import User
from ..schemas.user import UserResponse
from ..dependencies import get_current_user

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/", response_model=list[UserResponse])
def get_users(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(User).all()

@router.delete("/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    db.delete(user)
    db.commit()
    return {"message": "User deleted"}


---

7. Update /routers/todos.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.todo import Todo
from ..schemas.todo import TodoCreate, TodoResponse
from ..dependencies import get_current_user

router = APIRouter(prefix="/todos", tags=["Todos"])

@router.get("/", response_model=list[TodoResponse])
def get_todos(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(Todo).all()

@router.post("/")
def create_todo(todo: TodoCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")
    
    db_todo = Todo(**todo.dict(), owner_id=current_user.id)
    db.add(db_todo)
    db.commit()
    db.refresh(db_todo)
    return db_todo

@router.delete("/{todo_id}")
def delete_todo(todo_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")
    
    todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    db.delete(todo)
    db.commit()
    return {"message": "Todo deleted"}


---

8. Update /routers/graphql.py

from fastapi import APIRouter, Depends
from strawberry.fastapi import GraphQLRouter
import strawberry
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.user import User
from ..models.todo import Todo
from ..dependencies import get_current_user

@strawberry.type
class Query:
    @strawberry.field
    def users(self, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
        return db.query(User).all()

    @strawberry.field
    def todos(self, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
        return db.query(Todo).all()

schema = strawberry.Schema(query=Query)
router = APIRouter(prefix="/graphql")
graphql_app = GraphQLRouter(schema)
router.include_router(graphql_app)


---

9. Update main.py

from fastapi import FastAPI
from .database import Base, engine
from .routers import auth, users, todos, graphql

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(todos.router)
app.include_router(graphql.router)


---

Next Steps

1. Install dependencies:

pip install fastapi[all] sqlalchemy passlib[bcrypt] jose python-dotenv strawberry


2. Run the FastAPI server:

uvicorn main:app --reload


3. Access APIs:

Swagger UI: http://127.0.0.1:8000/docs

GraphQL UI: http://127.0.0.1:8000/graphql




This structure makes the codebase modular and maintainable. Let me know if you need further adjustments!






import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.ArrayList;
import java.util.List;

public class CheckBoxComboBoxExample {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(CheckBoxComboBoxExample::createAndShowGUI);
    }

    private static void createAndShowGUI() {
        JFrame frame = new JFrame("Multi-Select JComboBox");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(400, 200);
        frame.setLayout(new FlowLayout());

        // Create multi-select combo box
        String[] items = {"Apple", "Banana", "Cherry", "Mango", "Orange"};
        MultiSelectComboBox comboBox = new MultiSelectComboBox(items);
        frame.add(comboBox);

        frame.setVisible(true);
    }

    // Custom JComboBox with checkboxes
    static class MultiSelectComboBox extends JComboBox<String> {
        private final List<JCheckBox> checkBoxes = new ArrayList<>();
        private final DefaultComboBoxModel<String> model = new DefaultComboBoxModel<>();
        
        public MultiSelectComboBox(String[] items) {
            super(items);
            setModel(model); // Set custom model
            setRenderer(new CheckBoxRenderer());
            addActionListener(e -> toggleSelection());

            // Add checkboxes to track selection
            for (String item : items) {
                JCheckBox checkBox = new JCheckBox(item);
                checkBoxes.add(checkBox);
                model.addElement(item);
            }
        }

        // Toggle selection when an item is clicked
        private void toggleSelection() {
            int selectedIndex = getSelectedIndex();
            if (selectedIndex >= 0) {
                JCheckBox checkBox = checkBoxes.get(selectedIndex);
                checkBox.setSelected(!checkBox.isSelected());
                updateComboBoxDisplay();
            }
        }

        // Update the displayed text with selected items
        private void updateComboBoxDisplay() {
            List<String> selectedItems = new ArrayList<>();
            for (JCheckBox checkBox : checkBoxes) {
                if (checkBox.isSelected()) {
                    selectedItems.add(checkBox.getText());
                }
            }
            setSelectedItem(selectedItems.isEmpty() ? "Select Items" : String.join(", ", selectedItems));
        }
    }

    // Custom renderer to display checkboxes inside JComboBox dropdown
    static class CheckBoxRenderer extends JCheckBox implements ListCellRenderer<Object> {
        public Component getListCellRendererComponent(JList<?> list, Object value, int index, boolean isSelected, boolean cellHasFocus) {
            if (index >= 0) {
                setText(value.toString());
                setSelected(((JComboBox<?>) list.getParent()).getItemAt(index).equals(value));
            }
            return this;
        }
    }
}























import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;

public class MultiSelectComboBoxExample {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(MultiSelectComboBoxExample::createAndShowGUI);
    }

    private static void createAndShowGUI() {
        JFrame frame = new JFrame("Multi-Select JComboBox");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(400, 200);
        frame.setLayout(new FlowLayout());

        // Multi-select combo box with "Select All"
        String[] items = {"Apple", "Banana", "Cherry", "Mango", "Orange"};
        MultiSelectComboBox comboBox = new MultiSelectComboBox(items);
        frame.add(comboBox);

        frame.setVisible(true);
    }

    static class MultiSelectComboBox extends JComboBox<String> {
        private final List<JCheckBox> checkBoxes = new ArrayList<>();
        private final DefaultComboBoxModel<String> model = new DefaultComboBoxModel<>();
        private final JCheckBox selectAllCheckBox = new JCheckBox("Select All");
        private final Set<String> selectedItems = new HashSet<>();
        private boolean updating = false;

        public MultiSelectComboBox(String[] items) {
            super(items);
            setModel(model);
            setRenderer(new CheckBoxRenderer());
            addActionListener(e -> toggleSelection());

            // Add "Select All" checkbox
            checkBoxes.add(selectAllCheckBox);
            model.addElement("Select All");

            // Add individual item checkboxes
            for (String item : items) {
                JCheckBox checkBox = new JCheckBox(item);
                checkBoxes.add(checkBox);
                model.addElement(item);
            }

            // Handle "Select All" toggle
            selectAllCheckBox.addItemListener(e -> {
                if (!updating) {
                    boolean selectAll = selectAllCheckBox.isSelected();
                    selectAllItems(selectAll);
                }
            });

            // Handle individual item selection
            for (int i = 1; i < checkBoxes.size(); i++) {
                JCheckBox checkBox = checkBoxes.get(i);
                checkBox.addItemListener(e -> {
                    if (!updating) {
                        updateSelectAllStatus();
                    }
                });
            }
        }

        private void toggleSelection() {
            int selectedIndex = getSelectedIndex();
            if (selectedIndex >= 0) {
                JCheckBox checkBox = checkBoxes.get(selectedIndex);
                checkBox.setSelected(!checkBox.isSelected());
                updateSelectAllStatus();
            }
        }

        private void selectAllItems(boolean selectAll) {
            updating = true;
            selectedItems.clear();
            for (int i = 1; i < checkBoxes.size(); i++) { // Skip "Select All"
                checkBoxes.get(i).setSelected(selectAll);
                if (selectAll) {
                    selectedItems.add(checkBoxes.get(i).getText());
                }
            }
            updating = false;
            updateComboBoxDisplay();
        }

        private void updateSelectAllStatus() {
            updating = true;
            boolean allSelected = true;
            selectedItems.clear();

            for (int i = 1; i < checkBoxes.size(); i++) { // Skip "Select All"
                if (!checkBoxes.get(i).isSelected()) {
                    allSelected = false;
                } else {
                    selectedItems.add(checkBoxes.get(i).getText());
                }
            }

            selectAllCheckBox.setSelected(allSelected);
            updating = false;
            updateComboBoxDisplay();
        }

        private void updateComboBoxDisplay() {
            if (selectedItems.isEmpty()) {
                setSelectedItem("Select All");
            } else {
                setSelectedItem(String.join(", ", selectedItems));
            }
        }
    }

    static class CheckBoxRenderer implements ListCellRenderer<Object> {
        public Component getListCellRendererComponent(JList<?> list, Object value, int index, boolean isSelected, boolean cellHasFocus) {
            JCheckBox checkBox = new JCheckBox(value.toString());
            checkBox.setOpaque(true);
            checkBox.setBackground(isSelected ? Color.LIGHT_GRAY : Color.WHITE);
            return checkBox;
        }
    }
}
