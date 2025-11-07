# Changelog
## v = 1.x.x
### v = 1.2.x
#### v = 1.2.0
- "Tabless" mode added. If enabled, indentation is not used to save even more bytes.
- Bug-fixes and optimisations galore.
### v = 1.1.x
#### v = 1.1.0
- Parser overall given minor optimisations:
    - "}" and the first line are both now quickly interpreted, then skipped to avoid unnecessary string operations.
    - The variable that formerly tracked the number of tabs in a string has been removed, thus allowing an ion to include no tabs at all.
- Tab logic overall adjusted. The "prefix" variable now has 1 tab by default instead of 0, and ion Creation has been overall adjusted to fit this.
### v = 1.0.x
#### v = 1.0.1
- Adjusted logic. Empty tables are now displayed as simply `{}`, and the parser has been updated to detect this.
- Target file is now checked for `nil` when creating an ion as an extra precaution.
#### v = 1.0.0
Public release. Full list of features introduced in this update:
- ion Creation:
  - Datatables get turned into ions.
  - A Blacklist can be used to exclude entries with particular keys; Blacklists can be turned into Whitelists.
  - Positrons and Electrons can be passed to perform further comparison operations.
- ion Loading:
  - ions can be turned back into tables by specifying the file path.
