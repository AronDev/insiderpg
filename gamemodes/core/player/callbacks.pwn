public OnPlayerCommandReceived(playerid, cmd[], params[], flags) {
	if(isValidPlayer(playerid)) {
		if(PC_CommandExists(cmd)) {
			
		} else SCM(playerid, -1, getStrMsg(STR_NCF));
	} else SCM(playerid, -1, getStrMsg(STR_NLI));
	return true;
}
/*public OnPlayerCommandReceived(playerid, cmd[], params[], flags) {
	if(isValidPlayer(playerid)) {
		if(PC_CommandExists(cmd)) {
			if(getCommandPermission(cmd) != -1) {
				if(getPlayerAdminPermission(playerid) >= getCommandPermission(cmd) || IsSpecialUser(playerid)) {
					// serverLog
					serverLogFormatted(0, "Parancs: '/%s %s' - %s", cmd, params, getRawName(playerid));
					// *CmdLog*
					for(new i = 0; i < GetPlayerPoolSize() + 1; i++) {
						if(isValidPlayer(i)) {
							if(pInfo[i][P_TEMP][5]) {
								SFCM(i, COLOR_YELLOW, "*CmdLog* {77cdff}%s{ffffff} -> {77cdff}/%s %s{ffffff}", getName(playerid), cmd, params);
							}
						}
					}
					//
					return true;
				} else {
					SCM(playerid, -1, getStrMsg(STR_NHEP));
					// *CmdLog*
					for(new i = 0; i < GetPlayerPoolSize() + 1; i++) {
						if(isValidPlayer(i)) {
							if(pInfo[i][P_TEMP][5]) {
								SFCM(i, COLOR_YELLOW, "*CmdLog* {77cdff}%s{ffffff} -> {77cdff}/%s{ffffff} (nincs elég joga)", getName(playerid), cmd);
							}
						}
					}
					//
					return false;
				}
			} else {
				SCM(playerid, -1, getStrMsg(STR_CNCY));
				// *CmdLog*
				for(new i = 0; i < GetPlayerPoolSize() + 1; i++) {
					if(isValidPlayer(i)) {
						if(pInfo[i][P_TEMP][5]) {
							SFCM(i, COLOR_YELLOW, "*CmdLog* {77cdff}%s{ffffff} -> {77cdff}/%s{ffffff} (parancs nincs konfigurálva)", getName(playerid), cmd);
						}
					}
				}
				//
				return false;
			}
		} else {
			SCM(playerid, -1, getStrMsg(STR_NCF));
			// *CmdLog*
			for(new i = 0; i < GetPlayerPoolSize() + 1; i++) {
				if(isValidPlayer(i)) {
					if(pInfo[i][P_TEMP][5]) {
						SFCM(i, COLOR_YELLOW, "*CmdLog* {77cdff}%s{ffffff} -> {77cdff}/%s{ffffff} (ismeretlen parancs)", getName(playerid), cmd);
					}
				}
			}
			//
			return false;
		}
	} else SCM(playerid, -1, getStrMsg(STR_NLI));
	return true;
}*/

#include  <YSI\y_hooks>
hook OnPlayerClickMap(playerid,Float:fX,Float:fY,Float:fZ) {
    if(getPlayerAdminPermission(playerid) >= 2)
    {
        if(pInfo[playerid][P_TEMP][13])
        {
			new Float:z;
            if(IsPlayerInAnyVehicle(playerid)) {
                new veh = GetPlayerVehicleID(playerid);
				MapAndreas_FindZ_For2DCoord(fX,fY,z);
		        SetVehiclePos(veh, fX, fY, z+3);
		        PutPlayerInVehicle(playerid, veh, 0);
			} else {
				MapAndreas_FindZ_For2DCoord(fX,fY,z);
	            SetPlayerPos(playerid, fX, fY, z+1.0);
			}
        }
    }
}

#include <YSI\y_hooks>
hook OnPlayerStateChange(playerid, newstate, oldstate) {
    if(newstate == PLAYER_STATE_WASTED) {

	} else if(newstate == PLAYER_STATE_PASSENGER) {

	} else if(newstate == PLAYER_STATE_DRIVER) {
		new vehicleDBID = getVehicleDBIDFromID(GetPlayerVehicleID(playerid));
		if(getPlayerAdminPermission(playerid) >= 2) {
			if(vInfo[vehicleDBID][vFraction] > 0) {
				SFCM(playerid, COLOR_DARKRED, "(( Ez egy frakció jármû! (DBID = %d) ))", vehicleDBID);
			}
		} else {

		}
	}
	return 1;
}

#include <YSI\y_hooks>
hook OnPlayerDeath(playerid, killerid, reason) {
	// Add deaths
	mysql_format(mysql_id, queryStr, sizeof(queryStr), "UPDATE users SET deaths=deaths+1, hp='100.0' WHERE dbid='%d'", pInfo[playerid][pDBID]);
	mysql_query(mysql_id, queryStr);
	// Add kills
	mysql_format(mysql_id, queryStr, sizeof(queryStr), "UPDATE users SET kills=kills+1 WHERE dbid='%d'", pInfo[killerid][pDBID]);
	mysql_query(mysql_id, queryStr);

	pInfo[playerid][pHP] = 100;
	pInfo[playerid][P_TEMP][12] = true; //TODO
	pInfo[playerid][P_TEMP][TEMP_ADUTY] = false; // Admin duty
	pInfo[playerid][P_TEMP][6] = false; // Fraction duty
	pInfo[playerid][P_TEMP][14] = false; // PD Civil clothes
	pInfo[playerid][P_TEMP][9] = false; // Skinchanger
	return 1;
}

#include <YSI\y_hooks>
hook OnPlayerEnterCheckpoint(playerid) {
    DisablePlayerCheckpoint(playerid);
    return 1;
}

