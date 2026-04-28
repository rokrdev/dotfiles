---
description: Security rules
---
# Security Rules
- Never commit secrets, tokens, or credentials
- Always validate at system boundaries (user input, external APIs)
- No SQL string concatenation — use parameterized queries
  ```js
  // Safe
  db.query("SELECT * FROM users WHERE id = ?", [userId])
  // Unsafe
  db.query("SELECT * FROM users WHERE id = " + userId)
  ```
- No command injection — never interpolate user input into shell commands
  ```python
  # Safe
  subprocess.run(["ls", user_path])
  # Unsafe
  subprocess.run(f"ls {user_path}", shell=True)
  ```
- XSS: always escape output in templates
