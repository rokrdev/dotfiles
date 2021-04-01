local remap = vim.api.nvim_set_keymap

require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = true;
  min_length = 1;
  preselect = 'disable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  allow_prefix_unmatch = false;

  source = {
    path = true;
    buffer = true;
    calc = true;
    vsnip = true;
    nvim_lsp = true;
    nvim_lua = true;
    spell = true;
    tags = true;
    -- snippets_nvim = true;
  };
}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    return t "<S-Tab>"
  end
end

_G.snippet_expand = function()
  if vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif vim.fn.call("vsnip#jumpable", {1}) == 1 then
    return t "<Plug>(vsnip-jump-next)"
  else
    return t "<C-j>"
  end
end

remap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
remap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
remap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
remap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
remap("i", "<C-j>", "v:lua.snippet_expand()", {expr = true})

