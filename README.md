# ion.lua (v = 1.0.0)
A JSON inspired compact data storage format designed for Lua purposes.
This module's name is stylised as "ion", in all lowercase.

## LICENSE

This work is distributed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

## Usage

This module creates a file that stores data, called an "ion".\
To begin, install the module somewhere into your codebase, then do something akin to:
```lua
local ion = require("ion") -- Or, whatever the path to the module is.
```
This section will cover both methods this module has to offer.\
Note that each method's name is case sensitive.

### ion.Create

This function is used like this: (For more information on Positrons and Electrons, see the dedicated section.)
```lua
ion.Create(Datatable,Filename,Blacklist,Whitelist,Positrons,Electrons)
--[[
1. Datatable - An array or dictionary that is desired to be saved onto an ion.
2. Filename - The name of the file that the data will be stored onto.
3. List - An array or dictionary (though preferably the former) containing Datatable indices that will be excluded or included
depending on Whitelist.
4. Whitelist - Can be any value. If it's specifically set to true, then the provided List will act as a whitelist, and otherwise
will be a blacklist.
5. Positrons - An array of functions that return a boolean. If any boolean is true, then the entry will be allowed in, regardless
of the blacklist/whitelist.
6. Electrons - Same as above, with the difference being that they exclude regardless of the blacklist/whitelist.
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
ion.Create(db,"myIon",blacklist)
```
The resulting ion will look like so, having been created at "myIon.ion":
```
ion:{
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
ion.Create(db,"myIon",blacklist,false,myPositrons)
```
This will give a similar ion, but Bob's gender will also be listed.
```
ion:{
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
ion.Create(db,"myIon",_,false,_,myPositrons)
-- NOTE: The same variable is being used in this example for demonstration purposes.
-- Electrons, in practice, should be named clearly.
```
Then the following ion will be produced:
```
ion:{
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
### ion.Load
Load takes only one argument, and is used like this:
```lua
local nameOfTable = ion.Load(Path)
-- nameOfTable - The name of your table.
-- Path - Where you wish to seek for the ion.
```
If, after having created the first example ion at "myIon.ion", we can read its contents like so:
```lua
local myDatabase = ion.Load("myIon.ion")
```
This will give us back our original database (with the "Gender" index having been deleted).
