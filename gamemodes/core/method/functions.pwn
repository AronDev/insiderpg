stock formatNumber(iNum, const szChar[] = ".")
{
    new
        szStr[16]
    ;
    format(szStr, sizeof(szStr), "%d", iNum);

    for(new iLen = strlen(szStr) - 3; iLen > 0; iLen -= 3)
    {
        strins(szStr, szChar, iLen);
    }
    return szStr;
}

IsHelicopter(modelid) {
	if(modelid == 417||modelid ==425||modelid ==447||modelid ==469||modelid ==487||modelid ==488||modelid ==497||modelid ==548||modelid ==563) return 1;
	else return 0;
}
IsAirplane(modelid) {
	if(modelid == 460||modelid ==476||modelid ==511||modelid ==512||modelid ==513||modelid ==519||modelid ==520||modelid ==553||modelid ==577||modelid ==592||modelid ==593) return 1;
	else return 0;
}
IsABoat(modelid) {
	if(modelid == 430 || modelid == 446 || modelid == 452 || modelid == 453 || modelid == 454 || modelid == 472 || modelid == 473 || modelid == 484 || modelid == 493 || modelid == 595) return 1;
	else return 0;
}

getWeaponIDFromName(const wname[]) {
    for(new i = 0; i < 211; i++) {
        if(!strfind(weaponNames[i], wname, true))
            return i;
    }
    return -1;
}

getWeaponSlot(weaponid) {
    new slot;
    switch(weaponid) {
        case 0,1: slot = 0;
        case 2 .. 9: slot = 1;
        case 10 .. 15: slot = 10;
        case 16 .. 18, 39: slot = 8;
        case 22 .. 24: slot =2;
        case 25 .. 27: slot = 3;
        case 28, 29, 32: slot = 4;
        case 30, 31: slot = 5;
        case 33, 34: slot = 6;
        case 35 .. 38: slot = 7;
        case 40: slot = 12;
        case 41 .. 43: slot = 9;
        case 44 .. 46: slot = 11;
    }
    return slot;
}
serverLog(logType, logStr[]) {
    new logName[][] = {
        {"commands"},
        {"connects"},
        {"inventory"},
        {"vinventory"},
        {"playerchat"},
        {"adminchat"}
    };

    new fileName[128];
    new dirPath[256];
    new fullPath[256];

    new year, month, day, hour, minute, second;
    getdate(year, month, day);
    gettime(hour, minute, second);

    if(logType < sizeof(logName)) {
        format(fileName, sizeof(fileName), "%s_%04d-%02d-%02d.log", logName[logType], year, month, day);
        format(dirPath, sizeof(dirPath), "scriptfiles/logs/%s", logName[logType]);
        format(fullPath, sizeof(fullPath), "%s/%s", dirPath, fileName);

        if(!dir_exists(dirPath)) dir_create(dirPath);
        if(!file_exists(fullPath)) file_create(fullPath);

        new fileEntry[256];
        format(fileEntry, sizeof(fileEntry), "[%02d:%02d:%02d] %s\n", hour, minute, second, logStr);
        file_write(fullPath, fileEntry);
    } else printf("[SERVER] invalid logType in serverLog (%d)", logType);
    return 1;
}

randomPlate(vehID) {
    new plate[32];
    new platestring[32];
    if(IsHelicopter(vehID) || IsAirplane(vehID)) {
	 	if(randint(0,1) == 1) {
            new randnumber[4];
            for(new i = 0; i < sizeof(randnumber); i++) {
                randnumber[i] = randint(0,9);
            }
            format(platestring, sizeof(platestring), "HA-%d%d%d%d", randnumber[0],randnumber[1],randnumber[2],randnumber[3]);
        } else {
            RandomString(plate, 4);
            format(platestring, sizeof(platestring), "HA-%s", plate);
        }
    } else if(IsABoat(vehID)) {
        new randnumber[5];
        for(new i = 0; i < sizeof(randnumber); i++) {
            randnumber[i] = randint(0,9);
        }
        format(platestring, sizeof(platestring), "H-%d%d%d%d%d", randnumber[0],randnumber[1],randnumber[2],randnumber[3],randnumber[4]);
	} else {
         RandomString(plate, 3);
         new randnumber[3];
         for(new i = 0; i < sizeof(randnumber); i++) {
             randnumber[i] = randint(0,9);
         }
         format(platestring, sizeof(platestring), "%s-%d%d%d", plate, randnumber[0],randnumber[1],randnumber[2]);
    }
    return platestring;
}

