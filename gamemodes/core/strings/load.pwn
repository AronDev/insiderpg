#include <YSI\y_hooks>
hook public OnGameModeInit() {
    startStringLoad();
    return 1;
}
startStringLoad() {
    for(new i = 0; i < MAX_STRINGS; i++) {
        if(strInfo[i][strExist]) {
            strInfo[i][strExist] = false;
        }
    }
    mysql_pquery(mysql_id, "SELECT s.dbid as dbid, c.color AS 'color', s.str AS 'str' FROM (strings AS s JOIN colors AS c ON (c.name = s.color))", "loadStrings", "");
    return 1;
}

loadString(stringDBID) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT s.dbid as dbid, c.color AS 'color', s.str AS 'str' FROM (strings AS s JOIN colors AS c ON (c.name = s.color)) WHERE s.dbid='%d'", stringDBID);
    inline q_loadString() {
        new rows = cache_num_rows();
        if(rows) {
            new id = -1;
            mysql_get_int(i, "dbid", id);
            strInfo[id][strDBID] = id;
            mysql_get_string(i, "str", strInfo[id][strMsg], mysql_id, 255);
            mysql_get_string(i, "color", strInfo[id][strColor], mysql_id, 16);
            strInfo[id][strExist] = true;
        }
    }
    mysql_tquery_inline(mysql_id, queryStr, using inline q_loadString, "");
}

function loadStrings() {
    new rows = cache_num_rows();
    if(rows) {
        new id = -1;
        for(new i = 0; i < rows; i++) {
            mysql_get_int(i, "dbid", id);
            strInfo[id][strDBID] = id;
            mysql_get_string(i, "str", strInfo[id][strMsg], mysql_id, 255);
            mysql_get_string(i, "color", strInfo[id][strColor], mysql_id, 16);
            strInfo[id][strExist] = true;
        }
    } else return 0;
    return 1;
}
