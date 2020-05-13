// Includes
#include <a_samp>
#include <crashdetect>
// Define MAX_PLAYERS before including y_hooks
#undef MAX_PLAYERS
#define MAX_PLAYERS 300
#include <YSI\y_hooks>
#include <YSI\y_timers>
#include <YSI\y_inline>
#include <callbacks>
#include <a_mysql_r39-6>
#include <gvar>
#include <a_players>
#include <a_zones>
#include <strlib>
#include <sscanf2>
#include <Pawn.CMD>
#include <mapandreas>
#include <streamer>
#include <vfunc>
#include <fixchars>
#include <opvd>
#include <filemanager>

// Natives
native WP_Hash(buffer[], len, const str[]);

// Modules
#include "core/server/main.pwn"
