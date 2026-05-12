"""
Test Python file for production-grade LSP configuration
This should test type checking, diagnostics, and advanced features
"""

from typing import List, Optional, Dict, Union, Protocol, TypeVar, Generic
from dataclasses import dataclass, field
from abc import ABC, abstractmethod
import json
import logging
from pathlib import Path

# Generic type for demonstration
T = TypeVar('T')

# Protocol for type checking
class Drawable(Protocol):
    def draw(self) -> str:
        ...

# Dataclass with proper typing
@dataclass
class User:
    """User dataclass with comprehensive type hints"""
    id: int
    name: str
    email: str
    age: Optional[int] = None
    preferences: Dict[str, Union[str, int, bool]] = field(default_factory=dict)
    
    def __post_init__(self) -> None:
        if self.age is not None and self.age < 0:
            raise ValueError("Age cannot be negative")
    
    def get_display_name(self) -> str:
        """Get formatted display name"""
        if self.age is not None:
            return f"{self.name} ({self.age})"
        return self.name
    
    def update_preference(self, key: str, value: Union[str, int, bool]) -> None:
        """Update user preference with type safety"""
        self.preferences[key] = value
    
    def to_dict(self) -> Dict[str, Union[str, int, None, Dict[str, Union[str, int, bool]]]]:
        """Convert to dictionary for serialization"""
        return {
            "id": self.id,
            "name": self.name,
            "email": self.email,
            "age": self.age,
            "preferences": self.preferences
        }

# Generic repository pattern
class Repository(Generic[T], ABC):
    """Abstract repository for CRUD operations"""
    
    @abstractmethod
    def save(self, item: T) -> T:
        """Save an item to the repository"""
        pass
    
    @abstractmethod
    def find_by_id(self, item_id: int) -> Optional[T]:
        """Find item by ID"""
        pass
    
    @abstractmethod
    def find_all(self) -> List[T]:
        """Find all items"""
        pass
    
    @abstractmethod
    def delete(self, item_id: int) -> bool:
        """Delete item by ID"""
        pass

# Concrete implementation
class UserRepository(Repository[User]):
    """In-memory user repository implementation"""
    
    def __init__(self) -> None:
        self._users: Dict[int, User] = {}
        self._next_id: int = 1
    
    def save(self, user: User) -> User:
        """Save user to repository"""
        if user.id == 0:  # New user
            user.id = self._next_id
            self._next_id += 1
        
        self._users[user.id] = user
        return user
    
    def find_by_id(self, user_id: int) -> Optional[User]:
        """Find user by ID"""
        return self._users.get(user_id)
    
    def find_all(self) -> List[User]:
        """Get all users"""
        return list(self._users.values())
    
    def delete(self, user_id: int) -> bool:
        """Delete user by ID"""
        if user_id in self._users:
            del self._users[user_id]
            return True
        return False
    
    def find_by_email(self, email: str) -> Optional[User]:
        """Find user by email address"""
        for user in self._users.values():
            if user.email == email:
                return user
        return None

# Service layer with proper error handling
class UserService:
    """User service with business logic"""
    
    def __init__(self, repository: UserRepository) -> None:
        self.repository = repository
        self.logger = logging.getLogger(__name__)
    
    def create_user(self, name: str, email: str, age: Optional[int] = None) -> User:
        """Create a new user with validation"""
        # Check if email already exists
        existing_user = self.repository.find_by_email(email)
        if existing_user is not None:
            raise ValueError(f"User with email {email} already exists")
        
        # Validate email format (basic)
        if "@" not in email:
            raise ValueError("Invalid email format")
        
        # Create and save user
        user = User(id=0, name=name, email=email, age=age)
        saved_user = self.repository.save(user)
        
        self.logger.info(f"Created user: {saved_user.name} with ID {saved_user.id}")
        return saved_user
    
    def update_user_age(self, user_id: int, age: int) -> Optional[User]:
        """Update user age with validation"""
        user = self.repository.find_by_id(user_id)
        if user is None:
            return None
        
        if age < 0 or age > 150:
            raise ValueError("Age must be between 0 and 150")
        
        user.age = age
        return self.repository.save(user)
    
    def get_users_by_age_range(self, min_age: int, max_age: int) -> List[User]:
        """Get users within specified age range"""
        all_users = self.repository.find_all()
        return [
            user for user in all_users 
            if user.age is not None and min_age <= user.age <= max_age
        ]
    
    def export_users_to_json(self, file_path: Union[str, Path]) -> None:
        """Export all users to JSON file"""
        users_data = [user.to_dict() for user in self.repository.find_all()]
        
        path = Path(file_path)
        with path.open('w', encoding='utf-8') as f:
            json.dump(users_data, f, indent=2, ensure_ascii=False)
        
        self.logger.info(f"Exported {len(users_data)} users to {path}")

# Example drawable implementations for protocol testing
@dataclass
class Circle:
    radius: float
    
    def draw(self) -> str:
        return f"Circle with radius {self.radius}"

@dataclass 
class Rectangle:
    width: float
    height: float
    
    def draw(self) -> str:
        return f"Rectangle {self.width}x{self.height}"

def draw_shapes(shapes: List[Drawable]) -> List[str]:
    """Draw multiple shapes using the Drawable protocol"""
    return [shape.draw() for shape in shapes]

# Main function demonstrating the functionality
def main() -> None:
    """Main function to demonstrate the user management system"""
    
    # Configure logging
    logging.basicConfig(level=logging.INFO)
    
    # Create repository and service
    repository = UserRepository()
    service = UserService(repository)
    
    try:
        # Create some users
        john = service.create_user("John Doe", "john@example.com", 30)
        jane = service.create_user("Jane Smith", "jane@example.com", 25)
        bob = service.create_user("Bob Johnson", "bob@example.com")
        
        print(f"Created users:")
        for user in repository.find_all():
            print(f"  - {user.get_display_name()} ({user.email})")
        
        # Update Bob's age
        updated_bob = service.update_user_age(bob.id, 35)
        if updated_bob:
            print(f"Updated Bob's age to {updated_bob.age}")
        
        # Find users in age range
        adults = service.get_users_by_age_range(25, 40)
        print(f"Adults (25-40): {[user.name for user in adults]}")
        
        # Test drawable protocol
        shapes: List[Drawable] = [
            Circle(5.0),
            Rectangle(10.0, 20.0),
            Circle(3.0)
        ]
        
        print("Shapes:")
        for description in draw_shapes(shapes):
            print(f"  - {description}")
        
        # Export to JSON (commented out to avoid file creation in test)
        # service.export_users_to_json("users.json")
        
    except ValueError as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")

if __name__ == "__main__":
    main()
