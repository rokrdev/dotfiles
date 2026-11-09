# Flow Helix mode keybinding gaps

## Status

Written 2026-11-10 against the installed binary `v0.7.2-1974-gec13ccf7` (zig 0.17.1) and the clone at `/Users/bharat.joshi/projects/flow`, HEAD `1a2aa911`. HEAD is one commit ahead of the binary. That commit only refactors `src/tui/mode/helix.zig`. All file:line cites are for `1a2aa911`.

Flow's own `help.md` calls Helix mode "(work in progress)". Upstream's last cleanup is `d142bf22` ("fix bindings to commands that actually exist in flow with another name") and `83aa5cd5` ("correct commands names for next/previous split bindings"), both 2026-11-06. Tests for Helix mode are in `test/tests_helix.zig`.

The overlay `flow/.config/flow/keys/helix.json` inherits `<<builtin>>`. With it, no key in Helix mode should log `CommandNotFound`. The stale `~/.config/flow/keys/flow.json` noise is gone too, because the overlay's fallback is the builtin flow keymap, not the user file (`keybind.zig:440-443`). A static simulation of the merge finds no dead names left in the overlay's modes. It ignores sibling `inherit`.

The overlay hides the bugs below. It does not fix them. This doc is a snapshot, so re-check it after you rebase.

Tags: "run" means an earlier diagnosis pass saw it in an isolated pty session against the installed binary. "source" means read in the clone. "unverified" means neither.

## Bugs and traps in Flow

### 1. Pending prefix never times out

- Where: `src/keybind/keybind.zig:1285`.
- Symptom: press `g`, wait 3 s, press `j`. Flow reports "g j is unbound" and swallows the `j`. A stray `g`, `z`, `m`, `[`, `]` or `space` does the same. (run)
- Cause: the test is `last_key_event_timestamp_ms - timestamp > max_key_sequence_time_interval` (1500, declared at line 700). The operands are reversed, so the left side is never positive.
- Fix: swap the operands. Then fix the timeout branch. `terminate_sequence(.timeout)` (1340-1357) pushes the pending text into `insert_bytes`. That text goes to the mode's `insert_command` (default `insert_chars`, lines 88-91), and `on_match_failure` is ignored. After the swap, a timed-out `g` would probably type into the buffer in normal mode. Make the timeout branch drop the sequence for `ignore` and `nothing` modes. (source)

### 2. Dead command names in builtin helix.json

- 75 names bound in `src/keybind/builtin/helix.json` are not commands. A press shows `CommandNotFound` on the status line for 4 s (`src/tui/status/minilog.zig:24`) and does nothing else. (run)
- A normal-mode sweep fired 65 distinct names, all from the 75. The other 10 are bound in select, insert or other modes.
- Cause: `src/command.zig:272-275` raises the error at press time. Nothing checks names when the keymap loads.
- The full list is in the next section. A static check for it is described at the end.

### 3. `m d` and `m r` trap the prompt

- Where: `src/tui/mode/mini/match.zig:20-25`. Bindings: `helix.json:173-174` (normal) and `455-456` (select).
- Symptom: `m d` or `m r` opens a get-char prompt. After the dead command fails, the prompt stays and swallows every key until Escape. (run)
- Cause: `process_egc` runs `executeName(action)` with `try` before `exit_mini_mode`. The error returns early and the exit never runs.
- Fix: call `exit_mini_mode` first, or use `defer`. Do it even after `surround_delete` exists, because any failing action traps the prompt.

### 4. Select mode types text on an unbound key

- Where: `keybind.zig:866`. The select mode at `helix.json:275` has no `on_match_failure`.
- Symptom: with no setting and no `settings.inherit`, the mode defaults to `insert`. An unbound key such as `K` types `K` into the buffer. (run)
- Fix: add `"on_match_failure": "ignore"` to builtin select. Normal (line 7) and home (line 569) already set it. The overlay sets it for select at `keys/helix.json:159`.
- The struct default at `keybind.zig:825` is `.ignore`, but the loader falls back to `.insert` at 866. The two disagree. (source)