RandomString(strDest[], strLen = 10) {
       while(strLen--) {
           new ONE = 1;
           strDest[strLen] = ONE ? (random(26) + (random(2) ? 'A' : 'A')) : (random(10) + '0');
       }
       return 1;
}

function Float:GetDistanceBetweenPlayers(playerid,targetplayerid)
{
    new Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2;
    if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetplayerid)) {
        return -1.00;
    }
    GetPlayerPos(playerid,x1,y1,z1);
    GetPlayerPos(targetplayerid,x2,y2,z2);
    return floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
}

ReturnUser(text[], playerid = INVALID_PLAYER_ID)
{
	new pos = 0;
	while (text[pos] < 0x21) // Strip out leading spaces
	{
		if (text[pos] == 0) return INVALID_PLAYER_ID; // No passed text
		pos++;
	}
	new userid = INVALID_PLAYER_ID;
	if (IsNumeric(text[pos])) // Check whole passed string
	{
		// If they have a numeric name you have a problem (although names are checked on id failure)
		userid = strval(text[pos]);
		if (userid >=0 && userid < MAX_PLAYERS)
		{
			if(!IsPlayerConnected(userid))
			{
				/*if (playerid != INVALID_PLAYER_ID)
				{
					SendClientMessage(playerid, 0xFF0000AA, "User not connected");
				}*/
				userid = INVALID_PLAYER_ID;
			}
			else
			{
				return userid; // A player was found
			}
		}
		/*else
		{
			if (playerid != INVALID_PLAYER_ID)
			{
				SendClientMessage(playerid, 0xFF0000AA, "Invalid user ID");
			}
			userid = INVALID_PLAYER_ID;
		}
		return userid;*/
		// Removed for fallthrough code
	}
	// They entered [part of] a name or the id search failed (check names just incase)
	new len = strlen(text[pos]);
	new count = 0;
	new name[MAX_PLAYER_NAME];
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		if (IsPlayerConnected(i))
		{
			GetPlayerName(i, name, sizeof (name));
			if (strcmp(name, text[pos], true, len) == 0) // Check segment of name
			{
				if (len == strlen(name)) // Exact match
				{
					return i; // Return the exact player on an exact match
					// Otherwise if there are two players:
					// Me and MeYou any time you entered Me it would find both
					// And never be able to return just Me's id
				}
				else // Partial match
				{
					count++;
					userid = i;
				}
			}
		}
	}
	if (count != 1)
	{
		if (playerid != INVALID_PLAYER_ID)
		{
			if (count)
			{
				SendClientMessage(playerid, 0xFF0000AA, "Multiple users found, please narrow earch");
			}
			else
			{
				SendClientMessage(playerid, 0xFF0000AA, "No matching user found");
			}
		}
		userid = INVALID_PLAYER_ID;
	}
	return userid; // INVALID_USER_ID for bad return
}
IsNumeric(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}
strtok(string[],&idx,seperator = ' ')
{
	new ret[128], i = 0, len = strlen(string);
	while(string[idx] == seperator && idx < len) idx++;
	while(string[idx] != seperator && idx < len)
	{
	    ret[i] = string[idx];
	    i++;
		idx++;
	}
	while(string[idx] == seperator && idx < len) idx++;
	return ret;
}

isNumeric(const string[]) { // Thanks to KfirRP
    for (new i = 0, j = strlen(string); i < j; i++) {
        if (string[i] > '9' || string[i] < '0') return 0;
    }
    return 1;
}

