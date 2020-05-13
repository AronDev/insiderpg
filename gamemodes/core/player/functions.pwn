loadPlayerData(playerid, bool:spawn = false) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT * FROM users WHERE dbid='%d'", pInfo[playerid][pDBID]);
    mysql_tquery(mysql_id, queryStr, "q_loadPlayerData", "dd", playerid, spawn);
    return 1;
}
function q_loadPlayerData(playerid, bool:spawn) {
    if(cache_num_rows()) {
        mysql_get_int(0, "money", pInfo[playerid][pMoney]);
        mysql_get_int(0, "admin", pInfo[playerid][pAdmin]);
        mysql_get_int(0, "fraction", pInfo[playerid][pFraction]);
        mysql_get_int(0, "leader", pInfo[playerid][pLeader]);
        mysql_get_int(0, "rank", pInfo[playerid][pRank]);
        mysql_get_int(0, "division", pInfo[playerid][pDivision]);
        mysql_get_int(0, "job", pInfo[playerid][pJob]);
        mysql_get_int(0, "skin0", pInfo[playerid][pSkin][0]);
        mysql_get_int(0, "skin1", pInfo[playerid][pSkin][1]);
        mysql_get_int(0, "sex", pInfo[playerid][pSex]);
        mysql_get_int(0, "house", pInfo[playerid][pHouse]);
        mysql_get_float(0, "hp", pInfo[playerid][pHP]);
        mysql_get_float(0, "ap", pInfo[playerid][pAP]);

        if(spawn) {
            SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); // For automatic spawning after logging in.
            SpawnPlayer(playerid);
        }
    }
    return 1;
}

showNameForFriends(playerid) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT user1 FROM friends WHERE user2='%d'", pInfo[playerid][pDBID]);
    mysql_tquery(mysql_id, queryStr, "q_sNMFF", "d", playerid);
    return 1;
}

showFriendNamesForPlayer(playerid) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT user2 FROM friends WHERE user1='%d'", pInfo[playerid][pDBID]);
    mysql_tquery(mysql_id, queryStr, "q_sFNFP", "d", playerid);
    return 1;
}

function q_sFNFP(playerid) {
    new rows = cache_num_rows();
    if(rows) {
        new id = -1;
        for(new i = 0; i < rows; i++) {
            mysql_get_int(i, "user2", id);
            ShowPlayerNameTagForPlayer(playerid, getPlayerIDByDBID(id), true);
        }
    }
    return 1;
}

function q_sNMFF(playerid) {
    new rows = cache_num_rows();
    if(rows) {
        new id = -1;
        for(new i = 0; i < rows; i++) {
            mysql_get_int(i, "user1", id);
            ShowPlayerNameTagForPlayer(getPlayerIDByDBID(id), playerid, true);
        }
    }
    return 1;
}

getPlayerIDByDBID(playerDBID) {
    new playerID = -1;
    for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
        if(isValidPlayer(i)) {
            if(pInfo[i][pDBID] == playerDBID) {
                playerID = i;
                break;
            }
        }
    }
    return playerID;
}

Float:getDistanceBetweenPlayers(playerid,targetplayerid) {
    new Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2;
    if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetplayerid)) {
        return -1.00;
    }
    GetPlayerPos(playerid,x1,y1,z1);
    GetPlayerPos(targetplayerid,x2,y2,z2);
    return floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
}

getClosestPlayer(playerid) {
    new Float:dis, Float:dis2;
    new closestPlayer = -1;
    dis = 99999.99;
    for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
        if(isValidPlayer(i)) {
            if(i != playerid) {
                dis2 = GetDistanceBetweenPlayers(i, playerid);
                if(dis2 < dis && dis2 != -1.00) {
                    dis = dis2;
                    closestPlayer = i;
                }
            }
        }
    }
    return closestPlayer;
}

newFriend(playerid, targetid) { // playerid -> targetid
    doQuery("INSERT INTO friends (user1, user2) VALUES ('%d', '%d')", pInfo[playerid][pDBID], pInfo[targetid][pDBID]);

    if(isValidPlayer(playerid) && isValidPlayer(targetid)) ShowPlayerNameTagForPlayer(playerid, targetid, true);
}

_isPlayerIsFriend(playerid, targetid) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT user1 FROM friends WHERE user2='%d' AND user1='%d' LIMIT 1", pInfo[playerid][pDBID], pInfo[targetid][pDBID]);
    mysql_tquery(mysql_id, queryStr, "q_iPIF", "dd", playerid, targetid);
    return 1;
}
function q_iPIF(playerid, targetid) {
	if(cache_num_rows() == 1) {
		SetPVarInt(playerid, "isPlayerIsFriend", 1);
	} else SetPVarInt(playerid, "isPlayerIsFriend", 0);
	return 1;
}

isPlayerIsFriend(playerid, targetid) {
    if(isValidPlayer(playerid) && isValidPlayer(targetid)) {
        _isPlayerIsFriend(playerid, targetid);
    }
	return GetPVarInt(playerid, "isPlayerIsFriend") == 1 ? true : false;
}
//

vehicleEngine(playerid) {
    if(IsPlayerInAnyVehicle(playerid)) {
        new vehicleID = GetPlayerVehicleID(playerid);
        new vehicleDBID = getVehicleDBIDFromID(vehicleID);
        if(vInfo[vehicleDBID][vEngine]) {
            vInfo[vehicleDBID][vEngine] = false;
            new engine, lights, alarm, doors, bonnet, boot, objective;
        	GetVehicleParamsEx(vInfo[vehicleDBID][vID], engine, lights, alarm, doors, bonnet, boot, objective);
        	SetVehicleParamsEx(vInfo[vehicleDBID][vID], 0, lights, alarm, doors, bonnet, boot, objective);
            PC_EmulateCommand(playerid, "/me leállította a jármû motorját");
            showPlayerFooter(playerid, "Jarmu ~rg~leallitva", 3000);
        } else {
            if(vInfo[vehicleDBID][vFraction] == pInfo[playerid][pFraction] || vInfo[vehicleDBID][vFraction] == 0 || pInfo[playerid][P_TEMP][TEMP_ADUTY]) {
                if(!vInfo[vehicleDBID][isEngineStarting]) {
                    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT COUNT((SELECT inventory.param1 FROM inventory WHERE inventory.userdbid='%d' AND inventory.itemdbid='2' AND inventory.param1='%d')) as invCount, COUNT((SELECT vehicle_glove_comp.param1 FROM vehicle_glove_comp WHERE vehicle_glove_comp.vehicledbid='%d' AND vehicle_glove_comp.itemdbid='2' AND vehicle_glove_comp.param1='%d')) as gcompCount", pInfo[playerid][pDBID], vehicleDBID, vehicleDBID, vehicleDBID);
                    mysql_tquery(mysql_id, queryStr, "startVehicleEngine", "dd", playerid, vehicleDBID);
                } else SCM(playerid, COLOR_ORANGE, "(( Már indítod! ))");
            } else SCM(playerid, COLOR_DARKRED, "(( Frakció jármûvet nem vihetsz el! ))");
        }
    }
    return 1;
}

