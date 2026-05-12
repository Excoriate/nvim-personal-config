/**
 * Production-Grade TypeScript Test File
 * Tests: Advanced types, generics, decorators, async/await, modules, and enterprise patterns
 */

// Import statements to test module resolution and auto-imports
import { EventEmitter } from 'events';
import * as fs from 'fs/promises';
import { promisify } from 'util';

// Advanced type definitions for production use
type Environment = 'development' | 'staging' | 'production';

interface DatabaseConfig {
  readonly host: string;
  readonly port: number;
  readonly database: string;
  readonly ssl?: boolean;
  connectionPool?: {
    min: number;
    max: number;
    idleTimeoutMs: number;
  };
}

interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
  metadata: {
    timestamp: Date;
    requestId: string;
    version: string;
  };
}

// Generic utility types for enterprise applications
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

type RequiredKeys<T> = {
  [K in keyof T]-?: {} extends Pick<T, K> ? never : K;
}[keyof T];

type OptionalKeys<T> = {
  [K in keyof T]-?: {} extends Pick<T, K> ? K : never;
}[keyof T];

// Advanced conditional types
type NonNullable<T> = T extends null | undefined ? never : T;

type ExtractArrayType<T> = T extends (infer U)[] ? U : never;

// Decorator factory for production logging and monitoring
function Log(target: any, propertyName: string, descriptor: PropertyDescriptor) {
  const method = descriptor.value;
  descriptor.value = function (...args: any[]) {
    console.log(`Calling ${propertyName} with args:`, args);
    const start = performance.now();
    const result = method.apply(this, args);
    
    if (result instanceof Promise) {
      return result.finally(() => {
        console.log(`${propertyName} completed in ${performance.now() - start}ms`);
      });
    } else {
      console.log(`${propertyName} completed in ${performance.now() - start}ms`);
      return result;
    }
  };
}

function Validate(schema: Record<string, (value: any) => boolean>) {
  return function (target: any, propertyName: string, descriptor: PropertyDescriptor) {
    const method = descriptor.value;
    descriptor.value = function (...args: any[]) {
      for (const [key, validator] of Object.entries(schema)) {
        const argIndex = parseInt(key);
        if (!validator(args[argIndex])) {
          throw new Error(`Validation failed for argument ${argIndex} in ${propertyName}`);
        }
      }
      return method.apply(this, args);
    };
  };
}

// Abstract base class with generic constraints
abstract class BaseRepository<T extends { id: string | number }> {
  protected abstract tableName: string;
  
  abstract findById(id: T['id']): Promise<T | null>;
  abstract findAll(filters?: DeepPartial<T>): Promise<T[]>;
  abstract create(entity: Omit<T, 'id'>): Promise<T>;
  abstract update(id: T['id'], updates: Partial<T>): Promise<T>;
  abstract delete(id: T['id']): Promise<boolean>;
  
  // Template method pattern
  async findByIds(ids: T['id'][]): Promise<T[]> {
    const results = await Promise.allSettled(
      ids.map(id => this.findById(id))
    );
    
    return results
      .filter((result): result is PromiseFulfilledResult<T | null> => 
        result.status === 'fulfilled' && result.value !== null
      )
      .map(result => result.value!);
  }
}

// Domain model with complex types
interface User {
  id: string;
  email: string;
  profile: {
    firstName: string;
    lastName: string;
    dateOfBirth?: Date;
    preferences: UserPreferences;
  };
  roles: Role[];
  metadata: {
    createdAt: Date;
    updatedAt: Date;
    lastLoginAt?: Date;
    isEmailVerified: boolean;
  };
}

interface UserPreferences {
  theme: 'light' | 'dark' | 'auto';
  language: string;
  timezone: string;
  notifications: {
    email: boolean;
    push: boolean;
    inApp: boolean;
  };
}

interface Role {
  id: string;
  name: string;
  permissions: Permission[];
  isSystemRole: boolean;
}

interface Permission {
  resource: string;
  actions: ('create' | 'read' | 'update' | 'delete')[];
  conditions?: Record<string, unknown>;
}