/*
*
* Whitelist system
*
*/

function showPlayerWhitelistList(playerid) {
    if(cache_num_rows()) {
        new userName[MAX_PLAYER_NAME];
        new userDBID = -1;
        new timestamp[128];

        SCM(playerid, COLOR_WHITE, "(( |________________ Whitelist lista ________________| ))");
        for(new i = 0; i < cache_num_rows(); i++) {
            mysql_get_int(i, "userdbid", userDBID);
            mysql_get_string(i, "name", userName);
            mysql_get_string(i, "timestamp", timestamp);


            SFCM(playerid, COLOR_WHITE, "> {77cdff}%s{FFFFFF}(%d) - Hozzáadva: {77cdff}%s", userName, userDBID, timestamp);
        }
    } else {
        SCM(playerid, COLOR_ORANGE, "(( Üres a whitelist! ))");
    }
    return 1;
}

remUserFromWhitelist(playerid, const user[]) {
    if(isNumeric(user)) { // DBID
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT dbid, name FROM users WHERE dbid='%d'", strval(user)); // Check if is the user exist
        mysql_tquery(mysql_id, queryStr, "_remUserFromWhitelist", "d", playerid);
    } else { // Name
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT dbid, name FROM users WHERE name='%s'", user); // Check if is the user exist
        mysql_tquery(mysql_id, queryStr, "_remUserFromWhitelist", "d", playerid);
    }
    return 1;
}

function _remUserFromWhitelist(playerid) {
    if(cache_num_rows()) {
        new userdbid = -1;
        new username[MAX_PLAYER_NAME];
        mysql_get_int(0, "dbid", userdbid);
        mysql_get_string(0, "name", username);

        mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT userdbid FROM whitelist WHERE userdbid='%d'", userdbid);
        mysql_tquery(mysql_id, queryStr, "_remUserFromWhitelistCheck", "dds", playerid, userdbid, username);
    } else {
        SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen játékos! ))");
    }
    return 1;
}

function _remUserFromWhitelistCheck(playerid, userdbid, username[]) {
    if(cache_num_rows()) {
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "DELETE FROM whitelist WHERE userdbid='%d'", userdbid);
        mysql_tquery(mysql_id, queryStr, "", "");

        SFAM(6, COLOR_TOMATO, "*AdmCmd* %s %s törölte %s-t a whitelistbõl", getPlayerAdminRank(playerid), getName(playerid), username);
        SFCM(playerid, COLOR_GREEN, "(( Törölted %s-t a whitelistbõl! ))", username);
    } else {
        SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen játékos a whitelistben! ))");
    }
    return 1;
}

addUserToWhitelist(playerid, const user[]) {
    if(isNumeric(user)) { // DBID
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT dbid, name FROM users WHERE dbid='%d'", strval(user)); // Check if is the user exist
        mysql_tquery(mysql_id, queryStr, "_addUserToWhitelist", "d", playerid);
    } else { // Name
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT dbid, name FROM users WHERE name='%s'", user); // Check if is the user exist
        mysql_tquery(mysql_id, queryStr, "_addUserToWhitelist", "d", playerid);
    }
    return 1;
}
function _addUserToWhitelist(playerid) {
    if(cache_num_rows()) {
        new userdbid = -1;
        new username[MAX_PLAYER_NAME];
        mysql_get_int(0, "dbid", userdbid);
        mysql_get_string(0, "name", username);
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "INSERT INTO whitelist (userdbid) VALUES ('%d')", userdbid);
        mysql_tquery(mysql_id, queryStr, "", "");

        SFAM(6, COLOR_TOMATO, "*AdmCmd* %s %s hozzáadta %s-t a whitelisthez", getPlayerAdminRank(playerid), getName(playerid), username);
        SFCM(playerid, COLOR_GREEN, "(( Hozzáadtad %s-t a whitelisthez! ))", username);
    } else {
        SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen játékos! ))");
    }
    return 1;
}

//