### 5. A multi-command binding stops at the first failure

- Where: `keybind.zig:1244` (`for (binding.commands) |*cmd| try cmd.execute();`) and `command.zig:272-275`.
- Symptom: `["alt+k", ["enter_mode","insert"], ["no_such_cmd"]]` enters insert mode, then shows `CommandNotFound`. Earlier commands already ran, with no rollback. (run)
- No builtin helix binding is like this today. The overlay has several (`X`, `[ D`, `] G`, `[ space`, `ctrl+w F`), so every name in them must exist.
- Fix direction: check names in a test or build step, not at load time. Editor commands exist only while an editor is focused (item 11), so a load-time check would reject valid names. (unverified)

### 6. `0` poisons the next count

- Where: `keybind.zig:40-47` (`add_integer_argument_digit`), bindings at `helix.json:247` (normal) and `525` (select), consumer at `src/tui/editor.zig:3129-3139`.
- Symptom: after `0`, the next counted motion runs as `move_down [0]` and does not move. Only that one motion is affected. (run)
- Cause: `0` sets `integer_argument` to 0, and 0 is not null. `Command.execute` (`keybind.zig:510-515`) passes it as the count. `with_cursors_const_repeat` loops `while (repeat > 0)`, so the body runs zero times.
- Fix: ignore digit 0 in `add_integer_argument_digit` when `integer_argument` is null. `10j` still works.

### 7. Bare `G` raises an error

- Where: `helix.json:136` binds `G` to `goto_line`. `src/tui/editor.zig:8031-8035` returns `error.InvalidGotoLineArgument` when there is no count. (run)
- Helix does nothing here. `goto_line_impl` in `helix-term/src/commands.rs:4075` only acts when `cx.count` is set. (source, your Helix fork)
- Fix: return `error.Stop` (never displayed) instead of the named error. Select-mode `G` is `select_to_line` (`helix.json:363`). It swallows the error with `catch {}` (`editor.zig:8048`), so it is silent. (source)

### 8. Two spellings of the same key

- Helix's `alt+I` and `alt+_` are not the same key to Flow as `alt+shift+i` (`add_cursors_to_line_ends`, `flow.json:280`) and `alt+shift+minus` (`adjust_fontweight`, `flow.json:151` and `962`).
- Symptom: unbinding one spelling leaves the other live. (run)
- Fix: normalize shifted keys in `src/keybind/parse_flow.zig` so both spellings give one key event. Which spelling a terminal sends is unverified. The overlay unbinds both.

### 9. Stale user flow.json and bare modifier presses

- Helix mode falls back to the `flow` namespace. If `~/.config/flow/keys/flow.json` is an old full copy, it can bind bare left/right control, alt and shift to commands that no longer exist: `enable_jump_mode`, `disable_jump_mode`, `enable_fast_scroll`, `disable_fast_scroll`, `enable_alt_scroll`, `disable_alt_scroll`, `move_scroll_left`, `move_scroll_right`. (run)
- Cause: `sync_mod_state` (`src/renderer/vaxis/renderer.zig:978-992`) synthesizes `left_*` press and release events on every modifier change. Every Shift, Ctrl or Alt chord logs `CommandNotFound`, then the real key runs.
- Builtin `flow.json` has three dead names of its own: `select_scroll_page_up` and `select_scroll_page_down` (`alt+page_up/down`, select mode, lines 392-393), and `select_all_siblings` (`alt+a`, normal mode, line 289). The third one was found by a static check and not run. The overlay covers all three.
- Fix: delete the user `flow.json`, or never copy it whole. In a fork, skip command dispatch for modifier-only events with no binding. (unverified)

### 10. How dispatch works

A fork needs these facts. (source, partly run)

