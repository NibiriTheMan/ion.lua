# ion.lua

A JSON inspired compact data storage format designed for lua purposes.
Stylised as "ion", simply all lowercase.

## LICENSE

This work is distributed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

## Usage

This module creates a file that stores data, called an "ion".<br>
To begin, install the module somewhere into your codebase, then do something akin to:
```lua
local ion = require("ion") -- Or, whatever the path to the module is.
```
This section will cover both methods this module has to offer.

### Create

This function is used like this:
```lua
ion.Create(Datatable,Filename,Blacklist)
-- 1. Datatable - An array or dictionary that is desired to be saved onto an ion.
-- 2. Filename - The name of the file that the data will be stored onto.
-- 3. Blacklist - An array or dictionary (though preferably the former) containing indices that will be excluded from storage.
```
<!-- -->
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

### Load
Load takes only one argument, and is used like this:
```lua
local nameOfTable = ion.Load(Path)
-- nameOfTable - The name of your table.
-- Path - Where you wish to seek for the ion.
```
If, after having created the earlier ion at "myIon.ion", we can read its contents like so:
```lua
local myDatabase = ion.Load("myIon.ion")
```
This will give us back our original database (with the "Gender" index having been deleted).