function startVehicleEngine(playerid, vehicleDBID) {
    new invCount = 0, gcompCount = 0;
    if(cache_num_rows()) {
        mysql_get_int(0, "invCount", invCount);
        mysql_get_int(0, "gcompCount", gcompCount);
        if(invCount > 0 || gcompCount > 0) {
            vInfo[vehicleDBID][isEngineStarting] = true;
            GetVehicleHealth(vInfo[vehicleDBID][vID], vInfo[vehicleDBID][vHP]);
            new Float:vehHP = vInfo[vehicleDBID][vHP];
            new startTime = 1000;
            new bool:success = false;
            new rnd = 0;
            switch(floatround(vehHP)) {
                case 0..300: {
                    startTime = 5000;
                    success = false;
                } case 301..390: {
                    startTime = 4000;
                    rnd = randint(0,2);
                    if(rnd == 1) success = true;
                }  case 391..550: {
                    startTime = 3000;
                    rnd = randint(0,2);
                    if(rnd == 1) success = true;
                } case 551..650: {
                    startTime = 2000;
                    rnd = randint(0,1);
                    if(rnd == 1) success = true;
                } case 651..2000: {
                    startTime = 1000;
                    success = true;
                } default: {
                    startTime = 1000;
                    success = true;
                }
            }
            showPlayerFooter(playerid, "Inditas..", startTime);
            defer tDelayedVehicleStart[startTime](playerid, vehicleDBID, bool:success);
        } else {
            SCM(playerid, COLOR_ORANGE, "(( Ehhez a jármûhöz nincs kulcsod! ))");
            return 0;
        }
    }
    return 1;
}

timer tDelayedVehicleStart[1000](playerid, vehicleDBID, bool:success) {
    vInfo[vehicleDBID][isEngineStarting] = false;

    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vInfo[vehicleDBID][vID], engine, lights, alarm, doors, bonnet, boot, objective);

    if(success) {
        vInfo[vehicleDBID][vEngine] = true;
        SetVehicleParamsEx(vInfo[vehicleDBID][vID], 1, lights, alarm, doors, bonnet, boot, objective);
        PC_EmulateCommand(playerid, "/me elindította a jármû motorját");
        showPlayerFooter(playerid, "Jarmu ~g~elinditva", 3000);
    } else {
        SCM(playerid, COLOR_DARKRED, "(( A jármû lefulladt! ))");
    }
    return 1;
}

timePlayerFreeze(playerid, time = 500) {
    if(time != 0) {
        if(pInfo[playerid][P_TIMERS][2]) {
    		stop pInfo[playerid][P_TIMERS][2];
    	}

        GameTextForPlayer(playerid, "~w~Töltés..", time, 3);
        TogglePlayerControllable(playerid, 0);
        pInfo[playerid][P_TIMERS][2] = defer tTimePlayerFreeze[time](playerid);

        if(pInfo[playerid][P_TEMP][15]) SFCM(playerid, -1, "[DEBUG] Timer started -> ID = pInfo[playerid][P_TIMERS][2] (timePlayerFreeze(%d, %d))", playerid, time);
    }
    return 1;
}
timer tTimePlayerFreeze[500](playerid) {
    TogglePlayerControllable(playerid, 1);
    SetCameraBehindPlayer(playerid);
    if(pInfo[playerid][P_TEMP][15]) SCM(playerid, -1, "[DEBUG] Timer stopped -> ID = pInfo[playerid][P_TIMERS][2]");
    return 1;
}

playerIC(playerid, icStr[]) {
    if(!pInfo[playerid][P_TEMP][TEMP_ADUTY]) { // If the player is in aduty
        new Float:pPos[3];
        GetPlayerPos(playerid, PosEx(pPos));
        SetPlayerChatBubble(playerid, icStr, COLOR_WHITE, 15.0, 8000);
        SFCM(playerid, COLOR_WHITE, "Te mondod: %s", icStr);
        for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
            if(isValidPlayer(i)) {
                if(PlayerToPoint(i, 15.0, PosEx(pPos)) && !pInfo[i][P_TEMP][10]) {
                    if(i != playerid) {
                        if(isPlayerIsFriend(playerid, i) || pInfo[i][P_TEMP][TEMP_ADUTY]) {
                            SFCM(i, COLOR_WHITE, "%s mondja: %s", getName(playerid), icStr);
                        } else {
                            SFCM(i, COLOR_WHITE, "Valaki mondja: %s", icStr);
                        }
                    }
                } else if(pInfo[i][P_TEMP][10]) {
                    SFCM(i, COLOR_YELLOW, "*BigEar*{FFFFFF} %s mondja: %s", getName(playerid), icStr);
                }
            }
        }
    } else {
        playerOOC(playerid, icStr);
    }

    // serverLog
    serverLogFormatted(4, "%s mondja: %s", getRawName(playerid), icStr);
    return 1;
}
playerOOC(playerid, oocStr[]) {
    new formatStr[128];
    if(!pInfo[playerid][P_TEMP][TEMP_ADUTY]) {
        format(formatStr, sizeof(formatStr), "(( [%d] %s: %s ))", playerid, getName(playerid), oocStr);
        Prox(playerid, 20.0, formatStr, COLOR_GRAY);
        printf("[Chat] (( %s OOC: %s ))", getName(playerid), oocStr);
    } else {
        format(formatStr, sizeof(formatStr),"(( {%s}%s{FFFFFF} %s: %s ))", getPlayerAdminColor(playerid), getPlayerAdminRank(playerid), getName(playerid), oocStr);
        Prox(playerid, 20, formatStr, COLOR_WHITE);
        printf("[Chat] (( %s %s OOC: %s ))", getPlayerAdminRank(playerid), getName(playerid), oocStr);
    }
    // serverLog
    serverLogFormatted(4, "(( %s OOC: %s ))", getRawName(playerid), oocStr);
    return 1;
}
playerMe(playerid, meStr[]) {
    new Float:pPos[3];
    GetPlayerPos(playerid, PosEx(pPos));
    SFCM(playerid, COLOR_PURPLE, "* %s %s", getName(playerid), meStr);
    for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
        if(isValidPlayer(i)) {
            if(PlayerToPoint(i, 15.0, PosEx(pPos)) && !pInfo[i][P_TEMP][10]) {
                if(i != playerid) {
                    if(isPlayerIsFriend(playerid, i) || pInfo[i][P_TEMP][TEMP_ADUTY]) {
                        SFCM(i, COLOR_PURPLE, "* %s %s", getName(playerid), meStr);
                    } else {
                        SFCM(i, COLOR_PURPLE, "* Valaki %s", meStr);
                    }
                }
            }
        }
    }

    new resultstring[128];
    format(resultstring, sizeof(resultstring), "%s", meStr);
    SetPlayerChatBubble(playerid, resultstring, COLOR_PURPLE, 15.0, 8000);

    // serverLog
    serverLogFormatted(4, "* %s %s", getRawName(playerid), meStr);
    return 1;
}
playerDo(playerid, doStr[]) {
    new formatString[128];
    format(formatString, sizeof(formatString), "*** %s", doStr);
    Prox(playerid, 15.0, formatString, COLOR_PURPLE3);

    new resultstring[128];
    format(resultstring, sizeof(resultstring), "%s", doStr);
    SetPlayerChatBubble(playerid, resultstring, COLOR_PURPLE3, 15.0, 8000);

    // serverLog
    serverLogFormatted(4, "(%s)*** %s", getRawName(playerid), doStr);
    return 1;
}

