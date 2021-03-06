local lib          = require "resty.libxl.library"
local sheet        = require "resty.libxl.sheet"
local setmetatable = setmetatable
local rawget       = rawget
local rawset       = rawset
local type         = type

local sheets = {}

function sheets.new(opts)
    return setmetatable(opts, sheets)
end

function sheets:add(name, init)
    if lib.xlBookAddSheetA(self.book.context, name, init and init.context or init) == nil then
        return nil, self.book.error
    else
        return self[self.size]
    end
end

function sheets:insert(index, name, init)
    if lib.xlBookInsertSheetA(self.book.context, index, name, init and init.context or init) == nil then
        return nil, self.book.error
    else
        return self[index-1]
    end
end

function sheets:del(index)
    if lib.xlBookDelSheetA(self.book.context, index - 1) == 0 then
        return false, self.book.error
    else
        return true
    end
end

function sheets:type(index)
    return lib.xlBookSheetTypeA(self.book.context, index - 1)
end

function sheets:__len()
    return lib.xlBookSheetCountA(self.book.context)
end

function sheets:__index(n)
    if n == "active" then
        return lib.xlBookActiveSheetA(self.book.context) + 1
    elseif n == "size" or n == "count" or n == "n" then
        return lib.xlBookSheetCountA(self.book.context)
    elseif type(n) == "number" then
        return sheet.new{ index = n, context = lib.xlBookGetSheetA(self.book.context, n - 1), type = lib.xlBookSheetTypeA(self.book.context, n - 1), book = self.book }
    else
        return rawget(sheets, n)
    end
end

function sheets:__newindex(n, v)
    if n == "active" then
        lib.xlBookSetActiveSheetA(self.book.context, v - 1)
    else
        rawset(self, n, v)
    end
end

return sheets