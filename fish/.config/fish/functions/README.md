# fish-helix (vendored)

Helix-like modal keybindings for fish, vendored from
[sshilovsky/fish-helix](https://github.com/sshilovsky/fish-helix).

Vendored files (upstream `functions/`):

- `fish_helix_command.fish`
- `fish_helix_key_bindings.fish`
- `fish_bind_count.fish`
- `fish_default_mode_prompt.fish`

Sync status, checked against upstream `main` on 2026-10-01:

- `fish_helix_command.fish`, `fish_bind_count.fish`, `fish_default_mode_prompt.fish`
  are byte-identical to upstream.
- `fish_helix_key_bindings.fish` carries two local patches:
  1. an eval wrapper `__fish_helix_shared_bindings` around
     `__fish_shared_key_bindings` (a bare call only prints its body; it must
     be eval'd, the same way upstream fish does it)
  2. `ctrl-f` bound to `forward-char` in insert mode

To re-sync: pull upstream `functions/`, diff, and re-apply the two local
patches above.
