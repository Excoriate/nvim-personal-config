package main

import (
	"fmt"
	"os"
	"strconv"
)

// User represents a user in the system
type User struct {
	Name  string
	Age   int
	Email string
}

// NewUser creates a new user with validation
func NewUser(name string, age int, email string) (*User, error) {
	if name == "" {
		return nil, fmt.Errorf("name cannot be empty")
	}
	if age < 0 {
		return nil, fmt.Errorf("age cannot be negative")
	}
	return &User{
		Name:  name,
		Age:   age,
		Email: email,
	}, nil
}

// GetInfo returns formatted user information
func (u *User) GetInfo() string {
	return fmt.Sprintf("Name: %s, Age: %d, Email: %s", u.Name, u.Age, u.Email)
}

func main() {
	// Test autocompletion and hover - should show function signature
	user, err := NewUser("John Doe", 30, "john@example.com")
	if err != nil {
		fmt.Printf("Error creating user: %v\n", err)
		os.Exit(1)
	}

	// Test method autocompletion on user instance
	info := user.GetInfo()
	fmt.Println(info)

	// Test standard library autocompletion
	ageStr := strconv.Itoa(user.Age)
	fmt.Printf("Age as string: %s\n", ageStr)

	// This should show an error (unused variable)
	unusedVar := "this will trigger a diagnostic"

	// Test inlay hints for function parameters
	anotherUser, _ := NewUser("Jane", 25, "jane@example.com")
	fmt.Println(anotherUser.GetInfo())
}