getName(playerid) {
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	for(new i = 0; i < MAX_PLAYER_NAME; i++) {
		if(name[i] == '_') {
			name[i] = ' ';
		}
	}
	return name;
}

getPlayerAdminColor(playerid) {
    new adminlevelColor[16];
	format(adminlevelColor, sizeof(adminlevelColor), "%s", alInfo[pInfo[playerid][pAdmin]][alColor]);
	return adminlevelColor;
}

getPlayerAdminRank(playerid) {
	new adminlevelName[32];
	format(adminlevelName, sizeof(adminlevelName), "%s", alInfo[pInfo[playerid][pAdmin]][alName]);
	return adminlevelName;
}

getPlayerAdminPermission(playerid) {
	return alInfo[pInfo[playerid][pAdmin]][alPerm];
}

sendFractionMsg(const fractionDBID, const color, const msg[], bool:onduty = true, bool:sound = false, bool:radio = false) {
    for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
        if(isValidPlayer(i)) {
            if(pInfo[i][pFraction] == fractionDBID) {
                mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT amount FROM inventory WHERE inventory.itemdbid='1' AND inventory.userdbid='%d' LIMIT 1", pInfo[i][pDBID]);
                inline q_sendFrMsg(msgStr[]) {
                    new pRadioCount = 0;
                    if(cache_num_rows()) {
                        mysql_get_int(0, "amount", pRadioCount);
                        if(onduty) {
                            if(pInfo[i][P_TEMP][6]) {
                                if(sound) PlayerPlaySound(i, 1058, 0.0, 0.0, 0.0);
                                if(radio) {
                                    if(pRadioCount > 0) SCM(i, color, msgStr);
                                } else SCM(i, color, msgStr);
                            }
                        } else {
                            if(!pInfo[i][P_TEMP][6]) {
                                if(sound) PlayerPlaySound(i, 1058, 0.0, 0.0, 0.0);
                                if(radio) {
                                    if(pRadioCount > 0) SCM(i, color, msgStr);
                                } else SCM(i, color, msgStr);
                            }
                        }
                    }
                }
                mysql_tquery_inline(mysql_id, queryStr, using inline q_sendFrMsg, "s", msg);
            }
        }
    }
}

acceptCall(playerid, callID) {
    if(callID != -1) {
        if(cInfo[callID][cExist]) {
            SetPlayerCheckpoint(playerid, PosEx(cInfo[callID][cPos]), 3.0);
            new msgStr[128];
            format(msgStr, sizeof(msgStr), "** %s elfogadta a(z) %d számú hívást", getName(playerid), callID);
            sendFractionMsg(fInfo[pInfo[playerid][pFraction]][fType], COLOR_CYAN, msgStr, true);
            SFCM(playerid, COLOR_GREEN, "(( Elfogadtak a(z) %d-s segélykérést! ))", callID);
        } else SCM(playerid, COLOR_ORANGE, "(( Nem létezik ilyen segélykérés! ))");
    } else acceptCall(playerid, getLatestCall());
}

joinReportChannel(playerid, reportDBID) {
    pInfo[playerid][pSelectedReportCat] = reportDBID;
    return 1;
}
sendMsgInCategory(playerid, cat, const msg[]) {
    if(rInfo[cat][rExist]) {
        for(new i = 0, j = GetPlayerPoolSize()+1; i < j; i++) {
            if(isValidPlayer(i)) {
                // Ha a választott kategória (cat) megegyezik az admin kiválasztott kategóriájával vagy az admin mindenes kateg.-ban van
                // Vészhelyzetet minden adminnak elküldi bármely kateg.-ban van
                // AFK-ban lévő adminok semmit nem kapnak meg
                if(rInfo[pInfo[i][pSelectedReportCat]][rType] != 2) {
                    if((pInfo[i][pSelectedReportCat] == cat || rInfo[pInfo[i][pSelectedReportCat]][rType] == 3)  && rInfo[cat][rType] == 0) { // Normal text category
                        SFCM(i, -1, "{%s}*REPORT* *%s* %s[%d]: %s", rInfo[cat][rColor], rInfo[cat][rSName], getName(playerid), playerid, msg);
                    }
                    if(rInfo[cat][rType] == 1) { // Emergency category
                        SFCM(i, -1, "{%s}*%s* %s[%d] VÉSZHELYZETBEN VAN!", rInfo[cat][rColor], rInfo[cat][rSName], getName(playerid), playerid);
                    }
                }
            }
        }
    } else SCM(playerid, COLOR_DARKRED, "(( Hiba történt a jelentés elküldése közben! ))");
}


function showPlayerKeys(playerid) {
    new rows;
    rows = cache_get_row_count();
    if(rows) {
        new vehicleDBID = -1, vehicleModel = -1;
        new dialog[1024] = "{FFFFFF}Rendszám\t{FFFFFF}Megnevezés\n";
        new string[128];
        for(new i = 0; i < rows; i++) {
            mysql_get_int(i, "param1", vehicleDBID);
            mysql_get_int(i, "model", vehicleModel);

            format(string, sizeof(string), "%s\t%s\n", vInfo[vehicleDBID][vPlate], vehicleNames[vehicleModel-400]);
            strcat(dialog, string);
        }
        ShowPlayerDialog(playerid, DIALOG_KEYS, DIALOG_STYLE_TABLIST_HEADERS, "[ {77abff}Jármûkulcsok{FFFFFF} ]", dialog, "Mehet", "Mégse");
    } else SCM(playerid, COLOR_ORANGE, "(( Nincs egy jármûkulcsod se! ))");
    return 1;
}

function onPlayerInventoryItemSelect(playerid) {
	if(cache_num_rows()) {
		new itemName[64];
		new itemAmount = 0;
		new itemParam1 = -1;
		new itemDBID = -1;
		mysql_get_string(0, "name", itemName);
		mysql_get_int(0, "amount", itemAmount);
		mysql_get_int(0, "param1", itemParam1);
		mysql_get_int(0, "itemdbid", itemDBID);

		SetPVarString(playerid, "inv_selected_name", itemName);
		SetPVarInt(playerid, "inv_selected_amount", itemAmount);
		SetPVarInt(playerid, "inv_selected_param1", itemParam1);
		SetPVarInt(playerid, "inv_selected_itemdbid", itemDBID);

		new dialogTitle[64];
		format(dialogTitle, sizeof(dialogTitle), "[ {77abff}%s{FFFFFF} ]", itemName);
        ShowPlayerDialog(playerid, DIALOG_INVENTORY_ITEM, DIALOG_STYLE_LIST, dialogTitle, "Használat\nÁtadás\nEldobás", "Mehet", "Mégse");
	}
	return 1;
}

