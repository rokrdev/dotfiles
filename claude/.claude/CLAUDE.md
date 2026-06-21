# Agent Instructions
These are common instructions for all agents across all scenarios.
@RTK.md

## General Guidelines
• Never use the em dash "-". Use plain dash "-" instead
• When writing commit messages, NEVER auto-add your agent name as co-author
• Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
• When writing or substantially editing long Markdown files, put each full sentence on its own line. Preserve normal Markdown structure, but avoid wrapping multiple sentences onto one physical line.
• When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
• When doing bug fixes, always start with reproducing the bug in an EZE setting as closely aligned with how an end user experiences the bug. This makes sure you find the real problem so your fix will actually solve it.
• When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection. If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along
• Apply that same standard of engineering excellence: lint, test failures and test flakiness. If you see one, even if it is not cause by what you are working on right now, still get it fixed.
• Save project memory in MEMORY.md in the same project.
