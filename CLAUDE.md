# CLAUDE.md - Coding Assistant Guidelines

## Roadmap: DevOps Multi-App Development Environment

### Core Principles

1. **Repository-First Architecture**: 
   - **CRITICAL**: ALL application code must come from external repositories
   - No local application code, only infrastructure configuration
   - Consistent cloning and build patterns across all applications
   - Standardized environment variable naming (TKT0_REPO_URL, MOD0_REPO_URL, TKT4_REPO_URL, etc.)
   - Multiple containers can pull from different repositories simultaneously

2. **Shared Infrastructure**:
   - Central database services (MySQL + admin tools)
   - Traefik for routing/proxy with dashboard
   - Consistent networking configuration
   - Standardized health checks

3. **App Independence**:
   - Each app has its own docker-compose file and Dockerfile
   - Consistent directory structure across all apps
   - Independent build and run cycles
   - No special cases or app-specific code in main scripts

4. **Resource Management**:
   - Selective startup of services
   - Memory usage monitoring and reporting
     - Real-time container memory usage display at startup
     - Total system memory impact calculation
     - Detailed per-container memory usage in test-services.sh
   - Easy shutdown of resource-intensive services
   - Consistent port allocation to prevent conflicts

### Project Structure

```
/project-root/
├── docker-compose.yaml    # Core infrastructure only
├── .env                   # Repository URLs configuration
├── start.sh               # Main startup script
├── test-services.sh       # Health verification
├── README.md              # Documentation
├── CLAUDE.md              # Documentation for Claude assistant
├── tkt0/                  # Python Development Environment
│   ├── Dockerfile
│   ├── docker-compose.tkt0.yml
│   ├── app.py             # Default Flask application
│   ├── templates/         # Flask HTML templates
│   └── static/            # Static assets (CSS, etc.)
├── mod0/                  # Additional Python Development Environment
│   ├── Dockerfile
│   ├── docker-compose.mod0.yml
│   ├── app.py             # Default Flask application
│   ├── templates/         # Flask HTML templates
│   └── static/            # Static assets (CSS, etc.)
├── tkt4/                  # React Trivia App
│   ├── Dockerfile
│   └── docker-compose.tkt4.yml
├── tkt56/                 # Issue Tracker App
│   ├── Dockerfile
│   └── docker-compose.tkt56.yml
├── tkt7/                  # Redwood Blog
│   ├── Dockerfile
│   └── docker-compose.tkt7.yml
└── traefik/               # Traefik configuration
    └── config.yml
```

### Port Assignments

| Service | Port | Description |
|---------|------|-------------|
| Traefik Dashboard | 8081 | Service monitoring |
| MySQL | 3306 | Database server |
| phpMyAdmin | 8080 | Database admin |
| CloudBeaver | 8978 | SQL client |
| TKT0 Flask | 5000 | Python learning app |
| TKT0 Jupyter | 8888 | Jupyter notebooks |
| MOD0 Flask | 5001 | Additional Python app |
| MOD0 Jupyter | 8889 | Additional Jupyter notebooks |
| TKT4 Web | 5174 | React trivia app |
| TKT4 Storybook | 6007 | Trivia app components |
| TKT56 Web | 5175 | Issue tracker app |
| TKT56 Storybook | 6008 | Issue tracker components |
| TKT7 Web | 8910 | Redwood blog UI |
| TKT7 API | 8911 | Redwood GraphQL API |
| TKT7 Storybook | 6009 | Redwood components |

### Application Summaries

1. **TKT0** - Python Learning Environment
   - Python Flask + Jupyter notebook environment
   - Educational platform for learning Python concepts
   - External repository containing all code (NOT LOCAL)
   - Educational storybook integrated into Flask app

2. **MOD0** - Additional Python Development Environment
   - Secondary Python Flask + Jupyter notebook environment
   - Allows students to experiment with a second repository
   - Runs on different ports (5001/8889) to avoid conflicts with TKT0
   - Demonstrates the repository-first architecture pattern

3. **TKT4** - React Trivia App
   - React-based quiz application
   - Standard React with Storybook integration
   - External repository only

4. **TKT56** - Issue Tracker App
   - Next.js issue tracking application
   - Integrated Storybook for components
   - External repository only

5. **TKT7** - Redwood Blog
   - Full-stack Redwood.js application
   - Separate web and API servers
   - Prisma ORM database integration
   - External repository only

### Implementation Phases

1. **Infrastructure Setup**
   - Core docker-compose.yaml with database services
   - Traefik reverse proxy configuration
   - Network and volume setup
   - Basic health check implementation

2. **Script Development**
   - Repository configuration through .env file
   - Main start script with selective app startup
   - Support for multiple parallel development environments (TKT0, MOD0)
   - Service testing and verification
   - Memory usage monitoring

3. **App Integration**
   - Standardized app docker-compose files
   - Consistent repository cloning pattern
   - Port allocation and service discovery
   - Health check standardization

4. **Documentation & Testing**
   - Comprehensive README
   - App-specific documentation and templates
   - Tutorial content for repository switching
   - Full system testing
   - Resource usage optimization