function onPlayerInventoryGCompItemSel(playerid) { // When the player select an item in /kesztyutarto berak
    if(cache_num_rows()) {
		new itemName[64];
		new itemAmount = 0;
		new itemParam1 = -1;
		new itemDBID = -1;
		mysql_get_string(0, "name", itemName);
		mysql_get_int(0, "amount", itemAmount);
		mysql_get_int(0, "param1", itemParam1);
		mysql_get_int(0, "itemdbid", itemDBID);

		SetPVarString(playerid, "invgcomp_selected_name", itemName);
		SetPVarInt(playerid, "invgcomp_selected_amount", itemAmount);
		SetPVarInt(playerid, "invgcomp_selected_param1", itemParam1);
		SetPVarInt(playerid, "invgcomp_selected_itemdbid", itemDBID);

		new dialogTitle[64];
		format(dialogTitle, sizeof(dialogTitle), "[ {77abff}%s{FFFFFF} berakása ]", itemName);
		new dialogStr[256];
		if(itemParam1 == -1) format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg mennyi {77cdff}%s{ffffff}-t szeretnél berakni (van nálad %d db)!", itemName, itemAmount);
		else format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg mennyi {77cdff}%s{ffffff}(%s)-t szeretnél berakni (van nálad %d db)!", itemName, getVehiclePlateByDBID(itemParam1), itemAmount);
		ShowPlayerDialog(playerid, DIALOG_INVENTORY_GCOMP_ITEM, DIALOG_STYLE_INPUT, dialogTitle, dialogStr, "Berak", "Mégse");
	}
    return 1;
}

function onPlayerInventoryTrunkItemSel(playerid) { // When the player select an item in /csomagtarto berak
    if(cache_num_rows()) {
		new itemName[64];
		new itemAmount = 0;
		new itemParam1 = -1;
		new itemDBID = -1;
		mysql_get_string(0, "name", itemName);
		mysql_get_int(0, "amount", itemAmount);
		mysql_get_int(0, "param1", itemParam1);
		mysql_get_int(0, "itemdbid", itemDBID);

		SetPVarString(playerid, "invtrunk_selected_name", itemName);
		SetPVarInt(playerid, "invtrunk_selected_amount", itemAmount);
		SetPVarInt(playerid, "invtrunk_selected_param1", itemParam1);
		SetPVarInt(playerid, "invtrunk_selected_itemdbid", itemDBID);

		new dialogTitle[64];
		format(dialogTitle, sizeof(dialogTitle), "[ {77abff}%s{FFFFFF} berakása ]", itemName);
		new dialogStr[256];
		if(itemParam1 == -1) format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg mennyi {77cdff}%s{ffffff}-t szeretnél berakni (van nálad %d db)!", itemName, itemAmount);
		else format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg mennyi {77cdff}%s{ffffff}(%s)-t szeretnél berakni (van nálad %d db)!", itemName, getVehiclePlateByDBID(itemParam1), itemAmount);
		ShowPlayerDialog(playerid, DIALOG_INVENTORY_TRUNK_ITEM, DIALOG_STYLE_INPUT, dialogTitle, dialogStr, "Berak", "Mégse");
	}
    return 1;
}

function onVehicleGCompItemSelect(playerid) { // When the player select an item in /kesztyutarto tartalom
	if(cache_num_rows()) {
		new itemName[64];
		new itemAmount = 0;
		new itemParam1 = -1;
		new itemDBID = -1;
		mysql_get_string(0, "name", itemName);
		mysql_get_int(0, "amount", itemAmount);
		mysql_get_int(0, "param1", itemParam1);
		mysql_get_int(0, "itemdbid", itemDBID);

        if(vInfo[itemParam1][vFraction] == 0 || getPlayerAdminPermission(playerid) >= 2 || strval(getPlayerInfo(playerid, "leader")) == 1) {
            SetPVarString(playerid, "gcomp_selected_name", itemName);
    		SetPVarInt(playerid, "gcomp_selected_amount", itemAmount);
    		SetPVarInt(playerid, "gcomp_selected_param1", itemParam1);
    		SetPVarInt(playerid, "gcomp_selected_itemdbid", itemDBID);

    		new dialogTitle[64];
    		format(dialogTitle, sizeof(dialogTitle), "[ {77abff}%s{FFFFFF} kivétele ]", itemName);
    		new dialogStr[256];
    		if(itemParam1 == -1) format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg mennyi {77cdff}%s{ffffff}-t szeretnél kivenni (van bent %d db)!", itemName, itemAmount);
    		else format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg mennyi {77cdff}%s{ffffff}(%s)-t szeretnél kivenni (van bent %d db)!", itemName, getVehiclePlateByDBID(itemParam1), itemAmount);
    		ShowPlayerDialog(playerid, DIALOG_GCOMP_ITEM, DIALOG_STYLE_INPUT, dialogTitle, dialogStr, "Kivesz", "Mégse");
        } else SCM(playerid, COLOR_DARKRED, "(( Frakció jármûbõl nem veheted ki a kulcsot! ))");
	}
	return 1;
}

function onVehicleTrunkItemSelect(playerid) { // When the player select an item in /csomagtarto tartalom
	if(cache_num_rows()) {
		new itemName[64];
		new itemAmount = 0;
		new itemParam1 = -1;
		new itemDBID = -1;
		mysql_get_string(0, "name", itemName);
		mysql_get_int(0, "amount", itemAmount);
		mysql_get_int(0, "param1", itemParam1);
		mysql_get_int(0, "itemdbid", itemDBID);

		SetPVarString(playerid, "trunk_selected_name", itemName);
		SetPVarInt(playerid, "trunk_selected_amount", itemAmount);
		SetPVarInt(playerid, "trunk_selected_param1", itemParam1);
		SetPVarInt(playerid, "trunk_selected_itemdbid", itemDBID);

		new dialogTitle[64];
		format(dialogTitle, sizeof(dialogTitle), "[ {77abff}%s{FFFFFF} kivétele ]", itemName);
		new dialogStr[256];
		if(itemParam1 == -1) format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg mennyi {77cdff}%s{ffffff}-t szeretnél kivenni (van bent %d db)!", itemName, itemAmount);
		else format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg mennyi {77cdff}%s{ffffff}(%s)-t szeretnél kivenni (van bent %d db)!", itemName, getVehiclePlateByDBID(itemParam1), itemAmount);
		ShowPlayerDialog(playerid, DIALOG_TRUNK_ITEM, DIALOG_STYLE_INPUT, dialogTitle, dialogStr, "Kivesz", "Mégse");
	}
	return 1;
}

function showPlayerInventoryForPutGComp(playerid, vehicleDBID) {
    new rows = cache_num_rows();
    if(rows) {
        new itemName[64], itemAmount, itemParam1;
        new dialog[1024] = "{FFFFFF}Tárgy neve\t{FFFFFF}Mennyiség\t{FFFFFF}Egyéb\n";
        new string[128];
        for(new i = 0; i < rows; i++) {
            mysql_get_string(i, "name", itemName);
            mysql_get_int(i, "amount", itemAmount);
            mysql_get_int(i, "param1", itemParam1);

            SetPVarInt(playerid, "invgcomp_vehicledbid", vehicleDBID);

            format(string, sizeof(string), "%s\t%d\t%s\n", itemName, itemAmount, getVehiclePlateByDBID(itemParam1));
            strcat(dialog, string);
        }
        ShowPlayerDialog(playerid, DIALOG_INVENTORY_GCOMP, DIALOG_STYLE_TABLIST_HEADERS, "[ {77abff}Táskád tartalma{FFFFFF} ]", dialog, "Berak", "Mégse");
    } else SCM(playerid, COLOR_ORANGE, "(( Üres a táskád! ))");
    return 1;
}

