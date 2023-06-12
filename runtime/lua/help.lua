local M = {}

function M.map_help_tags(arg)
  -- Specific tags that either have a specific replacement or won't go through the generic rules.
  local help_mappings = {
    ["*"]         = "star",
    ["g*"]        = "gstar",
    ["[*"]        = "[star",
    ["]*"]        = "]star",
    [":*"]        = ":star",
    ["/*"]        = "/star",
    ["/\\*"]      = "/\\\\star",
    ["\"*"]       = "quotestar",
    ["**"]        = "starstar",
    ["cpo-*"]     = "cpo-star",
    ["/\\(\\)"]   = "/\\\\(\\\\)",
    ["/\\%(\\)"]  = "/\\\\%(\\\\)",
    ["?"]         = "?",
    ["??"]        = "??",
    [":?"]        = ":?",
    ["?<CR>"]     = "?<CR>",
    ["g?"]        = "g?",
    ["g?g?"]      = "g?g?",
    ["g??"]       = "g??",
    ["-?"]        = "-?",
    ["q?"]        = "q?",
    ["v_g?"]      = "v_g?",
    ["/\\?"]      = "/\\\\?",
    ["/\\z(\\)"]  = "/\\\\z(\\\\)",
    ["\\="]       = "\\\\=",
    [":s\\="]     = ":s\\\\=",
    ["[count]"]   = "\\[count]",
    ["[quotex]"]  = "\\[quotex]",
    ["[range]"]   = "\\[range]",
    [":[range]"]  = ":\\[range]",
    ["[pattern]"] = "\\[pattern]",
    ["\\|"]       = "\\\\bar",
    ["\\%$"]      = "/\\\\%\\$",
    ["s/\\~"]     = "s/\\\\\\~",
    ["s/\\U"]     = "s/\\\\U",
    ["s/\\L"]     = "s/\\\\L",
    ["s/\\1"]     = "s/\\\\1",
    ["s/\\2"]     = "s/\\\\2",
    ["s/\\3"]     = "s/\\\\3",
    ["s/\\9"]     = "s/\\\\9",
  }

  local expr_tbl = { "!=?", "!~?", "<=?", "<?", "==?", "=~?", ">=?", ">?", "is?", "isnot?" }
  local ret

  if vim.startswith(arg, 'expr-') then
    -- When the string starts with "expr-" and contains '?' and matches the table, it is taken
    -- literally (but ~ is escaped). Otherwise '?' is recognized as a wildcard.
    ret = expr_tbl[arg:sub(6)]

    if ret ~= nil then
      ret:gsub('~', '\\~')
    end
  else
    -- Recognize a few exceptions to the rule.  Some strings that contain '*'are changed to "star",
    -- otherwise '*' is recognized as a wildcard.
    ret = help_mappings[arg]
  end

  -- If match is found in table, return.
  if ret ~= nil then return ret end

  -- Replace "\S" with "/\\S", etc. Otherwise every tag is matched.
  -- Make the same replacement for "\%^", "\%(", "\zs", "\z1", "\@<", "\@=", "\@<=", "\_$", "\_^".
  if arg[1] == '\\' and ((arg[2] ~= nil and arg[3] == nil)
                         or (([[%_z@]]):match(arg[2]) and arg[3] ~= nil))
  then
    ret = [[/\\]] .. arg:sub(2)
    -- Check for "/\\_$", should be "/\\_\$"
    if ret[4] == '_' and ret[5] == '%' then
      ret = ret:sub(1,4) .. [[\$]]
    end
  -- Replace:
  -- "[:...:]" with "\[:...:]"
  -- "[++...]" with "\[++...]"
  -- "\{" with "\\{"               -- matching "} \}"
  else
    local repl_patterns = {
      [ [[^\(.)$]] ] = [[/\\%1]],
      [ [[^\([%%_z@].)]] ] = [[/\\%1]],
      [ [[^%[:]] ] = [[\[:]],
      [ [[^%[++]] ] = [[\[++]],
      [ [[^\{]] ] = [[\\{]],
      [ [[^(']] ] = [[']],
      ['|'] = 'bar',
      ['"'] = 'quote',
      ['*'] = '.*',
      ['?'] = '.',
      ['$'] = '\\$',
      ['.'] = '\\.',
      ['~'] = '\\~',
    }
  end
end