#include <YSI\y_hooks>
hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	new pVW = GetPlayerVirtualWorld(playerid);
	new pInt = GetPlayerInterior(playerid);
	new Float:pPos[3];
	GetPlayerPos(playerid, PosEx(pPos));
	if(PRESSED(KEY_SECONDARY_ATTACK)) {
		new teleportDBID = getClosestTeleportToPlayer(playerid);

		if(teleportDBID != -1) {
			if(PlayerToPoint(playerid, tpInfo[teleportDBID][tpRad][0], tpInfo[teleportDBID][tpPos][0], tpInfo[teleportDBID][tpPos][1], tpInfo[teleportDBID][tpPos][2])) {
				if(tpInfo[teleportDBID][tpVW][0] == pVW && tpInfo[teleportDBID][tpInt][0] == pInt) {
					if(pInfo[playerid][P_TEMP][15]) SFCM(playerid, -1, "[DEBUG] Teleport DBID = %d, Pos = 0", teleportDBID);

					DeletePVar(playerid, "int_true");
					DeletePVar(playerid, "int_posx");
					DeletePVar(playerid, "int_posy");
					DeletePVar(playerid, "int_posz");

					if(tpInfo[teleportDBID][tpPos][5] > 500.0) {
						SetPVarInt(playerid, "int_true", 1);
						SetPVarFloat(playerid, "int_posx", pPos[0]);
						SetPVarFloat(playerid, "int_posy", pPos[1]);
						SetPVarFloat(playerid, "int_posz", pPos[2]);
					}

					SetPlayerPos(playerid, tpInfo[teleportDBID][tpPos][3], tpInfo[teleportDBID][tpPos][4], tpInfo[teleportDBID][tpPos][5]);
					SetPlayerInterior(playerid, tpInfo[teleportDBID][tpInt][1]);
					SetPlayerVirtualWorld(playerid, tpInfo[teleportDBID][tpVW][1]);

					timePlayerFreeze(playerid);
				}
			} else if(PlayerToPoint(playerid, tpInfo[teleportDBID][tpRad][1], tpInfo[teleportDBID][tpPos][3], tpInfo[teleportDBID][tpPos][4], tpInfo[teleportDBID][tpPos][5])) {
				if(tpInfo[teleportDBID][tpVW][1] == pVW && tpInfo[teleportDBID][tpInt][1] == pInt) {
					if(pInfo[playerid][P_TEMP][15]) SFCM(playerid, -1, "[DEBUG] Teleport DBID = %d, Pos = 1", teleportDBID);

					DeletePVar(playerid, "int_true");
					DeletePVar(playerid, "int_posx");
					DeletePVar(playerid, "int_posy");
					DeletePVar(playerid, "int_posz");

					if(tpInfo[teleportDBID][tpPos][2] > 500.0) {
						SetPVarInt(playerid, "int_true", 1);
						SetPVarFloat(playerid, "int_posx", pPos[0]);
						SetPVarFloat(playerid, "int_posy", pPos[1]);
						SetPVarFloat(playerid, "int_posz", pPos[2]);
					}

					SetPlayerPos(playerid, tpInfo[teleportDBID][tpPos][0], tpInfo[teleportDBID][tpPos][1], tpInfo[teleportDBID][tpPos][2]);
					SetPlayerInterior(playerid, tpInfo[teleportDBID][tpInt][0]);
					SetPlayerVirtualWorld(playerid, tpInfo[teleportDBID][tpVW][0]);

					timePlayerFreeze(playerid);
				}
			}
		}
	}

	if(PRESSED(KEY_AIM)) {
		if(pInfo[playerid][P_TEMP][9]) {
			onSkinChangerFinish(playerid, -1);
		}
	}
	if(PRESSED(KEY_FIRE)) {
		if(pInfo[playerid][P_TEMP][9]) {
			onSkinChangerFinish(playerid, GetPlayerSkin(playerid));
		}
	}
	if(PRESSED(KEY_JUMP)) {
		if(pInfo[playerid][P_TEMP][9]) {
			moveSkinChangerIndex(playerid, -1);
		}
	}
	if(PRESSED(KEY_SPRINT)) {
		if(pInfo[playerid][P_TEMP][9]) {
			moveSkinChangerIndex(playerid, 1);
		}
	}

	if(PRESSED(KEY_HANDBRAKE) && !IsPlayerInAnyVehicle(playerid)) {
        //if(pInfo[playerid][pInjury] == 0) {
			ClearAnimations(playerid);
	        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	        TogglePlayerControllable(playerid, 1);
            //PC_EmulateCommand(playerid, "/anim stop");
        //}
    }

	if(PRESSED(KEY_CROUCH)) {
        if(pInfo[playerid][P_TEMP][11]) {
			pPos[0] = GetPVarFloat(playerid, "satellite_cam_posx");
	        pPos[1] = GetPVarFloat(playerid, "satellite_cam_posy");
	        pPos[2] = GetPVarFloat(playerid, "satellite_cam_posz");
			if(pPos[2] >= SATELLITE_MIN) {
				new Float:zPos;
				MapAndreas_FindZ_For2DCoord(pPos[0], pPos[1], zPos);
				SetPlayerPos(playerid, pPos[0], pPos[1], zPos - 50);

				TogglePlayerControllable(playerid, 0);
	            SetPlayerCameraPos(playerid, pPos[0], pPos[1], pPos[2] - SATELLITE_UPDOWN);
	            SetPlayerCameraLookAt(playerid, pPos[0], pPos[1], pPos[2] - 500);
	            SetPVarFloat(playerid, "satellite_cam_posx", pPos[0]);
				SetPVarFloat(playerid, "satellite_cam_posy", pPos[1]);
				SetPVarFloat(playerid, "satellite_cam_posz", pPos[2] - SATELLITE_UPDOWN);
			}
        }
    } if(PRESSED(KEY_JUMP)) {
        if(pInfo[playerid][P_TEMP][11]) {
			pPos[0] = GetPVarFloat(playerid, "satellite_cam_posx");
            pPos[1] = GetPVarFloat(playerid, "satellite_cam_posy");
            pPos[2] = GetPVarFloat(playerid, "satellite_cam_posz");
			if(pPos[2] <= SATELLITE_MAX) {
				new Float:zPos;
				MapAndreas_FindZ_For2DCoord(pPos[0], pPos[1], zPos);
				SetPlayerPos(playerid, pPos[0], pPos[1], zPos - 50);

				TogglePlayerControllable(playerid, 0);
	            SetPlayerCameraPos(playerid, pPos[0], pPos[1], pPos[2] + SATELLITE_UPDOWN);
	            SetPlayerCameraLookAt(playerid, pPos[0], pPos[1], pPos[2] - 500);
	            SetPVarFloat(playerid, "satellite_cam_posx", pPos[0]);
				SetPVarFloat(playerid, "satellite_cam_posy", pPos[1]);
				SetPVarFloat(playerid, "satellite_cam_posz", pPos[2] + SATELLITE_UPDOWN);
			}
        }
    }

	if(PRESSED(KEY_SUBMISSION)) {
		if(IsPlayerInAnyVehicle(playerid)) {
			new vehicleID = GetPlayerVehicleID(playerid);
			new vehicleDBID = getVehicleDBIDFromID(vehicleID);
			PlayerPlaySound(playerid, 1027, 0.0, 0.0, 0.0);
			new engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(vInfo[vehicleDBID][vID], engine, lights, alarm, doors, bonnet, boot, objective);
			if(vInfo[vehicleDBID][vLights]) {
				vInfo[vehicleDBID][vLights] = false;
				SetVehicleParamsEx(vInfo[vehicleDBID][vID], engine, 0, alarm, doors, bonnet, boot, objective);
				showPlayerFooter(playerid, "~r~Lekapcsoltad ~w~a lampakat", 3000);
			} else {
				vInfo[vehicleDBID][vLights] = true;
				SetVehicleParamsEx(vInfo[vehicleDBID][vID], engine, 1, alarm, doors, bonnet, boot, objective);
				showPlayerFooter(playerid, "~g~Felkapcsoltad ~w~a lampakat", 3000);
			}
		}
	}

	if((newkeys & (KEY_HANDBRAKE | KEY_SUBMISSION)) == (KEY_HANDBRAKE | KEY_SUBMISSION) && (oldkeys & (KEY_HANDBRAKE | KEY_SUBMISSION)) != (KEY_HANDBRAKE | KEY_SUBMISSION)) {
		if(IsPlayerInAnyVehicle(playerid)) {
			vehicleEngine(playerid);
		}
	}
	return 1;
}

#include <YSI\y_hooks>
hook OnPlayerText(playerid, text[]) {
	playerIC(playerid, text);
	return 0;
}

#include <YSI\y_hooks>
hook OnPlayerUpdate(playerid) {
	new Keys,ud,lr;
    new Float:pPos[3];
    GetPlayerKeys(playerid,Keys,ud,lr);
    if(ud == KEY_UP) {
        if(pInfo[playerid][P_TEMP][11]) {
            pPos[0] = GetPVarFloat(playerid, "satellite_cam_posx");
            pPos[1] = GetPVarFloat(playerid, "satellite_cam_posy");
            pPos[2] = GetPVarFloat(playerid, "satellite_cam_posz");

			new Float:zPos;
			MapAndreas_FindZ_For2DCoord(pPos[0], pPos[1], zPos);
			SetPlayerPos(playerid, pPos[0], pPos[1], zPos - 50);

            TogglePlayerControllable(playerid, 0);
            SetPlayerCameraPos(playerid, pPos[0], pPos[1] + SATELLITE_MOVE, pPos[2]);
            SetPlayerCameraLookAt(playerid, pPos[0], pPos[1] + SATELLITE_MOVE, pPos[2] - 500);
            SetPVarFloat(playerid, "satellite_cam_posx", pPos[0]);
			SetPVarFloat(playerid, "satellite_cam_posy", pPos[1] + SATELLITE_MOVE);
			SetPVarFloat(playerid, "satellite_cam_posz", pPos[2]);
        }
    } else if(ud == KEY_DOWN) {
        if(pInfo[playerid][P_TEMP][11]) {
            pPos[0] = GetPVarFloat(playerid, "satellite_cam_posx");
            pPos[1] = GetPVarFloat(playerid, "satellite_cam_posy");
            pPos[2] = GetPVarFloat(playerid, "satellite_cam_posz");

			new Float:zPos;
			MapAndreas_FindZ_For2DCoord(pPos[0], pPos[1], zPos);
			SetPlayerPos(playerid, pPos[0], pPos[1], zPos - 50);

			TogglePlayerControllable(playerid, 0);
            SetPlayerCameraPos(playerid, pPos[0], pPos[1] - SATELLITE_MOVE, pPos[2]);
            SetPlayerCameraLookAt(playerid, pPos[0], pPos[1] - SATELLITE_MOVE, pPos[2] - 500);
            SetPVarFloat(playerid, "satellite_cam_posx", pPos[0]);
			SetPVarFloat(playerid, "satellite_cam_posy", pPos[1] - SATELLITE_MOVE);
			SetPVarFloat(playerid, "satellite_cam_posz", pPos[2]);
        }
    } if(lr == KEY_LEFT) {
        if(pInfo[playerid][P_TEMP][11]) {
			pPos[0] = GetPVarFloat(playerid, "satellite_cam_posx");
            pPos[1] = GetPVarFloat(playerid, "satellite_cam_posy");
            pPos[2] = GetPVarFloat(playerid, "satellite_cam_posz");

			new Float:zPos;
			MapAndreas_FindZ_For2DCoord(pPos[0], pPos[1], zPos);
			SetPlayerPos(playerid, pPos[0], pPos[1], zPos - 50);

			TogglePlayerControllable(playerid, 0);
            SetPlayerCameraPos(playerid, pPos[0] - SATELLITE_MOVE, pPos[1], pPos[2]);
            SetPlayerCameraLookAt(playerid, pPos[0] - SATELLITE_MOVE, pPos[1], pPos[2] - 500);
           	SetPVarFloat(playerid, "satellite_cam_posx", pPos[0] - SATELLITE_MOVE);
			SetPVarFloat(playerid, "satellite_cam_posy", pPos[1]);
			SetPVarFloat(playerid, "satellite_cam_posz", pPos[2]);
        }
    } else if(lr == KEY_RIGHT) {
        if(pInfo[playerid][P_TEMP][11]) {
			pPos[0] = GetPVarFloat(playerid, "satellite_cam_posx");
            pPos[1] = GetPVarFloat(playerid, "satellite_cam_posy");
            pPos[2] = GetPVarFloat(playerid, "satellite_cam_posz");

			new Float:zPos;
			MapAndreas_FindZ_For2DCoord(pPos[0], pPos[1], zPos);
			SetPlayerPos(playerid, pPos[0], pPos[1], zPos - 50);

			TogglePlayerControllable(playerid, 0);
            SetPlayerCameraPos(playerid, pPos[0] + SATELLITE_MOVE, pPos[1], pPos[2]);
            SetPlayerCameraLookAt(playerid, pPos[0] + SATELLITE_MOVE, pPos[1], pPos[2] - 500);
            SetPVarFloat(playerid,"satellite_cam_posx", pPos[0] + SATELLITE_MOVE);
			SetPVarFloat(playerid,"satellite_cam_posy", pPos[1]);
			SetPVarFloat(playerid,"satellite_cam_posz", pPos[2]);
        }
    }
	return 1;
}

