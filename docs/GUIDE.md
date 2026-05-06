# Codebase Guide

**Version:** 1.0 (2026-05-06)  
**Updated:** 2026-05-06 09:12  
**Status:** Active

## Overview

This is a comprehensive development course/book covering **Rails 8 + React/Next.js** application development. The codebase contains progressive examples and exercises organized by chapters, with a focus on:

- **37signals/One Person Framework** patterns
- **Maquina** tools (generators, UI components)
- **Claude Code** AI-assisted development
- **Tailwind CSS** for styling
- **Mobile development** (Android/iOS) alongside web

## Directory Structure

```
/Users/tichlabs/Documents/codebase/
├── dev-setup.html          # Development environment setup guide
├── assets/
│   └── AppIcon.png         # App icon
└── code/
    ├── ch01_00 to ch01_24  # Chapter 1: Foundation (25 steps)
    ├── ch02_01 to ch02_23  # Chapter 2 (23 steps)
    ├── ch03_01 to ch03_16  # Chapter 3 (16 steps)
    ├── ch04_01 to ch04_17  # Chapter 4 (17 steps)
    ├── ch05_01 to ch05_22  # Chapter 5 (22 steps)
    ├── ch06_01 to ch06_32  # Chapter 6 (32 steps)
    ├── ch07_01 to ch07_23  # Chapter 7 (23 steps)
    ├── ch08_00 to ch08_22  # Chapter 8 (23 steps)
    ├── ch09_01 to ch09_09  # Chapter 9 (9 steps)
    └── ch10_01 to ch10_68  # Chapter 10 (68 steps, main project)
```

**Total: 259 chapter folders** covering the full development lifecycle.

## Chapter Contents

Each chapter folder (`chXX_YY`) contains:

| File/Folder | Description |
|-------------|-------------|
| `.gitignore` | Git ignore rules |
| `.tool-versions` | asdf/rtx tool version manager config |
| `bin/` | Scripts (e.g., `android.sh`) |
| `rails/` | Rails 8 application |
| `android/` | Android mobile app (later chapters) |
| `ios/` | iOS mobile app (later chapters) |

## Rails Application Structure

The `rails/` folder in each chapter contains a standard Rails 8 app:

```
rails/
├── app/              # Controllers, models, views, assets
├── config/           # Application configuration
├── db/               # Database schema and migrations
├── vendor/           # Third-party code
├── Dockerfile        # Container configuration
├── Gemfile           # Ruby dependencies
├── Gemfile.lock      # Locked dependencies
└── .ruby-version     # Ruby version (likely 3.3+)
```

Key features:
- **Dockerized** (has Dockerfile)
- **SQLite** with Solid Queue and Solid Errors
- **Tailwind CSS** for styling
- **StimulusJS** for interactivity
- **Maquina Components** for UI

## Technology Stack

### Backend (Rails)
- Ruby on Rails 8.0+
- SQLite (with Solid Queue, Solid Errors)
- Tailwind CSS 4
- StimulusJS
- Maquina Generators & Components
- Rack Attack (security)

### Frontend (React/Next.js)
- Next.js 15
- TypeScript (strict mode)
- Tailwind CSS
- React 19+

### Mobile
- Android (native or React Native)
- iOS (native or React Native)

### AI Development Tools
- **Claude Code CLI** - AI coding assistant
- **rails-simplifier** - 37signals patterns
- **rails-security-auditor** - Security audits
- **mvp-creator** - MVP documentation
- **better-stimulus** - StimulusJS best practices
- **maquina-ui-standards** - UI component standards
- **codewarden** - React security & quality
- **vibe-coding-plugin** - 77 skills, 18 auditor agents

## Development Environment Setup

See `dev-setup.html` for complete setup instructions. Quick start:

### Prerequisites
- Ruby 3.3+ (managed via asdf/rtx)
- Node.js 20+ (for React/Next.js)
- VS Code with extensions:
  - Shopify Ruby LSP
  - Rails Snippets
  - ES7+ React Snippets
  - Tailwind CSS IntelliSense
  - ESLint, Prettier

### Quick Commands
```bash
# Start Rails server
cd code/chXX_YY/rails && bin/rails server

# Run Maquina generator (in a Rails project)
bin/rails g maquina:app --auth registration

# Start Claude Code
claude

# Create MVP documentation
> Create MVP documentation for [your app]
```

## Chapter Progression

Based on folder naming and structure:

1. **Chapter 1** (ch01_00-24): Foundation - Rails setup, basic app structure
2. **Chapter 2** (ch02_01-23): Core features, models, controllers
3. **Chapter 3** (ch03_01-16): Views, Tailwind styling
4. **Chapter 4** (ch04_01-17): Authentication, user management
5. **Chapter 5** (ch05_01-22): Adding mobile (Android/iOS)
6. **Chapter 6** (ch06_01-32): Advanced features, business logic
7. **Chapter 7** (ch07_01-23): API development
8. **Chapter 8** (ch08_00-22): Integration, third-party services
9. **Chapter 9** (ch09_01-09): Testing, quality assurance
10. **Chapter 10** (ch10_01-68): Full production app, deployment

Note: Chapter 10 has the most steps (68), suggesting it's the main comprehensive project.

## Key Resources

- [Maquina App](https://maquina.app) - Tools extracted from production Rails apps
- [Rails Claude Code Plugins](https://github.com/maquina-app/rails-claude-code)
- [Maquina Generators](https://github.com/maquina-app/maquina_generators)
- [Maquina Components](https://github.com/maquina-app/maquina_components)
- [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code)
- [37signals Patterns](https://37signals.com)

## Workflow Example

```
💡 Idea/Prompt
    ↓
[MVP Creator] Research + Business Plan + User Journeys
    ↓
[Spec-Driven Dev] Shape Specs → Create Tasks
    ↓
[Maquina Generators] rails g maquina:app
    ↓
[Claude Code] Build with 37signals patterns
    ↓
[rails-security-auditor] Validate before deploy
```

## Notes

- Chapter folders are sequential - each builds on the previous
- The `.tool-versions` file ensures consistent tooling across chapters
- Mobile folders (android/, ios/) appear in later chapters (ch05+)
- Chapter 10 (ch10_*) has the most comprehensive implementation
- Missing folder: `ch10_38` (may be intentional or oversight)
