# Claude Rules: {{PROJECT_NAME}}

## Project Overview

**Purpose:** Reusable library/package
**Tech Stack:** TypeScript, npm/pnpm

## Workflow Rules

### Library Development
- Maintain backward compatibility
- Document all public APIs
- Write comprehensive tests
- Keep bundle size minimal

### Commands

```bash
# Development
npm run build         # Build library
npm run test          # Run tests
npm run test:watch    # Test in watch mode
npm run lint          # Check code style

# Documentation
npm run docs          # Generate API docs

# Publishing
npm run prepublishOnly  # Pre-publish checks
npm publish             # Publish to npm
```

## Project Structure

```
{{PROJECT_NAME}}/
├── src/
│   ├── index.ts      # Public exports
│   └── lib/          # Implementation
├── tests/
├── docs/             # Documentation
└── package.json      # With proper exports field
```

## Package.json Requirements

- Set `"type": "module"` for ESM
- Configure `"exports"` field properly
- Include `"types"` for TypeScript
- Use `"files"` to control what's published