// Concrete repository implementation
class UserRepository extends BaseRepository<User> {
  protected tableName = 'users';
  private cache = new Map<string, User>();
  
  @Log
  async findById(id: string): Promise<User | null> {
    // Check cache first
    if (this.cache.has(id)) {
      return this.cache.get(id)!;
    }
    
    // Simulate database query
    const user = await this.simulateDatabaseQuery<User>(`SELECT * FROM ${this.tableName} WHERE id = ?`, [id]);
    
    if (user) {
      this.cache.set(id, user);
    }
    
    return user;
  }
  
  @Log
  @Validate({
    '0': (filters) => typeof filters === 'object'
  })
  async findAll(filters?: DeepPartial<User>): Promise<User[]> {
    const query = this.buildQuery(filters);
    return this.simulateDatabaseQuery<User[]>(query.sql, query.params);
  }
  
  @Log
  async create(userData: Omit<User, 'id'>): Promise<User> {
    const user: User = {
      id: this.generateId(),
      ...userData,
      metadata: {
        ...userData.metadata,
        createdAt: new Date(),
        updatedAt: new Date(),
      }
    };
    
    await this.simulateDatabaseQuery(
      `INSERT INTO ${this.tableName} (id, email, profile, roles, metadata) VALUES (?, ?, ?, ?, ?)`,
      [user.id, user.email, JSON.stringify(user.profile), JSON.stringify(user.roles), JSON.stringify(user.metadata)]
    );
    
    this.cache.set(user.id, user);
    return user;
  }
  
  @Log
  async update(id: string, updates: Partial<User>): Promise<User> {
    const existingUser = await this.findById(id);
    if (!existingUser) {
      throw new Error(`User with id ${id} not found`);
    }
    
    const updatedUser: User = {
      ...existingUser,
      ...updates,
      metadata: {
        ...existingUser.metadata,
        ...updates.metadata,
        updatedAt: new Date(),
      }
    };
    
    await this.simulateDatabaseQuery(
      `UPDATE ${this.tableName} SET email = ?, profile = ?, roles = ?, metadata = ? WHERE id = ?`,
      [updatedUser.email, JSON.stringify(updatedUser.profile), JSON.stringify(updatedUser.roles), JSON.stringify(updatedUser.metadata), id]
    );
    
    this.cache.set(id, updatedUser);
    return updatedUser;
  }
  
  @Log
  async delete(id: string): Promise<boolean> {
    const result = await this.simulateDatabaseQuery<{ affectedRows: number }>(
      `DELETE FROM ${this.tableName} WHERE id = ?`,
      [id]
    );
    
    if (result && result.affectedRows > 0) {
      this.cache.delete(id);
      return true;
    }
    
    return false;
  }
  
  // Advanced query methods with complex types
  async findByRole(roleName: string): Promise<User[]> {
    const users = await this.findAll();
    return users.filter(user => 
      user.roles.some(role => role.name === roleName)
    );
  }
  
  async findByPermission(resource: string, action: Permission['actions'][number]): Promise<User[]> {
    const users = await this.findAll();
    return users.filter(user =>
      user.roles.some(role =>
        role.permissions.some(permission =>
          permission.resource === resource && permission.actions.includes(action)
        )
      )
    );
  }
  
  // Helper methods with proper typing
  private buildQuery(filters?: DeepPartial<User>): { sql: string; params: any[] } {
    let sql = `SELECT * FROM ${this.tableName}`;
    const params: any[] = [];
    
    if (filters) {
      const conditions: string[] = [];
      
      if (filters.email) {
        conditions.push('email LIKE ?');
        params.push(`%${filters.email}%`);
      }
      
      if (filters.profile?.firstName) {
        conditions.push('JSON_EXTRACT(profile, "$.firstName") LIKE ?');
        params.push(`%${filters.profile.firstName}%`);
      }
      
      if (conditions.length > 0) {
        sql += ` WHERE ${conditions.join(' AND ')}`;
      }
    }
    
    return { sql, params };
  }
  
