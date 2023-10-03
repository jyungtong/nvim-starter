local M = {}
local s = {}
local uv = vim.loop or vim.uv

M.window = nil
s.empty = true

function M.setup()
  local command = vim.api.nvim_create_user_command

  command('BufferNav', s.buffer_nav, {nargs = 1})
  command('BufferNavMenu', M.show_menu, {})
  command('BufferNavMark', s.add_file, {bang = true})
  command('BufferNavRead', s.read_content, {nargs = 1, complete = 'file'})
  command('BufferNavSave', s.save_content, {nargs = '?', complete = 'file'})
  command('BufferNavClose', s.close_window, {})
end

function M.show_menu()
  if M.window == nil then
    M.window = s.create_window()
  end

  M.window.mount()
end

function s.add_file(input)
  local name = vim.fn.bufname('%')
  local should_mount = M.window == nil

  if should_mount then
    M.window = s.create_window()
  end

  local start_row = vim.api.nvim_buf_line_count(M.window.bufnr)
  local end_row = start_row

  if s.empty then
    s.empty = false
    start_row = 0
    end_row = 1
  end

  vim.api.nvim_buf_set_lines(
    M.window.bufnr,
    start_row,
    end_row,
    false,
    {vim.fn.fnamemodify(name, ':.')}
  )

  if input.bang == false then
    return
  end

  if should_mount then
    M.window.mount()
  end
end

function M.go_to_file(index)
  if M.window == nil then
    return
  end

  local count = vim.api.nvim_buf_line_count(M.window.bufnr)

  if index > count then
    return
  end

  local path = vim.api.nvim_buf_get_lines(
    M.window.bufnr,
    index - 1,
    index,
    false
  )[1]

  if path == nil then
    return
  end

  if vim.fn.bufloaded(path) == 1 then
    vim.cmd.buffer(path)
    return
  end

  if uv.fs_stat(path) then
    vim.cmd.edit(path)
  end
end

function M.load_content(path)
  if M.window then
    M.window.unmount()
    s.filepath = nil
  end

  local window = s.create_window()
  vim.api.nvim_buf_call(window.bufnr, function()
    vim.cmd.read(path)
    vim.api.nvim_buf_set_lines(window.bufnr, 0, 1, false, {})
    vim.api.nvim_buf_set_name(window.bufnr, path)
    s.filepath = path
    s.empty = false
  end)

  M.window = window
end

function s.create_window()
  local buf_id = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf_id, 'filetype', 'BufferNav')
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, {''})

  local close = s.close_window
  local opts = {noremap = true, buffer = buf_id}

  vim.keymap.set('n', '<esc>', close, opts)
  vim.keymap.set('n', 'q', close, opts)
  vim.keymap.set('n', '<C-c>', close, opts)

  vim.keymap.set('n', '<cr>', function()
    local index = vim.fn.line('.')
    close()
    M.go_to_file(index)
  end, opts)

  local autocmd = vim.api.nvim_create_autocmd

  autocmd('BufLeave', {buffer = buf_id, once = true, callback = close})
  autocmd('WinLeave', {buffer = buf_id, callback = close})

  autocmd('VimResized', {buffer = buf_id , callback = close})

  local mount = function()
    local cursorline = vim.o.cursorline
    local id = s.open_float(buf_id)

    M.window.winid = id
    vim.api.nvim_buf_call(M.window.bufnr, function()
      vim.api.nvim_win_set_option(id, 'number', true)
      vim.api.nvim_win_set_option(id, 'cursorline', cursorline)
    end)
  end

  local unmount = function()
    close()
    if vim.api.nvim_buf_is_valid(buf_id) then
      vim.api.nvim_buf_delete(buf_id, {force = true})
    end
  end

  return {
    bufnr = buf_id,
    mount = mount,
    hide = close,
    unmount = unmount,
  }
end

function s.open_float(bufnr)
  local config = {
    title = '[Buffers]',
    title_pos = 'center',
    anchor = 'NW',
    border = 'rounded',
    focusable = true,
    relative = 'editor',
    style = 'minimal',
    zindex = 99,
  }

  local width = vim.api.nvim_get_option('columns')
  local height = vim.api.nvim_get_option('lines')

  config.height = math.ceil(height * 0.35)
  config.width = math.ceil(width * 0.5)

  config.row = math.ceil((height - config.height) / 6)
  config.col = math.ceil((width - config.width) / 2)

  return vim.api.nvim_open_win(bufnr, true, config)
end

function s.close_window()
  local id = M.window.winid
  if id and vim.api.nvim_win_is_valid(id) then
    vim.api.nvim_win_close(id, true)
    M.window.winid = nil
  end
end

function s.buffer_nav(input)
  local index = tonumber(input.args)
  if index == nil then
    return
  end

  M.go_to_file(index)
end

function s.read_content(input)
  local path = input.args
  if path == nil then
    return
  end

  M.load_content(path)
end

function s.save_content(input)
  if vim.bo.filetype ~= 'BufferNav' then
    return
  end

  local path = input.args

  if path == '' then
    path = s.filepath
  end

  if path == nil then
    vim.notify('Must provide a filepath', vim.log.levels.WARN)
    return
  end

  s.filepath = path
  vim.cmd.write({args = {path}, bang = true})
end

return M

