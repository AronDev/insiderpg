#include <YSI\y_hooks>
hook public OnGameModeInit() {
    startAdminLevelLoad();
    return 1;
}
startAdminLevelLoad() {
    for(new i = 0; i < MAX_ADMINLEVELS; i++) {
        if(alInfo[i][alExist]) {
            alInfo[i][alExist] = false;
        }
    }
    mysql_pquery(mysql_id, "SELECT al.dbid AS 'dbid', al.name AS 'name', al.permission AS 'perm', c.color AS 'color' FROM (adminlevels AS al JOIN colors AS c ON (c.name = al.color))", "loadAdminLevels", "");
    return 1;
}

loadAdminLevel(adminlevelDBID) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT al.dbid AS 'dbid', al.name AS 'name', al.permission AS 'perm', c.color AS 'color' FROM (adminlevels AS al JOIN colors AS c ON (c.name = al.color)) WHERE al.dbid='%d'", adminlevelDBID);
    inline q_loadAdminLevel() {
        new rows = cache_num_rows();
        if(rows) {
            new id = -1;
            mysql_get_int(i, "dbid", id);
            alInfo[id][alDBID] = id;
            mysql_get_string(i, "name", alInfo[id][alName], mysql_id, 32);
            mysql_get_string(i, "color", alInfo[id][alColor], mysql_id, 16);
            mysql_get_int(i, "perm", alInfo[id][alPerm]);
            alInfo[id][alExist] = true;
        }
    }
    mysql_tquery_inline(mysql_id, queryStr, using inline q_loadAdminLevel, "");
}

function loadAdminLevels() {
    new rows = cache_num_rows();
    if(rows) {
        new id = -1;
        for(new i = 0; i < rows; i++) {
            mysql_get_int(i, "dbid", id);
            alInfo[id][alDBID] = id;
            mysql_get_string(i, "name", alInfo[id][alName], mysql_id, 32);
            mysql_get_string(i, "color", alInfo[id][alColor], mysql_id, 16);
            mysql_get_int(i, "perm", alInfo[id][alPerm]);
            alInfo[id][alExist] = true;
        }
    } else return 0;
    return 1;
}
