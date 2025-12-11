# ion.lua (v = "1.3.0")
A JSON inspired compact data storage format designed for Lua purposes.
This module's name is stylised as "ion", in all lowercase.
It has absolutely no association with a somewhat similar Amazon product, and was created without knowledge of it.

## LICENSE

This work [is distributed](https://github.com/NibiriTheMan/ion.lua/blob/main/LICENSE) under [MPL 2.0](https://www.mozilla.org/en-US/MPL/2.0/).

## Prerequisites

To use this module, you will need at least Lua 5.2+ or LuaJIT 2.0+. Note that many dialects are incompatible, even if based on a compatible version of Lua or LuaJIT (e.g., Luau).

## Usage

This module creates a file that stores data, called an "ion".\
To begin, install the module (from either Releases, https://nibiritheman.github.io/ion.lua/downloads.html, or from the root directory) somewhere into your codebase, then do something akin to:
```lua
local ion = require("ion") -- Or, whatever the path to the module is.
```
This section will cover both methods this module has to offer.\
Note that each method's name is case sensitive.

### ion.Create

This function is used like this: (For more information on Positrons and Electrons, see the dedicated section.)
```lua
ion.Create(Datatable,Filename,Tabless,Blacklist,Whitelist,Positrons,Electrons)
--[[
1. Datatable - An array or dictionary that is desired to be saved onto an ion.
2. Filename - The name of the file that the data will be stored onto.
3. Tabless - If (and only if) true, indentation is not used in the final ion.
4. List - An array or dictionary (though preferably the former) containing
Datatable indices that will be excluded or included depending on Whitelist.
5. Whitelist - Can be any value. If it's specifically set to true, then the
provided List will act as a whitelist, and otherwise will be a blacklist.
6. Positrons - An array of functions that return a boolean. If any boolean is
true, then the entry will be allowed in, regardless of the blacklist/whitelist.
7. Electrons - Same as above, with the difference being that they exclude
regardless of the blacklist/whitelist.
]]--
```
Thus, an example ion being created looks like this:
```lua
local db = {
  ["People"] = {
    ["Bob"] = {
      ["Age"] = 23,
      ["Gender"] = "Male"
    },
    ["Alice"] = {
      ["Age"] = 27,
      ["Gender"] = "Female"
    }
  }
}

local blacklist = {"Gender"}
ion.Create(db,"myIon",_,blacklist)
```
The resulting ion will look like so, having been created at "myIon.ion":
```
|ion:{
  |People:{
    |Bob:{
      |Age:23
    }
    |Alice:{
      |Age:27
    }
  }
}
```
It can be clearly noted that the "Gender" key has been excluded by the blacklist, and thus only the age has been stored.

#### Positrons and Electrons

A Positron/Electron will look something like this:
```lua
local myPositrons = {
  function(Value,Key)
    return Value == "Male" -- This boolean can take any form, as long as the boolean itself wouldn't error.
  end
}
```
Now, if ion.Create is run again, but with these Positrons:
```lua
ion.Create(db,"myIon",_,blacklist,false,myPositrons)
```
This will give a similar ion, but Bob's gender will also be listed.
```
|ion:{
  |People:{
    |Bob:{
      |Age:23
      |Gender:|Male
    }
    |Alice:{
      |Age:27
    }
  }
}
```
This can also be used in the reverse via Electrons. If the same Positrons are passed, except as Electrons and with an empty Blacklist, like so:
```lua
ion.Create(db,"myIon",_,_,false,_,myPositrons)
-- NOTE: The same variable is being used in this example for demonstration purposes.
-- Electrons, in practice, should be named clearly.
```
Then the following ion will be produced:
```
|ion:{
  |People:{
    |Bob:{
      |Age:23
    }
    |Alice:{
      |Age:27
      |Gender:|Female
    }
  }
}
```

### ion.Read

Read takes only one argument, and is used like this:
```lua
local nameOfTable = ion.Read(Path)
-- nameOfTable - The name of your table.
-- Path - Where you wish to seek for the ion.
```
If, after having created the first example ion at "myIon.ion", we can read its contents like so:
```lua
local myDatabase = ion.Read("myIon.ion")
```
This will give us back our original database (with the "Gender" index having been deleted).