  private generateId(): string {
    return `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
  
  private async simulateDatabaseQuery<T>(sql: string, params: any[]): Promise<T> {
    // Simulate async database operation
    await new Promise(resolve => setTimeout(resolve, Math.random() * 100));
    
    // Mock response based on query type
    if (sql.includes('SELECT')) {
      return this.mockSelectResult<T>(sql);
    }
    
    return { affectedRows: 1 } as T;
  }
  
  private mockSelectResult<T>(sql: string): T {
    const mockUser: User = {
      id: this.generateId(),
      email: 'test@example.com',
      profile: {
        firstName: 'John',
        lastName: 'Doe',
        dateOfBirth: new Date('1990-01-01'),
        preferences: {
          theme: 'dark',
          language: 'en',
          timezone: 'UTC',
          notifications: {
            email: true,
            push: false,
            inApp: true,
          },
        },
      },
      roles: [
        {
          id: 'role_1',
          name: 'user',
          permissions: [
            {
              resource: 'profile',
              actions: ['read', 'update'],
            },
          ],
          isSystemRole: false,
        },
      ],
      metadata: {
        createdAt: new Date(),
        updatedAt: new Date(),
        isEmailVerified: true,
      },
    };
    
    if (sql.includes('COUNT') || sql.includes('affectedRows')) {
      return [mockUser] as T;
    }
    
    return mockUser as T;
  }
}

// Service layer with complex business logic
class UserService extends EventEmitter {
  constructor(
    private userRepository: UserRepository,
    private emailService: EmailService,
    private auditLogger: AuditLogger,
    private config: ApplicationConfig
  ) {
    super();
    
    // Set up event listeners for business events
    this.on('user:created', this.handleUserCreated.bind(this));
    this.on('user:updated', this.handleUserUpdated.bind(this));
    this.on('user:deleted', this.handleUserDeleted.bind(this));
  }
  
  @Log
  async createUser(userData: CreateUserRequest): Promise<ApiResponse<User>> {
    try {
      // Validate business rules
      await this.validateUserCreation(userData);
      
      // Create user with proper defaults
      const user = await this.userRepository.create({
        email: userData.email.toLowerCase().trim(),
        profile: {
          firstName: userData.firstName.trim(),
          lastName: userData.lastName.trim(),
          dateOfBirth: userData.dateOfBirth,
          preferences: {
            theme: 'auto',
            language: userData.language || 'en',
            timezone: userData.timezone || 'UTC',
            notifications: {
              email: true,
              push: true,
              inApp: true,
            },
          },
        },
        roles: await this.getDefaultRoles(),
        metadata: {
          createdAt: new Date(),
          updatedAt: new Date(),
          isEmailVerified: false,
        },
      });
      
      // Emit business event
      this.emit('user:created', user);
      
      // Log audit event
      await this.auditLogger.log('USER_CREATED', user.id, { email: user.email });
      
      return {
        success: true,
        data: user,
        metadata: {
          timestamp: new Date(),
          requestId: this.generateRequestId(),
          version: this.config.apiVersion,
        },
      };
    } catch (error) {
      return this.createErrorResponse(error as Error);
    }
  }
  
  @Log
  async updateUserProfile(userId: string, updates: UpdateUserProfileRequest): Promise<ApiResponse<User>> {
    try {
      const existingUser = await this.userRepository.findById(userId);
      if (!existingUser) {
        throw new Error(`User with id ${userId} not found`);
      }
      
      // Validate business rules for updates
      await this.validateUserUpdate(existingUser, updates);
      
      const updatedUser = await this.userRepository.update(userId, {
        profile: {
          ...existingUser.profile,
          firstName: updates.firstName?.trim() || existingUser.profile.firstName,
          lastName: updates.lastName?.trim() || existingUser.profile.lastName,
          dateOfBirth: updates.dateOfBirth || existingUser.profile.dateOfBirth,
          preferences: {
            ...existingUser.profile.preferences,
            ...updates.preferences,
          },
        },
      });
      
      this.emit('user:updated', updatedUser, existingUser);
      await this.auditLogger.log('USER_UPDATED', userId, { changes: updates });
      
      return {
        success: true,
        data: updatedUser,
        metadata: {
          timestamp: new Date(),
          requestId: this.generateRequestId(),
          version: this.config.apiVersion,
        },
      };
    } catch (error) {
      return this.createErrorResponse(error as Error);
    }
  }
  
  // Advanced search with filtering and pagination
  async searchUsers(
    criteria: UserSearchCriteria,
    pagination: PaginationOptions = { page: 1, limit: 20 }
  ): Promise<ApiResponse<PaginatedResult<User>>> {
    try {
      const filters: DeepPartial<User> = {};
      
      if (criteria.email) {
        filters.email = criteria.email;
      }
      
      if (criteria.name) {
        filters.profile = {
          firstName: criteria.name,
        };
      }
      
      const allUsers = await this.userRepository.findAll(filters);
      
      // Apply additional filtering
      let filteredUsers = allUsers;
      
      if (criteria.roles && criteria.roles.length > 0) {
        filteredUsers = filteredUsers.filter(user =>
          criteria.roles!.some(role =>
            user.roles.some(userRole => userRole.name === role)
          )
        );
      }
      
      if (criteria.isEmailVerified !== undefined) {
        filteredUsers = filteredUsers.filter(user =>
          user.metadata.isEmailVerified === criteria.isEmailVerified
        );
      }
      
      // Apply pagination
      const startIndex = (pagination.page - 1) * pagination.limit;
      const endIndex = startIndex + pagination.limit;
      const paginatedUsers = filteredUsers.slice(startIndex, endIndex);
      
      const result: PaginatedResult<User> = {
        data: paginatedUsers,
        pagination: {
          page: pagination.page,
          limit: pagination.limit,
          total: filteredUsers.length,
          totalPages: Math.ceil(filteredUsers.length / pagination.limit),
        },
      };
      
      return {
        success: true,
        data: result,
        metadata: {
          timestamp: new Date(),
          requestId: this.generateRequestId(),
          version: this.config.apiVersion,
        },
      };
    } catch (error) {
      return this.createErrorResponse(error as Error);
    }
  }
  
  // Event handlers for business logic
  private async handleUserCreated(user: User): Promise<void> {
    // Send welcome email
    await this.emailService.sendWelcomeEmail(user.email, {
      firstName: user.profile.firstName,
      lastName: user.profile.lastName,
    });
    
    // Schedule email verification
    await this.emailService.sendVerificationEmail(user.email, user.id);
  }
  
  private async handleUserUpdated(updatedUser: User, previousUser: User): Promise<void> {
    // Check if email changed
    if (updatedUser.email !== previousUser.email) {
      await this.emailService.sendEmailChangeNotification(
        previousUser.email,
        updatedUser.email
      );
    }
  }
  
  private async handleUserDeleted(user: User): Promise<void> {
    // Clean up related data
    await this.cleanupUserData(user.id);
    
    // Send account deletion confirmation
    await this.emailService.sendAccountDeletionConfirmation(user.email, {
      firstName: user.profile.firstName,
      lastName: user.profile.lastName,
    });
  }
  
  // Validation methods with comprehensive business logic
  private async validateUserCreation(userData: CreateUserRequest): Promise<void> {
    // Check if email is already in use
    const existingUsers = await this.userRepository.findAll({ email: userData.email });
    if (existingUsers.length > 0) {
      throw new Error('Email address is already in use');
    }
    
    // Validate email format
    if (!this.isValidEmail(userData.email)) {
      throw new Error('Invalid email format');
    }
    
    // Validate age requirements
    if (userData.dateOfBirth) {
      const age = this.calculateAge(userData.dateOfBirth);
      if (age < this.config.minimumAge) {
        throw new Error(`Users must be at least ${this.config.minimumAge} years old`);
      }
    }
  }
  
  private async validateUserUpdate(user: User, updates: UpdateUserProfileRequest): Promise<void> {
    // Validate that email change is allowed
    if (updates.email && updates.email !== user.email) {
      const existingUsers = await this.userRepository.findAll({ email: updates.email });
      if (existingUsers.length > 0) {
        throw new Error('Email address is already in use');
      }
    }
    
    // Validate age if date of birth is being updated
    if (updates.dateOfBirth) {
      const age = this.calculateAge(updates.dateOfBirth);
      if (age < this.config.minimumAge) {
        throw new Error(`Users must be at least ${this.config.minimumAge} years old`);
      }
    }
  }
  
  // Utility methods with proper typing
  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }
  
  private calculateAge(dateOfBirth: Date): number {
    const today = new Date();
    const birthDate = new Date(dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    return age;
  }
  
  private async getDefaultRoles(): Promise<Role[]> {
    return [
      {
        id: 'default_user_role',
        name: 'user',
        permissions: [
          {
            resource: 'profile',
            actions: ['read', 'update'],
          },
        ],
        isSystemRole: true,
      },
    ];
  }
  
  private generateRequestId(): string {
    return `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
  
  private createErrorResponse(error: Error): ApiResponse<never> {
    return {
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: error.message,
        details: {
          stack: error.stack,
        },
      },
      metadata: {
        timestamp: new Date(),
        requestId: this.generateRequestId(),
        version: this.config.apiVersion,
      },
    };
  }
  