- `tui.zig:1158` `dispatch_input` sends the event to the mode's input handler. The handler's `receive` (`keybind.zig:1215`) calls `process_key_event` (1254). That walks `press.items` in order, and the first `.matched` wins. `receive` then runs the binding's commands in order (1244).
- Fallback to the `flow` namespace is merged once at load time (`keybind.zig:403-407`, `419-424`, and `BindingSet.load` at `841-974`). It is never consulted at press time.
- A mode that the namespace does not define falls back to the fallback's `normal` (`load_mode`, line 462).
- `append_if_not_match` (1130) drops an inherited binding that equals, is a prefix of, or extends an own binding.
- `unbind` (1114-1128) claims the key during the merge, and `drop_unbound` (970, 1122) removes it afterward. The key ends with no binding and no fall-through.
- The status line shows an error for 4 s. A later info message cannot replace a visible error (`minilog.zig:183-184`).
- `error.Stop` is never displayed (`minilog.zig:150-153`). A command that stops on a boundary looks like nothing happened.

### 11. Editor commands exist only while an editor has focus

- `src/tui/editor.zig:9559-9572`: `focus` calls `commands.register()` and `unfocus` unregisters.
- On the home screen or another panel, valid editor commands give `CommandNotFound`. (source, not run)

### 12. Other traps hit during the port

- `flow --list-languages` segfaults (exit 139) when any file type has `formatter []`. `src/list_languages.zig:55` reads `formatter[0]` with no length check. The editor's `get_formatter` (`editor.zig:8976`) does check. (run)
- Flow rewrites `~/.config/flow/config` itself, so you cannot stow it. Put your values in a file and pull it in with `include_files`.
- A `file_type/<name>.conf` replaces the whole builtin entry. It does not merge.
- A user theme JSON with an unknown top-level key is an error.

## Dead command names in builtin helix.json

All 75, confirmed against the `_meta` list at `1a2aa911`. Rows apply to normal and select mode unless a mode is named. The `home` mode copies `goto_last_modification`, `goto_first_diag`, `goto_last_diag`, `workspace_symbol_picker`, `jumplist_picker`, `close_other_splits`, `swap_left_split`, `swap_right_split` and `goto_file_split`. "Overlay" is what `keys/helix.json` does today.