function showPlayerInventoryForPutTrunk(playerid, vehicleDBID) {
    new rows = cache_num_rows();
    if(rows) {
        new itemName[64], itemAmount, itemParam1;
        new dialog[1024] = "{FFFFFF}Tárgy neve\t{FFFFFF}Mennyiség\t{FFFFFF}Egyéb\n";
        new string[128];
        for(new i = 0; i < rows; i++) {
            mysql_get_string(i, "name", itemName);
            mysql_get_int(i, "amount", itemAmount);
            mysql_get_int(i, "param1", itemParam1);

            SetPVarInt(playerid, "invtrunk_vehicledbid", vehicleDBID);

            format(string, sizeof(string), "%s\t%d\t%s\n", itemName, itemAmount, getVehiclePlateByDBID(itemParam1));
            strcat(dialog, string);
        }
        ShowPlayerDialog(playerid, DIALOG_INVENTORY_TRUNK, DIALOG_STYLE_TABLIST_HEADERS, "[ {77abff}Táskád tartalma{FFFFFF} ]", dialog, "Berak", "Mégse");
    } else SCM(playerid, COLOR_ORANGE, "(( Üres a táskád! ))");
    return 1;
}

function showPlayerInventory(playerid) {
    new rows = cache_num_rows();
    if(rows) {
        new itemName[64], itemAmount, itemParam1;
        new dialog[1024] = "{FFFFFF}Tárgy neve\t{FFFFFF}Mennyiség\t{FFFFFF}Egyéb\n";
        new string[128];
        for(new i = 0; i < rows; i++) {
            mysql_get_string(i, "name", itemName);
            mysql_get_int(i, "amount", itemAmount);
            mysql_get_int(i, "param1", itemParam1);

            format(string, sizeof(string), "%s\t%d\t%s\n", itemName, itemAmount, getVehiclePlateByDBID(itemParam1));
            strcat(dialog, string);
        }
        ShowPlayerDialog(playerid, DIALOG_INVENTORY, DIALOG_STYLE_TABLIST_HEADERS, "[ {77abff}Táskád tartalma{FFFFFF} ]", dialog, "Mehet", "Mégse");
    } else SCM(playerid, COLOR_ORANGE, "(( Üres a táskád! ))");
    return 1;
}

// Footer
showPlayerFooter(playerid, string[], time = 5000) {
	if(pInfo[playerid][P_TEMP][1]) {
	    PlayerTextDrawHide(playerid, pInfo[playerid][P_TEXTDRAWS][1]);
		stop pInfo[playerid][P_TIMERS][1];
	}
	PlayerTextDrawSetString(playerid, pInfo[playerid][P_TEXTDRAWS][1], string);
	PlayerTextDrawShow(playerid, pInfo[playerid][P_TEXTDRAWS][1]);

	pInfo[playerid][P_TEMP][1] = true;
	pInfo[playerid][P_TIMERS][1] = defer t_hidePlayerFooter[time](playerid);
}

timer t_hidePlayerFooter[5000](playerid) {
	if(!pInfo[playerid][P_TEMP][1]) return 0;
	pInfo[playerid][P_TEMP][1] = false;
	return PlayerTextDrawHide(playerid, pInfo[playerid][P_TEXTDRAWS][1]);
}

// HintBox
showPlayerHint(playerid, string[], time = 5000) {
	if(pInfo[playerid][P_TEMP][0]) {
	    PlayerTextDrawHide(playerid, pInfo[playerid][P_TEXTDRAWS][0]);
		stop pInfo[playerid][P_TIMERS][0];
	}
	PlayerTextDrawSetString(playerid, pInfo[playerid][P_TEXTDRAWS][0], string);
	PlayerTextDrawShow(playerid, pInfo[playerid][P_TEXTDRAWS][0]);

	pInfo[playerid][P_TEMP][0] = true;
	pInfo[playerid][P_TIMERS][0] = defer t_hidePlayerHint[time](playerid);
}

timer t_hidePlayerHint[5000](playerid) {
	if(!pInfo[playerid][P_TEMP][0]) return 0;
	pInfo[playerid][P_TEMP][0] = false;
	return PlayerTextDrawHide(playerid, pInfo[playerid][P_TEXTDRAWS][0]);
}

