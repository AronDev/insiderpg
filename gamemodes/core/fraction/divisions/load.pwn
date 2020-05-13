#include <YSI\y_hooks>
hook public OnGameModeInit() {
    startDivisionLoad();
    return 1;
}
startDivisionLoad() {
    for(new i = 0; i < MAX_DIVISIONS; i++) dInfo[i][dExist] = false;
    mysql_pquery(mysql_id, "SELECT * FROM divisions", "loadDivisions", "");
    return 1;
}
function loadDivisions() {
    new rows = cache_num_rows();
    if(rows) {
        new id = -1;
        for(new i = 0; i < rows; i++) {
            mysql_get_int(i, "dbid", id);
            dInfo[id][dExist] = true;
            dInfo[id][dDBID] = id;
            mysql_get_int(i, "division_id", dInfo[id][dID]);
            mysql_get_string(i, "name", dInfo[id][dName], mysql_id, 64);
            mysql_get_string(i, "short_name", dInfo[id][dSName], mysql_id, 32);
            mysql_get_int(i, "type", dInfo[id][dType]);
            mysql_get_int(i, "maxmembers", dInfo[id][dMaxMembers]);
            mysql_get_int(i, "linked_fraction", dInfo[id][dLF]);
        }
    }
    return 1;
}