| Dead name | Key | Helix action | Overlay |
|---|---|---|---|
| `select_regex` | `s` | select regex matches in selection | unbound |
| `split_selection` | `S` | split selection on regex | unbound |
| `collapse_selections` | `;` | collapse selection to cursor | `cancel` |
| `flip_selections` | `alt+;` | swap cursor and anchor | `selections_reverse` |
| `remove_primary_selection` | `alt+,` | remove primary selection | `pop_cursor` |
| `rotate_selections_backward`, `rotate_selections_forward` | `(` `)` | rotate selections | unbound |
| `rotate_selection_contents_backward`, `rotate_selection_contents_forward` | `alt+(` `alt+)` | rotate selection contents | unbound |
| `merge_selections`, `merge_consecutive_selections` | `alt+-` `alt+_` | merge all / consecutive selections | unbound |
| `align_selections`, `trim_selections` | `&` `_` | align in columns / trim whitespace | unbound |
| `extend_to_line_bounds` | `X` | extend to line bounds | 6-command sequence |
| `shrink_to_line_bounds` | `alt+x` | shrink to line bounds | unbound |
| `select_all_siblings` | `alt+a` | select all siblings of node | unbound |
| `select_all_children` | `alt+I`, `alt+shift+down` | select all children | unbound |
| `move_parent_node_end`, `move_parent_node_start` | `alt+e` `alt+b` (normal) | move to parent node end / start | unbound |
| `extend_parent_node_end`, `extend_parent_node_start` | `alt+e` `alt+b` (select) | extend to parent node end / start | unbound |
| `extend_search_next` | `N` (select) | extend to previous match | `add_cursor_prev_match` |
| `extend_to_line_start`, `extend_to_line_end` | `home` `end` (select) | extend to line start / end | `select_begin`, `select_end` |
| `join_selections` | `J` | join lines | `join_next_line` |
| `join_selections_space` | `alt+J` | join lines, select the space | `join_next_line` |
| `format_selections` | `=` | format selections | `format` |
| `change_backward_helix` | `alt+c` (normal) | change selection, no yank | `enter_mode insert` + `delete_forward` |
| `increment`, `decrement` | `ctrl+a` `ctrl+x` | add / subtract 1 on number | unbound |
| `switch_to_uppercase` | `` alt+` `` (select) | uppercase selection | `to_upper` |
| `system_paste_after` | `space p` | paste clipboard after | `system_paste` |
| `select_register` | `"` | select register | unbound |
| `record_macro`, `replay_macro` | `q` `Q` | record / replay macro (Helix has `Q` record, `q` replay, so Flow is swapped) | unbound |
| `shell_pipe` | `\|` | pipe selections through a command | unbound |
| `shell_pipe_to` | `alt+\|` | pipe, discard output | unbound |
| `shell_insert_output` | `!` | insert command output before selection | unbound |
| `shell_append_output` | `alt+!` | append command output after selection | unbound |
| `shell_keep_pipe` | `$` | keep selections whose command succeeds | unbound |
| `surround_delete`, `surround_replace` | `m d` `m r` | delete / replace surrounding pair (args to `match`, see bug 3) | unbound |
| `repeat_last_motion` | `alt+.` | repeat last `t` `T` `f` `F` | unbound |
| `goto_window_top`, `goto_window_center`, `goto_window_bottom` | `g t` `g c` `g b` | cursor to window top / center / bottom | unbound |
| `goto_last_modification` | `g .` | go to last modification | unbound |
| `rfind` | `?` | search backward | `find` |
| `goto_first_diag`, `goto_last_diag` | `[ D` `] D` | first / last diagnostic | buffer begin / end, then next / prev diagnostic |
| `goto_first_change`, `goto_last_change` | `[ G` `] G` | first / last change | buffer begin / end, then next / prev change |
| `goto_prev_function`, `goto_next_function` | `[ f` `] f` | function | unbound |
| `goto_prev_class`, `goto_next_class` | `[ t` `] t` | class or type | unbound |
| `goto_prev_parameter`, `goto_next_parameter` | `[ a` `] a` | parameter | unbound |
| `goto_prev_comment`, `goto_next_comment` | `[ c` `] c` | comment | unbound |
| `goto_prev_entry`, `goto_next_entry` | `[ e` `] e` | entry | unbound |
| `goto_prev_test`, `goto_next_test` | `[ T` `] T` | test | unbound |
| `add_newline_above`, `add_newline_below` | `[ space` `] space` | add blank line above / below | `insert_line_before` / `insert_line_after`, then move |
| `close_other_splits` | `ctrl+w o` | close other windows | `close_splits` |
| `swap_left_split`, `swap_right_split` | `ctrl+w H` `ctrl+w L` | swap window left / right | `move_tab_previous_split`, `move_tab_next_split` |
| `goto_file_split` | `ctrl+w F` | open file under cursor in vsplit | `add_split` + `open_file` |
| `jumplist_picker` | `space j` | jumplist picker | unbound |
| `workspace_symbol_picker` | `space S` | workspace symbols | unbound |
| `select_references_to_symbol_under_cursor` | `space h` | select references to symbol | `references` |
| `file_picker_in_current_directory` | `space F` (select) | file picker in cwd | `find_file` |
| `run_ls` | `ctrl+o` (insert) | none in Helix | unbound |

## Insert mode clashes

Builtin helix insert mode falls back to Flow's `normal`, so Flow keys win where `helix.json` is silent. The overlay rebinds all but the last two rows. (from the earlier gap analysis, not re-run)