#include <YSI\y_hooks>
hook OnPlayerConnect(playerid) {
	SetPlayerColor(playerid, COLOR_ORANGE); // For indicating players who didn't login yet
	// serverLog
	serverLogFormatted(1, "%s csatlakozott a szerverhez. IP = %s", getRawName(playerid), getPlayerIP(playerid));
    if(!IsPlayerNPC(playerid)) {
		createTextDraws(playerid);
		if(srvInfo[SRV_WHITELIST]) {
			mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT users.dbid FROM users INNER JOIN whitelist ON whitelist.userdbid=users.dbid WHERE name='%e' LIMIT 1", getRawName(playerid));
			new Cache:result = mysql_query(mysql_id, queryStr);
			if(cache_num_rows() == 1) {
				SCM(playerid, COLOR_GREEN, "(( A szerveren whitelist zárolás van. Szerepelsz a listában! ))");
				mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT dbid, activated FROM users WHERE name='%e' LIMIT 1", getRawName(playerid));
				mysql_tquery(mysql_id, queryStr, "onUserCheck", "d", playerid);
			} else {
				SCM(playerid, COLOR_DARKRED, "(( A szerver whitelist zárolás alatt van jelenleg. Nem szerepelsz a listában! ))");
				KickPlayer(playerid);
			}
			cache_delete(result);
		} else {
			mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT dbid, activated FROM users WHERE name='%e' LIMIT 1", getRawName(playerid));
			mysql_tquery(mysql_id, queryStr, "onUserCheck", "d", playerid);
		}
    } else {
        // If the player is an NPC
    }
    return 1;
}

function onUserCheck(playerid) {
    if(cache_num_rows() == 1) { // If the player does have an account
        mysql_get_int(0, "dbid", pInfo[playerid][pDBID]);
		if(cache_get_field_content_int(0, "activated") == 1) {
			mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT bans.expire, bans.reason, users.name FROM bans INNER JOIN users ON users.dbid=bans.admin_dbid WHERE (banned_dbid='%d' OR banned_ip='%s') AND expire > NOW()", pInfo[playerid][pDBID], getPlayerIP(playerid));
			mysql_tquery(mysql_id, queryStr, "onUserBanCheck", "d", playerid);
		} else SCM(playerid, COLOR_DARKRED, "(( A felhasználód még nem lett elfogadva! ))");
    } else {
        SCM(playerid, COLOR_DARKRED, "(( Nincs ilyen név az adatbázisban! Regisztrálj egyet a weboldalon! ))");
		SCM(playerid, COLOR_DARKRED, "(( Ideiglenes weboldal: arondev.xyz/arondev/samp/ucp/ ))"); // --------------------------------------------------------------------------
        KickPlayer(playerid);
    }
    return 1;
}

function onUserBanCheck(playerid) {
    if(cache_num_rows() == 0) { // If the player isn't banned
        new dialogStr[128];
        format(dialogStr, sizeof(dialogStr), "{FFFFFF}Üdvözlünk, {77abff}%s{FFFFFF}!\nKérlek, add meg a jelszavad!", getName(playerid));
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "[ {77abff}Belépés{FFFFFF} ]", dialogStr, "Belépés", "Mégse");
    } else {
        new expire[64], reason[128], admin[MAX_PLAYER_NAME];
        mysql_get_string(0, "expire", expire);
        mysql_get_string(0, "reason", reason);
        mysql_get_string(0, "name", admin);
        SFCM(playerid, COLOR_DARKRED, "(( Bannolva vagy %s miatt %s által! ))", reason, admin);
        SFCM(playerid, COLOR_DARKRED, "(( A tíltás %s-kor fog lejárni! ))", expire);
        KickPlayer(playerid);
    }
    return 1;
}

#include <YSI\y_hooks>
hook OnPlayerDisconnect(playerid, reason) {
	new discreason[3][] = {"kifagyott", "kilépett", "kirúgták"};
	new str[128];
	format(str, sizeof(str), "(( %s %s ))", getName(playerid), discreason[reason]);
	Prox(playerid, 15.0, str, COLOR_LIGHTGREEN);

	// last_online
	doQuery("UPDATE users SET last_online=CURRENT_TIMESTAMP WHERE dbid='%d'", pInfo[playerid][pDBID]);

	// serverLog
	serverLogFormatted(1, "%s lecsatlakozott a szerverrõl. IP = %s", getRawName(playerid), getPlayerIP(playerid));
	// ConLog
	for(new i = 0; i < GetPlayerPoolSize() + 1; i++) {
		if(isValidPlayer(i)) {
			if(pInfo[i][P_TEMP][3]) {
				SFCM(i, COLOR_YELLOW, "*ConLog* {77cdff}%s{ffffff} kilépett ({77cdff}%s{ffffff})", getName(playerid), getPlayerIP(playerid));
			}
		}
	}
	//
    return 1;
}

