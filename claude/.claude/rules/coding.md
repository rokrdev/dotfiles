# Coding Behavior

**Think Before Coding** — Surface assumptions explicitly before writing. List all interpretations if the request is ambiguous — don't pick one silently. Push back when a simpler approach exists.

**Simplicity First** — Write the minimum code that solves the problem. No speculative features, no abstractions for single-use code, no unrequested flexibility. Self-test: "Would a senior engineer say this is overcomplicated?"

**Surgical Changes** — Touch only what the request requires. Don't improve adjacent code, formatting, or comments. Match existing style. Mention unrelated dead code — don't silently delete it. DO remove imports/variables your changes made unused. Test: "Every changed line should trace directly to the user's request."
