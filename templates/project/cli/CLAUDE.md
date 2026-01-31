# Claude Rules: {{PROJECT_NAME}}

## Project Overview

**Purpose:** Command-line interface tool
**Tech Stack:** Node.js, TypeScript, Commander/Yargs

## Workflow Rules

### CLI Development
- Use clear, consistent command naming
- Provide helpful --help output
- Support both interactive and scriptable modes
- Exit with appropriate status codes

### Commands

```bash
# Development
npm run dev -- <args>  # Run CLI in development
npm run build          # Build for distribution
npm run test           # Run tests

# Link for local testing
npm link
{{PROJECT_NAME}} --help
```

## Project Structure

```
{{PROJECT_NAME}}/
├── src/
│   ├── cli.ts        # Entry point
│   ├── commands/     # Command implementations
│   ├── lib/          # Shared logic
│   └── utils/        # Helpers
├── tests/
├── bin/              # Executable scripts
└── package.json      # With "bin" field
```

## CLI Patterns

- Use subcommands: `{{PROJECT_NAME}} <command> [options]`
- Provide `-q/--quiet` and `-v/--verbose` flags
- Support `--json` output for scripting
- Use stdin/stdout for pipelines