| Key | Helix | Builtin Flow action | Overlay |
|---|---|---|---|
| `ctrl+w` | delete word back | `close_file` | `delete_word_left` |
| `alt+backspace` | delete word back | none | `delete_word_left` |
| `alt+d`, `alt+delete` | delete word forward | `add_cursor_prev_match`, none | `delete_word_right` |
| `ctrl+u` | delete to line start | `move_scroll_page_up` | `delete_to_begin` |
| `ctrl+d` | delete next char | `move_scroll_page_down` | `delete_forward` |
| `ctrl+h` | delete previous char | none | `delete_backward` |
| `ctrl+b`, `ctrl+f` | char back / forward | `move_to_char`, `find` | `move_left`, `move_right` |
| `ctrl+e`, `ctrl+a` | line end / start | `find_file`, `select_all` | `move_end`, `smart_move_begin` |
| `ctrl+j` | newline | `toggle_panel` | `smart_insert_line` |
| `ctrl+x` | autocomplete | `cut` | `completion` |
| `ctrl+s` | commit undo checkpoint | `save_file` | left as is |
| `ctrl+r` | insert register | `open_recent_project` | left as is |

## Helix keys that need new Zig

Nothing in Flow can do these today. Where-to-implement hints are guesses. (unverified)

Commands live in a `command.Collection(struct {...})`. Helix-specific ones go in `src/tui/mode/helix.zig` (collection at line 27, `Target = void`). Selection and buffer work goes through `Editor` helpers in `src/tui/editor.zig`. `surround_add` already uses one of them, `with_cursels_mut_once_arg`.

| Keys | Helix action | Where |
|---|---|---|
| `alt+.` | repeat last `t` `T` `f` `F` | `helix.zig`, near `to_char_helix` (598): store the last char motion |
| `alt+:` | ensure selections forward | `editor.zig`, next to `selections_reverse` (6350): flip only when reversed |
| `g t` `g c` `g b` | cursor to window top / center / bottom | `editor.zig`, near `scroll_view_top` (3990): move the cursor, not the view |
| `g .` | last modification | `editor.zig`: record the edit position on buffer update |
| `z m` | align view middle | `editor.zig`, near `scroll_view_center` (3973) |
| `ctrl+a` `ctrl+x` | increment / decrement number | `editor.zig` cursel helpers |
| `q` `Q`, `"` | macros, named registers | new recording state in `keybind.zig` or `tui.zig`. Registers touch the yank path in `editor.zig`. Flow's builtin has `q` record and `Q` replay, the reverse of Helix |
| `s` `S` `K` `alt+K` | select / split / keep / remove by regex | `editor.zig`. Flow's find has a regex mode (`toggle_find_mode_regex`) and `add_cursor_all_matches` (5276) |
| `\|` `alt+\|` `!` `alt+!` `$` | shell pipe family | `filter` (`editor.zig:9006`) and `shell_execute_insert` (`mainview.zig:2930`) take a fixed argv. Add a prompt mode like the `match` mini mode |
| `(` `)` | rotate selections | `editor.zig` |
| `alt+(` `alt+)` | rotate selection contents | `editor.zig` |
| `alt+-` `alt+_` | merge selections | `editor.zig` |
| `&` `_` | align / trim selections | `editor.zig` |
| `alt+x` | shrink to line bounds | `editor.zig`, near `select_line_at_cursor` (6328) |
| `alt+a` `alt+I` | select all siblings / children | `editor.zig`, near `select_next_sibling` (6494), using `node_at_selection` (6357) |
| `alt+e` `alt+b` | move to parent node end / start | `editor.zig`, near `expand_selection` (6420) |
| `m d` `m r` | surround delete / replace | `helix.zig`: copy `surround_add` (434, impl 922) |
| `[` `]` with `f` `t` `a` `c` `e` `T` `x` | tree-sitter textobject motions | Flow ships no textobject queries. They live in the `flow-syntax` package. Existing `select_textobject_*` is text-based (`helix.zig:648`) |
| `space C` | toggle block comment | `editor.zig`, near `toggle_comment` (5602). That one is line-based |
| `space j` | jumplist picker | picker over `jump_back` / `jump_forward` state |
| `space S` | workspace symbols | `src/LSPClient.zig` has `textDocument/documentSymbol` (1534) and no `workspace/symbol` |
| `space G` | DAP menu | Flow has no DAP |
| `g I` `g O` | call hierarchy (your Helix fork) | no Flow command, no LSP request |
| `alt+u` `alt+U` | undo tree earlier / later | builtin binds `undo` / `redo` |
| `ctrl+w s` `j` `k` `J` `K` `t` `f` | stacked splits and the window commands that need them | Flow splits sit side by side only (`create_home_split`, `mainview.zig`). Needs new layout code |
| `ctrl+w F` | open file under cursor in vsplit | new command that reads the path at the cursor |
| reload config | reload config command | Flow reloads config by itself when the file changes |

