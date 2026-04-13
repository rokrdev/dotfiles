# Maintenance Notes

- **After `ctx upgrade`**: context-mode hook paths in `settings.json` are version-pinned by the plugin. Verify hook commands still resolve after upgrades — run `ctx doctor` if hooks stop firing.
