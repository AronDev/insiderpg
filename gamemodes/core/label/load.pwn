#include <YSI\y_hooks>
hook public OnGameModeInit() {
    startLabelsLoad();
    return 1;
}
startLabelsLoad() {
    for(new i = 0; i < MAX_LABELS; i++) {
        if(lInfo[i][lExist]) {
            lInfo[i][lExist] = false;
            DestroyDynamic3DTextLabel(lInfo[i][lID]);
        }
    }
    mysql_pquery(mysql_id, "SELECT * FROM labels", "loadLabels", "");
    return 1;
}

loadLabel(labelDBID) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT * FROM labels WHERE dbid='%d'", labelDBID);
    inline q_loadLabel() {
        new rows = cache_num_rows();
        if(rows) {
            new id = -1, lRawPos[128];
            mysql_get_int(0, "dbid", id);
            lInfo[id][lDBID] = id;
            mysql_get_string(0, "text", lInfo[id][lText], mysql_id, 256);
            mysql_get_int(0, "color", lInfo[id][lColor]);
            mysql_get_string(0, "pos", lRawPos);
            sscanf(lRawPos, "p<,>fff", PosEx(lInfo[id][lPos]));
            mysql_get_float(0, "draw_distance", lInfo[id][lDrawDistance]);
            mysql_get_int(0, "vw", lInfo[id][lVW]);
            mysql_get_int(0, "testLOS", lInfo[id][lTestLOS]);
            lInfo[id][lExist] = true;

            lInfo[id][lID] = CreateDynamic3DTextLabel(lInfo[id][lText], convertLabelColor(lInfo[id][lColor]), PosEx(lInfo[id][lPos]), lInfo[id][lDrawDistance], INVALID_PLAYER_ID, INVALID_VEHICLE_ID, lInfo[id][lTestLOS], lInfo[id][lVW]);
        }
    }
    mysql_tquery_inline(mysql_id, queryStr, using inline q_loadLabel, "");
}

function loadLabels() {
    new rows = cache_num_rows();
    if(rows) {
        new id = -1, lRawPos[128];
        for(new i = 0; i < rows; i++) {
            mysql_get_int(i, "dbid", id);
            lInfo[id][lDBID] = id;
            mysql_get_string(i, "text", lInfo[id][lText], mysql_id, 256);
            mysql_get_int(i, "color", lInfo[id][lColor]);
            mysql_get_string(i, "pos", lRawPos);
            sscanf(lRawPos, "p<,>fff", PosEx(lInfo[id][lPos]));
            mysql_get_float(i, "draw_distance", lInfo[id][lDrawDistance]);
            mysql_get_int(i, "vw", lInfo[id][lVW]);
            mysql_get_int(i, "testLOS", lInfo[id][lTestLOS]);
            lInfo[id][lExist] = true;

            lInfo[id][lID] = CreateDynamic3DTextLabel(lInfo[id][lText], convertLabelColor(lInfo[id][lColor]), PosEx(lInfo[id][lPos]), lInfo[id][lDrawDistance], INVALID_PLAYER_ID, INVALID_VEHICLE_ID, lInfo[id][lTestLOS], lInfo[id][lVW]);
        }
    } else return 0;
    return 1;
}