## Approximate rebinds in the overlay

These keys run but differ from Helix. A fork should make them exact.

| Key | Overlay | Gap |
|---|---|---|
| `alt+J` | `join_next_line` | does not select the space |
| `alt+,` | `pop_cursor` | removes the last-added cursor, not the primary |
| `?`, `z ?` | `find` | forward only. Needs `rfind` |
| `alt+*` | `find_word_at_cursor` | searches the word, not the selection |
| `X` | `select_up`, `select_begin`, `selections_reverse`, `select_end`, `select_right`, `selections_reverse` | exact on the first press. A second `X` over-extends one line (run) |
| `[ D` `] D` | `move_buffer_begin` / `move_buffer_end`, then `goto_next_diagnostic` / `goto_prev_diagnostic` | approximate |
| `[ G` `] G` | same pattern with `goto_next_change` / `goto_prev_change` | approximate |
| `[ space` `] space` | `insert_line_before` / `insert_line_after`, then `move_down` / `move_up` | cursor column resets to 0 |
| `ctrl+w w` | `focus_next_split` | no wrap |
| `ctrl+w H` `ctrl+w L` | `move_tab_previous_split` / `move_tab_next_split` | moves the tab, does not swap |
| `ctrl+w F` | `add_split`, then `open_file` | opens the `open_file` prompt, not the path under the cursor |
| `ctrl+w o` | `close_splits` | keeps split 0, not the active one |
| `ctrl+w n s` | `add_split`, then `create_scratch_buffer` | also splits vertically, same as `n v` |
| `space Y`, `space p`, `space h`, `space B` | `copy`, `system_paste`, `references`, `toggle_inline_vcs_blame` | not semantically tested. `space h` lists references instead of selecting them. `space B` toggles inline blame globally |
| `alt+c` (normal) | `enter_mode insert`, then `delete_forward` | deletes without yanking. Not semantically tested |
| `N` (select) | `add_cursor_prev_match` | adds a cursor instead of extending. Not semantically tested |
| `alt+page_up` `alt+page_down` (select) | `select_page_up` / `select_page_down` | replaces Flow's dead `select_scroll_page_*`. Not semantically tested |
| `=` | `format` | formats the whole buffer, not the selection |
| `;` | `cancel` | also drops extra cursors |
| `tab` | `jump_forward` | builtin binds `indent` through the flow fallback (`flow.json:333`) |

Builtin approximations the overlay leaves alone: `alt+u` / `alt+U` run `undo` / `redo` (`helix.json:64`, `69`). `ctrl+z` runs `undo` through the flow fallback, where Helix suspends. Builtin select mode has no `ctrl+w`, `space e` or `space g` bindings. The overlay copies the normal ones.

The sticky `Z` view mode works as a custom `view` mode entered with `enter_mode` (run). It costs 42 `unbind` lines, because a mode that the builtin does not define falls back to the builtin `normal` (`keybind.zig:462`) and inherits all of it, dead names included. It exists in normal mode only, not select. Each new builtin normal binding leaks into `view` until you unbind it there. A fork could fall back to an empty set for undefined modes. (unverified)

## Keys the overlay unbinds

Re-bind each one when the matching command exists. Normal and select mode carry the same 49 `unbind` lines:

