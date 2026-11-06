local TERMINAL = "com.superlogical.terminal"

-- Decode only file:// URLs from OSC 7, since plain paths may contain a literal %.
local function pane_cwd(ctx)
  local r = rex.block.call(TERMINAL, "pwd", { block_id = ctx.block_id })
  local p = r and r.pwd
  if p == nil or p == "" then
    return nil
  end
  local path = p:match("^file://[^/]*(.*)$")
  if path == nil then
    return p
  end
  if path == "" then
    return nil
  end
  return (path:gsub("%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end))
end

-- Default exit behavior closes the pane when the command ends.
local function popup(ctx, command)
  local _, err = rex.session.new_layer({
    bounds = { 0.025, 0.025, 0.95, 0.95 },
    focus = true,
    layout = rex.layout.block({
      flavor = TERMINAL .. ".shell",
      options = { command = command, cwd = pane_cwd(ctx) },
    }),
  })
  if err ~= nil then
    error(err, 0)
  end
end

rex.action({
  name = "popup_gitui",
  title = "Popup: gitui",
  run = function(ctx)
    popup(ctx, { "gitui" })
  end,
})

rex.action({
  name = "popup_vault",
  title = "Popup: vault",
  run = function(ctx)
    popup(ctx, { "fish", "-c", "cd ~/Documents/rokr_vault; and hx index.md" })
  end,
})

rex.action({
  name = "popup_shell",
  title = "Popup: shell",
  run = function(ctx)
    popup(ctx, { "fish" })
  end,
})

-- Capture the origin block by id, since the popup is the focused one.
rex.action({
  name = "popup_scrollback",
  title = "Popup: scrollback",
  run = function(ctx)
    popup(ctx, { "fish", "-c", "rex capture -b $argv[1] --trim | hx -", ctx.block_id })
  end,
})

rex.bind("cmd+s>s", "session.switch")
rex.bind("cmd+s>n", "session.new")
rex.bind("cmd+s>x", "session.close")
rex.bind("cmd+s>r", "session.rename")

rex.bind("cmd+o>g", "popup_gitui")
rex.bind("cmd+o>v", "popup_vault")
rex.bind("cmd+o>f", "popup_shell")
rex.bind("cmd+o>l", "popup_scrollback")
rex.bind("cmd+o>r", "client.config.reload")

rex.bind("cmd+z", "pane.zoom")
rex.bind("cmd+l", "pane.go_to")

-- Exclusive so stray keys never reach the terminal mid-resize.
rex.mode("resize", { exclusive = true })
rex.bind("cmd+r", "client.mode.enter", { name = "resize" })

for _, m in ipairs({ { "h", "left" }, { "j", "down" }, { "k", "up" }, { "l", "right" } }) do
  rex.bind("resize/" .. m[1], "pane.resize", { direction = m[2] })
  rex.bind("resize/" .. m[2], "pane.resize", { direction = m[2] })
end