#include <YSI\y_hooks>
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    switch(dialogid) {
		case DIALOG_MAKEADMIN1: {
			if(response) {
				new targetPlayerID = GetPVarInt(playerid, "makeadmin_targetPlayerID");
				new AdminLevelDBID = strval(inputtext);
				EmulateFormattedCommand(playerid, "/makeadmin %d %d", targetPlayerID, AdminLevelDBID);
			}
			// Delete PVars
			DeletePVar(playerid, "makeadmin_targetPlayerID");
		}
		case DIALOG_LEADER1: {
			if(response) {
				new dialogStr[1024];
				new dialogRow[128];
				switch(listitem) {
					case 0: {
						mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT u.name AS uname, fat.name AS fatname, fat.color AS fatcolor FROM fraction_applies AS fa JOIN users AS u ON u.dbid=fa.userdbid INNER JOIN fraction_apply_types AS fat ON fat.type_entry=fa.status ORDER BY timestamp DESC LIMIT 10");
						inline q_showFractionApplies() {
							new rows = cache_num_rows();
							format(dialogStr, sizeof(dialogStr), "{ffffff}Jelentkezõ\t{ffffff}Státusz\n");
							if(rows > 0) {
								new uname[MAX_PLAYER_NAME];
								new status[64];
								new color[16];
								for(new i = 0; i < rows; i++) {
									mysql_get_string(i, "uname", uname);
									mysql_get_string(i, "fatname", status);
									mysql_get_string(i, "fatcolor", color);
									format(dialogRow, sizeof(dialogRow), "{ffffff}%s\t{%s}%s\n", uname, color, status);
									strcat(dialogStr, dialogRow);
								}
								ShowPlayerDialog(playerid, DIALOG_LEADER2, DIALOG_STYLE_TABLIST_HEADERS, "Jelentkezõk", dialogStr, "Tovább", "Vissza");
							} else {
								SCM(playerid, COLOR_ORANGE, "(( Nincsenek jelentkezõk! ))");
								PC_EmulateCommand(playerid, "/leader");
							}
						}
						mysql_tquery_inline(mysql_id, queryStr, using inline q_showFractionApplies, "");
					}
				}
			}
		} case DIALOG_LEADER2: {
			if(response) {
				new dialogStr[1024];
				mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT u.dbid AS dbid, u.name AS un, u.born_time AS bt, fa.timestamp AS ts, fa.status as status, fat.name AS fatname, fat.color AS fatcolor FROM fraction_applies AS fa INNER JOIN users AS u ON u.dbid=fa.userdbid INNER JOIN fraction_apply_types AS fat ON fat.type_entry=fa.status WHERE u.name='%s'", inputtext);
				inline q_showFractionApply() {
					new rows = cache_num_rows();
					format(dialogStr, sizeof(dialogStr), "{ffffff}Jelentkezõ\t{ffffff}Státusz\n");
					if(rows > 0) {
						new bt[128];
						new statusname[64];
						new statuscolor[16];
						new ts[128];
						new dbid = 0;
						new uname[MAX_PLAYER_NAME];
						new status = 0;
						mysql_get_string(0, "un", uname);
						mysql_get_string(0, "bt", bt);
						mysql_get_string(0, "ts", ts);
						mysql_get_string(0, "fatname", statusname);
						mysql_get_string(0, "fatcolor", statuscolor);
						mysql_get_int(0, "dbid", dbid);
						mysql_get_int(0, "status", status);

						SetPVarInt(playerid, "leader_applyDBID", dbid);
						SetPVarInt(playerid, "leader_applyStatus", status);
						SetPVarString(playerid, "leader_applyName", uname);

						format(dialogStr, sizeof(dialogStr), "{77cdff}Név: {ffffff}%s\n{77cdff}Jelentkezési idõ: {ffffff}%s\n\n{77cdff}Állapot: {%s}%s", uname, ts, statuscolor, statusname);
						ShowPlayerDialog(playerid, DIALOG_LEADER3, DIALOG_STYLE_MSGBOX, "Jelentkezési lap", dialogStr, status == 0 ? ("Elbírálás") : ("Vissza"), status == 0 ? ("Vissza") : (""));
					} else {
						SCM(playerid, COLOR_ORANGE, "(( Hiba történt a jelentkezési lap megnyitásakor! ))");
					}
				}
				mysql_tquery_inline(mysql_id, queryStr, using inline q_showFractionApply, "");
			} else {
				PC_EmulateCommand(playerid, "/leader");
			}
		} case DIALOG_LEADER3: {
			if(response) {
				if(GetPVarInt(playerid, "leader_applyStatus") == 0) {
					ShowPlayerDialog(playerid, DIALOG_LEADER4, DIALOG_STYLE_LIST, "{ffffff}Jelentkezés elbírálása", "{ffffff}Elfogad\n{ffffff}Elutasítás", "Mehet", "Vissza");
				} else {
					// TODO
					// fraction_applies list
				}
			}
		} case DIALOG_LEADER4: {
			if(response) {
				new applyUserDBID = GetPVarInt(playerid, "leader_applyDBID");
				new applyUserName[MAX_PLAYER_NAME];
				GetPVarString(playerid, "leader_applyName", applyUserName, sizeof(applyUserName));
				switch(listitem) {
					case 0: { // Accept
						SFCM(playerid, COLOR_CYAN, "(( Elfogadtad %s jelentkezését! ))", applyUserName);

						new id = ReturnUser(applyUserName);
						if(id >= 0) {
							if(isValidPlayer(id)) {
								SFCM(id, COLOR_CYAN, "(( Elfogadták a jelentkezésed a(z) %s-hoz! ))", fInfo[pInfo[playerid][pFraction]][fName]);

								pInfo[id][pFraction] = pInfo[playerid][pFraction];
								pInfo[id][pRank] = 1;
								pInfo[id][pLeader] = 0;
								pInfo[id][pDivision] = 0;
								pInfo[id][pSkin][1] = -1;
							}
						}
						doQuery("UPDATE users SET fraction='%s', rank='1', leader='0', division='0', skin1='-1' WHERE dbid='%d'", pInfo[playerid][pFraction], applyUserDBID);

						/*
						doQuery("DELETE FROM fraction_employees WHERE userdbid='%d'", applyUserDBID);
						doQuery("INSERT INTO fraction_employees (userdbid, fraction, added_by) VALUES ('%d', '%d','%d')", applyUserDBID, pInfo[playerid][pFraction], pInfo[playerid][pDBID]);
						*/
						doQuery("UPDATE fraction_applies SET status='2' WHERE userdbid='%d'", applyUserDBID);
					} case 1: { // Decline
						SFCM(playerid, COLOR_CYAN, "(( Elutasítottad %s jelentkezését! ))", applyUserName);

						new id = ReturnUser(applyUserName);
						if(id >= 0) {
							if(isValidPlayer(id)) {
								SFCM(id, COLOR_CYAN, "(( Elutasították a jelentkezésed a(z) %s-hoz! ))", fInfo[pInfo[playerid][pFraction]][fName]);
							}
						}

						doQuery("UPDATE fraction_applies SET status='1' WHERE userdbid='%d'", applyUserDBID);
					}
				}
			} else {
				// apply
			}

		} case DIALOG_PUTAWAY: {
			if(response) {
				new weapID = getWeaponIDFromName(inputtext);
				new weapAmmo = -1;
				GetPlayerWeaponData(playerid, getWeaponSlot(weapID), weapID, weapAmmo);
				GivePlayerWeapon(playerid, weapID, -weapAmmo);
				playerMe(playerid, "elrakott egy tárgyat");
				SFCM(playerid, COLOR_GREEN, "(( Elraktál egy %s-t %d tölténnyel! ))", weaponNames[weapID][0], weapAmmo);

				new itemID = -1;
				itemID = 100 + weapID;
				addItem(playerid, itemID, weapAmmo);

				serverLogFormatted(2, "%s elrakott a táskájába egy %s-t %ddb tölténnyel", getRawName(playerid), weaponNames[weapID][0], weapAmmo);
			}
		} case DIALOG_GCOMP_ITEM: {
			if(response) {
				if(isNumeric(inputtext)) {
					new inputAmount = strval(inputtext);
					if(inputAmount > 0) {
						new itemName[64];
						new itemAmount = 0;
						new itemParam1 = -1;
						new itemDBID = -1;

						new vehicleDBID = GetPVarInt(playerid, "gcomp_vehicledbid");

						GetPVarString(playerid, "gcomp_selected_name", itemName, sizeof(itemName));
						itemAmount = GetPVarInt(playerid, "gcomp_selected_amount");
						itemParam1 = GetPVarInt(playerid, "gcomp_selected_param1");
						itemDBID = GetPVarInt(playerid, "gcomp_selected_itemdbid");

						if(itemAmount - inputAmount >= 0) {
							if(itemParam1 == -1) {
								SFCM(playerid, COLOR_CYAN, "(( Kivettél %d db %s-t a kesztyûtartóból! ))", inputAmount, itemName);
							} else {
								if(vInfo[vehicleDBID][vFraction] == pInfo[playerid][pFraction] || vInfo[vehicleDBID][vFraction] == 0 || getPlayerAdminPermission(playerid) >= 2) {
										SFCM(playerid, COLOR_CYAN, "(( Kivettél %d db %s(%s)-t a kesztyûtartóból! ))", inputAmount, itemName, getVehiclePlateByDBID(itemParam1));
								} else {
									SCM(playerid, COLOR_ORANGE, "(( Nem veheted ki a jármûbõl a kulcsot! ))");
								}
							}
							removeGloveCompItem(vehicleDBID, itemDBID, inputAmount, itemParam1);
							addItem(playerid, itemDBID, inputAmount, itemParam1);
						} else {
							SCM(playerid, COLOR_ORANGE, "(( Ennyi nincs a kesztyûtartóban! ))");
						}
						// Deleting PVars
						DeletePVar(playerid, "gcomp_selected_name");
						DeletePVar(playerid, "gcomp_selected_amount");
						DeletePVar(playerid, "gcomp_selected_param1");
						DeletePVar(playerid, "gcomp_selected_itemdbid");
						DeletePVar(playerid, "gcomp_vehicledbid");
					} else {
						SCM(playerid, COLOR_ORANGE, "(( Túl kevés! ))");
						mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_glove_comp.amount, vehicle_glove_comp.param1, items.name FROM vehicle_glove_comp INNER JOIN items ON items.dbid=vehicle_glove_comp.itemdbid WHERE vehicle_glove_comp.vehicledbid='%d'", GetPVarInt(playerid, "gcomp_vehicledbid"));
			            mysql_tquery(mysql_id, queryStr, "onVehicleGCompShow", "dd", playerid, GetPVarInt(playerid, "gcomp_vehicledbid"));
					}
				} else {
					SCM(playerid, COLOR_ORANGE, "(( Csak szám lehet! ))");
					mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_glove_comp.amount, vehicle_glove_comp.param1, items.name FROM vehicle_glove_comp INNER JOIN items ON items.dbid=vehicle_glove_comp.itemdbid WHERE vehicle_glove_comp.vehicledbid='%d'", GetPVarInt(playerid, "gcomp_vehicledbid"));
		            mysql_tquery(mysql_id, queryStr, "onVehicleGCompShow", "dd", playerid, GetPVarInt(playerid, "gcomp_vehicledbid"));
				}
			} else {
				mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_glove_comp.amount, vehicle_glove_comp.param1, items.name FROM vehicle_glove_comp INNER JOIN items ON items.dbid=vehicle_glove_comp.itemdbid WHERE vehicle_glove_comp.vehicledbid='%d'", GetPVarInt(playerid, "gcomp_vehicledbid"));
				mysql_tquery(mysql_id, queryStr, "onVehicleGCompShow", "dd", playerid, GetPVarInt(playerid, "gcomp_vehicledbid"));
			}
		} case DIALOG_GLOVE_COMP: {
			if(response) {
				new vehicleDBID = GetPVarInt(playerid, "gcomp_vehicledbid");
				new rowIndex = listitem;
				mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_glove_comp.amount, vehicle_glove_comp.param1, vehicle_glove_comp.itemdbid, items.name FROM vehicle_glove_comp INNER JOIN items ON items.dbid=vehicle_glove_comp.itemdbid WHERE vehicledbid='%d' LIMIT %d,1", vehicleDBID, rowIndex);
				mysql_tquery(mysql_id, queryStr, "onVehicleGCompItemSelect", "d", playerid);
			}
		} case DIALOG_INVENTORY_GCOMP: {
		    if(response) {
				new rowIndex = listitem;
				mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount, inventory.param1, inventory.itemdbid, items.name FROM inventory INNER JOIN items ON items.dbid=inventory.itemdbid WHERE inventory.userdbid='%d' LIMIT %d,1", pInfo[playerid][pDBID], rowIndex);
				mysql_tquery(mysql_id, queryStr, "onPlayerInventoryGCompItemSel", "d", playerid);
		    }
		} case DIALOG_INVENTORY_GCOMP_ITEM: {
			if(response) {
				if(isNumeric(inputtext)) {
					new inputAmount = strval(inputtext);
					if(inputAmount > 0) {
						new itemName[64];
						GetPVarString(playerid, "invgcomp_selected_name", itemName, sizeof(itemName));
						new itemAmount = GetPVarInt(playerid, "invgcomp_selected_amount");
						new itemParam1 = GetPVarInt(playerid, "invgcomp_selected_param1");
						new itemDBID = GetPVarInt(playerid, "invgcomp_selected_itemdbid");
						new vehicleDBID = GetPVarInt(playerid, "invgcomp_vehicledbid");

						if(itemAmount - inputAmount >= 0) {
							if(itemParam1 == -1) {
								SFCM(playerid, COLOR_CYAN, "(( Beraktál %d db %s-t a jármû kesztyûtartójába! ))", inputAmount, itemName);
							} else {
								SFCM(playerid, COLOR_CYAN, "(( Beraktál %d db %s(%s)-t a jármû kesztyûtartójába! ))", inputAmount, itemName, getVehiclePlateByDBID(itemParam1));
							}
							removeItem(playerid, itemDBID, inputAmount, itemParam1);
							addGloveCompItem(vehicleDBID, itemDBID, inputAmount, itemParam1, playerid);
						} else {
							SCM(playerid, COLOR_ORANGE, "(( Ennyi nincs nálad! ))");
						}
						// Delete PVars
						DeletePVar(playerid, "invgcomp_selected_name");
						DeletePVar(playerid, "invgcomp_selected_amount");
						DeletePVar(playerid, "invgcomp_selected_param1");
						DeletePVar(playerid, "invgcomp_selected_itemdbid");
						DeletePVar(playerid, "invgcomp_vehicledbid");
					}
				} else {
					SCM(playerid, COLOR_ORANGE, "(( Csak szám lehet! ))");
					mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_glove_comp.amount, vehicle_glove_comp.param1, items.name FROM vehicle_glove_comp INNER JOIN items ON items.dbid=vehicle_glove_comp.itemdbid WHERE vehicle_glove_comp.vehicledbid='%d'", GetPVarInt(playerid, "gcomp_vehicledbid"));
		            mysql_tquery(mysql_id, queryStr, "onVehicleGCompShow", "dd", playerid, GetPVarInt(playerid, "gcomp_vehicledbid"));
				}
			} else {
				mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_glove_comp.amount, vehicle_glove_comp.param1, items.name FROM vehicle_glove_comp INNER JOIN items ON items.dbid=vehicle_glove_comp.itemdbid WHERE vehicle_glove_comp.vehicledbid='%d'", GetPVarInt(playerid, "gcomp_vehicledbid"));
				mysql_tquery(mysql_id, queryStr, "onVehicleGCompShow", "dd", playerid, GetPVarInt(playerid, "gcomp_vehicledbid"));
			}
		} case DIALOG_TRUNK: {
			if(response) {
				new vehicleDBID = GetPVarInt(playerid, "trunk_vehicledbid");
				new rowIndex = listitem;
				mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_trunks.amount, vehicle_trunks.param1, vehicle_trunks.itemdbid, items.name FROM vehicle_trunks INNER JOIN items ON items.dbid=vehicle_trunks.itemdbid WHERE vehicledbid='%d' LIMIT %d,1", vehicleDBID, rowIndex);
				mysql_tquery(mysql_id, queryStr, "onVehicleTrunkItemSelect", "d", playerid);
			}
		} case DIALOG_TRUNK_ITEM: {
			if(response) {
				if(isNumeric(inputtext)) {
					new inputAmount = strval(inputtext);
					if(inputAmount > 0) {
						new itemName[64];
						new itemAmount = 0;
						new itemParam1 = -1;
						new itemDBID = -1;

						new vehicleDBID = GetPVarInt(playerid, "trunk_vehicledbid");

						GetPVarString(playerid, "trunk_selected_name", itemName, sizeof(itemName));
						itemAmount = GetPVarInt(playerid, "trunk_selected_amount");
						itemParam1 = GetPVarInt(playerid, "trunk_selected_param1");
						itemDBID = GetPVarInt(playerid, "trunk_selected_itemdbid");

						if(itemAmount - inputAmount >= 0) {
							if(itemParam1 == -1) {
								SFCM(playerid, COLOR_CYAN, "(( Kivettél %d db %s-t a csomagtartóból! ))", inputAmount, itemName);
							} else {
								SFCM(playerid, COLOR_CYAN, "(( Kivettél %d db %s(%s)-t a csomagtartóból! ))", inputAmount, itemName, getVehiclePlateByDBID(itemParam1));
							}
							removeTrunkItem(vehicleDBID, itemDBID, inputAmount, itemParam1);
							addItem(playerid, itemDBID, inputAmount, itemParam1);
						} else {
							SCM(playerid, COLOR_ORANGE, "(( Ennyi nincs a csomagtartóban! ))");
						}
						// Deleting PVars
						DeletePVar(playerid, "trunk_selected_name");
						DeletePVar(playerid, "trunk_selected_amount");
						DeletePVar(playerid, "trunk_selected_param1");
						DeletePVar(playerid, "trunk_selected_itemdbid");
						DeletePVar(playerid, "trunk_vehicledbid");
					} else {
						SCM(playerid, COLOR_ORANGE, "(( Túl kevés! ))");
						mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_trunks.amount, vehicle_trunks.param1, items.name FROM vehicle_trunks INNER JOIN items ON items.dbid=vehicle_trunks.itemdbid WHERE vehicle_trunks.vehicledbid='%d'", GetPVarInt(playerid, "trunk_vehicledbid"));
		                mysql_tquery(mysql_id, queryStr, "onVehicleTrunkShow", "dd", playerid, GetPVarInt(playerid, "trunk_vehicledbid"));
					}
				} else {
					SCM(playerid, COLOR_ORANGE, "(( Csak szám lehet! ))");
					mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_trunks.amount, vehicle_trunks.param1, items.name FROM vehicle_trunks INNER JOIN items ON items.dbid=vehicle_trunks.itemdbid WHERE vehicle_trunks.vehicledbid='%d'", GetPVarInt(playerid, "trunk_vehicledbid"));
	                mysql_tquery(mysql_id, queryStr, "onVehicleTrunkShow", "dd", playerid, GetPVarInt(playerid, "trunk_vehicledbid"));
				}
			} else {
				mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_trunks.amount, vehicle_trunks.param1, items.name FROM vehicle_trunks INNER JOIN items ON items.dbid=vehicle_trunks.itemdbid WHERE vehicle_trunks.vehicledbid='%d'", GetPVarInt(playerid, "trunk_vehicledbid"));
                mysql_tquery(mysql_id, queryStr, "onVehicleTrunkShow", "dd", playerid, GetPVarInt(playerid, "trunk_vehicledbid"));
			}
		}
		case DIALOG_KEYS: {
			if(response) {
				new vehicleDBID = getVehicleDBIDFromPlate(inputtext);
				SetPVarInt(playerid, "key_vehicledbid", vehicleDBID);
				new dialogTitle[64];
				format(dialogTitle, sizeof(dialogTitle), "[ {77abff}%s{FFFFFF}(%s) ]", vehicleNames[GetVehicleModel(vInfo[vehicleDBID][vID])-400], inputtext);
				// Kinyit/Bezár\nParkol (player)
				// Kinyit/Bezár\nParkol\nRespawn\nIdehoz\nOdamegy\nFeltankol\nMegjavít (3 admin)
				//TODO
				new dialogStr[256];
				if(getPlayerAdminPermission(playerid) >= 4) format(dialogStr, sizeof(dialogStr), "%s\nParkol\nRespawn\nIdehoz\nOdamegy\nMegjavít\nFeltankol", vInfo[vehicleDBID][vLocked] ? ("Kinyit") : ("Bezár"));
				else format(dialogStr, sizeof(dialogStr), "%s\nParkol", vInfo[vehicleDBID][vLocked] ? ("Kinyit") : ("Bezár"));
				ShowPlayerDialog(playerid, DIALOG_KEYS_KEY, DIALOG_STYLE_LIST, dialogTitle, dialogStr, "Mehet", "Mégse");
			}
		}
		case DIALOG_KEYS_KEY: {
			if(response) {
				new vehicleDBID = GetPVarInt(playerid, "key_vehicledbid");
				switch(listitem) {
					case 0: { // Lock- and unlock the door
						if(getDistanceToCar(playerid, vInfo[vehicleDBID][vID]) <= 30) {
							PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
							new engine, lights, alarm, doors, bonnet, boot, objective;
							GetVehicleParamsEx(vInfo[vehicleDBID][vID], engine, lights, alarm, doors, bonnet, boot, objective);
							if(vInfo[vehicleDBID][vLocked]) {
								vInfo[vehicleDBID][vLocked] = false;
								doQuery("UPDATE vehicles SET locked='0' WHERE dbid='%d'", vehicleDBID);
								PC_EmulateCommand(playerid, "/me kinyitott egy jármûvet");
								SetVehicleParamsEx(vInfo[vehicleDBID][vID], engine, lights, alarm, 0, bonnet, boot, objective);
							} else {
								vInfo[vehicleDBID][vLocked] = true;
								doQuery("UPDATE vehicles SET locked='1' WHERE dbid='%d'", vehicleDBID);
								PC_EmulateCommand(playerid, "/me bezárt egy jármûvet");
								SetVehicleParamsEx(vInfo[vehicleDBID][vID], engine, lights, alarm, 1, bonnet, boot, objective);
							}
						} else SCM(playerid, COLOR_ORANGE, "(( Túl messze vagy a jármûtõl! ))");
					} case 1: { // Park the car
						if(getDistanceToCar(playerid, vInfo[vehicleDBID][vID]) <= 30) {
							SCM(playerid, COLOR_GREEN, "(( Leparkoltad a jármûvedet! Mostantól itt fog parkolni! ))");
							parkCar(vehicleDBID);
						} else SCM(playerid, COLOR_ORANGE, "(( Túl messze vagy a jármûtõl! ))");
					} case 2: { // Respawn
						SFCM(playerid, COLOR_GREEN, "(( Respawnoltad a jármûvet. (DBID = %d) ))", vehicleDBID);
						SetVehicleToRespawn(vInfo[vehicleDBID][vID]);
					} case 3: { // Getcar
						EmulateFormattedCommand(playerid, "/getcar %d", vehicleDBID);
					} case 4: { // Gotocar
						EmulateFormattedCommand(playerid, "/gotocar %d", vehicleDBID);
					} case 5: { // Fixveh
						EmulateFormattedCommand(playerid, "/fixveh %d", vehicleDBID);
					} case 6: { // Fuel
						SCM(playerid, -1, "TODO");
					}
				}
			} else {
				mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.param1, vehicles.model FROM inventory INNER JOIN vehicles ON vehicles.dbid=inventory.param1 WHERE inventory.userdbid='%d' AND inventory.itemdbid='2' AND inventory.amount>='1'", pInfo[playerid][pDBID]);
			    mysql_tquery(mysql_id, queryStr, "showPlayerKeys", "");
			}
		}
		case DIALOG_AREPORT: {
			if(response) {
				new areportNames[2][64];
				strexplode(areportNames, inputtext, "-");
				strtrim(areportNames[0]);
				joinReportChannel(playerid, getReportDBIDBySName(areportNames[0]));

				if(!pInfo[playerid][P_TEMP][2]) {
					SFAM(1, COLOR_TOMATO, "*AdmCmd* %s %s átlépett a(z) '%s' kategóriába", getPlayerAdminRank(playerid), getName(playerid), areportNames[0]);
				}
				SFCM(playerid, COLOR_GREEN, "(( Átléptél a(z) '%s' kategóriába! ))", areportNames[0]);
			}
		}
		case DIALOG_REPORT: {
			if(response) {
				new reportNames[2][64];
				strexplode(reportNames, inputtext, "-");
				strtrim(reportNames[0]);
				new reportDBID = getReportDBIDBySName(reportNames[0]);
				SetPVarInt(playerid, "report_selected_cat", reportDBID);
				new dialogStr[128];

				switch(rInfo[reportDBID][rType]) {
					case 0: {
						format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg az üzeneted amit el szeretnél küldeni a(z) {%s}%s {ffffff}kategóriába!", rInfo[reportDBID][rColor], reportNames[0]);
						ShowPlayerDialog(playerid, DIALOG_REPORT_MSG, DIALOG_STYLE_INPUT, "[ {77abff}Jelentés írás{FFFFFF} ]", dialogStr, "Küldés", "Mégse");
					} case 1: {
						sendMsgInCategory(playerid, reportDBID, "VÉSZHELYZETBEN VAN!");
						SCM(playerid, -1, getStrMsg(STR_RS));
					} case 2: { // AFK channel
						SCM(playerid, -1, getStrMsg(STR_EO));
					} case 3: { // All channel
						SCM(playerid, -1, getStrMsg(STR_EO));
					}
				}
			}
		}
		case DIALOG_REPORT_MSG: {
			if(response) {
				if(strlen(inputtext) >= 2) {
					sendMsgInCategory(playerid, GetPVarInt(playerid, "report_selected_cat"), inputtext);
					SCM(playerid, -1, getStrMsg(STR_RS));
					SFCM(playerid, COLOR_YELLOW, "(( *%s* %s ))", rInfo[GetPVarInt(playerid, "report_selected_cat")][rSName], inputtext);
				} else SCM(playerid, -1, getStrMsg(STR_TS));
			}
		}
		case DIALOG_INVENTORY_ITEM: {
			if(response) {
				switch(listitem) {
					case 0: { // Use
						if(playerItem(playerid, GetPVarInt(playerid, "inv_selected_itemdbid")) > 0) {
							useItem(playerid, GetPVarInt(playerid, "inv_selected_itemdbid"));
						} else {
							SFCM(playerid, COLOR_DARKRED, "(( Hiba történt a(z) %s felhasználása közben! ))", GetPVarInt(playerid, "inv_selected_name"));
						}
						// Delete PVars
						DeletePVar(playerid, "inv_selected_name");
						DeletePVar(playerid, "inv_selected_amount");
						DeletePVar(playerid, "inv_selected_param1");
						DeletePVar(playerid, "inv_selected_itemdbid");
					} case 1: { // Give it to a player
						new itemName[64];
						GetPVarString(playerid, "inv_selected_name", itemName, sizeof(itemName));
						new itemParam1 = GetPVarInt(playerid, "inv_selected_param1");

						new dialogTitle[64];
						format(dialogTitle, sizeof(dialogTitle), "[ {77abff}%s{FFFFFF} átadása ]", itemName);
						new dialogStr[256];
						if(itemParam1 == -1) format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg kinek szeretnéd átadni a(z) {77cdff}%s{ffffff}-t!", itemName);
						else format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg kinek szeretnéd átadni a(z) {77cdff}%s{ffffff}(%s)-t!", itemName, getVehiclePlateByDBID(itemParam1));
						ShowPlayerDialog(playerid, DIALOG_INVENTORY_GIVETO, DIALOG_STYLE_INPUT, dialogTitle, dialogStr, "Mehet", "Mégse");
					} case 2: { // Drop
						new itemName[64];
						GetPVarString(playerid, "inv_selected_name", itemName, sizeof(itemName));
						new itemAmount = GetPVarInt(playerid, "inv_selected_amount");
						new itemParam1 = GetPVarInt(playerid, "inv_selected_param1");

						new dialogTitle[64];
						format(dialogTitle, sizeof(dialogTitle), "[ {77abff}%s{FFFFFF} eldobása ]", itemName);
						new dialogStr[256];
						if(itemParam1 == -1) format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg mennyi {77cdff}%s{ffffff}-t szeretnél eldobni (van nálad %d db)!", itemName, itemAmount);
						else format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg mennyi {77cdff}%s{ffffff}(%s)-t szeretnél eldobni (van nálad %d db)!", itemName, getVehiclePlateByDBID(itemParam1), itemAmount);
						ShowPlayerDialog(playerid, DIALOG_INVENTORY_DROP, DIALOG_STYLE_INPUT, dialogTitle, dialogStr, "Eldob", "Mégse");
					}
				}
			}
		}
		case DIALOG_INVENTORY_GIVETO_NUM: {
			if(response) {
				if(isNumeric(inputtext)) {
					new inputAmount = strval(inputtext);
					if(inputAmount > 0) {
						new id = GetPVarInt(playerid, "inv_selected_giveto_pid");
						if(Float:GetDistanceBetweenPlayers(playerid, id) <= 5.0) {
							new itemName[64];
							GetPVarString(playerid, "inv_selected_name", itemName, sizeof(itemName));
							new itemParam1 = GetPVarInt(playerid, "inv_selected_param1");
							new itemAmount = GetPVarInt(playerid, "inv_selected_amount");
							new itemDBID = GetPVarInt(playerid, "inv_selected_itemdbid");

							if(itemAmount - inputAmount >= 0) {
								if(itemParam1 == -1) {
									SFCM(playerid, COLOR_CYAN, "(( Átadtál %d db %s-t %s-nak/nek! ))", inputAmount, itemName, getName(id));
									SFCM(id, COLOR_CYAN, "(( %s átadott neked %d db %s-t! ))", getName(playerid), itemAmount, itemName);

									serverLogFormatted(2, "%s átadott %s-nak/nek %ddb %s-t", getName(playerid), getName(id), itemAmount, itemName);
								} else {
									SFCM(playerid, COLOR_CYAN, "(( Átadtál %d db %s(%s)-t %s-nak/nek! ))", inputAmount, itemName, getVehiclePlateByDBID(itemParam1), getName(id));
									SFCM(id, COLOR_CYAN, "(( %s átadott neked %d db %s(%s)-t! ))", getName(playerid), itemAmount, itemName, getVehiclePlateByDBID(itemParam1));

									serverLogFormatted(2, "%s átadott %s-nak/nek %ddb %s(%s)-t", getName(playerid), getName(id), itemAmount, itemName, getVehiclePlateByDBID(itemParam1));
								}
								removeItem(playerid, itemDBID, inputAmount, itemParam1);
								addItem(id, itemDBID, inputAmount, itemParam1);
							} else {
								SCM(playerid, COLOR_ORANGE, "(( Ennyi nincs nálad! ))");
							}
							// Delete PVars
							DeletePVar(playerid, "inv_selected_name");
							DeletePVar(playerid, "inv_selected_amount");
							DeletePVar(playerid, "inv_selected_param1");
							DeletePVar(playerid, "inv_selected_itemdbid");
							DeletePVar(playerid, "inv_selected_giveto_pid");
						} else SCM(playerid, COLOR_ORANGE, "(( A játékos nincs a közeledben! ))");
					} else SCM(playerid, COLOR_ORANGE, "(( Túl kevés! ))");
				} else {
					SCM(playerid, COLOR_ORANGE, "(( Csak szám lehet! ))");
				}
			}
		}
		case DIALOG_INVENTORY_GIVETO: {
			if(response) {
				new id = ReturnUser(inputtext);
				if(isValidPlayer(id)) {
					if(id != playerid) {
						if(Float:GetDistanceBetweenPlayers(playerid, id) <= 5.0) {
							new itemName[64];
							GetPVarString(playerid, "inv_selected_name", itemName, sizeof(itemName));
							new itemParam1 = GetPVarInt(playerid, "inv_selected_param1");
							new itemAmount = GetPVarInt(playerid, "inv_selected_amount");

							SetPVarInt(playerid, "inv_selected_giveto_pid", id);

							new dialogTitle[64];
							format(dialogTitle, sizeof(dialogTitle), "[ {77abff}%s{FFFFFF} átadása {77abff}%s{FFFFFF}-nak/nek ]", itemName, getName(id));
							new dialogStr[256];
							if(itemParam1 == -1) format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg mennyi {77cdff}%s{ffffff}-t szeretnél átadni {77cdff}%s{ffffff}-nak/nek! (van nálad %d db)", itemName, getName(id), itemAmount);
							else format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg mennyi {77cdff}%s{ffffff}(%s)-t szeretnél átadni {77cdff}%s{ffffff}-nak/nek! (van nálad %d db)", itemName, getVehiclePlateByDBID(itemParam1), getName(id), itemAmount);
							ShowPlayerDialog(playerid, DIALOG_INVENTORY_GIVETO_NUM, DIALOG_STYLE_INPUT, dialogTitle, dialogStr, "Átad", "Mégse");
						} else {
							SCM(playerid, COLOR_ORANGE, "(( A játékos nincs a közeledben! ))");

							// Show dialog every time s/he enters a wrong id
							new itemName[64];
							GetPVarString(playerid, "inv_selected_name", itemName, sizeof(itemName));
							new itemParam1 = GetPVarInt(playerid, "inv_selected_param1");

							new dialogTitle[64];
							format(dialogTitle, sizeof(dialogTitle), "[ {77abff}%s{FFFFFF} átadása ]", itemName);
							new dialogStr[256];
							if(itemParam1 == -1) format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg kinek szeretnéd átadni a(z) {77cdff}%s{ffffff}-t!", itemName);
							else format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg kinek szeretnéd átadni a(z) {77cdff}%s{ffffff}(%s)-t!", itemName, getVehiclePlateByDBID(itemParam1));
							ShowPlayerDialog(playerid, DIALOG_INVENTORY_GIVETO, DIALOG_STYLE_INPUT, dialogTitle, dialogStr, "Mehet", "Mégse");
						}
					} else SCM(playerid, COLOR_ORANGE, "(( Magadnak nem adhatod át! ))");
				} else {
					SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen játékos! ))");

					// Show dialog every time s/he enters a wrong id
					new itemName[64];
					GetPVarString(playerid, "inv_selected_name", itemName, sizeof(itemName));
					new itemParam1 = GetPVarInt(playerid, "inv_selected_param1");

					new dialogTitle[64];
					format(dialogTitle, sizeof(dialogTitle), "[ {77abff}%s{FFFFFF} átadása ]", itemName);
					new dialogStr[256];
					if(itemParam1 == -1) format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg kinek szeretnéd átadni a(z) {77cdff}%s{ffffff}-t!", itemName);
					else format(dialogStr, sizeof(dialogStr), "{ffffff}Add meg kinek szeretnéd átadni a(z) {77cdff}%s{ffffff}(%s)-t!", itemName, getVehiclePlateByDBID(itemParam1));
					ShowPlayerDialog(playerid, DIALOG_INVENTORY_GIVETO, DIALOG_STYLE_INPUT, dialogTitle, dialogStr, "Mehet", "Mégse");
				}
			}
		}
		case DIALOG_INVENTORY_DROP: {
			if(response) {
				if(isNumeric(inputtext)) {
					new inputAmount = strval(inputtext);
					if(inputAmount > 0) {
						new itemName[64];
						GetPVarString(playerid, "inv_selected_name", itemName, sizeof(itemName));
						new itemAmount = GetPVarInt(playerid, "inv_selected_amount");
						new itemParam1 = GetPVarInt(playerid, "inv_selected_param1");
						new itemDBID = GetPVarInt(playerid, "inv_selected_itemdbid");

						if(itemAmount - inputAmount >= 0) {
							if(itemParam1 == -1) {
								SFCM(playerid, COLOR_CYAN, "(( Eldobtál %d db %s-t a táskádból! ))", inputAmount, itemName);
							} else {
								SFCM(playerid, COLOR_CYAN, "(( Eldobtál %d db %s(%s)-t a táskádból! ))", inputAmount, itemName, getVehiclePlateByDBID(itemParam1));
							}
							removeItem(playerid, itemDBID, inputAmount, itemParam1);
						} else {
							SCM(playerid, COLOR_ORANGE, "(( Ennyi nincs nálad! ))");
						}
						// Delete PVars
						DeletePVar(playerid, "inv_selected_name");
						DeletePVar(playerid, "inv_selected_amount");
						DeletePVar(playerid, "inv_selected_param1");
						DeletePVar(playerid, "inv_selected_itemdbid");
					} else {
						SCM(playerid, COLOR_ORANGE, "(( Túl kevés! ))");
						mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount as amount, inventory.param1 as param1, items.name as name FROM inventory INNER JOIN items ON items.dbid = inventory.itemdbid WHERE inventory.userdbid='%d'", pInfo[playerid][pDBID]);
					    mysql_pquery(mysql_id, queryStr, "showPlayerInventory", "d", playerid);
					}
				} else {
					SCM(playerid, COLOR_ORANGE, "(( Csak szám lehet! ))");
					mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount as amount, inventory.param1 as param1, items.name as name FROM inventory INNER JOIN items ON items.dbid = inventory.itemdbid WHERE inventory.userdbid='%d'", pInfo[playerid][pDBID]);
				    mysql_pquery(mysql_id, queryStr, "showPlayerInventory", "d", playerid);
				}
			} else {
				mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount as amount, inventory.param1 as param1, items.name as name FROM inventory INNER JOIN items ON items.dbid = inventory.itemdbid WHERE inventory.userdbid='%d'", pInfo[playerid][pDBID]);
			    mysql_pquery(mysql_id, queryStr, "showPlayerInventory", "d", playerid);
			}
		}
		case DIALOG_INVENTORY_TRUNK_ITEM: {
			if(response) {
				if(isNumeric(inputtext)) {
					new inputAmount = strval(inputtext);
					if(inputAmount > 0) {
						new itemName[64];
						GetPVarString(playerid, "invtrunk_selected_name", itemName, sizeof(itemName));
						new itemAmount = GetPVarInt(playerid, "invtrunk_selected_amount");
						new itemParam1 = GetPVarInt(playerid, "invtrunk_selected_param1");
						new itemDBID = GetPVarInt(playerid, "invtrunk_selected_itemdbid");
						new vehicleDBID = GetPVarInt(playerid, "invtrunk_vehicledbid");

						if(itemAmount - inputAmount >= 0) {
							if(itemParam1 == -1) {
								SFCM(playerid, COLOR_CYAN, "(( Beraktál %d db %s-t a jármûbe! ))", inputAmount, itemName);
							} else {
								SFCM(playerid, COLOR_CYAN, "(( Beraktál %d db %s(%s)-t a jármûbe! ))", inputAmount, itemName, getVehiclePlateByDBID(itemParam1));
							}
							removeItem(playerid, itemDBID, inputAmount, itemParam1);
							addTrunkItem(vehicleDBID, itemDBID, inputAmount, itemParam1, playerid);
						} else {
							SCM(playerid, COLOR_ORANGE, "(( Ennyi nincs nálad! ))");
						}
						// Delete PVars
						DeletePVar(playerid, "invtrunk_selected_name");
						DeletePVar(playerid, "invtrunk_selected_amount");
						DeletePVar(playerid, "invtrunk_selected_param1");
						DeletePVar(playerid, "invtrunk_selected_itemdbid");
						DeletePVar(playerid, "invtrunk_vehicledbid");
					}
				} else {
					SCM(playerid, COLOR_ORANGE, "(( Csak szám lehet! ))");
					mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount as amount, inventory.param1 as param1, items.name as name FROM inventory INNER JOIN items ON items.dbid = inventory.itemdbid WHERE inventory.userdbid='%d'", pInfo[playerid][pDBID]);
                    mysql_pquery(mysql_id, queryStr, "showPlayerInventoryForPutTrunk", "dd", playerid, GetPVarInt(playerid, "invtrunk_vehicledbid"));
				}
			} else {
				mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount as amount, inventory.param1 as param1, items.name as name FROM inventory INNER JOIN items ON items.dbid = inventory.itemdbid WHERE inventory.userdbid='%d'", pInfo[playerid][pDBID]);
				mysql_pquery(mysql_id, queryStr, "showPlayerInventoryForPutTrunk", "dd", playerid, GetPVarInt(playerid, "invtrunk_vehicledbid"));
			}
		}
		case DIALOG_INVENTORY_TRUNK: {
		    if(response) {
				new rowIndex = listitem;
				mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount, inventory.param1, inventory.itemdbid, items.name FROM inventory INNER JOIN items ON items.dbid=inventory.itemdbid WHERE inventory.userdbid='%d' LIMIT %d,1", pInfo[playerid][pDBID], rowIndex);
				mysql_tquery(mysql_id, queryStr, "onPlayerInventoryTrunkItemSel", "d", playerid);
		    }
		}
		case DIALOG_INVENTORY: {
			if(response) {
				new rowIndex = listitem;
				mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount, inventory.param1, inventory.itemdbid, items.name FROM inventory INNER JOIN items ON items.dbid=inventory.itemdbid WHERE inventory.userdbid='%d' LIMIT %d,1", pInfo[playerid][pDBID], rowIndex);
				mysql_tquery(mysql_id, queryStr, "onPlayerInventoryItemSelect", "d", playerid);
			}
		}
		case DIALOG_LOGIN: {
			if(response) {
				new password[129];
                new dialogStr[128];
				if(strlen(inputtext) > 0) {
					WP_Hash(password, sizeof(password), inputtext);
					mysql_format(mysql_id, queryStr,sizeof(queryStr), "SELECT dbid FROM users WHERE dbid='%d' AND password='%s'",pInfo[playerid][pDBID], password);
					new Cache:result = mysql_query(mysql_id, queryStr);
                    if(cache_num_rows() == 1) { // If passwords matches
						onPlayerLogin(playerid);
                    } else {
                        if(pInfo[playerid][pLoginTries] >= 3) { // If the user reached the 3 login tries
							SCM(playerid, COLOR_DARKRED, "(( Túl sok próbálkozás! ))");
                            KickPlayer(playerid);
                        } else {
							SFCM(playerid, COLOR_DARKRED, "(( Rossz jelszó! Még %i próbálkozásod van! ))", 3 - pInfo[playerid][pLoginTries]);
							format(dialogStr, sizeof(dialogStr), "{FFFFFF}Üdvözlünk, {77abff}%s{FFFFFF}!\nKérlek, add meg a jelszavad!", getName(playerid));
				            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "[ {77abff}Belépés{FFFFFF} ]", dialogStr, "Belépés", "Mégse");
                            pInfo[playerid][pLoginTries]++;
                        }
                    }
                    cache_delete(result);
				} else {
					SCM(playerid, COLOR_DARKRED, "(( Túl rövid jelszó! ))");
					format(dialogStr, sizeof(dialogStr), "{FFFFFF}Üdvözlünk, {77abff}%s{FFFFFF}!\nKérlek, add meg a jelszavad!", getName(playerid));
		            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "[ {77abff}Belépés{FFFFFF} ]", dialogStr, "Belépés", "Mégse");
				}
			} else {
				Kick(playerid);
			}
		}
    }
    return 1;
}

