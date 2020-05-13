#include <YSI\y_hooks>
hook OnGameModeInit() {
    mysql_pquery(mysql_id, "SELECT dbid FROM vehicles ORDER BY dbid ASC", "loadVehicles", "");
    return 1;
}

function loadVehicles() {
    new rows = cache_num_rows();
    if(rows) {
        new id = -1;
        for(new i = 0; i < rows; i++){
            mysql_get_int(i, "dbid", id);
            spawnVehicle(id);
        }
    }
}
