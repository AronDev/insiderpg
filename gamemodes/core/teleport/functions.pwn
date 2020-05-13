getClosestTeleportToPlayer(playerid) {
    new dbid = -1;
    for(new i = 0; i < MAX_TELEPORTS; i++) {
        if(tpInfo[i][tpExist]) {
            if(PlayerToPoint(playerid, tpInfo[i][tpRad][0], PosEx(tpInfo[i][tpPos])) || PlayerToPoint(playerid, tpInfo[i][tpRad][1], tpInfo[i][tpPos][3], tpInfo[i][tpPos][4], tpInfo[i][tpPos][5])) {
                dbid = i;
                break;
            }
        }
    }
    return dbid;
}

isValidTeleport(dbid) {
    return tpInfo[dbid][tpExist];
}

clearTeleport(dbid) {
    tpInfo[dbid][tpExist] = false;
    tpInfo[dbid][tpDBID] = -1;

    for(new i = 0; i < 6; i++) {
        tpInfo[dbid][tpPos][i] = 0.0;
    }

    for(new i = 0; i < 2; i++) {
        tpInfo[dbid][tpRad][i] = 0.0;
        tpInfo[dbid][tpVW][i] = 0;
        tpInfo[dbid][tpInt][i] = 0;
        DestroyDynamicPickup(tpInfo[dbid][tpPickup][i]);
    }
}
