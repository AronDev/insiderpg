sendAdminMessage(const perm, const color, const msg[]) {
    for(new i = 0; i < GetPlayerPoolSize() + 1; i++) {
        if(isValidPlayer(i)) { // If 'i' is a valid player (logged + connected)
            if(getPlayerAdminPermission(i) >= perm) { // If the player has enough permission to see the message
                SFCM(i, color, "%s", msg);
            }
        }
    }
    return 1;
}

getAdminLevelDBIDFromName(const name[]) {
    new adminlevelDBID = -1;
    for(new i = 0; i < MAX_ADMINLEVELS; i++) {
        if(alInfo[i][alExist]) {
            if(equals(alInfo[i][alName], name)) {
                adminlevelDBID = alInfo[i][alDBID];
                break;
            }
        }
    }
    return adminlevelDBID;
}

getMaxAdminLevels() {
	new alCount = 0;
	for(new i = 0; i < MAX_ADMINLEVELS; i++) {
		if(alInfo[i][alExist]) alCount++;
	}
	return alCount;
}