function onPlayerLogin(playerid) {
    pInfo[playerid][logged] = true;
    SetPlayerColor(playerid, COLOR_WHITE);

	loadPlayerData(playerid, true);

	// serverLog
	serverLogFormatted(1, "%s sikeresen bejelentkezett. DBID = %d, IP = %s", getRawName(playerid), pInfo[playerid][pDBID], getPlayerIP(playerid));

	// last_online
	doQuery("UPDATE users SET last_online=CURRENT_TIMESTAMP WHERE dbid='%d'", pInfo[playerid][pDBID]);

	// ConLog
	for(new i = 0; i < GetPlayerPoolSize() + 1; i++) {
		if(isValidPlayer(i)) {
			if(pInfo[i][P_TEMP][3]) {
				SFCM(i, COLOR_YELLOW, "*ConLog* {77cdff}%s{ffffff} bejelentkezett ({77cdff}%s{ffffff})", getName(playerid), getPlayerIP(playerid));
			}
		}
	}
	//

    mysql_format(mysql_id, queryStr,sizeof(queryStr), "SELECT dbid FROM users WHERE dbid='%d'", pInfo[playerid][pDBID]);
    new Cache:result = mysql_query(mysql_id, queryStr);

    if(cache_num_rows() == 1) {
		SCM(playerid, COLOR_GREEN, "(( Sikeres belépés! ))");
    } else {
		SCM(playerid, COLOR_DARKRED, "(( Hoppá! Valami elromlott, lépj be újra! ))");
        KickPlayer(playerid);
    }
    cache_delete(result);
}