stock Prox(playerid,Float:rad,string[],color)
{
    if(IsPlayerConnected(playerid))
    {
        new Float:x,Float:y,Float:z;
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetPlayerPos(playerid,oldposx,oldposy,oldposz);
        for(new i = 0; i <= GetPlayerPoolSize()+1; i++)
        {
            if(IsPlayerConnected(i))
            {
                if(!pInfo[i][P_TEMP][10])
                {
	                if(GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
	                {
						GetPlayerPos(i,x,y,z);
						tempposx = (oldposx - x);
	                    tempposy = (oldposy - y);
	                    tempposz = (oldposz - z);
	                    if (((tempposx < rad) && (tempposx > -rad)) && ((tempposy < rad) && (tempposy > -rad)) && ((tempposz < rad) && (tempposz > -rad)))
	                    {
                            SCM(i, color, string);
	                    }
	                }
				}
				else
				{
                    SFCM(i, COLOR_YELLOW, "*BigEar* {%06x}%s", color >>> 8, string);
				}
			}
		}
    }
    return 1;
}

createTextDraws(playerid) {
    // HintBox
    pInfo[playerid][P_TEXTDRAWS][0] = CreatePlayerTextDraw(playerid, 10.333333, 222.755432, "This is the ~y~hint~w~ box.");
	PlayerTextDrawLetterSize(playerid, pInfo[playerid][P_TEXTDRAWS][0], 0.194665, 1.023406);
	PlayerTextDrawTextSize(playerid, pInfo[playerid][P_TEXTDRAWS][0], 122.999923, 9.125933);
	PlayerTextDrawAlignment(playerid, pInfo[playerid][P_TEXTDRAWS][0], 1);
	PlayerTextDrawColor(playerid, pInfo[playerid][P_TEXTDRAWS][0], -1);
	PlayerTextDrawUseBox(playerid, pInfo[playerid][P_TEXTDRAWS][0], true);
	PlayerTextDrawBoxColor(playerid, pInfo[playerid][P_TEXTDRAWS][0], 100);
	PlayerTextDrawSetShadow(playerid, pInfo[playerid][P_TEXTDRAWS][0], 0);
	PlayerTextDrawSetOutline(playerid, pInfo[playerid][P_TEXTDRAWS][0], 0);
	PlayerTextDrawBackgroundColor(playerid, pInfo[playerid][P_TEXTDRAWS][0], 255);
	PlayerTextDrawFont(playerid, pInfo[playerid][P_TEXTDRAWS][0], 1);
	PlayerTextDrawSetProportional(playerid, pInfo[playerid][P_TEXTDRAWS][0], 1);
	PlayerTextDrawSetSelectable(playerid, pInfo[playerid][P_TEXTDRAWS][0], 0);

    // Footer
    pInfo[playerid][P_TEXTDRAWS][1] = CreatePlayerTextDraw(playerid, 320.000000, 420.207427, "Footer text");
	PlayerTextDrawLetterSize(playerid, pInfo[playerid][P_TEXTDRAWS][1], 0.380997, 1.463109);
	PlayerTextDrawAlignment(playerid, pInfo[playerid][P_TEXTDRAWS][1], 2);
	PlayerTextDrawColor(playerid, pInfo[playerid][P_TEXTDRAWS][1], -1);
	PlayerTextDrawSetShadow(playerid, pInfo[playerid][P_TEXTDRAWS][1], 2);
	PlayerTextDrawSetOutline(playerid, pInfo[playerid][P_TEXTDRAWS][1], 0);
	PlayerTextDrawBackgroundColor(playerid, pInfo[playerid][P_TEXTDRAWS][1], 51);
	PlayerTextDrawFont(playerid, pInfo[playerid][P_TEXTDRAWS][1], 1);
	PlayerTextDrawSetProportional(playerid, pInfo[playerid][P_TEXTDRAWS][1], 1);
	PlayerTextDrawSetSelectable(playerid, pInfo[playerid][P_TEXTDRAWS][1], 0);
}

function query_showPlayerLogDialog(playerid, id) {
    if(cache_num_rows()) {
        new dialogStr[1024] = "{FFFFFF}Log típusa\t{FFFFFF}Log\t{FFFFFF}Idõpont\n";
        new rowStr[256];

        new type[12];
        new log[255];
        new timestamp[32];

        for(new i = 0; i < cache_num_rows(); i++) {
            mysql_get_string(i, "type", type);
            mysql_get_string(i, "log", log);
            mysql_get_string(i, "timestamp", timestamp);

            format(rowStr, sizeof(rowStr), "%s\t%s\t%s\n", type, log, timestamp);
            strcat(dialogStr, rowStr);
        }
        new dialogTitle[128];
        format(dialogTitle, sizeof(dialogTitle), "[ {77abff}%s logja{FFFFFF} ]", getName(id));
        ShowPlayerDialog(playerid, DIALOG_PLAYERLOG, DIALOG_STYLE_TABLIST_HEADERS, dialogTitle, dialogStr, "Bezár", "");
    } else SCM(playerid, COLOR_ORANGE, "(( Nincs találat! ))");
    return 1;
}

/*
*
* Skinchanger System functions
*
*/

moveSkinChangerIndex(playerid, index) {
    if(pInfo[playerid][P_TEMP][9]) {
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT skinid FROM fraction_skins WHERE fractiondbid='%d' AND gender='%d'", strval(getPlayerInfo(playerid, "fraction")), strval(getPlayerInfo(playerid, "sex")));
        new Cache:result = mysql_query(mysql_id, queryStr);

        new rows = cache_num_rows();

        new current_index = GetPVarInt(playerid, "skinchanger_current_index");

        new skinArray[MAX_SKINS_PER_FRACTION];

        if(rows) {
            // Putting skins into array
            for(new i = 0; i < rows; i++) {
                mysql_get_int(i, "skinid", skinArray[i]);
            }
            cache_delete(result);

            // Checking the index and set preview skin for the player
            if(index == -1) { // go backward
                if(current_index - 1 < 0) current_index = rows-1;
	            else current_index--;
            } else if(index == 1) { // go forward
                if(current_index + 1 >= rows) current_index = 0;
            	else current_index++;
            }
        	SetPlayerSkin(playerid, skinArray[current_index]);
            SetPVarInt(playerid, "skinchanger_current_index", current_index);
        } else {
            SCM(playerid, COLOR_DARKRED, "(( A frakciónak nincsenek munkaruhái! ))");
            onSkinChangerFinish(playerid, -1);
        }
    }
}

setPlayerInSatellite(playerid) {
    // Save player current location
    new Float:pPos[3], interior, vw;
	GetPlayerPos(playerid, PosEx(pPos));
    interior = GetPlayerInterior(playerid);
    vw = GetPlayerVirtualWorld(playerid);
	SetPVarFloat(playerid, "satellite_posx", pPos[0]);
 	SetPVarFloat(playerid, "satellite_posy", pPos[1]);
 	SetPVarFloat(playerid, "satellite_posz", pPos[2]);
    SetPVarInt(playerid, "satellite_interior", interior);
    SetPVarInt(playerid, "satellite_vw", vw);
    TogglePlayerControllable(playerid, 0);
    SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
    pInfo[playerid][P_TEMP][11] = true;

    SetPVarFloat(playerid, "satellite_cam_posx", 0);
    SetPVarFloat(playerid, "satellite_cam_posy", 0);
    SetPVarFloat(playerid, "satellite_cam_posz", 250);
	SetPlayerCameraPos(playerid, 0, 0, 250.0000);
	SetPlayerCameraLookAt(playerid, 0, 0, 0.0000);

    showPlayerHint(playerid, "~w~Hasznald a ~y~W~w~, ~y~A~w~, ~y~S~w~, ~y~D~w~ gombot az elore es hatra mozgashoz. Le es fel a ~y~~k~~PED_DUCK~~w~-vel es a ~y~~k~~PED_JUMPING~~w~-vel tudsz.", 8000);
    return 1;
}
finishPlayerSatellite(playerid) {
    new Float:pPos[3], pInt, pVW;
    pPos[0] = GetPVarFloat(playerid, "satellite_posx");
    pPos[1] = GetPVarFloat(playerid, "satellite_posy");
    pPos[2] = GetPVarFloat(playerid, "satellite_posz");
    pInt = GetPVarInt(playerid, "satellite_interior");
    pVW = GetPVarInt(playerid, "satellite_vw");
    SetPlayerPos(playerid, PosEx(pPos));
    SetPlayerInterior(playerid, pInt);
    SetPlayerVirtualWorld(playerid, pVW);
    TogglePlayerControllable(playerid, 1);
    SetCameraBehindPlayer(playerid);
    pInfo[playerid][P_TEMP][11] = false;

    DeletePVar(playerid, "satellite_posx");
    DeletePVar(playerid, "satellite_posy");
    DeletePVar(playerid, "satellite_posz");
    DeletePVar(playerid, "satellite_interior");
    DeletePVar(playerid, "satellite_vw");

    timePlayerFreeze(playerid);
    return 1;
}

setPlayerInSkinChanger(playerid) {
    // Save player current location
    new Float:pPos[3], interior, vw;
	GetPlayerPos(playerid, PosEx(pPos));
    interior = GetPlayerInterior(playerid);
    vw = GetPlayerVirtualWorld(playerid);
	SetPVarFloat(playerid, "skinchanger_posx", pPos[0]);
 	SetPVarFloat(playerid, "skinchanger_posy", pPos[1]);
 	SetPVarFloat(playerid, "skinchanger_posz", pPos[2]);
    SetPVarInt(playerid, "skinchanger_interior", interior);
    SetPVarInt(playerid, "skinchanger_vw", vw);

    // Teleport the player to skinchanger place
    SetPlayerInterior(playerid,1);
	SetPlayerVirtualWorld(playerid,playerid+100);
	TogglePlayerControllable(playerid,0);
	//TogglePlayerSpectating(playerid,1);
	SetPlayerPos(playerid,209.3954,-34.2704,1001.9297);
	SetPlayerFacingAngle(playerid,131.4016);
	SetPlayerCameraPos(playerid, 205.606918, -37.785255, 1002.366394);
	SetPlayerCameraLookAt(playerid, 209.113021, -34.220531, 1002.367614);

    SetPVarInt(playerid, "skinchanger_current_index", 0);
    pInfo[playerid][P_TEMP][9] = true;

    showPlayerHint(playerid, "~w~Hasznald az ~y~~k~~PED_SPRINT~~w~-t az elore-, ~y~~k~~PED_JUMPING~~w~-t a hatra lepteteshez. ~n~A kivalasztashoz hasznald a ~y~~k~~PED_FIREWEAPON~~w~-t, kilepeshez ~y~~k~~PED_LOCK_TARGET~~w~-t.", 8000);

    // Set the first skin on enter
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT skinid FROM fraction_skins WHERE fractiondbid='%d' AND gender='%d' LIMIT 1", strval(getPlayerInfo(playerid, "fraction")), strval(getPlayerInfo(playerid, "sex")));
    new Cache:result = mysql_query(mysql_id, queryStr);

    new rows = cache_num_rows();

    if(rows) {
        new firstSkin = 0;
        mysql_get_int(0, "skinid", firstSkin);
        SetPlayerSkin(playerid, firstSkin);
    } else {
        SCM(playerid, COLOR_DARKRED, "(( A frakciónak nincsenek munkaruhái! ))");
        onSkinChangerFinish(playerid, -1);
    }
    cache_delete(result);
}

onSkinChangerFinish(playerid, selectedSkin) {
    // Set the players position tho his original pos
    new Float:pPos[3], interior, vw;
	pPos[0] = GetPVarFloat(playerid, "skinchanger_posx");
 	pPos[1] = GetPVarFloat(playerid, "skinchanger_posy");
 	pPos[2] = GetPVarFloat(playerid, "skinchanger_posz");
    interior = GetPVarInt(playerid, "skinchanger_interior");
 	vw = GetPVarInt(playerid, "skinchanger_vw");
    TogglePlayerSpectating(playerid, 0);
    TogglePlayerControllable(playerid, 1);
    SetPlayerPos(playerid, PosEx(pPos));
    SetPlayerInterior(playerid, interior);
    SetPlayerVirtualWorld(playerid, vw);
    SetCameraBehindPlayer(playerid);
    pInfo[playerid][P_TEMP][9] = false;

    // Delete PVars
    DeletePVar(playerid, "skinchanger_posx");
    DeletePVar(playerid, "skinchanger_posy");
    DeletePVar(playerid, "skinchanger_posz");
    DeletePVar(playerid, "skinchanger_interior");
    DeletePVar(playerid, "skinchanger_vw");
    DeletePVar(playerid, "skinchanger_current_index");

    if(selectedSkin != -1) { // If he selected a skin
        doQuery("UPDATE users SET skin1='%d' WHERE dbid='%d'", selectedSkin, pInfo[playerid][pDBID]);
        pInfo[playerid][pSkin][1] = selectedSkin;
        SCM(playerid, COLOR_GREEN, "(( Megváltoztattad a munkaruhádat! ))");
        if(pInfo[playerid][P_TEMP][6]) { // If the player is on-duty
            SetPlayerSkin(playerid, selectedSkin);
        } else {
            SetPlayerSkin(playerid, pInfo[playerid][pSkin][0]);
        }
    } else { // If he just left the skinchanger
        SetPlayerSkin(playerid, pInfo[playerid][pSkin][0]);
        SCM(playerid, COLOR_WHITE, "(( Kiléptél a munkaruha választóból! ))");
    }

    timePlayerFreeze(playerid);
}

ApplyAnim(playerid, animlib[], animname[], Float:Speed, looping, lockx, locky, lp, time, vsync = 1) {
	ApplyAnimation(playerid, animlib, "null", 0.0, 0, 0, 0, 0, 0, 0);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lp, time, vsync);
	ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lp, time, vsync);
}

