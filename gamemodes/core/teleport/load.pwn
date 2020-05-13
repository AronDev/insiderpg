#include <YSI\y_hooks>
hook public OnGameModeInit() {
    startTeleportsLoad();
    return 1;
}
startTeleportsLoad() {
    for(new i = 0; i < MAX_TELEPORTS; i++) {
        if(tpInfo[i][tpExist]) {
            tpInfo[i][tpExist] = false;
            DestroyDynamicPickup(tpInfo[i][tpPickup][0]);
            DestroyDynamicPickup(tpInfo[i][tpPickup][1]);
        }
    }
    mysql_pquery(mysql_id, "SELECT * FROM teleports", "loadTeleports", "");
    return 1;
}

loadTeleport(teleportDBID) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT * FROM teleports WHERE dbid='%d'", teleportDBID);
    inline q_loadTeleports() {
        new rows = cache_num_rows();
        if(rows) {
            new id = -1;
            new tpPosStr[2][128];
            mysql_get_int(0, "dbid", id);
            tpInfo[id][tpDBID] = id;
            mysql_get_string(0, "pos1", tpPosStr[0]);
            sscanf(tpPosStr[0], "p<,>fff", PosEx(tpInfo[id][tpPos]));
            mysql_get_string(0, "pos2", tpPosStr[1]);
            sscanf(tpPosStr[1], "p<,>fff", tpInfo[id][tpPos][3], tpInfo[id][tpPos][4], tpInfo[id][tpPos][5]);
            mysql_get_int(0, "interior1", tpInfo[id][tpInt][0]);
            mysql_get_int(0, "interior2", tpInfo[id][tpInt][1]);
            mysql_get_int(0, "vw1", tpInfo[id][tpVW][0]);
            mysql_get_int(0, "vw2", tpInfo[id][tpVW][1]);
            mysql_get_float(0, "rad1", tpInfo[id][tpRad][0]);
            mysql_get_float(0, "rad2", tpInfo[id][tpRad][1]);
            tpInfo[id][tpExist] = true;

            tpInfo[id][tpPickup][0] = CreateDynamicPickup(1318, 1, PosEx(tpInfo[id][tpPos]), tpInfo[id][tpVW][0], tpInfo[id][tpInt][0]);
            tpInfo[id][tpPickup][1] = CreateDynamicPickup(1318, 1, tpInfo[id][tpPos][3], tpInfo[id][tpPos][4], tpInfo[id][tpPos][5], tpInfo[id][tpVW][1], tpInfo[id][tpInt][1]);
        }
    }
    mysql_tquery_inline(mysql_id, queryStr, using inline q_loadTeleports, "");
}

function loadTeleports() {
    new rows = cache_num_rows();
    if(rows) {
        new id = -1;
        new tpPosStr[2][128];
        for(new i = 0; i < rows; i++) {
            mysql_get_int(i, "dbid", id);
            tpInfo[id][tpDBID] = id;
            mysql_get_string(i, "pos1", tpPosStr[0]);
            sscanf(tpPosStr[0], "p<,>fff", PosEx(tpInfo[id][tpPos]));
            mysql_get_string(i, "pos2", tpPosStr[1]);
            sscanf(tpPosStr[1], "p<,>fff", tpInfo[id][tpPos][3], tpInfo[id][tpPos][4], tpInfo[id][tpPos][5]);
            mysql_get_int(i, "interior1", tpInfo[id][tpInt][0]);
            mysql_get_int(i, "interior2", tpInfo[id][tpInt][1]);
            mysql_get_int(i, "vw1", tpInfo[id][tpVW][0]);
            mysql_get_int(i, "vw2", tpInfo[id][tpVW][1]);
            mysql_get_float(i, "rad1", tpInfo[id][tpRad][0]);
            mysql_get_float(i, "rad2", tpInfo[id][tpRad][1]);
            tpInfo[id][tpExist] = true;

            tpInfo[id][tpPickup][0] = CreateDynamicPickup(1318, 1, PosEx(tpInfo[id][tpPos]), tpInfo[id][tpVW][0], tpInfo[id][tpInt][0]);
            tpInfo[id][tpPickup][1] = CreateDynamicPickup(1318, 1, tpInfo[id][tpPos][3], tpInfo[id][tpPos][4], tpInfo[id][tpPos][5], tpInfo[id][tpVW][1], tpInfo[id][tpInt][1]);
        }
    } else return 0;
    return 1;
}