  private async cleanupUserData(userId: string): Promise<void> {
    // Implementation for cleaning up user-related data
    // This would typically involve calling other services
    await Promise.resolve(); // Placeholder
  }
}

// Supporting interfaces and types
interface CreateUserRequest {
  email: string;
  firstName: string;
  lastName: string;
  dateOfBirth?: Date;
  language?: string;
  timezone?: string;
}

interface UpdateUserProfileRequest {
  firstName?: string;
  lastName?: string;
  dateOfBirth?: Date;
  email?: string;
  preferences?: Partial<UserPreferences>;
}

interface UserSearchCriteria {
  email?: string;
  name?: string;
  roles?: string[];
  isEmailVerified?: boolean;
}

interface PaginationOptions {
  page: number;
  limit: number;
}

interface PaginatedResult<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

interface ApplicationConfig {
  apiVersion: string;
  minimumAge: number;
  database: DatabaseConfig;
  email: {
    provider: string;
    apiKey: string;
  };
}

// Mock service classes for dependency injection
class EmailService {
  async sendWelcomeEmail(email: string, user: { firstName: string; lastName: string }): Promise<void> {
    console.log(`Sending welcome email to ${email} for ${user.firstName} ${user.lastName}`);
  }
  
  async sendVerificationEmail(email: string, userId: string): Promise<void> {
    console.log(`Sending verification email to ${email} for user ${userId}`);
  }
  
