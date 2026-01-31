# Claude Rules: {{PROJECT_NAME}}

## Project Overview

**Purpose:** REST/GraphQL API service
**Tech Stack:** Node.js, TypeScript, Express/Fastify

## Workflow Rules

### API Development
- Follow REST conventions or GraphQL best practices
- Validate all inputs
- Use proper error handling with status codes
- Document endpoints

### Security
- Never commit secrets - use `op://` references
- Use `dev-infra secret` for runtime secrets
- Validate and sanitize all inputs
- Use parameterized queries for databases

### Commands

```bash
# Development
npm run dev          # Start dev server with hot reload
npm run test         # Run tests
npm run test:api     # Run API integration tests
npm run lint         # Check code style

# Database
npm run db:migrate   # Run migrations
npm run db:seed      # Seed development data

# Secrets
dev-infra secret "op://Developer/PostgreSQL/connection_string"
```

## Project Structure

```
{{PROJECT_NAME}}/
├── src/
│   ├── routes/      # API routes
│   ├── services/    # Business logic
│   ├── models/      # Data models
│   ├── middleware/  # Express/Fastify middleware
│   └── utils/       # Helpers
├── tests/
│   ├── unit/        # Unit tests
│   └── integration/ # API tests
├── scripts/         # Utility scripts
└── migrations/      # Database migrations
```

## Environment Variables

Required (from 1Password):
- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - JWT signing key

Optional (in .env):
- `PORT` - Server port (default: 3000)
- `LOG_LEVEL` - Logging level (default: info)
