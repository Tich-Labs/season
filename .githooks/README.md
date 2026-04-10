# Local Development Setup

## Git Hooks

This project uses git hooks to enforce code quality standards before pushing.

### Setup

After cloning, configure git to use the project's hooks:

```bash
git config core.hooksPath .githooks
```

### Pre-Push Hook

The pre-push hook automatically runs:
- **RuboCop** — Ruby code linting & style checks
- **ERB Lint** — ERB template linting

If either linter fails, the push is blocked. Fix violations and try again.

### Manual Linting

Run linters manually anytime:

```bash
# Ruby (RuboCop)
bin/rubocop

# Auto-fix Ruby violations
bin/rubocop -A

# ERB templates
bundle exec erb_lint --lint-all

# Auto-fix ERB violations
bundle exec erb_lint --lint-all --autocorrect
```

### Disabling the Hook (Not Recommended)

To temporarily bypass the hook:

```bash
git push --no-verify
```

Use only when absolutely necessary and after verifying code quality manually.
