#include <YSI\y_hooks>
hook public OnGameModeInit() {
    startFractionLoad();
    return 1;
}
startFractionLoad() {
    for(new i = 0; i < MAX_FRACTIONS; i++) fInfo[i][fExist] = false;
    mysql_pquery(mysql_id, "SELECT * FROM fractions", "loadFractions", "");
    return 1;
}
function loadFractions() {
    new rows = cache_num_rows();
    if(rows) {
        new id = -1;
        for(new i = 0; i < rows; i++) {
            mysql_get_int(i, "dbid", id);
            fInfo[id][fExist] = true;
            fInfo[id][fDBID] = id;
            mysql_get_string(i, "name", fInfo[id][fName], mysql_id, 128);
            mysql_get_string(i, "short_name", fInfo[id][fSName], mysql_id, 32);
            mysql_get_int(i, "maxmembers", fInfo[id][fMaxMembers]);
            mysql_get_int(i, "type", fInfo[id][fType]);
        }
    }
    return 1;
}
