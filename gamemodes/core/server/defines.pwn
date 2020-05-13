// Colors
#define COLOR_SPRINGGREEN 0x00FF7FAA
#define COLOR_OLIVE 0x808000AA
#define COLOR_LAWNGREEN 0x7CFC00AA
#define COLOR_CYAN 0x33CCFFFF
#define COLOR_BURLYWOOD 0xDEB887FF
#define COLOR_RED 0xff0000FF
#define COLOR_LIGHTGREEN 0x9ACD32FF
#define COLOR_SBLUE 0x0077BBFF
#define COLOR_BLUE 0x1394BFFF
#define COLOR_TOMATO 0xFF6347AA
#define COLOR_KHAKI 0x999900AA
#define COLOR_LIGHTGRAY 0xD3D3D3FF
#define COLOR_LIGHTGREEN2 0xA2FF99FF
#define COLOR_GRAY 0xAFAFAFAA
#define COLOR_YELLOW 0xffff00FF
#define COLOR_PURPLE 0xc455e0FF // /me
#define COLOR_PURPLE2 0xebabfcFF // /try
#define COLOR_PURPLE3 0x856e9aFF // /do
#define COLOR_ORANGE 0xFF9900FF
#define COLOR_DARKRED 0xAA3333FF
#define COLOR_RADIO 0x7f7fffFF
#define COLOR_WHITE -1
#define COLOR_GREEN 0x33AA33FF
#define COLOR_LIME 0x10F441AA
#define COLOR_SPRING 0x00fa9aFF

// max numbers
#define MAX_INVENTORY_SPACE 50*1000 // 50kgs, in sql we work in gramms
#define MAX_TRUNK_SPACE 600*1000 // 600kgs
#define MAX_SKINS_PER_FRACTION 20
#define MAX_POSITIONS 500
#define MAX_POS_TYPES 10
#define MAX_FRACTIONS 30
#define MAX_RANKS MAX_FRACTIONS * 15
#define MAX_DIVISIONS MAX_FRACTIONS * 10
#define MAX_REPORT_CATS 15+1
#define MAX_LABELS 300
#define MAX_TELEPORTS 500
#define MAX_CALLS 1000
#define MAX_STRINGS 100
#define MAX_HP 100
#define MAX_AP 100
#define MAX_VHP 1000
#define MAX_ADMINLEVELS 15

// positions type
#define POS_TYPE_DUTY 0
#define POS_TYPE_SATELLITE 1

// Vehicle types <vfunc.inc>
#define VTYPE_ROAD 0
#define VTYPE_BIKE 1
#define VTYPE_PLANE 2
#define VTYPE_HELI 3
#define VTYPE_BOAT 4
#define VTYPE_TRAIN 5

// Satellite values
#define SATELLITE_MOVE 20
#define SATELLITE_UPDOWN 10
#define SATELLITE_MIN 50
#define SATELLITE_MAX 500

#if !defined IsValidVehicle
    native IsValidVehicle(vehicleid);
#endif

// Macros
#define KEY_AIM KEY_HANDBRAKE
#define HOLDING(%0) ((newkeys & (%0)) == (%0))
#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define RELEASED(%0) (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
// R39-6
#define mysql_get_int(%1,%2,%3) (%3 = cache_get_field_content_int(%1,%2))
#define mysql_get_float(%1,%2,%3) (%3 = cache_get_field_content_float(%1,%2))
#define mysql_get_string cache_get_field_content
// R41-4
/*#define mysql_get_int cache_get_value_name_int
#define mysql_get_float cache_get_value_name_float
#define mysql_get_string cache_get_value_name*/
#define doQuery(%0,%1) mysql_tquery(mysql_id,(format(queryStr, sizeof(queryStr), (%0), %1), queryStr),"","")


#define randint(%1,%2) (%1+random(%2-%1+1)) // Random number between 2 numbers
#define function%0(%1) forward%0(%1); public%0(%1) // A shorter way to make functions
#define equals(%1) (!strcmp(%1, true)) // A shorter way to make string comparison
#define PosEx(%1) %1[0], %1[1], %1[2] // A shorter way to get all three cord from a position array
#define PlayerToPoint IsPlayerInRangeOfPoint // Just personal preference
#define sendFormattedAdminMessage(%1,%2,%3,%4) do{new sendfstring[512];format(sendfstring,sizeof(sendfstring),(%3),%4);sendAdminMessage(%1,%2,sendfstring);}while(FALSE) // sendAdminMessage with format
#define sendFormattedClientMessage(%1,%2,%3,%4) do{new sendfstring[512];format(sendfstring,sizeof(sendfstring),(%3),%4);SendClientMessage(%1,(%2),sendfstring);}while(FALSE) // SCM with format
#define serverLogFormatted(%1,%2,%3) do{new sendfstring[512];format(sendfstring,sizeof(sendfstring),(%2),%3);serverLog(%1,sendfstring);}while(FALSE) // serverLog with format
#define EmulateFormattedCommand(%1,%2,%3) do{new sendfstring[512];format(sendfstring,sizeof(sendfstring),(%2),%3);PC_EmulateCommand(%1,sendfstring);}while(FALSE) // serverLog with format
#define SFCM sendFormattedClientMessage
#define SFCMToAll(%1,%2,%3) do{for(new i=0;i<GetPlayerPoolSize()+1;i++){SFCM(i,%1,%2,%3);}}while(FALSE)
#define SCM SendClientMessage
#define SFAM sendFormattedAdminMessage
