#include <YSI\y_hooks>
hook public OnGameModeInit() {
    startPosLoad();
    startPosTypeLoad();
    return 1;
}
startPosLoad() {
    for(new i = 0; i < MAX_POSITIONS; i++) clearPosition(i);
    mysql_pquery(mysql_id, "SELECT * FROM positions", "loadPositions", "");
    return 1;
}
startPosTypeLoad() {
    for(new i = 0; i < MAX_POS_TYPES; i++) clearPositionType(i);
    mysql_pquery(mysql_id, "SELECT * FROM position_types", "loadPosTypes", "");
    return 1;
}
function loadPositions() {
    new rows = cache_num_rows();
    if(rows) {
        new id = -1, posstr[128];
        for(new i = 0; i < rows; i++) {
            mysql_get_int(i, "dbid", id);
            posInfo[id][posExist] = true;
            posInfo[id][posDBID] = id;
            mysql_get_string(i, "pos", posstr);
            sscanf(posstr, "p<,>fff", PosEx(posInfo[id][posPos]));
            mysql_get_float(i, "rad", posInfo[id][posRad]);
            mysql_get_int(i, "interior", posInfo[id][posInt]);
            mysql_get_int(i, "vw", posInfo[id][posVW]);
            mysql_get_int(i, "type", posInfo[id][posType]);
            mysql_get_int(i, "linked_fraction", posInfo[id][posLF]);
            mysql_get_string(i, "comment", posInfo[id][posComment], mysql_id, 64);
        }
    } else return 0;
    return 1;
}
function loadPosTypes() {
    new rows = cache_num_rows();
    if(rows) {
        new id = -1;
        for(new i = 0; i < rows; i++) {
            mysql_get_int(i, "position_type", id);
            ptypeInfo[id][ptypeExist] = true;
            ptypeInfo[id][ptypeDBID] = id;
            mysql_get_string(i, "name", ptypeInfo[id][ptypeName], mysql_id, 64);
        }
    } else return 0;
    return 1;
}
