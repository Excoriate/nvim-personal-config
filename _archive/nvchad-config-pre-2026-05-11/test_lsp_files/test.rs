/*!
 * Test Rust file for LSP functionality via rustaceanvim
 * This should test autocompletion, diagnostics, type inference, and rust-analyzer features
 */

use std::collections::HashMap;
use std::error::Error;
use std::fmt;

// Custom error type to test error handling
#[derive(Debug)]
struct UserError {
    message: String,
}

impl fmt::Display for UserError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "User error: {}", self.message)
    }
}

impl Error for UserError {}

impl UserError {
    fn new(message: &str) -> Self {
        Self {
            message: message.to_string(),
        }
    }
}

// Struct to test derive macros and field completion
#[derive(Debug, Clone, PartialEq)]
struct User {
    id: u32,
    name: String,
    age: u8,
    email: String,
    preferences: Option<UserPreferences>,
}

#[derive(Debug, Clone, PartialEq)]
struct UserPreferences {
    theme: Theme,
    notifications_enabled: bool,
    language: String,
}

// Enum to test pattern matching and completion
#[derive(Debug, Clone, PartialEq)]
enum Theme {
    Light,
    Dark,
    Auto,
}

impl Default for Theme {
    fn default() -> Self {
        Theme::Auto
    }
}

// Implementation to test method completion and self usage
impl User {
    // Test constructor pattern and Result types
    fn new(name: String, age: u8, email: String) -> Result<Self, UserError> {
        if name.is_empty() {
            return Err(UserError::new("Name cannot be empty"));
        }
        
        if !email.contains('@') {
            return Err(UserError::new("Invalid email format"));
        }
        
        Ok(User {
            id: 0, // Will be set by UserManager
            name,
            age,
            email,
            preferences: None,
        })
    }
    
    // Test method chaining and builder pattern
    fn with_preferences(mut self, preferences: UserPreferences) -> Self {
        self.preferences = Some(preferences);
        self
    }
    
    // Test borrow checker and string methods
    fn get_display_name(&self) -> &str {
        &self.name
    }
    
    // Test lifetime annotations and string slicing
    fn get_email_domain(&self) -> Option<&str> {
        self.email.split('@').nth(1)
    }
    
    // Test mutability and Option handling
    fn set_preferences(&mut self, preferences: UserPreferences) {
        self.preferences = Some(preferences);
    }
}

// Generic struct to test generics and trait bounds
#[derive(Debug)]
struct Repository<T> {
    items: HashMap<u32, T>,
    next_id: u32,
}

impl<T> Repository<T> {
    fn new() -> Self {
        Self {
            items: HashMap::new(),
            next_id: 1,
        }
    }
    
    fn add(&mut self, mut item: T) -> u32
    where
        T: HasId,
    {
        let id = self.next_id;
        item.set_id(id);
        self.items.insert(id, item);
        self.next_id += 1;
        id
    }
    
    fn get(&self, id: u32) -> Option<&T> {
        self.items.get(&id)
    }
    
    fn get_all(&self) -> Vec<&T> {
        self.items.values().collect()
    }
}

// Trait to test trait definitions and implementations
trait HasId {
    fn get_id(&self) -> u32;
    fn set_id(&mut self, id: u32);
}

impl HasId for User {
    fn get_id(&self) -> u32 {
        self.id
    }
    
    fn set_id(&mut self, id: u32) {
        self.id = id;
    }
}

// Test async/await and Future types
async fn async_operation(delay_ms: u64) -> Result<String, Box<dyn Error>> {
    // Simulate async work
    tokio::time::sleep(tokio::time::Duration::from_millis(delay_ms)).await;
    Ok("Async operation completed".to_string())
}

// Test closures and iterator methods
fn filter_users_by_age(users: &[User], min_age: u8) -> Vec<&User> {
    users
        .iter()
        .filter(|user| user.age >= min_age)
        .collect()
}

// Test pattern matching and Result handling
fn process_user_result(result: Result<User, UserError>) {
    match result {
        Ok(user) => {
            println!("Created user: {} ({})", user.name, user.email);
            
            // Test method completion on struct fields
            if let Some(domain) = user.get_email_domain() {
                println!("Email domain: {}", domain);
            }
        }
        Err(error) => {
            eprintln!("Failed to create user: {}", error);
        }
    }
}

// Test macro usage and format strings
macro_rules! create_user_with_logging {
    ($name:expr, $age:expr, $email:expr) => {{
        println!("Creating user: {} ({} years old)", $name, $age);
        User::new($name.to_string(), $age, $email.to_string())
    }};
}

// Main function to test all features
fn main() -> Result<(), Box<dyn Error>> {
    let mut user_repo = Repository::<User>::new();
    
    // Test macro usage
    let user1_result = create_user_with_logging!("Alice Johnson", 28, "alice@example.com");
    process_user_result(user1_result.clone());
    
    // Test method completion and error handling
    if let Ok(mut user1) = user1_result {
        // Test struct field completion
        let preferences = UserPreferences {
            theme: Theme::Dark,
            notifications_enabled: true,
            language: "en".to_string(),
        };
        
        // Test method chaining
        user1 = user1.with_preferences(preferences);
        
        // Test repository operations
        let user_id = user_repo.add(user1);
        println!("Added user with ID: {}", user_id);
    }
    
    // Test Result and Option types
    let user2_result = User::new("Bob Smith".to_string(), 35, "bob@example.com");
    if let Ok(user2) = user2_result {
        user_repo.add(user2);
    }
    
    // Test iterator methods and closure completion
    let all_users = user_repo.get_all();
    let adult_users = filter_users_by_age(&all_users.iter().map(|&u| u).collect::<Vec<_>>(), 18);
    
    println!("Found {} adult users:", adult_users.len());
    for user in adult_users {
        println!("- {}: {} years old", user.get_display_name(), user.age);
    }
    
    // Test Vec methods and type inference
    let user_names: Vec<String> = user_repo
        .get_all()
        .iter()
        .map(|user| user.name.clone())
        .collect();
    
    println!("All user names: {:?}", user_names);
    
    // This should show an unused variable warning
    let _unused_variable = "This will trigger a diagnostic";
    
    // Test enum pattern matching
    let theme = Theme::Dark;
    match theme {
        Theme::Light => println!("Using light theme"),
        Theme::Dark => println!("Using dark theme"),
        Theme::Auto => println!("Using auto theme"),
    }
    
    Ok(())
}

// Test conditional compilation
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_user_creation() {
        let user = User::new("Test User".to_string(), 25, "test@example.com");
        assert!(user.is_ok());
        
        let user = user.unwrap();
        assert_eq!(user.name, "Test User");
        assert_eq!(user.age, 25);
    }
    
    #[test]
    fn test_invalid_email() {
        let user = User::new("Test User".to_string(), 25, "invalid-email");
        assert!(user.is_err());
    }
}