```
ctrl+a ctrl+x                          increment, decrement
alt+.                                  repeat last motion
alt+- alt+_ alt+shift+minus            merge selections (alt+shift+minus is Flow's adjust_fontweight spelling)
alt+e alt+b                            parent node motions
alt+a alt+x                            select all siblings, shrink to line bounds
alt+I alt+shift+i alt+shift+down       select all children (alt+shift+i is add_cursors_to_line_ends, alt+shift+down is add_cursor_down)
alt+( alt+) alt+| alt+!                rotate contents, pipe-to, append output
S s & _ ( ) " | ! $                    regex split/select, align, trim, rotate, register, shell
g t  g c  g b  g .                     window top/center/bottom, last modification
m d  m r                               surround delete, replace
[ T [ f [ t [ a [ c [ e                textobject motions backward
] T ] f ] t ] a ] c ] e                textobject motions forward
q Q                                    macros
space S  space j                       workspace symbols, jumplist picker
```

Other modes:

- `home`: `g .`, `[ D`, `] D`, `space S`, `space j` (5 lines). Builtin `home` copies these dead bindings.
- `insert`: `ctrl+o` (dead `run_ls`) and `alt+a`.
- `overlay/dropdown`, `overlay/dropdown-noninvasive`, `mini/replace`: `alt+a`. Flow's builtin has no `mini/replace`, and the dropdowns inherit `normal`, so they pick up the dead `select_all_siblings`. (source)
- `view`: 42 lines. See above.

### Fork checklist

1. Add the command in the right collection: `pub fn <name>(...)` plus a required `pub const <name>_meta: Meta = .{ .description = ..., .arguments = ... }`. A missing `_meta` is a compile error. Helix commands go in `src/tui/mode/helix.zig`, editor ones in `src/tui/editor.zig` (collection at 9513).
2. Remove the matching `unbind` lines from `keys/helix.json` in every mode listed above, then add the binding. Or add it to `src/keybind/builtin/helix.json` in the fork and delete the overlay line. Builtin keymaps are `flow.json`, `vim.json`, `helix.json` and `emacs.json` in `src/keybind/builtin/`, embedded with `@embedFile` (`keybind.zig:22-25`).
3. Replace each approximate rebind with the exact command and update the table above.
4. Add a test. `test/tests_helix.zig` calls `helix.test_internal` (`helix.zig:1338`) on a string buffer. Only word motions are covered today. Keymap parsing tests are inline in `keybind.zig` from about line 1680.
5. Run the static check below. The exact command list is `grep -rhoE 'pub const [a-z_0-9]+_meta' src`.

## Flow limits that are not keybinding bugs

- No named registers, no macros.
- No vertically stacked splits.
- No soft wrap.
- No inlay-hint rendering.
- No rainbow brackets.
- One language server per file type.
- Grammars and queries are compiled into the binary.
- Format on save is global.

## How to test a keymap change without touching your real config

Run the installed or fork-built `flow` in a pty with an isolated environment. Point `FLOW_CONFIG_DIR`, `XDG_STATE_HOME` and `XDG_CACHE_HOME` at a scratch dir. Pass `-X -N --log-stdout --server disable`. Put the keys file at `<scratch>/keys/helix.json` and write `input_mode "helix"` into `<scratch>/config`. Send keys, then grep the log for `CommandNotFound`.

`--server disable` avoids `ThespianUnxAcceptorListenFailed` noise. The noise comes from a unix socket path longer than macOS's 104-byte limit when the scratch path is long. Keep the scratch path short.

For a static check, collect every command name that the merged keymap uses, builtin plus overlay, and diff it against the `_meta` list. Read the second token of `match` and `move_to_char` bindings too, because it is a command name. Applying the merge rules (own entries first, inherited entries dropped by `append_if_not_match`, `unbind` removed last) keeps shadowed builtin bindings out of the diff. A raw diff of builtin `helix.json` alone gives the 75 names above. Raw builtin `flow.json` gives the 3 names in item 9.
