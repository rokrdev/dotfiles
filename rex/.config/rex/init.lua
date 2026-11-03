-- Herdr-style bindings: ctrl+b prefix, same keys after it.
local PREFIX = "ctrl+b"
local TERMINAL = "com.superlogical.terminal"

local function bind(k, action, args)
  rex.bind(PREFIX .. ">" .. k, action, args)
end

-- session.list is creation order, which the sidebar shows by default.
rex.action{
  name = "workspace_goto",
  title = "Go to Workspace by Number",
  args = { index = "integer" },
  run = function(ctx, args)
    local r, err = rex.call("session.list")
    if err ~= nil then error(err, 0) end
    local s = r.sessions[args.index]
    if s == nil then return end
    rex.client.queue("session.select", { session_id = s.session_id })
  end,
}

-- Decode only file:// URLs from OSC 7, since plain paths may contain a literal %.
local function pane_cwd(ctx)
  local r = rex.block.call(TERMINAL, "pwd", { block_id = ctx.block_id })
  local p = r and r.pwd
  if p == nil or p == "" then return nil end
  local path = p:match("^file://[^/]*(.*)$")
  if path == nil then return p end
  if path == "" then return nil end
  return (path:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

-- Default exit behavior closes the pane when the command ends.
local function popup(ctx, command)
  local _, err = rex.session.new_layer{
    bounds = { 0.025, 0.025, 0.95, 0.95 },
    focus = true,
    layout = rex.layout.block{
      flavor = TERMINAL .. ".shell",
      options = { command = command, cwd = pane_cwd(ctx) },
    },
  }
  if err ~= nil then error(err, 0) end
end

rex.action{
  name = "popup_gitui",
  title = "Popup: gitui",
  run = function(ctx) popup(ctx, { "gitui" }) end,
}

rex.action{
  name = "popup_vault",
  title = "Popup: vault",
  run = function(ctx) popup(ctx, { "fish", "-c", "cd ~/Documents/rokr_vault; and hx index.md" }) end,
}

rex.action{
  name = "popup_shell",
  title = "Popup: shell",
  run = function(ctx) popup(ctx, { "fish" }) end,
}

bind("shift+g", "popup_gitui")
bind("ctrl+d", "popup_vault")
bind("f", "popup_shell")

bind("c", "client.tab.new")
bind("n", "client.tab.next")
bind("p", "client.tab.previous")
bind("shift+t", "client.tab.rename")
bind("shift+x", "client.tab.close")

-- Herdr workspaces map to Rex sessions
bind("shift+n", "session.new")
bind("w", "session.switch")
bind("shift+w", "session.rename")
bind("shift+d", "session.close")

for i = 1, 9 do
  bind(tostring(i), "client.tab.goto", { index = i })
  bind("ctrl+" .. i, "workspace_goto", { index = i })
end

bind("v", "pane.split", { direction = "right" })
bind("-", "pane.split", { direction = "down" })
bind("x", "pane.close")
bind("z", "pane.zoom")
bind("tab", "pane.focus_next")

for _, m in ipairs{ { "h", "left" }, { "j", "down" }, { "k", "up" }, { "l", "right" } } do
  bind(m[1], "pane.focus", { direction = m[2] })
end

-- Exclusive so stray keys never reach the terminal mid-resize.
rex.mode("resize", { exclusive = true })
bind("r", "client.mode.enter", { name = "resize" })

for _, m in ipairs{ { "h", "left" }, { "j", "down" }, { "k", "up" }, { "l", "right" } } do
  rex.bind("resize/" .. m[1], "pane.resize", { direction = m[2] })
  rex.bind("resize/" .. m[2], "pane.resize", { direction = m[2] })
end

bind("b", "client.sidebar.toggle")
bind("s", "client.settings")
bind("shift+r", "client.config.reload")
bind("g", "client.palette.toggle")
bind("ctrl+f", "pane.go_to_directory")

-- Lets programs such as Helix receive a literal ctrl+b.
bind(PREFIX, "pane.send_key", { key = PREFIX })
