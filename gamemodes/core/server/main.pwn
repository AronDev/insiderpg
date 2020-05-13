/*
*
* defines.pwn - Contains defines (e.g. colors, macros)
* exit.pwn - Executes when OnGameModeExit() called
* load.pwn - Loads server config from the MySQL Server
* init.pwn - Executes when OnGameModeInit() called
*
*/

// SQL
#include "core/sql/main.pwn"

// Local modules
#include "core/server/dialogs.pwn"
#include "core/server/datastores.pwn"
#include "core/server/defines.pwn"
#include "core/server/functions.pwn"
#include "core/server/exit.pwn"
#include "core/server/init.pwn"
#include "core/server/load.pwn"
#include "core/server/map/main.pwn"

// Other modules
#include "core/label/main.pwn" // Label System
#include "core/call/main.pwn" // Call System (eg. /ek, /rta etc. and NOT call like /call xyz)
#include "core/fraction/main.pwn" // Fraction System
#include "core/vehicle/main.pwn" // Vehicle System
#include "core/report/main.pwn" // Report Category System
#include "core/teleport/main.pwn" // Teleport System
#include "core/positions/main.pwn" // Position System (eg. dutypos, satellite pos etc..)
#include "core/strings/main.pwn" // In Game messages
#include "core/admin/main.pwn" // Admin Rank System
#include "core/player/main.pwn" // Player System (eg. commands, callbacks etc.)
#include "core/method/main.pwn" // Functions
