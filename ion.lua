local ion = {}
local file,prefix,list,whitelist,tabless = nil,"\t",{},false,false

local positrons,electrons = {},{}
local function compare(table,i,v)
	for _,w in pairs(table) do
		if type(w) == "function" and w(v,i) == true then
			return true
		end
	end
	return false
end
local function crawl(table,fp)
	if file == nil then
		error("Something went wrong with file definition")
	end
	local noOp = true
	for i,v in pairs(table) do
		local blacklisted,granted,denied = whitelist,false,false
		if type(v) == "function" then
			blacklisted = true
		else
			granted = compare(positrons,i,v)
			denied = compare(electrons,i,v)
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
		if (granted and not denied) or ((denied == granted) and not blacklisted) then
			if noOp then
				file:write(string.char(10))
				noOp = false
			end
			local index
			if type(i) == "string" then
				index = "|"..i:gsub("\\","\\\\"):gsub("\n","\\n"):gsub("|","\\|")
			else
				index = i
				if type(i) == "boolean" then
					index = (index and "t") or "f"
				end
			end
			if not tabless then
				file:write(prefix)
			end
			file:write(index)
			local value
			if type(v) == "table" then
				value = "{"
				if not tabless then
					prefix = prefix.."\t"
				end
				file:write(value)
				crawl(v)
			else
				if type(v) == "string" then
					value = "|"..v:gsub("\\","\\\\"):gsub("\n","\\n"):gsub("|","\\|")
				else
					value = v
					if type(value) == "boolean" then
						value = (value and "t") or "f"
					end
					value = ":"..value
				end
				file:write(value,string.char(10))
			end
		end
	end
	if not tabless then
		prefix = prefix:sub(1,-2)
		if not noOp then
			file:write(prefix)
		end
	end
	file:write("}")
	if (not tabless or noOp) and not fp then
		file:write(string.char(10))
	end
end

function ion.Create(entries,name,noTabs,l,wl,p,e)
	prefix = "\t"
	tabless = noTabs == true
	whitelist = wl == true
	positrons = (type(p) == "table" and p) or {}
	electrons = (type(e) == "table" and e) or {}
	list = (type(l) == "table" and l) or {}
	name = (type(name) == "string" and name) or "ion"
	name = name..".ion"
	file = io.open(name,"w"); file:write("|ion{"); file:close(); file = io.open(name,"a")
	crawl(entries,true)
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
	local k = readIon:read("l")
	local legacyMode = false
	if k == nil then
		error("ERROR: Empty ion")
	elseif k == "|ion:{" or k == "|ion:{}" then
		legacyMode = true
		print("WARNING: Pre-2.0.0 ion detected, now converting.")
	elseif k ~= "|ion{" and k ~= "|ion{}" then
		error("ERROR: Corrupt or invalid ion")
	end
	local isTabless = false
	::start::
	k = readIon:read("l")
	if k == nil then
		if legacyMode then
			ion.Create(levels[1][2],read:gsub("%.ion$",""),isTabless)
		end
		return levels[1][2]
	end
	lineNumber = lineNumber + 1
	k,tabs = k:gsub("^\t+","")
	local found = k:match("^}+")
	if found ~= nil then
		for _=1,#found do
			if #levels >= 2 then
				levels[#levels - 1][2][levels[#levels][1]] = levels[#levels][2]
				table.remove(levels,#levels)
			end
		end
		k = k:gsub(found,"")
		if k == "" then
			goto start
		end
	end
	if tabs < 1 and legacyMode and not isTabless then
		isTabless = true
	end
	local valueIsString, keyIsString
	local originalLine = k
	local key,firstPass = k:gsub("([^\\])|.*","%1")
	if firstPass < 1 then
		key = key:gsub(":[^:]+$",""):gsub("{}?$","")
	elseif legacyMode then
		key = key:gsub(":$","")
	end
	k = k:gsub("^"..key:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1"), ""):gsub("^:", "")
	k,valueIsString = k:gsub("^|","")
	key,keyIsString = key:gsub("^|","")
	local val,finalKey
	if keyIsString < 1 then
		if tonumber(key) ~= nil then
			finalKey = tonumber(key)
		else
			if key == "t" or key == "f" then
				finalKey = key == "t"
			else
				malformed(lineNumber, originalLine)
			end
		end
	else
		finalKey = key:gsub("\\|","|"):gsub("\\n","\n"):gsub([[\\]],"\\")
	end
	if valueIsString < 1 then
		if tonumber(k) ~= nil then
			val = tonumber(k)
		else
			if k == "{" then
				table.insert(levels,{finalKey,{}})
			else
				if k == "t" or k == "f" then
					val = k == "t"
				elseif k == "{}" then
					val = {}
				else
					malformed(lineNumber, originalLine)
				end
			end
		end
	else
		val = k:gsub("\\|","|"):gsub("\\n","\n"):gsub([[\\]],"\\")
	end
	levels[#levels][2][finalKey] = val
	goto start
end

return ion
