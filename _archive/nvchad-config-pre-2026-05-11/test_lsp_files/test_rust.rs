use std::collections::HashMap;
use std::io::{self, Write};

#[derive(Debug, Clone)]
pub struct User {
    pub id: u32,
    pub name: String,
    pub email: String,
    pub age: Option<u8>,
}

impl User {
    pub fn new(id: u32, name: String, email: String) -> Self {
        Self {
            id,
            name,
            email,
            age: None,
        }
    }

    pub fn set_age(&mut self, age: u8) -> Result<(), String> {
        if age > 150 {
            return Err("Age must be realistic".to_string());
        }
        self.age = Some(age);
        Ok(())
    }

    pub fn display_info(&self) -> String {
        match self.age {
            Some(age) => format!("{} ({}) - {}", self.name, age, self.email),
            None => format!("{} - {}", self.name, self.email),
        }
    }
}

#[derive(Debug)]
pub struct UserDatabase {
    users: HashMap<u32, User>,
    next_id: u32,
}

impl UserDatabase {
    pub fn new() -> Self {
        Self {
            users: HashMap::new(),
            next_id: 1,
        }
    }

    pub fn add_user(&mut self, name: String, email: String) -> u32 {
        let id = self.next_id;
        let user = User::new(id, name, email);
        self.users.insert(id, user);
        self.next_id += 1;
        id
    }

    pub fn get_user(&self, id: u32) -> Option<&User> {
        self.users.get(&id)
    }

    pub fn update_user_age(&mut self, id: u32, age: u8) -> Result<(), String> {
        match self.users.get_mut(&id) {
            Some(user) => user.set_age(age),
            None => Err(format!("User with id {} not found", id)),
        }
    }

    pub fn list_users(&self) -> Vec<&User> {
        self.users.values().collect()
    }
}

fn main() -> io::Result<()> {
    let mut db = UserDatabase::new();
    
    // Add some users
    let john_id = db.add_user("John Doe".to_string(), "john@example.com".to_string());
    let jane_id = db.add_user("Jane Smith".to_string(), "jane@example.com".to_string());
    
    // Update ages
    if let Err(e) = db.update_user_age(john_id, 30) {
        eprintln!("Error updating John's age: {}", e);
    }
    
    if let Err(e) = db.update_user_age(jane_id, 25) {
        eprintln!("Error updating Jane's age: {}", e);
    }
    
    // Display all users
    println!("All users:");
    for user in db.list_users() {
        println!("- {}", user.display_info());
    }
    
    // Test error handling
    match db.update_user_age(999, 30) {
        Ok(_) => println!("User updated successfully"),
        Err(e) => println!("Expected error: {}", e),
    }
    
    io::stdout().flush()?;
    Ok(())
}