/*
*
* Inventory System functions
*
*/

useItem(playerid, item) {
    switch(item) {
        case 1: {
            // Radio
        } case 2: {
            SCM(playerid, COLOR_WHITE, "(( Használd a {77cdff}/kulcs{FFFFFF} parancsot! ))");
        } case 3..5: {
            new Float:playerHP;
            GetPlayerHealth(playerid, playerHP);
            pInfo[playerid][pHP] = playerHP;
            SetPlayerHealth(playerid, playerHP + 10);

            ApplyAnim(playerid, "FOOD", "EAT_Burger",4.1,0,1,1,0,0);
            EmulateFormattedCommand(playerid, "/me megevett egy %s-t", getItemNameFromDBID(item));
            removeItem(playerid, item, 1);
        } case 100..146: { // Weapons
            new itemAmount = playerItem(playerid, item);
            SFCM(playerid, COLOR_GREEN, "(( Elõvettél egy %s-t %d tölténnyel! ))", weaponNames[item-100][0], itemAmount);
            playerMe(playerid, "elõvett egy tárgyat a táskájából");

            removeItem(playerid, item, itemAmount);
            GivePlayerWeapon(playerid, item-100, itemAmount);

            serverLogFormatted(2, "%s elõvett a táskájából egy %s-t %ddb tölténnyel", getRawName(playerid), weaponNames[item-100][0], itemAmount);
        }
        default: SCM(playerid, COLOR_ORANGE, "(( Ennek a tárgynak nincs semmi funkciója! ))");
    }
}