  async sendEmailChangeNotification(oldEmail: string, newEmail: string): Promise<void> {
    console.log(`Sending email change notification from ${oldEmail} to ${newEmail}`);
  }
  
  async sendAccountDeletionConfirmation(email: string, user: { firstName: string; lastName: string }): Promise<void> {
    console.log(`Sending account deletion confirmation to ${email} for ${user.firstName} ${user.lastName}`);
  }
}

class AuditLogger {
  async log(action: string, userId: string, details: Record<string, unknown>): Promise<void> {
    console.log(`Audit log: ${action} for user ${userId}`, details);
  }
}

// Factory pattern for dependency injection
class ServiceFactory {
  private static instance: ServiceFactory;
  private userService?: UserService;
  
  private constructor() {}
  
  static getInstance(): ServiceFactory {
    if (!ServiceFactory.instance) {
      ServiceFactory.instance = new ServiceFactory();
    }
    return ServiceFactory.instance;
  }
  
  getUserService(): UserService {
    if (!this.userService) {
      const config: ApplicationConfig = {
        apiVersion: '1.0.0',
        minimumAge: 13,
        database: {
          host: 'localhost',
          port: 5432,
          database: 'myapp',
          ssl: true,
          connectionPool: {
            min: 2,
            max: 10,
            idleTimeoutMs: 30000,
          },
        },
        email: {
          provider: 'sendgrid',
          apiKey: process.env.SENDGRID_API_KEY || 'test-key',
        },
      };
      
      const userRepository = new UserRepository();
      const emailService = new EmailService();
      const auditLogger = new AuditLogger();
      
      this.userService = new UserService(userRepository, emailService, auditLogger, config);
    }
    
    return this.userService;
  }
}

