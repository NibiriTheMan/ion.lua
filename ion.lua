local ion = {}
local file,prefix,list,whitelist = nil,"",{},false

local positrons,electrons = {},{}
local function compare(table,i,v,result)
      for _,w in pairs(table) do
            if type(w) == "function" and w(v,i) == true then
                  return not result
            end
      end
      return result
end
local function crawl(table)
      if file == nil then
            error("Something went wrong with file definition")
      end
      local noOp = true
      for i,v in pairs(table) do
            local blacklisted,granted,denied = whitelist,false,false
            if type(v) == "function" then
                  blacklisted = true
            else
                  if type(positrons) == "table" then
                        granted = compare(positrons,i,v,granted)
                  end
                  if type(electrons) == "table" then
                        denied = compare(electrons,i,v,denied)
                  end
                  if denied == granted then
                        if type(list) == "table" then
                              for _,w in pairs(list) do
                                    if w == i then
                                          blacklisted = not blacklisted
                                          break
                                    end
                              end
                        end
                  end
            end
            if (blacklisted == false and denied == granted) or (denied == false and granted == true) then
                  if noOp == true then
                        noOp = false
                  end
                  local index = i
                  if type(index) == "string" then
                        index = "|"..index:gsub("\\","\\\\"):gsub("\n","\\n"):gsub("\t","\\t")
                  elseif type(index) == "boolean" then
                        index = (i == true and "t") or (i == false and "f")
                  end
                  file:write("\n",prefix,"\t",index,":")
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
                  file:write(value)
                  if type(v) == "table" then
                        crawl(v)
                  end
            end
      end
      if noOp == false then
            file:write("\n",prefix)
      end
      file:write("}")
      prefix = prefix:sub(1,-2)
end

function ion.Create(entries,name,l,wl,p,e)
      prefix = ""
      whitelist = (wl == true and true) or false
      positrons = p or {}
      electrons = e or {}
      if type(l) == "table" then
            list = l
      else
            list = {}
      end
      if name == nil then
            name = "ion"
      end
      name = name..".ion"
      file = io.open(name,"w"); file:write("|ion:{"); file:close(); file = io.open(name,"a")
      crawl(entries)
      file:close()
end

local function malformed(lineNumber,line)
      error("ERROR: Malformed ion at line "..lineNumber..": "..line)
end
function ion.Read(read)
      local readIon = assert(io.open(read,"r"))
      if readIon == nil then
            error("ERROR: File does not exist: "..read)
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
                  error("ERROR: Malformed or empty ion")
            end
            local k,count = k:gsub("\t", "")
            if count == 0 and k ~= "|ion:{" and k ~= "}" then
                  malformed(lineNumber,k)
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
            if k ~= "}" and k ~= "{}" then
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
                                    malformed(lineNumber,originalLine)
                              end
                        end
                  else
                        finalKey,_ = key:gsub("\\n","\n"):gsub("\\t","\t"):gsub([[\\]],"\\")
                  end
                  if valueIsString == 0 then
                        if tonumber(k) ~= nil then
                              val = tonumber(k)
                        else
                              if k ~= "{" then
                                    if k == "t" or k == "f" then
                                          val = ((k == "t") and true) or false
                                    else
                                          malformed(lineNumber,originalLine)
                                    end
                              elseif count >= 1 then
                                    table.insert(levels,{finalKey,{}})
                              end
                        end
                  else
                        val,_ = k:gsub("\\n","\n"):gsub("\\t","\t"):gsub([[\\]],"\\")
                  end
                  levels[#levels][2][finalKey] = val
            end
      end
end

return ion

