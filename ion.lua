local ion = {}

local file,blacklist,prefix = nil,{},""
local function crawl(table,fp)
      for i,v in pairs(table) do
            local blacklisted = false
            if next(blacklist) ~= nil then
                  for j, w in pairs(blacklist) do
                        if w == i then
                              blacklisted = true
                              break
                        end
                  end
            end
            if blacklisted ~= true then
                  local index = i
                  if type(index) == "string" then
                        index = "|"..index:gsub("\\","\\\\"):gsub("\n","\\n"):gsub("\t","\\t")
                  elseif type(index) == "boolean" then
                        index = (i == true and "t") or (i == false and "f")
                  end
                  file:write(prefix,"\t",index,":")
                  local value = v
                  if type(value) == "table" then
                        value = "{"
                        prefix = prefix.."\t"
                  else
                        if type(value) == "string" then
                              value = "|"..value:gsub("\\","\\\\"):gsub("\n","\\n"):gsub("\t","\\t")
                        else
                              value = (value == true and "t") or (value == false and "f") or v
                        end
                  end
                  file:write(value,"\n")
                  if type(v) == "table" then
                        crawl(v)
                  end
            end
      end
      file:write(prefix,"}")
      if fp == nil then
            file:write("\n")
      end
      prefix = prefix:sub(1,-2)
end

function ion.Create(entries,name,bl)
      prefix = ""
      if bl ~= nil then
            blacklist = bl
      else
            blacklist = {}
      end
      if name == nil then
            name = "ion"
      end
      name = name..".ion"
      file = io.open(name,"w"); file:write("|ion:{\n"); file:close(); file = io.open(name,"a")
      crawl(entries,true)
      file:close()
end

function ion.Read(read)
      local readIon = assert(io.open(read,"r"))
      if readIon == nil then
            print("File does not exist: "..read)
            return
      end
      io.input(readIon)
      local levels = { {
            "",
            {}
      } }
      local lineNumber = 0
      while true do
            local k = readIon:read("l")
            lineNumber = lineNumber + 1
            if k == nil then
                  print("Malformed or empty ion")
                  return {}
            end
            local k,count = k:gsub("\t", "")
            if count == 0 and k ~= "|ion:{" and k ~= "}" then
                  print("Malformed ion at line "..lineNumber..": "..k)
                  return {}
            end
            if k == "}" then
                  if count == 0 then
                        io.close(readIon)
                        return levels[1][2]
                  else
                        levels[#levels - 1][2][levels[#levels][1]] = levels[#levels][2]
                        table.remove(levels, #levels)
                  end
            end
            local valueIsString, keyIsString
            local originalLine = k
            key,firstPass = k:gsub(":|.+", "")
            if firstPass == 0 then
                  key,_ = key:gsub(":[^:]+$","")
            end
            k,_ = k:gsub(key..":", "")
            print(key,k)
            if k ~= "}" then
                  k, valueIsString = k:gsub("^|", "")
                  key, keyIsString = key:gsub("^|", "")
                  local val, finalKey
                  if keyIsString == 0 then
                        if tonumber(key) ~= nil then
                              finalKey = tonumber(key)
                        else
                              if key == "t" or key == "f" then
                                    finalKey = ((key == "t") and true) or false
                              else
                                    print("Malformed ion at line "..lineNumber..": "..originalLine)
                                    return {}
                              end
                        end
                  else
                        finalKey,_ = key:gsub("\n","\n"):gsub("\\t","\t"):gsub([[\\]],"\\")
                  end
                  if valueIsString == 0 then
                        if tonumber(k) ~= nil then
                              val = tonumber(k)
                        else
                              if k ~= "{" then
                                    if k == "t" or k == "f" then
                                          val = ((k == "t") and true) or false
                                    else
                                          print("Malformed ion at line "..lineNumber..": "..originalLine)
                                          return {}
                                    end
                              elseif count >= 1 then
                                    table.insert(levels,{finalKey,{}})
                              end
                        end
                  else
                        val,_ = k:gsub("\n","\n"):gsub("\\t","\t"):gsub([[\\]],"\\")
                  end
                  levels[#levels][2][finalKey] = val
            end
      end
end

return ion
