#include <YSI\y_hooks>
hook public OnGameModeInit() {
    startRankLoad();
    return 1;
}
startRankLoad() {
    for(new i = 0; i < MAX_RANKS; i++) raInfo[i][raExist] = false;
    mysql_pquery(mysql_id, "SELECT * FROM fraction_ranks", "loadRanks", "");
    return 1;
}
function loadRanks() {
    new rows = cache_num_rows();
    if(rows) {
        new id = -1;
        for(new i = 0; i < rows; i++) {
            mysql_get_int(i, "dbid", id);
            raInfo[id][raExist] = true;
            raInfo[id][raDBID] = id;
            mysql_get_int(i, "rank_id", raInfo[id][raID]);
            mysql_get_string(i, "name", raInfo[id][raName], mysql_id, 64);
            mysql_get_int(i, "linked_fraction", raInfo[id][raLF]);
        }
    }
    return 1;
}
