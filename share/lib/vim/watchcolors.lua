local uv = vim.loop

local handle = uv.new_fs_event()

local event_cb = function(err, filename, _events)
  if err then
    error(err)
    uv.fs_event_stop(handle)
  elseif filename == 'vimcolor' then
    vim.schedule(function()
      vim.cmd(':ColorScheme')
    end)
  end
end

uv.fs_event_start(handle, vim.env.HOME .. '/.local/etc', {}, event_cb)