// Main demonstration function with comprehensive error handling
async function demonstrateProductionTypeScript(): Promise<void> {
  console.log('🚀 Production TypeScript LSP Test');
  console.log('================================');
  
  try {
    const serviceFactory = ServiceFactory.getInstance();
    const userService = serviceFactory.getUserService();
    
    // Test user creation with comprehensive type checking
    const createUserRequest: CreateUserRequest = {
      email: 'alice.johnson@example.com',
      firstName: 'Alice',
      lastName: 'Johnson',
      dateOfBirth: new Date('1995-05-15'),
      language: 'en',
      timezone: 'America/New_York',
    };
    
    console.log('Creating user...');
    const createResponse = await userService.createUser(createUserRequest);
    
    if (!createResponse.success) {
      throw new Error(`Failed to create user: ${createResponse.error?.message}`);
    }
    
    const userId = createResponse.data!.id;
    console.log(`✅ User created with ID: ${userId}`);
    
    // Test user profile update with partial types
    const updateRequest: UpdateUserProfileRequest = {
      preferences: {
        theme: 'dark',
        notifications: {
          email: false,
          push: true,
          inApp: true,
        },
      },
    };
    
    console.log('Updating user profile...');
    const updateResponse = await userService.updateUserProfile(userId, updateRequest);
    
    if (updateResponse.success) {
      console.log('✅ User profile updated successfully');
    }
    
    // Test search functionality with complex filtering
    const searchCriteria: UserSearchCriteria = {
      name: 'Alice',
      roles: ['user'],
      isEmailVerified: false,
    };
    
    console.log('Searching users...');
    const searchResponse = await userService.searchUsers(searchCriteria, { page: 1, limit: 10 });
    
    if (searchResponse.success && searchResponse.data) {
      console.log(`✅ Found ${searchResponse.data.data.length} users`);
      console.log(`Total pages: ${searchResponse.data.pagination.totalPages}`);
    }
    
    // Test advanced TypeScript features
    const users = searchResponse.data?.data || [];
    
    // Type guards and advanced array methods
    const verifiedUsers = users.filter((user): user is User & { metadata: { isEmailVerified: true } } =>
      user.metadata.isEmailVerified
    );
    
    // Complex type transformations
    const userSummaries: Array<Pick<User, 'id' | 'email'> & { fullName: string }> = users.map(user => ({
      id: user.id,
      email: user.email,
      fullName: `${user.profile.firstName} ${user.profile.lastName}`,
    }));
    
    console.log('✅ Advanced TypeScript features tested successfully');
    console.log(`Processed ${userSummaries.length} user summaries`);
    
    // Test async/await with proper error handling
    const fileOperations = await Promise.allSettled([
      fs.writeFile('/tmp/users.json', JSON.stringify(userSummaries, null, 2)),
      fs.writeFile('/tmp/search_results.json', JSON.stringify(searchResponse.data, null, 2)),
    ]);
    
    const successfulOps = fileOperations.filter(op => op.status === 'fulfilled').length;
    console.log(`✅ File operations completed: ${successfulOps}/${fileOperations.length} successful`);
    
  } catch (error) {
    console.error('❌ Error during demonstration:', error);
    
    if (error instanceof Error) {
      console.error('Error details:', {
        name: error.name,
        message: error.message,
        stack: error.stack,
      });
    }
  }
}

// Export for module testing
export {
  UserService,
  UserRepository,
  ServiceFactory,
  type User,
  type ApiResponse,
  type CreateUserRequest,
  type UpdateUserProfileRequest,
  type UserSearchCriteria,
  type PaginatedResult,
};

// Run demonstration if this file is executed directly
if (require.main === module) {
  demonstrateProductionTypeScript()
    .then(() => {
      console.log('🎉 Production TypeScript demonstration completed successfully!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('💥 Production TypeScript demonstration failed:', error);
      process.exit(1);
    });
}

// This line should trigger unused variable warning to test diagnostics
const unusedVariable = 'This should trigger a TypeScript diagnostic';
