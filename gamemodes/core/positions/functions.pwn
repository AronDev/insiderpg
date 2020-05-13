createPosition(playerid, type, fk, Float:rad, comment[]) {
    if(strlen(comment) < 64) {
        new Float:pPos[3];
        GetPlayerPos(playerid, PosEx(pPos));
        new pPosStr[128];
        format(pPosStr, sizeof(pPosStr), "%f,%f,%f", PosEx(pPos));
        new pInt = GetPlayerInterior(playerid);
        new pVW = GetPlayerVirtualWorld(playerid);

        mysql_format(mysql_id, queryStr, sizeof(queryStr), "INSERT INTO positions (pos, rad, interior, vw, type, linked_fraction, comment) VALUES ('%s', '%f', '%d', '%d', '%d', '%d', '%s')", pPosStr, rad, pInt, pVW, type, fk, comment);
        mysql_tquery(mysql_id, queryStr, "onPositionCreate", "dffffdddds", playerid, PosEx(pPos), rad, pInt, pVW, type, fk, comment);
    } else SCM(playerid, COLOR_ORANGE, "(( Túl hosszú megjegyzés! ))");
    return 1;
}

function onPositionCreate(playerid, Float:pos1, Float:pos2, Float:pos3, Float:rad, pInt, pVW, type, fk, comment[]) {
    new posID = cache_insert_id();
    posInfo[posID][posExist] = true;
    posInfo[posID][posDBID] = posID;
    posInfo[posID][posPos][0] = pos1;
    posInfo[posID][posPos][1] = pos2;
    posInfo[posID][posPos][2] = pos3;
    posInfo[posID][posRad] = rad;
    posInfo[posID][posInt] = pInt;
    posInfo[posID][posVW] = pVW;
    posInfo[posID][posLF] = fk;
    posInfo[posID][posType] = type;
    format(posInfo[posID][posComment], 64, comment);

    /*if(!pInfo[playerid][P_TEMP][2]) {
        SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s létrehozott egy szolgálati helyet (DBID = %d)", getPlayerAdminRank(playerid), getName(playerid), posID);
    }*/
    SCM(playerid, COLOR_GREEN, "(( Létrehoztál egy szolgálati helyet! ))");
    SFCM(playerid, COLOR_GREEN, "(( DBID = %d, Hatókör = %.2f, VW = %d, Int = %d, Típus = %s(%d) ))", posID, rad, pVW, pInt, ptypeInfo[type][ptypeName], type);
    SFCM(playerid, COLOR_GREEN, "(( Frakció = %s(%d) ))", fInfo[fk][fName], fk);
    return 1;
}

removePosition(playerid, posId) {
    if(isValidPosition(posId)) {
        /*if(!pInfo[playerid][P_TEMP][2]) {
            SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s törölt egy szolgálati helyet (DBID = %d)", getPlayerAdminRank(playerid), getName(playerid), posId);
        }*/
        SFCM(playerid, COLOR_GREEN, "(( Töröltél egy szolgálati helyet! (DBID = %d) ))", posId);

        mysql_format(mysql_id, queryStr, sizeof(queryStr), "DELETE FROM positions WHERE dbid='%d'", posId);
        mysql_tquery(mysql_id, queryStr, "", "");

        clearPosition(posId);
    } else SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen pozició! ))");
}

clearPositionType(position_typeDBID) {
    ptypeInfo[position_typeDBID][ptypeExist] = false;
    ptypeInfo[position_typeDBID][ptypeDBID] = 0;
    format(ptypeInfo[position_typeDBID][ptypeName], 64, "REMOVED PTYPE");
}

clearPosition(positionDBID) {
    posInfo[positionDBID][posExist] = false;
    posInfo[positionDBID][posDBID] = 0;
    posInfo[positionDBID][posPos][0] = 0;
    posInfo[positionDBID][posPos][1] = 0;
    posInfo[positionDBID][posPos][2] = 0;
    posInfo[positionDBID][posRad] = 0.0;
    posInfo[positionDBID][posInt] = 0;
    posInfo[positionDBID][posVW] = 0;
    posInfo[positionDBID][posLF] = 0;
    format(posInfo[positionDBID][posComment], 64, "REMOVED POS");
    return 1;
}

isValidPosition(posdbid) {
    return posInfo[posdbid][posExist] ? true : false;
}
