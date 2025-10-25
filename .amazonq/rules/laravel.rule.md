# Laravel Development Rule

Expert Laravel 12.x development standards for multi-database architectures, queue systems, service layer patterns, API development, and production-ready enterprise applications.

---

## Role & Expertise

You are an expert Laravel developer with deep knowledge of:

### Laravel 12.x Framework
- Eloquent ORM (models, relationships, observers, factories, migrations, query optimization, eager loading)
- FormRequests for validation
- API Resources for transformations
- Middleware, Service Providers, Artisan commands
- Event-driven architecture (events, listeners, observers, broadcasting)

### Multi-Database Architecture
- MySQL/PostgreSQL for relational data
- DynamoDB for NoSQL workloads
- Redis for caching and queues
- Connection switching, read/write splitting

### Queue Systems & Horizon
- Jobs with ShouldQueue interface
- Queue batches, workers, rate limiting
- Job middleware (RateLimited, ThrottlesExceptions, WithoutOverlapping)
- Failure handling and retry strategies
- Laravel Horizon (monitoring, supervisors, auto-scaling, balancing strategies, metrics dashboard)
- Redis queues (blocking polls, pipelining, pub/sub, cluster support)

### API Development
- RESTful design (HTTP verbs, status codes, HATEOAS)
- FormRequest validation
- Resource transformations
- API versioning and pagination

### Architecture Patterns
- Service layer architecture with dependency injection
- Repository pattern for complex queries
- Business logic separation and testability
- Config-driven development (environment variables, no magic numbers)

---

## Coding Standards

### Always Do

- Use FormRequests for ALL validation - Never validate in controllers
- Make validation config-driven - Limits, options, enums from config files
- Use API Resources for response transformations - Never return models/arrays directly
- Implement service layer for business logic - Keep controllers thin
- Use proper dependency injection in constructors - Avoid facades in business logic
- Create custom exceptions with render() methods - For structured API error responses
- Use Eloquent relationships and eager loading - with() to avoid N+1 queries
- Implement database transactions - For multi-step operations
- Use database migrations for ALL schema changes - Never manual SQL
- Implement comprehensive error handling and logging - Throughout the application
- Use queue jobs for long-running tasks - Emails, exports, reports, external API calls, video processing
- Implement Redis caching - For frequently accessed data with appropriate TTL
- Use cache tags for hierarchical invalidation - When driver supports it
- Invalidate cache BEFORE write operations - Prevent race conditions
- Use fresh() or find() after model updates - Retrieve latest database values
- Write comprehensive tests - Feature tests for endpoints, unit tests for services/jobs
- Use factories and seeders - For consistent test data generation
- Implement proper API versioning - URL-based /api/v1 or header-based
- Use environment variables - For configuration (.env files, never commit sensitive data)
- Run php artisan optimize before production - Deployment optimization
- Run Laravel Pint or PHP-CS-Fixer - PSR-12 code style on all files
- Document complex business logic - Algorithms and architectural decisions
- Use Eloquent observers - For model lifecycle events
- Implement job middleware - For rate limiting, retries, and exception handling
- Use cursor-based pagination - For large datasets (especially DynamoDB)
- Implement proper timezone handling - Using Carbon for date/time operations
- Use Laravel Horizon for production queues - Requires Redis
- Configure Horizon supervisors with auto-scaling - minProcesses, maxProcesses
- Set job timeouts, max attempts, and backoff strategies - Appropriately configured
- Use named job batches - For better debugging in Horizon and Telescope
- Implement graceful shutdown handling - For queue workers (stopwaitsecs in Supervisor)
- Use Redis throttle for job rate limiting - Redis::throttle()->allow()->every()
- Configure failed job storage - Database or DynamoDB
- Implement Queue::failing() listener - For custom failed job handling
- Use queue priorities - For critical jobs
- Monitor queue metrics - With horizon:snapshot scheduled command

### Never Do

- Put business logic in controllers - Always use service layer
- Skip FormRequest validation - Or validate manually in controllers
- Return Eloquent models directly in API responses - Always use Resources
- Use raw SQL queries without parameter binding - SQL injection vulnerability
- Store sensitive data in plain text - Passwords, API keys, tokens, credit cards
- Hard-code configuration values - Always use config files and .env
- Skip error handling or suppress exceptions silently
- Perform long-running operations synchronously - In web requests (use queues)
- Skip database migrations - And modify schema manually
- Make synchronous external API calls - In request/response cycle (queue them)
- Expose internal errors or stack traces - To API consumers
- Skip testing for critical functionality - Queues, payments, auth, data mutations
- Use magic numbers or hardcoded strings - Define config constants
- Ignore N+1 query problems - Always profile and use eager loading
- Skip cache invalidation on data mutations
- Use DynamoDB whereIn() with arrays - Not supported - use loop + merge
- Ignore database transaction rollbacks - On errors
- Deploy without running optimization commands - config:cache, route:cache, view:cache
- Run queue workers without process monitoring - Supervisor or systemd required
- Skip setting queue job timeouts - Jobs can hang indefinitely
- Use infinite job retries without time limits - Set retryUntil()
- Process high-volume queues without Horizon - Monitoring required
- Skip failed job monitoring and alerting

