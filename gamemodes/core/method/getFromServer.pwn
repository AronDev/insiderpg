

getVehiclePlateByDBID(vdbid) {
	new plate[32];
	if(vdbid != -1) {
		format(plate, sizeof(plate), vInfo[vdbid][vPlate]);
	} else plate = "";
	return plate;
}

getPlayerRankName(playerid) {
	new rankStr[64];
	if(pInfo[playerid][pFraction] > 0) {
		for(new i = 0; i < MAX_RANKS; i++) {
			if(raInfo[i][raLF] == pInfo[playerid][pFraction]) {
				if(raInfo[i][raID] == pInfo[playerid][pRank]) {
					format(rankStr, sizeof(rankStr), raInfo[i][raName]);
				}
			}
		}
	} else format(rankStr, sizeof(rankStr), raInfo[0][raName]);
	return rankStr;
}

getPlayerFractionText(playerid) {
    new fkString[64];
    if(dInfo[pInfo[playerid][pDivision]][dType] == 0) format(fkString, sizeof(fkString), "%s", fInfo[pInfo[playerid][pFraction]][fSName]);
    else format(fkString, sizeof(fkString), "%s %s", fInfo[pInfo[playerid][pFraction]][fSName], getDivSNameByDivID(pInfo[playerid][pFraction], pInfo[playerid][pDivision]));
    return fkString;
}

getRawName(playerid) {
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}
getPlayerIP(playerid) {
    new ip[16];
    GetPlayerIp(playerid, ip, sizeof(ip));
	return ip;
}

isVehicleOccupied(vehicleid) {
    for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
        if(IsPlayerInVehicle(i, vehicleid)) return 1;
    }
    return 0;
}

getVehicleModelFromName(const vname[]) {
    for(new i = 0; i < 211; i++) {
        if(!strfind(vehicleNames[i], vname, true))
            return i + 400;
    }
    return -1;
}

isValidPlayer(playerid) {
	if(IsPlayerConnected(playerid) && pInfo[playerid][logged])
		return 1;
	else
		return 0;
}

isValidSkin(skinid) {
	if(skinid >= 0 && skinid <= 311) return 1;
	else return 0;
}

getVehicleDBIDFromID(vehicle) {
	new vehicleDBID = -1;
	for(new i = 1, j = GetVehiclePoolSize()+1; i < j; i++) {
		if(isValidVehicle(i)) {
			if(vInfo[i][vID] == vehicle) {
				vehicleDBID = vInfo[i][vDBID];
				break;
			}
		}
	}
	return vehicleDBID;
}

IsPlayerInWater(playerid) {
        new Float:X, Float:Y, Float:Z, an = GetPlayerAnimationIndex(playerid);
        GetPlayerPos(playerid, X, Y, Z);
        if((1544 >= an >= 1538 || an == 1062 || an == 1250) && (Z <= 0 || (Z <= 41.0 && IsPlayerInArea(playerid, -1387, -473, 2025, 2824))) ||
        (1544 >= an >= 1538 || an == 1062 || an == 1250) && (Z <= 2 || (Z <= 39.0 && IsPlayerInArea(playerid, -1387, -473, 2025, 2824)))) {
            return 1;
        }
        return 0;
}

getClosestVehicle(playerid)
{
     if (!IsPlayerConnected(playerid))
     {
          return -1;
     }
     new Float:prevdist = 5;
     new prevcar;
     for (new carid = 0, j = GetVehiclePoolSize()+1; carid < j; carid++)
     {
          new Float:dist = getDistanceToCar(playerid,carid);
          if ((dist < prevdist))
          {
               prevdist = dist;
               prevcar = carid;
          }
     }
     return prevcar;
}

getDistanceToCar(playerid, carid) {
     new Float:dis;
     new Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2;
     if (!IsPlayerConnected(playerid)) {
     	return -1;
     }
     GetPlayerPos(playerid,x1,y1,z1);
     GetVehiclePos(carid,x2,y2,z2);
     dis = floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
     return floatround(dis);
}
