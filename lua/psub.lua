local function __gensubs(pats, reps, subs)
  if #pats == 0 then
    return subs
  end
  local pat = table.remove(pats, 1)
  local rep = table.remove(reps, 1)
  local newsubs = {}
  if pat:match("{[^}]+}") then
    pat = vim.fn.split(pat:sub(2, -2), ",")
    rep = rep and vim.fn.split(rep:sub(2, -2), ",") or {}
    for _ = 1, #pat do
      table.insert(rep, "")
    end
    for i = 1, #pat do
      for _, sub in ipairs(subs) do
        table.insert(newsubs, { sub[1] .. pat[i], sub[2] .. rep[i] })
      end
    end
  else
    for _, sub in ipairs(subs) do
      table.insert(newsubs, { sub[1] .. pat, sub[2] .. rep })
    end
  end
  return __gensubs(pats, reps, newsubs)
end

local function gensubs(pattern, replacement)
  local pats = vim.fn.split(pattern, "{[^}]+}\\zs")
  local reps = vim.fn.split(replacement, "{[^}]+}\\zs")
  return __gensubs(pats, reps, { { "", "" } })
end

local function __substitute(str, pattern, replacement, flags)
  local subs = gensubs(pattern, replacement)
  for i, sub in ipairs(subs) do
    local rep = "" .. string.rep("", i) .. ""
    str = vim.fn.substitute(str, sub[1], rep, flags)
  end
  for i, sub in ipairs(subs) do
    local rep = "" .. string.rep("", i) .. ""
    str = vim.fn.substitute(str, rep, sub[2], flags)
  end
  return str
end

local function find(str, c, start)
  local escaped = false
  for i = start, #str do
    local d = str:sub(i, i)
    if escaped then
      escaped = false
    elseif d == "\\" then
      escaped = true
    elseif d == c then
      return i
    end
  end
  return -1
end

local function argparse(arg)
  local sep = arg:sub(1, 1)
  local i = 2
  local j = find(arg, sep, i)
  local k = find(arg, sep, j + 1)
  local pat = arg:sub(i, j - 1)
  local rep = arg:sub(j + 1, k - 1)
  local flags = arg:sub(k + 1)
  return pat, rep, flags
end

return function(tbl)
  local arg = tbl.fargs[1]
  local pat, rep, flags = argparse(arg)
  local range = vim.fn.getline(tbl.line1, tbl.line2)
  local result = {}
  for _, line in ipairs(range) do
    table.insert(result, __substitute(line, pat, rep, flags))
  end
  vim.fn.setline(tbl.line1, result)
end
