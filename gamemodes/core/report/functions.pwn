getReportDBIDByName(name[]) {
    new result = -1;
    for(new i = 0; i < MAX_REPORT_CATS-1; i++) {
        if(rInfo[i][rExist]) {
            if(equals(rInfo[i][rName], name)) {
                result = rInfo[i][rDBID];
            }
        }
    }
    return result;
}
getReportDBIDBySName(sname[]) {
    new result = -1;
    for(new i = 0; i < MAX_REPORT_CATS-1; i++) {
        if(rInfo[i][rExist]) {
            if(equals(rInfo[i][rSName], sname)) {
                result = rInfo[i][rDBID];
            }
        }
    }
    return result;
}
