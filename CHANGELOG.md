# Changelog
## v = 1.x.x
### v = 1.0.1
- Adjusted logic. Empty tables are now displayed as simply `{}`, and the parser has been updated to detect this.
- Target file is now checked for `nil` when creating an ion as an extra precaution.
### v = 1.0.0
Public release. Full list of features introduced in this update:
- ion Creation:
  - Datatables get turned into ions.
  - A Blacklist can be used to exclude entries with particular keys; Blacklists can be turned into Whitelists.
  - Positrons and Electrons can be passed to perform further comparison operations.
- ion Loading:
  - ions can be turned back into tables by specifying the file path.
