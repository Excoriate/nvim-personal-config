"""
Test Python file for LSP functionality
This should test autocompletion, diagnostics, and type hints
"""

from typing import List, Optional, Dict
import json
import os


class User:
    """A user class to test LSP features"""
    
    def __init__(self, name: str, age: int, email: str) -> None:
        self.name = name
        self.age = age
        self.email = email
        self._id: Optional[int] = None
    
    def get_info(self) -> Dict[str, str]:
        """Get user information as a dictionary"""
        return {
            "name": self.name,
            "age": str(self.age),
            "email": self.email
        }
    
    def set_id(self, user_id: int) -> None:
        """Set the user ID"""
        if user_id < 0:
            raise ValueError("User ID cannot be negative")
        self._id = user_id
    
    @property
    def id(self) -> Optional[int]:
        """Get the user ID"""
        return self._id


def create_users(user_data: List[Dict[str, str]]) -> List[User]:
    """Create a list of users from data"""
    users = []
    for data in user_data:
        # Test autocompletion - should suggest dict keys
        user = User(
            name=data["name"],
            age=int(data["age"]),
            email=data["email"]
        )
        users.append(user)
    return users


def save_users_to_file(users: List[User], filename: str) -> None:
    """Save users to a JSON file"""
    user_data = []
    for user in users:
        # Test method autocompletion
        info = user.get_info()
        user_data.append(info)
    
    # Test standard library autocompletion
    with open(filename, 'w') as f:
        json.dump(user_data, f, indent=2)


def main() -> None:
    """Main function to test LSP features"""
    # Test type checking - this should show correct types
    sample_data = [
        {"name": "Alice", "age": "30", "email": "alice@example.com"},
        {"name": "Bob", "age": "25", "email": "bob@example.com"}
    ]
    
    # Test function autocompletion and parameter hints
    users = create_users(sample_data)
    
    # Test method autocompletion on objects
    for user in users:
        print(user.get_info())
        user.set_id(len(users))
    
    # Test error detection - this should show a type error
    # wrong_type_user = User(123, "invalid", "test@example.com")
    
    # This should show an unused variable warning
    unused_variable = "This will trigger a diagnostic"
    
    # Test os module autocompletion
    current_dir = os.getcwd()
    filename = os.path.join(current_dir, "users.json")
    
    # Test function call with proper types
    save_users_to_file(users, filename)


if __name__ == "__main__":
    main()
