/*
*
* getPlayerAdminPermission(playerid) - Returns the players admin permission from MySQL Server
* getPlayerAdminLevel(playerid) - Returns the players admin id from MySQL Server
*
*/

// getItemDBIDByName
getItemDBIDFromName(name[]) {
	mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT items.dbid FROM items WHERE items.name='%e' LIMIT 1", name);
	new Cache:result = mysql_query(mysql_id, queryStr);
	new itemDBID = -1;
	if(cache_num_rows()) {
		mysql_get_int(0, "dbid", itemDBID);
		SetGVarInt("getItemDBIDFromName", itemDBID);
	} else {
		printf("[SERVER - MYSQL] No rows found (Query: %s)", queryStr);
	}
	cache_delete(result);
	return itemDBID;
}

getMaxFractionRankID(fractionDBID) {
	new rankID = 0;
	mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT rank_id FROM fraction_ranks WHERE linked_fraction='%d' ORDER BY rank_id DESC LIMIT 1", fractionDBID);
	new Cache:result = mysql_query(mysql_id, queryStr);
	if(cache_num_rows()) {
		mysql_get_int(0, "rank_id", rankID);
	} else rankID = -1;
	cache_delete(result);
	return rankID;
}

// getItemNameByDBID
_getItemNameFromDBID(itemDBID) {
	mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT items.name FROM items WHERE items.dbid='%d'", itemDBID);
	mysql_tquery(mysql_id, queryStr, "q_getItemNameFromDBID", "d", itemDBID);
	return 1;
}
function q_getItemNameFromDBID(itemDBID) {
	new itemName[64];
	if(cache_num_rows()) {
		mysql_get_string(0, "name", itemName);
		SetGVarString("getItemNameByDBID", itemName, itemDBID);
	} else {
		printf("[SERVER - MYSQL] No rows found (Query: %s)", queryStr);
	}
	return 1;
}
getItemNameFromDBID(itemDBID) {
	_getItemNameFromDBID(itemDBID);
	new name[64];
	GetGVarString("getItemNameByDBID", name, sizeof(name), itemDBID);
	//DeleteGVar("getItemNameByDBID", itemDBID);
	return name;
}

getVehicleDBID(const vehicle[]) {
	new vdbid = -1;
	if(isNumeric(vehicle)) {
	    vdbid = vInfo[strval(vehicle)][vDBID];
	} else {
	    vdbid = getVehicleDBIDFromPlate(vehicle);
	}

	if(vdbid != -1) {
	    if(isValidVehicle(vdbid)) {
			return vdbid;
	    } else return -1;
	} else return -1;
}

//
getVehicleDBIDFromPlate(const vehiclePlate[]) {
	new vdbid = -1;
	for(new i = 0; i < GetVehiclePoolSize()+1; i++) {
		if(isValidVehicle(i)) {
			if(equals(vInfo[i][vPlate], vehiclePlate)) {
				vdbid = i;
				break;
			}
		}
	}
	return vdbid;
}
//

getCommandPermission(const cmd[]) {
	new perm = -1;

	mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT permission FROM commands WHERE command='%s'", cmd);
	new Cache:result = mysql_query(mysql_id, queryStr);

	if(cache_num_rows()) {
		mysql_get_int(0, "permission", perm);
	} else {
		printf("[SERVER - MYSQL] No rows found (Query: %s)", queryStr);
		return -1;
	}
	cache_delete(result);
	return perm;
}

getPlayerInfo(playerid, const column[]) {
	new columnValue[255];
	mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT %e FROM users WHERE dbid='%d'", column, pInfo[playerid][pDBID]);
	new Cache:result = mysql_query(mysql_id, queryStr);

	if(cache_num_rows())  {
		mysql_get_string(0, column, columnValue);
	} else {
		printf("[SERVER - MYSQL] No rows found (Query: %s)", queryStr);
	}
	cache_delete(result);
	return columnValue;
}

IsSpecialUser(playerid) {
	mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT user_dbid FROM special_users WHERE user_dbid='%d'", pInfo[playerid][pDBID]);
	new Cache:result = mysql_query(mysql_id, queryStr);
	if(cache_num_rows())  {
		cache_delete(result);
		return true;
	} else {
		cache_delete(result);
		return false;
	}
}

isValidItem(item) {
	mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT items.dbid FROM items WHERE items.dbid='%d'", item);
	new Cache:result = mysql_query(mysql_id, queryStr);
	if(cache_num_rows() == 1)  {
		cache_delete(result);
		return true;
	} else {
		cache_delete(result);
		return false;
	}
}

isValidVehicle(vdbid) {
	if(vInfo[vdbid][vExist]) {
		if(IsValidVehicle(vInfo[vdbid][vID])) {
			return true;
		}
	} else return false;
	return true;
}
