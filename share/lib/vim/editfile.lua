--vim.cmd.cnoreabbrev([[<expr> e (getcmdtype() == ':' && getcmdline() =~ '^e$') ? 'EditFile' : 'e']])
local function complete(lead, _, _)
  local base = vim.fs.basename(lead) or ''
  local dir = vim.fs.dirname(lead) or ''
  local relative = (dir == '' or dir == '.')
  local out = {}
  for name, ftype in vim.fs.dir(relative and '.' or dir) do
    if name:sub(1, #base) == base
        and not (base:sub(1, 1) ~= '.' and name:sub(1, 1) == '.') then
      local cand = (relative and '' or dir .. '/') .. name
      if ftype == 'directory' then
        cand = cand .. '/'
      end
      out[#out + 1] = cand
    end
  end
  table.sort(out)
  return out
end
vim.api.nvim_create_user_command('E', function(opts)
  local args
  if opts.args ~= '' then
    args = { opts.args }
  end
  vim.api.nvim_cmd({ cmd = 'edit', bang = opts.bang, args = args }, {})
end, {
  nargs = '?',
  bang = true,
  complete = complete,
  desc = ':edit with literal file completion',
})