addItem(playerid, item, amount, param1 = -1) {
    // Get the used space
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT SUM(inventory.amount) as used_space FROM inventory WHERE inventory.userdbid='%d'", pInfo[playerid][pDBID]);
    new Cache:result = mysql_query(mysql_id, queryStr);
    new usedSpace;
    mysql_get_int(0, "used_space", usedSpace);
    cache_delete(result);
    // Get the required item gramm/piece and calculate with the amount (weight*amount)
    // Get the name for logging..
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT items.name, items.weight FROM items WHERE items.dbid='%d'", item);
    result = mysql_query(mysql_id, queryStr);
    new itemName[64];
    mysql_get_string(0, "name", itemName);
    new pieceWeight;
    mysql_get_int(0, "weight", pieceWeight);
    cache_delete(result);
    new itemWeight = amount * pieceWeight;
    // Check is there enough space for the item
    if(usedSpace + itemWeight > MAX_INVENTORY_SPACE) { // Not enough inventory space for the item
        SFCM(playerid, COLOR_ORANGE, "(( %d darab %s nem fér el a táskádban! ))", amount, itemName);
        return false;
    } else { // Player has enough space
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount FROM inventory WHERE inventory.userdbid='%d' AND inventory.itemdbid='%d' AND inventory.param1 = '%d'", pInfo[playerid][pDBID], item, param1);
        result = mysql_query(mysql_id, queryStr);
        new currentAmount;
        mysql_get_int(0, "amount", currentAmount);
        if(cache_num_rows() == 1) { // Already owning that item
            cache_delete(result);
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "UPDATE inventory SET inventory.amount = inventory.amount + %d WHERE inventory.userdbid='%d' AND inventory.itemdbid='%d' AND inventory.param1 = '%d'", amount, pInfo[playerid][pDBID], item, param1);
            result = mysql_query(mysql_id, queryStr);
            if(result) {
                printf("[SERVER] Item added to %s! (itemname = '%s', new_amount = %d, old_amount = %d, param1 = %d)", getName(playerid), itemName, currentAmount + amount, currentAmount, param1);
                cache_delete(result);
                return true;
            } else { // query error
                cache_delete(result);
                return false;
            }
        } else { // New item in the inventory
            cache_delete(result);
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "INSERT INTO inventory (userdbid, itemdbid, amount, param1) VALUES ('%d', '%d', '%d', '%d')",pInfo[playerid][pDBID], item, amount, param1);
            result = mysql_query(mysql_id, queryStr);
            if(result) {
                printf("[SERVER] New item added to %s! (itemname = '%s', new_amount = %d, old_amount = %d, param1 = %d)", getName(playerid), itemName, currentAmount + amount, currentAmount, param1);
                cache_delete(result);
                return true;
            } else {
                cache_delete(result);
                return false;
            }
        }
    }
}
removeItem(playerid, item, amount, param1 = -1) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount FROM inventory WHERE (inventory.itemdbid='%d' AND inventory.userdbid='%d' AND inventory.param1='%d') LIMIT 1", item, pInfo[playerid][pDBID], param1);
    new Cache:result = mysql_query(mysql_id, queryStr);
    new itemAmount;
    mysql_get_int(0, "amount", itemAmount);
    cache_delete(result);
    if(itemAmount - amount > 0) {
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "UPDATE inventory SET inventory.amount='%d' WHERE (inventory.itemdbid='%d' AND inventory.userdbid='%d' AND inventory.param1='%d') LIMIT 1", (itemAmount-amount), item, pInfo[playerid][pDBID], param1);
        result = mysql_query(mysql_id, queryStr);
        cache_delete(result);
        return true;
    } else {
        clearItem(playerid, item, param1);
        return false;
    }
}

clearItem(playerid, item, param1 = -1) {
    printf("clearItem(%d, %d, %d);",playerid, item, param1);
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "DELETE FROM inventory WHERE (inventory.itemdbid='%d' AND inventory.userdbid='%d' AND inventory.param1='%d')", item, pInfo[playerid][pDBID], param1);
    mysql_tquery(mysql_id, queryStr, "", "");
}

playerItem(playerid, item) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount FROM inventory WHERE inventory.itemdbid='%d' AND inventory.userdbid='%d' LIMIT 1", item, pInfo[playerid][pDBID]);
    new Cache:result = mysql_query(mysql_id, queryStr);
    new itemAmount = 0;
    if(cache_num_rows()) {
        mysql_get_int(0, "amount", itemAmount);
    } else {
		printf("[SERVER - MYSQL] No rows found (Query: %s)", queryStr);
        return -1;
	}
    cache_delete(result);
    return itemAmount;
}

/*
*
* KickPlayer(playerid) - Kicks the player out of the server with a default 500ms delay due to SAMP things..
*
*/
KickPlayerEx(adminid = -1, kickedid, reason[], bool:knaplo, bool:show) {
    if(adminid != -1) { // Kicked by an admin
        if(knaplo) doQuery("INSERT INTO karakternaplo (userdbid,admindbid,reason,type) VALUES ('%d', '%d', '%s','KICK')", pInfo[kickedid][pDBID], pInfo[adminid][pDBID], reason);
        if(show) SFCMToAll(COLOR_TOMATO, "%s %s kickelte %s-t. Indok: %s", getPlayerAdminRank(adminid), getName(adminid), getName(kickedid), reason);
        KickPlayer(kickedid);
    } else { // Kicked by the system
        if(knaplo) doQuery("INSERT INTO karakternaplo (userdbid,admindbid,reason,type) VALUES ('%d', '-1', '%s','KICK')", pInfo[kickedid][pDBID], reason);
        if(show) SFCMToAll(COLOR_TOMATO, "Rendszer kickelte %s-t. Indok: %s", getName(kickedid), reason);
        KickPlayer(kickedid);
    }
}
BanPlayerEx(adminid = -1, bannedid, time, reason[], bool:knaplo, bool:show) {

}
KickPlayer(playerid) {
    defer tDelayedKick(playerid);
}
timer tDelayedKick[500](playerid) {
    Kick(playerid);
}

function onVehicleGCompShow(playerid, vehicleDBID) {
    new rows = cache_num_rows();
    if(rows) {
        new itemName[64], itemAmount, itemParam1;
        new dialog[1024] = "{FFFFFF}Tárgy neve\t{FFFFFF}Mennyiség\t{FFFFFF}Egyéb\n";
        new string[128];
        for(new i = 0; i < rows; i++) {
            mysql_get_string(i, "name", itemName);
            mysql_get_int(i, "amount", itemAmount);
            mysql_get_int(i, "param1", itemParam1);

            format(string, sizeof(string), "%s\t%d\t%s\n", itemName, itemAmount, getVehiclePlateByDBID(itemParam1));
            strcat(dialog, string);
        }
        ShowPlayerDialog(playerid, DIALOG_GLOVE_COMP, DIALOG_STYLE_TABLIST_HEADERS, "[ {77abff}Kesztyûtartó tartalma{FFFFFF} ]", dialog, "Kivesz", "Mégse");
    } else SCM(playerid, COLOR_ORANGE, "(( Üres a kesztyûtartó! ))");
    return 1;
}

function onVehicleTrunkShow(playerid, vehicleDBID) {
    new rows = cache_num_rows();
    if(rows) {
        new itemName[64], itemAmount, itemParam1;
        new dialog[1024] = "{FFFFFF}Tárgy neve\t{FFFFFF}Mennyiség\t{FFFFFF}Egyéb\n";
        new string[128];
        for(new i = 0; i < rows; i++) {
            mysql_get_string(i, "name", itemName);
            mysql_get_int(i, "amount", itemAmount);
            mysql_get_int(i, "param1", itemParam1);

            format(string, sizeof(string), "%s\t%d\t%s\n", itemName, itemAmount, getVehiclePlateByDBID(itemParam1));
            strcat(dialog, string);
        }
        ShowPlayerDialog(playerid, DIALOG_TRUNK, DIALOG_STYLE_TABLIST_HEADERS, "[ {77abff}Csomagtartó tartalma{FFFFFF} ]", dialog, "Kivesz", "Mégse");
    } else SCM(playerid, COLOR_ORANGE, "(( Üres a csomagtartó! ))");
    return 1;
}