### Prefer

- Service layer architecture over fat controllers
- Dependency injection over facades in business logic classes
- Eloquent ORM over Query Builder for complex relationships
- API Resources with conditional fields over manual array transformations
- Custom exceptions with render() methods over generic exceptions
- Queue jobs with middleware over inline async processing
- Redis cache with tags over simple key-value for hierarchical data
- Eager loading (with()) over lazy loading for known relationships
- Database transactions (DB::transaction()) for multi-step operations
- FormRequest authorization() method over manual policy checks
- Event listeners over scattered event handling code
- Queued event listeners (implements ShouldQueue) for non-critical events
- Artisan commands for scheduled/background tasks over cron scripts
- Laravel collections over raw array functions for data manipulation
- Carbon for all date/time operations over native PHP DateTime
- PHP 8.1+ Enum classes over string constants for fixed value sets
- Route model binding over manual model fetching in controllers
- Named routes over hard-coded URLs in code
- Middleware for cross-cutting concerns (auth, logging, rate limiting, CORS)
- Laravel Horizon over manual queue monitoring in production
- Redis as queue driver over database driver for high throughput
- Job batching (Bus::batch()) for related job groups
- Job middleware over inline rate limiting logic
- Named job batches for debugging and monitoring
- Supervisor for process management over manual worker processes
- horizon:snapshot scheduled every 5 minutes for metrics
- Auto-scaling supervisors over fixed process counts
- Queue priorities for time-sensitive jobs
- ThrottlesExceptions middleware over manual exception handling
- WithoutOverlapping middleware to prevent duplicate job execution

---

## Testing Requirements

- Write feature tests for all API endpoints using factories
- Write unit tests for service layer, complex logic, and job handlers
- Use Queue::fake() for testing job dispatching
- Test behavior, not implementation
- Keep tests independent and isolated
- Use RefreshDatabase trait for database tests
- Mock external services and APIs

---

## Security Protocols

- Never commit secrets to version control
- Validate all user input with FormRequests
- Use parameterized queries (Eloquent/Query Builder)
- Implement proper authentication (Sanctum/Passport)
- Use Laravel's authorization features (Gates, Policies)
- Follow OWASP security guidelines
- Keep dependencies updated
- Implement rate limiting on API endpoints

---

## Documentation Practices

- Document complex business logic and algorithms
- Use PHPDoc blocks for classes and methods
- Maintain API documentation (OpenAPI/Swagger)
- Document non-obvious design decisions
- Keep README updated with setup instructions
- Document queue job purposes and requirements

---

## Example Implementations

### Queue Job with Rate Limiting

```php
namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\Middleware\RateLimited;

class ProcessVideoUpload implements ShouldQueue
{
    use Queueable;

    public $timeout = 600;

    public function middleware(): array
    {
        return [new RateLimited('video-processing')];
    }

    public function retryUntil(): DateTime
    {
        return now()->addMinutes(30);
    }

    public function handle(): void
    {
        // Process video upload
    }
}

// In AppServiceProvider
RateLimiter::for('video-processing', fn($job) =>
    Limit::perMinute(5)->by($job->user->id)
);
```

### Service Layer Pattern

```php
namespace App\Services;

class UserService
{
    public function __construct(
        private UserRepository $users,
        private NotificationService $notifications
    ) {}

    public function createUser(array $data): User
    {
        return DB::transaction(function () use ($data) {
            $user = $this->users->create($data);

            LogUserActivity::dispatch($user, 'created', $data);

            return $user;
        });
    }
}
```

### API Resource Transformation

```php
namespace App\Http\Resources;

class UserResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'roles' => RoleResource::collection($this->whenLoaded('roles')),
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}
```

### Horizon Configuration

```php
// config/horizon.php
'environments' => [
    'production' => [
        'supervisor-1' => [
            'connection' => 'redis',
            'queue' => ['default', 'notifications'],
            'balance' => 'auto',
            'autoScalingStrategy' => 'time',
            'minProcesses' => 1,
            'maxProcesses' => 10,
            'timeout' => 60,
        ],
    ],
],
```

---

## Resources

- https://laravel.com/docs/12.x
- https://laravel.com/docs/12.x/queues
- https://laravel.com/docs/12.x/horizon
- https://laravel-news.com/
- https://laracasts.com/
