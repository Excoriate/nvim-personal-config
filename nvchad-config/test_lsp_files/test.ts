/**
 * Test TypeScript file for LSP functionality
 * This should test autocompletion, diagnostics, type inference, and inlay hints
 */

// Interface to test type definitions and autocompletion
interface User {
  readonly id: number;
  name: string;
  age: number;
  email: string;
  preferences?: UserPreferences;
}

interface UserPreferences {
  theme: 'light' | 'dark';
  notifications: boolean;
  language: string;
}

// Class to test method autocompletion and type checking
class UserManager {
  private users: User[] = [];
  private nextId = 1;

  // Test parameter type hints and return type inference
  addUser(name: string, age: number, email: string): User {
    const user: User = {
      id: this.nextId++,
      name,
      age,
      email
    };
    
    this.users.push(user);
    return user;
  }

  // Test array methods and autocompletion
  findUserById(id: number): User | undefined {
    return this.users.find(user => user.id === id);
  }

  // Test generic types and method chaining
  getUsersByAge(minAge: number): User[] {
    return this.users
      .filter(user => user.age >= minAge)
      .sort((a, b) => a.age - b.age);
  }

  // Test async/await and Promise types
  async saveUsersToStorage(): Promise<void> {
    try {
      const userData = JSON.stringify(this.users, null, 2);
      // Simulate async storage operation
      await new Promise(resolve => setTimeout(resolve, 100));
      console.log('Users saved to storage');
    } catch (error) {
      console.error('Failed to save users:', error);
      throw error;
    }
  }

  // Test getter with type inference
  get userCount(): number {
    return this.users.length;
  }
}

// Test function types and callbacks
type UserValidator = (user: Partial<User>) => boolean;

const validateUser: UserValidator = (user) => {
  // Test object property autocompletion
  return Boolean(user.name && user.email && user.age && user.age > 0);
};

// Test arrow functions and type inference
const createDefaultPreferences = (): UserPreferences => ({
  theme: 'light',
  notifications: true,
  language: 'en'
});

// Test union types and type guards
function processUserInput(input: string | number): string {
  if (typeof input === 'string') {
    // Type narrowing - should show string methods
    return input.trim().toLowerCase();
  } else {
    // Type narrowing - should show number methods
    return input.toString();
  }
}

// Test generics and constraints
function mapArray<T, U>(array: T[], mapper: (item: T) => U): U[] {
  return array.map(mapper);
}

// Main function to test all features
async function main(): Promise<void> {
  const userManager = new UserManager();
  
  // Test method autocompletion and parameter hints
  const user1 = userManager.addUser("Alice Johnson", 28, "alice@example.com");
  const user2 = userManager.addUser("Bob Smith", 35, "bob@example.com");
  
  // Test object property autocompletion
  console.log(`Created user: ${user1.name} (ID: ${user1.id})`);
  
  // Test method chaining and array methods
  const adults = userManager.getUsersByAge(18);
  console.log(`Found ${adults.length} adult users`);
  
  // Test optional chaining and nullish coalescing
  const foundUser = userManager.findUserById(1);
  const userName = foundUser?.name ?? 'Unknown';
  console.log(`Found user: ${userName}`);
  
  // Test destructuring with type inference
  const { name, age, email } = user1;
  console.log(`User details: ${name}, ${age}, ${email}`);
  
  // Test array methods with type inference
  const userNames = userManager.getUsersByAge(0)
    .map(user => user.name)
    .filter(name => name.length > 5);
  
  // Test generic function usage
  const userAges = mapArray(adults, user => user.age);
  console.log('User ages:', userAges);
  
  // Test async/await
  try {
    await userManager.saveUsersToStorage();
  } catch (error) {
    console.error('Error saving users:', error);
  }
  
  // This should show a type error (uncomment to test)
  // const invalidUser: User = { name: "Invalid", age: "not a number" };
  
  // Test unused variable warning
  const unusedVariable = "This should trigger a diagnostic";
  
  // Test function parameter type checking
  const isValid = validateUser({ name: "Test", email: "test@example.com", age: 25 });
  console.log('User is valid:', isValid);
}

// Execute main function
main().catch(console.error);
