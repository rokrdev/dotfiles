---
description: Security rules
globs: ["**/auth/**", "**/api/**", "**/routes/**", "**/*.env*", "**/config/**"]
---
# Security Rules
- Never commit secrets, tokens, or credentials
- Always validate at system boundaries (user input, external APIs)
- No SQL string concatenation — use parameterized queries
- No command injection — never interpolate user input into shell commands
- XSS: always escape output in templates