#include <YSI\y_hooks>
hook OnPlayerVehicleDamage(playerid, vehicleid, Float:Damage) {
	new vehicleDBID = getVehicleDBIDFromID(vehicleid);
	new panels, doors, lights, tires;
    GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
    vInfo[vehicleDBID][vConditions][0] = panels;
    vInfo[vehicleDBID][vConditions][1] = doors;
    vInfo[vehicleDBID][vConditions][2] = lights;
    vInfo[vehicleDBID][vConditions][3] = tires;
	if(vInfo[vehicleDBID][vHP] - Damage < 250.0) {
		vInfo[vehicleDBID][vHP] = 250.0;
	} else vInfo[vehicleDBID][vHP] -= Damage;
	return 1;
}

#include <YSI\y_hooks>
hook OnPlayerSpawn(playerid) {
	for(new i = 0; i < 10; i++) {
		SetPlayerSkillLevel(playerid, i, 990);
	}

	for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
		ShowPlayerNameTagForPlayer(playerid, i, false);
	}

	if(pInfo[playerid][logged]) { // Extra security against some exploits. (e.g. RakSAMP client)
		if(pInfo[playerid][pHouse]) {	// If the player doesn't have an assigned house
			// Get the biggest SQL dbid entry for random spawning
			new Cache:result = mysql_query(mysql_id, "SELECT dbid FROM random_spawns ORDER BY dbid DESC LIMIT 1");
			new maxDBID;
			mysql_get_int(0, "dbid", maxDBID);
			cache_delete(result);
			// Get a random record from the table
			mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT pos FROM random_spawns WHERE dbid='%d'", randint(1, maxDBID));
			result = mysql_query(mysql_id, queryStr);
			// Process the raw varchar position into a float array
			new randomSpawnPosRaw[128];
			new Float:randomSpawnPos[3];
			mysql_get_string(0, "pos", randomSpawnPosRaw);
			cache_delete(result);
			sscanf(randomSpawnPosRaw, "p<,>fff", PosEx(randomSpawnPos));
			// Set the player position to the processed array
			SetPlayerPos(playerid, PosEx(randomSpawnPos));
			SCM(playerid, COLOR_WHITE, "(( Mivel nincs beállított lakcímed, ezért az utcán ébredtél! ))");
		} else {
			// TODO setpos to house
			SCM(playerid, COLOR_WHITE, "(( A házadban ébredtél! ))");
		}
		//
		Delete3DTextLabel(pInfo[playerid][P_LABELS][0]); // Delete adminduty label
		SetPlayerSkin(playerid, pInfo[playerid][pSkin][0]); // Set civilian skin
		//
		showNameForFriends(playerid);
		showFriendNamesForPlayer(playerid);
	} else {
		SCM(playerid, COLOR_DARKRED, "(( Hoppá! Valami elromlott, lépj be újra! ))");
		KickPlayer(playerid);
	}
}
