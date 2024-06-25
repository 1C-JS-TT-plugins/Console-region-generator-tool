# Console region generator tool v4.0.2

**Please, before installation:**
- Remove or move older versions out of the plugins folder
to prevent id conflict errors
- Starting from v4.0.2, rename the file extension to .zip
as the game is unable to load unencrypted .plugin files

**Usage:**
- Press "+" to add a new map;
- - Cick the map to change size or remove it;
- - Hold and drag the map go move it anywhere
- View and copy JSON code and use it to generate a region from the console
- Import the region from the command field JSON

~This plugin calls [TheoTown.execute("cr:{}")](https://doc.theotown.com/modules/TheoTown.html#execute) to generate a region (you can do so from the console stage), which causes lag (or even crashes on low-end devices) (unless the region is small enough for your hardware to handle), and for some every-lua-plugin-f\*\*\*ing reason the region doesn't generate and instead displays a **'...///bit32' not found: ...///bit32Library was not found** error, so I have nothing to do about these issues, except for the latter, which the devs must fix now if they are reading this message.~
