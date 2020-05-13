#include <YSI\y_hooks>
hook OnGameModeInit() {
    startReportCatLoad();
    return 1;
}

startReportCatLoad() {
    for(new i = 0; i < MAX_REPORT_CATS-1; i++) rInfo[i][rExist] = false;
    mysql_pquery(mysql_id, "SELECT rc.dbid AS 'dbid', rc.name AS 'name', rc.sname AS 'sname', rc.type AS 'type', c.color AS 'color' FROM report_categories AS rc JOIN colors AS c ON (rc.color=c.name)", "loadReportCategories", "");
    return 1;
}

function loadReportCategories() {
    new rows = cache_num_rows();
    if(rows) {
        new reportDBID = -1;
        for(new i = 0; i < rows; i++) {
            mysql_get_int(i, "dbid", reportDBID);
            rInfo[reportDBID][rDBID] = reportDBID;
            mysql_get_string(i, "name", rInfo[reportDBID][rName], mysql_id, 64);
            mysql_get_string(i, "sname", rInfo[reportDBID][rSName], mysql_id, 16);
            mysql_get_string(i, "color", rInfo[reportDBID][rColor], mysql_id, 16);
            mysql_get_int(i, "type", rInfo[reportDBID][rType]);
            rInfo[reportDBID][rExist] = true;
        }
    }
}
