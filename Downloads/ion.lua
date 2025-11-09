local ion = {}
local file,prefix,list,whitelist,compact = nil,"\t",{},false,false

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
			granted = compare(positrons,i,v,granted)
			denied = compare(electrons,i,v,denied)
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
			if type(i) == "string" then
				index = "|"..i:gsub("\\","\\\\"):gsub("\n","\\n"):gsub("\t","\\t"):gsub("|","\\|")
			elseif type(i) == "boolean" then
				index = (i == true and "t") or "f"
			end
			file:write("\n")
			if compact ~= true then
				file:write(prefix)
			end
			file:write(index,":")
			local value
			if type(v) == "table" then
				value = "{"
				if compact ~= true then
					prefix = prefix.."\t"
				end
				file:write(value)
				crawl(v)
			else
				if type(v) == "string" then
					value = "|"..v:gsub("\\","\\\\"):gsub("\n","\\n"):gsub("\t","\\t"):gsub("|","\\|")
				else
					value = v
					if type(value) == "boolean" then
						value = (value == true and "t") or "f"
					end
				end
				file:write(value)
			end
		end
	end
	if compact ~= true then
		prefix = prefix:sub(1,-2)
	end
	if noOp == false then
		file:write("\n")
		if compact == false then
			file:write(prefix)
		end
	end
	file:write("}")
end

function ion.Create(entries,name,noTabs,l,wl,p,e)
	prefix = "\t"
	compact = noTabs
	whitelist = wl == true
	positrons = (type(p) == "table" and p) or {}
	electrons = (type(e) == "table" and e) or {}
	list = (type(l) == "table" and l) or {}
	name = (type(name) == "string" and name) or "ion"
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
	end
	local levels = {{
		"",
		{}
	}}
	local lineNumber = 1
	while true do
		local k = readIon:read("l")
		if lineNumber == 1 then
			if k == nil then
				error("ERROR: Empty ion")
			elseif k ~= "|ion:{" and k ~= "|ion:{}" then
				error("ERROR: Corrupt or invalid ion")
			else
				k = readIon:read("l")
			end
		end
		::start::
		if k == nil then
			return levels[1][2]
		end
		k,_ = k:gsub("\t", "")
		lineNumber = lineNumber + 1
		if k == "}" then
			if #levels >= 2 then
				levels[#levels - 1][2][levels[#levels][1]] = levels[#levels][2]
				table.remove(levels, #levels)
			end
			k = readIon:read("l")
			goto start
		end
		local valueIsString, keyIsString
		local originalLine = k
		local key,firstPass = k:gsub(":|.+", "")
		if firstPass == 0 then
			key,_ = key:gsub(":[^:]+$","")
		end
		k,_ = k:gsub(key..":","")
		if k ~= "{}" then
			k, valueIsString = k:gsub("^|", "")
			key, keyIsString = key:gsub("^|", "")
			local val, finalKey
			if keyIsString == 0 then
				if tonumber(key) ~= nil then
					finalKey = tonumber(key)
				else
					if key == "t" or key == "f" then
						finalKey = key == "t"
					else
						malformed(lineNumber,originalLine)
					end
				end
			else
				finalKey,_ = key:gsub("\\|","|"):gsub("\\n","\n"):gsub("\\t","\t"):gsub([[\\]],"\\")
			end
			if valueIsString == 0 then
				if tonumber(k) ~= nil then
					val = tonumber(k)
				else
					if k ~= "{" then
						if k == "t" or k == "f" then
							val = k == "t"
						else
							malformed(lineNumber,originalLine)
						end
					else
						table.insert(levels,{finalKey,{}})
					end
				end
			else
				val,_ = k:gsub("\\|","|"):gsub("\\n","\n"):gsub("\\t","\t"):gsub([[\\]],"\\")
			end
			levels[#levels][2][finalKey] = val
		end
	end
end

return ion
