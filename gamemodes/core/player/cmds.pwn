/*
*
* Player/admin commands
*
*/

CMD:teleport(playerid, params[]) {
    new t[12];
    if(sscanf(params, "s[12]{}", t)) return SCM(playerid, COLOR_WHITE, "(( Használat: /teleport <típus> ))"), SCM(playerid, COLOR_WHITE, "(( Típusok: add, remove, near, info, goto ))");

    if(equals(t, "add")) {
        new pos;
        new Float:rad;
        new Float:pPos[3];
        if(sscanf(params, "{s[12]}dF(2.0)", pos, rad)) return SCM(playerid, COLOR_WHITE, "(( Használat: /teleport add <pozicíó (0/1)> [hatótáv(=2.0)] ))");

        GetPlayerPos(playerid, PosEx(pPos));

        switch(pos) {
            case 0: {
                SetPVarInt(playerid, "tp_newSaved", 1);
                SetPVarFloat(playerid, "tp_newPosX", pPos[0]);
                SetPVarFloat(playerid, "tp_newPosY", pPos[1]);
                SetPVarFloat(playerid, "tp_newPosZ", pPos[2]);
                SetPVarInt(playerid, "tp_newInt", GetPlayerInterior(playerid));
                SetPVarInt(playerid, "tp_newVW", GetPlayerVirtualWorld(playerid));
                SetPVarFloat(playerid, "tp_newRad", rad);

                SCM(playerid, COLOR_GREEN, "(( Lementetted az elsõ pozicíót! ))");
            } case 1: {
                if(GetPVarInt(playerid, "tp_newSaved") == 1) {

                    new Float:p0, Float:p1, Float:p2, inter, vw, Float:r;
                    p0 = GetPVarFloat(playerid, "tp_newPosX");
                    p1 = GetPVarFloat(playerid, "tp_newPosY");
                    p2 = GetPVarFloat(playerid, "tp_newPosZ");
                    r = GetPVarFloat(playerid, "tp_newRad");
                    inter = GetPVarInt(playerid, "tp_newInt");
                    vw = GetPVarInt(playerid, "tp_newVW");

                    DeletePVar(playerid, "tp_newSaved");

                    mysql_format(mysql_id, queryStr, sizeof(queryStr), "INSERT INTO teleports (`pos1`, `interior1`, `vw1`, `rad1`, `pos2`, `interior2`, `vw2`, `rad2`) VALUES ('%f,%f,%f', '%d', '%d', '%f', '%f,%f,%f', '%d', '%d', '%f')", p0, p1, p2, inter, vw, r, PosEx(pPos), GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid), rad);
                    inline q_InsertNewTeleport() {
                        new dbid = cache_insert_id();
                        SFCM(playerid, COLOR_GREEN, "(( Létrehoztál egy teleportot! DBID = %d ))", dbid);
                        loadTeleport(dbid);
                    }
                    mysql_tquery_inline(mysql_id, queryStr, using inline q_InsertNewTeleport, "");
                } else SCM(playerid, COLOR_ORANGE, "(( Elõbb mentsd le az elsõ pozicíót! ))");
            } default: SCM(playerid, COLOR_ORANGE, "(( Hibás érték! ))");
        }
    } else if(equals(t, "remove") || equals(t, "rem")) {
        new dbid = -1;
        if(sscanf(params, "{s[12]}d", dbid)) return SCM(playerid, COLOR_WHITE, "(( Használat: /teleport remove <dbid> ))");
        if(isValidTeleport(dbid)) {
            SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s törölt egy teleportot. (DBID = %d)", getPlayerAdminRank(playerid), getName(playerid), dbid);
            SFCM(playerid, COLOR_GREEN, "(( Töröltél egy teleportot! DBID = %d ))", dbid);

            clearTeleport(dbid);
        } else SCM(playerid, -1, getStrMsg(STR_NTPF));
    } else if(equals(t, "goto")) {
        new dbid = -1, pos = 0;
        if(sscanf(params, "{s[12]}dI(0)", dbid, pos)) return SCM(playerid, COLOR_WHITE, "(( Használat: /teleport goto <dbid> [pozicíó (0/1)] ))");
        if(isValidTeleport(dbid)) {
            switch(pos) {
                case 0: {
                    SetPlayerPos(playerid, PosEx(tpInfo[dbid][tpPos]));
                    SetPlayerInterior(playerid, tpInfo[dbid][tpInt][0]);
                    SetPlayerVirtualWorld(playerid, tpInfo[dbid][tpVW][0]);
                    SFCM(playerid, COLOR_GREEN, "(( Elteleportáltál egy teleporthoz! (DBID = %d, Pos = %d) ))", dbid, pos);
                } case 1: {
                    SetPlayerPos(playerid, tpInfo[dbid][tpPos][3], tpInfo[dbid][tpPos][4], tpInfo[dbid][tpPos][5]);
                    SetPlayerInterior(playerid, tpInfo[dbid][tpInt][1]);
                    SetPlayerVirtualWorld(playerid, tpInfo[dbid][tpVW][1]);
                    SFCM(playerid, COLOR_GREEN, "(( Elteleportáltál egy teleporthoz! (DBID = %d, Pos = %d) ))", dbid, pos);
                } default: SCM(playerid, COLOR_ORANGE, "(( Hibás érték! ))");
            }
        } else SCM(playerid, -1, getStrMsg(STR_NTPF));
    } else SCM(playerid, -1, getStrMsg(STR_NTF));
    return 1;
}

CMD:whitelist(playerid, params[]) {
    new t[12];
    if(sscanf(params, "s[12]{}", t)) return SCM(playerid, COLOR_WHITE, "(( Használat: /whitelist <típus> ))"), SCM(playerid, COLOR_WHITE, "(( Típusok: add, remove, enable, disable, status, list ))");

    if(equals(t, "add")) {
        new user[MAX_PLAYER_NAME];
        if(sscanf(params, "{s[12]}s[" #MAX_PLAYER_NAME "]", user)) return SCM(playerid, COLOR_WHITE, "(( Használat: /whitelist add <név / dbid> ))");

        addUserToWhitelist(playerid, user);
    } else if(equals(t, "remove") || equals(t, "rem")) {
        new user[MAX_PLAYER_NAME];
        if(sscanf(params, "{s[12]}s[" #MAX_PLAYER_NAME "]", user)) return SCM(playerid, COLOR_WHITE, "(( Használat: /whitelist remove <név / dbid> ))");

        remUserFromWhitelist(playerid, user);
    } else if(equals(t, "list")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s megnézte a whitelist listát", getPlayerAdminRank(playerid), getName(playerid));

        mysql_pquery(mysql_id, "SELECT whitelist.userdbid, whitelist.timestamp, users.name FROM whitelist INNER JOIN users ON users.dbid=whitelist.userdbid", "showPlayerWhitelistList", "d", playerid);

    } else if(equals(t, "enable")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s bekapcsolta a whitelistet", getPlayerAdminRank(playerid), getName(playerid));

        mysql_tquery(mysql_id, "UPDATE config SET whitelist='1' ORDER BY dbid DESC LIMIT 1");
        srvInfo[SRV_WHITELIST] = true;
        SCM(playerid, COLOR_GREEN, "(( Bekapcsoltad a whitelistet! ))");
    } else if(equals(t, "disable")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s kikapcsolt a whitelistet", getPlayerAdminRank(playerid), getName(playerid));

        mysql_tquery(mysql_id, "UPDATE config SET whitelist='0' ORDER BY dbid DESC LIMIT 1");
        srvInfo[SRV_WHITELIST] = false;
        SCM(playerid, COLOR_GREEN, "(( Kikapcsoltad a whitelistet! ))");
    } else if(equals(t, "status")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s megnézte a whitelist állapotát", getPlayerAdminRank(playerid), getName(playerid));

        SFCM(playerid, COLOR_WHITE, "(( Whitelist állapota a szerveren: %s {ffffff}))", srvInfo[SRV_WHITELIST] ? ("{8fff84}Bekapcsolva") : ("{c83250}Kikapcsolva"));
    } else SCM(playerid, -1, getStrMsg(STR_NTF));
    return 1;
}

CMD:csomagtarto(playerid, params[]) {
    new type[12];
    if(sscanf(params, "s[12]", type)) return SCM(playerid, COLOR_WHITE, "(( Használat: /csomagtarto <kinyit / becsuk / tartalom / berak> ))");

    if(equals(type, "kinyit")) {
        new nearVeh = getClosestVehicle(playerid);
        if(getDistanceToCar(playerid, nearVeh) <= 5.0) {
            new vehicleDBID = getVehicleDBIDFromID(nearVeh);
            if(!vInfo[vehicleDBID][vLocked]) {
                new engine, lights, alarm, doors, bonnet, boot, objective;
            	GetVehicleParamsEx(vInfo[vehicleDBID][vID], engine, lights, alarm, doors, bonnet, boot, objective);
                if(!vInfo[vehicleDBID][vTrunk]) {
                    vInfo[vehicleDBID][vTrunk] = true;
                    SetVehicleParamsEx(vInfo[vehicleDBID][vID], engine, lights, alarm, doors, bonnet, 1, objective);
                    playerMe(playerid, "kinyitotta a jármû csomagtartóját");
                    SCM(playerid, COLOR_GREEN, "(( Kinyitottad a jármû csomgagtartóját! ))");
                } else SCM(playerid, COLOR_ORANGE, "(( A csomagtartó már nyitva van! ))");
            } else SCM(playerid, COLOR_ORANGE, "(( A jármû be van zárva! ))");
        } else SCM(playerid, COLOR_ORANGE, "(( Nincs jármû a közeledben! ))");
    } else if(equals(type, "becsuk")) {
        new nearVeh = getClosestVehicle(playerid);
        if(getDistanceToCar(playerid, nearVeh) <= 5.0) {
            new vehicleDBID = getVehicleDBIDFromID(nearVeh);
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vInfo[vehicleDBID][vID], engine, lights, alarm, doors, bonnet, boot, objective);
            if(vInfo[vehicleDBID][vTrunk]) {
                vInfo[vehicleDBID][vTrunk] = false;
                SetVehicleParamsEx(vInfo[vehicleDBID][vID], engine, lights, alarm, doors, bonnet, 0, objective);
                playerMe(playerid, "becsukta a jármû csomagtartóját");
                SCM(playerid, COLOR_GREEN, "(( Becsuktad a jármû csomgagtartóját! ))");
            } else SCM(playerid, COLOR_ORANGE, "(( A csomagtartó már csukva van! ))");
        } else SCM(playerid, COLOR_ORANGE, "(( Nincs jármû a közeledben! ))");
    } else if(equals(type, "tartalom")) {
        if(!IsPlayerInAnyVehicle(playerid)) {
            new nearVeh = getClosestVehicle(playerid);
            if(getDistanceToCar(playerid, nearVeh) <= 5.0) {
                new vehicleDBID = getVehicleDBIDFromID(nearVeh);
                if(vInfo[vehicleDBID][vTrunk]) {
                    playerMe(playerid, "megnézi a csomagtartó tartalmát");
                    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_trunks.amount, vehicle_trunks.param1, items.name FROM vehicle_trunks INNER JOIN items ON items.dbid=vehicle_trunks.itemdbid WHERE vehicle_trunks.vehicledbid='%d'", vehicleDBID);
                    mysql_tquery(mysql_id, queryStr, "onVehicleTrunkShow", "dd", playerid, vehicleDBID);
                    SetPVarInt(playerid, "trunk_vehicledbid", vehicleDBID);
                } else SCM(playerid, COLOR_ORANGE, "(( A csomagtartó be van csukva! ))");
            } else SCM(playerid, COLOR_ORANGE, "(( Nincs jármû a közeledben! ))");
        } else SCM(playerid, COLOR_ORANGE, "(( Jármûben nem használhatod! ))");
    } else if(equals(type, "berak")) {
        if(!IsPlayerInAnyVehicle(playerid)) {
            new nearVeh = getClosestVehicle(playerid);
            if(getDistanceToCar(playerid, nearVeh) <= 5.0) {
                new vehicleDBID = getVehicleDBIDFromID(nearVeh);
                if(vInfo[vehicleDBID][vTrunk]) {
                    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount as amount, inventory.param1 as param1, items.name as name FROM inventory INNER JOIN items ON items.dbid = inventory.itemdbid WHERE inventory.userdbid='%d'", pInfo[playerid][pDBID]);
                    mysql_pquery(mysql_id, queryStr, "showPlayerInventoryForPutTrunk", "dd", playerid, vehicleDBID);
                } else SCM(playerid, COLOR_ORANGE, "(( A csomagtartó be van csukva! ))");
            } else SCM(playerid, COLOR_ORANGE, "(( Nincs jármû a közeledben! ))");
        } else SCM(playerid, COLOR_ORANGE, "(( Jármûben nem használhatod! ))");
    } else SCM(playerid, -1, getStrMsg(STR_NTF));
    return 1;
}

CMD:newcar(playerid, params[]) {
    new model[12], colors[2];
    if(sscanf(params, "s[12]I(1)I(1)", model, colors[0], colors[1])) return SCM(playerid, COLOR_WHITE, "(( Használat: /newcar <model> [szín 1] [szín 2] ))");

    new vehicleModel = getVehicleModelFromName(model);

    new Float:pPos[3] = {0.0, 0.0, 0.0};

    GetPlayerPos(playerid, PosEx(pPos));

    if(vehicleModel == -1) {
        vehicleModel = strval(model);
        if(vehicleModel < 400 || vehicleModel > 611)
            return SCM(playerid, -1, getStrMsg(STR_NVMF));
    }

    new newcarPlate[32];
    format(newcarPlate, sizeof(newcarPlate), randomPlate(vehicleModel));

    mysql_format(mysql_id, queryStr, sizeof(queryStr), "INSERT INTO vehicles (model, color, plate, pos) VALUES ('%d','%d,%d','%s', '%f,%f,%f,0.0')", vehicleModel, colors[0], colors[1], newcarPlate, PosEx(pPos));
    inline q_newCar() {
        new vehicleDBID = cache_insert_id();

        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s létrehozott egy %s(%d)-t (DBID = %d, Rendszám = %s)", getPlayerAdminRank(playerid), getName(playerid), vehicleNames[vehicleModel-400], vehicleModel, vehicleDBID, newcarPlate);

        if(!pInfo[playerid][P_TEMP][2]) {
            SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s létrehozott egy %s(%d)-t (DBID = %d, Rendszám = %s)", getPlayerAdminRank(playerid), getName(playerid), vehicleNames[vehicleModel-400], vehicleModel, vehicleDBID, newcarPlate);
        }
        SFCM(playerid, COLOR_GREEN, "(( Létrehoztál egy jármûvet! (DBID = %d, Rendszám: %s ) ))", vehicleDBID, newcarPlate);

        addGloveCompItem(vehicleDBID, 2, 2, vehicleDBID);
        spawnVehicle(vehicleDBID);
    }
    mysql_tquery_inline(mysql_id, queryStr, using inline q_newCar, "");
    return 1;
}

CMD:kesztyutarto(playerid, params[]) {
    if(IsPlayerInAnyVehicle(playerid)) {
        new t[12];
        if(sscanf(params, "s[12]", t)) return SCM(playerid, COLOR_WHITE, "(( Használat: /kesztyutarto <tartalom / berak> ))");

        new vehicleDBID = getVehicleDBIDFromID(GetPlayerVehicleID(playerid));

        if(equals(t, "tartalom")) {
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_glove_comp.amount, vehicle_glove_comp.param1, items.name FROM vehicle_glove_comp INNER JOIN items ON items.dbid=vehicle_glove_comp.itemdbid WHERE vehicle_glove_comp.vehicledbid='%d'", vehicleDBID);
            mysql_tquery(mysql_id, queryStr, "onVehicleGCompShow", "dd", playerid, vehicleDBID);
            SetPVarInt(playerid, "gcomp_vehicledbid", vehicleDBID);
        } else if(equals(t, "berak")) {
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount as amount, inventory.param1 as param1, items.name as name FROM inventory INNER JOIN items ON items.dbid = inventory.itemdbid WHERE inventory.userdbid='%d'", pInfo[playerid][pDBID]);
            mysql_pquery(mysql_id, queryStr, "showPlayerInventoryForPutGComp", "dd", playerid, vehicleDBID);
        } else SCM(playerid, -1, getStrMsg(STR_NTF));
    } else SCM(playerid, -1, getStrMsg(STR_OAIV));
    return 1;
}

CMD:changecar(playerid, params[]) {
    new param[12];
    if(sscanf(params, "s[12]{}", param)) return SCM(playerid, COLOR_WHITE, "(( Használat: /changecar <típus> ))"), SCM(playerid, COLOR_WHITE, "(( Típusok: model, siren, plate, color ))");

    if(equals(param, "model")) {
        new model[12], vehicle[32];
        if(sscanf(params, "{s[12]}s[32]s[12]", vehicle, model)) return SCM(playerid, COLOR_WHITE, "(( Használat: /changecar model <jármû> <model> ))");

        new vehicleDBID = getVehicleDBID(vehicle);

        if(vehicleDBID != -1) {
            // Get the model id
            new vehicleModel = getVehicleModelFromName(model);
            if(vehicleModel == -1) {
                vehicleModel = strval(model);
    			if(vehicleModel < 400 || vehicleModel > 611)
                    return SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen jármû model! ))");
    		}
            //
            doQuery("UPDATE vehicles SET model='%d' WHERE dbid='%d'", vehicleModel, vehicleDBID);
            saveVehicle(vehicleDBID, true);
            SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította a(z) %s(%d) jármûnek a modeljét %s(%d)-ra/re", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID, vehicleNames[vehicleModel-400], vehicleModel);
            SFCM(playerid, COLOR_GREEN, "(( Átállítottad a(z) %s(%d) jármûnek a modeljét %s(%d)-ra/re! ))", vInfo[vehicleDBID][vPlate], vehicleDBID, vehicleNames[vehicleModel-400], vehicleModel);
        } else SCM(playerid, -1, getStrMsg(STR_NVF));
    } else if(equals(param, "color")) {
        new c[2], vehicle[32];
        if(sscanf(params, "{s[12]}s[32]dd", vehicle, c[0], c[1])) return SCM(playerid, COLOR_WHITE, "(( Használat: /changecar color <jármû> <szín 1> <szín 2> ))");

        new vehicleDBID = getVehicleDBID(vehicle);

        if(vehicleDBID != -1) {
            doQuery("UPDATE vehicles SET color='%d,%d' WHERE dbid='%d'", c[0], c[1], vehicleDBID);
            ChangeVehicleColor(vInfo[vehicleDBID][vID], c[0], c[1]);
            vInfo[vehicleDBID][vColor][0] = c[0];
            vInfo[vehicleDBID][vColor][1] = c[1];

            // serverLog
            serverLogFormatted(5, "*AdmCmd* %s %s átállított a(z) %s(%d) járműnek a színét (%d, %d)", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID, c[0], c[1]);

            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította a(z) %s(%d) jármûnek a színét", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID);
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* Új szín: %s(%d), %s(%d)", vehicleColors[c[0]], c[0], vehicleColors[c[1]], c[1]);
            }
            SFCM(playerid, COLOR_GREEN, "(( Átállítottad a(z) %s(%d) jármûnek a színét! ))", vInfo[vehicleDBID][vPlate], vehicleDBID);
            SFCM(playerid, COLOR_GREEN, "(( Új szín: %s(%d), %s(%d) ))", vehicleColors[c[0]], c[0], vehicleColors[c[1]], c[1]);
        } else SCM(playerid, -1, getStrMsg(STR_NVF));
    } else if(equals(param, "plate")) {
        new newPlate[32], vehicle[32];
        if(sscanf(params, "{s[12]}s[32]s[32]", vehicle, newPlate)) return SCM(playerid, COLOR_WHITE, "(( Használat: /changecar plate <jármû> <rendszám> ))");

        new vehicleDBID = getVehicleDBID(vehicle);

        if(vehicleDBID != -1) {
            if(equals(newPlate, "_RAND_")) {
                format(newPlate, sizeof(newPlate), randomPlate(vehicleDBID));
            }

            // serverLog
            serverLogFormatted(5, "*AdmCmd* %s %s átállított a(z) %s(%d) járműnek a rendszámát %s-ra/re", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID, newPlate);

            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította a(z) %s(%d) jármûnek a rendszámát %s-ra/re", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID, newPlate);
            }
            SFCM(playerid, COLOR_GREEN, "(( Átállítottad a(z) %s(%d) jármûnek a rendszámát %s-ra/re! ))", vInfo[vehicleDBID][vPlate], vehicleDBID, newPlate);
            format(vInfo[vehicleDBID][vPlate], 32, newPlate);
            doQuery("UPDATE vehicles SET plate='%s' WHERE dbid='%d'", newPlate, vehicleDBID);
            saveVehicle(vehicleDBID, true);
        } else SCM(playerid, -1, getStrMsg(STR_NVF));
    } else if(equals(param, "siren")) {
        new siren, vehicle[32];
        if(sscanf(params, "{s[12]}s[32]d", vehicle, siren)) return SCM(playerid, COLOR_WHITE, "(( Használat: /changecar siren <jármû> <0 / 1> ))");

        new vehicleDBID = getVehicleDBID(vehicle);

        if(vehicleDBID != -1) {
            if(siren >= 0 && siren <= 1) {
                if(!pInfo[playerid][P_TEMP][2]) {
                    switch(siren) {
                        case 0: SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s kiszerelte a(z) %s(%d) jármûbõl a szirénát", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID);
                        case 1: SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s beszerelte a(z) %s(%d) jármûbe a szirénát", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID);
                    }
                }
                switch(siren) {
                    case 0: {
                        // serverLog
                        serverLogFormatted(5, "*AdmCmd* %s %s kiszerelte a(z) %s(%d) jármûbõl a szirénát", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID);

                        SFCM(playerid, COLOR_GREEN, "(( Kiszerelted a(z) %s(%d) jármûbõl a szirénát! ))", vInfo[vehicleDBID][vPlate], vehicleDBID);
                    } case 1: {
                        // serverLog
                        serverLogFormatted(5, "*AdmCmd* %s %s beszerelte a(z) %s(%d) jármûbe a szirénát", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID);

                        SFCM(playerid, COLOR_GREEN, "(( Beszerelted a(z) %s(%d) jármûbe a szirénát! ))", vInfo[vehicleDBID][vPlate], vehicleDBID);
                    }
                }
                vInfo[vehicleDBID][vSiren] = siren == 0 ? false : true;
                doQuery("UPDATE vehicles SET siren='%d' WHERE dbid='%d'", siren, vehicleDBID);
                saveVehicle(vehicleDBID, true);
            } else SCM(playerid, COLOR_ORANGE, "(( Érvénytelen érték! ))");
        } else SCM(playerid, -1, getStrMsg(STR_NVF));
    }
    else SCM(playerid, -1, getStrMsg(STR_NTF));
    return 1;
}

CMD:online(playerid, params[]) {
    SFCM(playerid, COLOR_WHITE, "(( Online töltött idõ {77cdff}%d{ffffff} mp. ))", NetStats_GetConnectedTime(playerid)/1000);
    return 1;
}

CMD:skinvalto(playerid, params[]) {
    new playerID;
    if(sscanf(params, "u", playerID)) return SCM(playerid, COLOR_WHITE, "(( Használat: /skinvalto <id / név> ))");

    if(isValidPlayer(playerID)) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s munkaruha választóba rakta %s-t", getPlayerAdminRank(playerid), getName(playerid), getName(playerID));

        if(!pInfo[playerid][P_TEMP][2]) {
            SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s munkaruha választóba rakta %s-t", getPlayerAdminRank(playerid), getName(playerid), getName(playerID));
        }
        SFCM(playerid, COLOR_GREEN, "(( Munkaruha választóba raktad %s-t! ))", getName(playerID));
        SFCM(playerID, COLOR_GREEN, "(( %s %s munkaruha választóba rakott! ))", getPlayerAdminRank(playerid), getName(playerid));
        setPlayerInSkinChanger(playerID);
    } else SCM(playerid, -1, getStrMsg(STR_NPF));
    return 1;
}

CMD:parkcar(playerid) {
    if(IsPlayerInAnyVehicle(playerid)) {
        new vehicleDBID = getVehicleDBIDFromID(GetPlayerVehicleID(playerid));
        if(isValidVehicle(vehicleDBID)) {
            // serverLog
            serverLogFormatted(5, "*AdmCmd* %s %s leparkolta a(z) %s(%d) jármûvet", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID);

            SFCM(playerid, COLOR_GREEN, "(( Leparkoltad a(z) %s(%d) jármûvet! ))", vInfo[vehicleDBID][vPlate], vehicleDBID);
            parkCar(vehicleDBID);
        } else SCM(playerid, -1, getStrMsg(STR_NVF));
    } else SCM(playerid, COLOR_ORANGE, "(( Nem ülsz jármûben! ))");
    return 1;
}

CMD:setint(playerid, params[]) {
    new id, newInt;
    if(sscanf(params, "uI(0)", id, newInt)) return SCM(playerid, COLOR_WHITE, "(( Használat: /setint <id/név> [int] ))");
    if(isValidPlayer(id)) {
        new oldInt = GetPlayerInterior(id);

        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s átállította %s interiorját %d-ra/re (Régi = %d)", getPlayerAdminRank(playerid), getName(playerid), getName(id), newInt, oldInt);

        if(id == playerid) {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította a saját interiorját %d-ra/re", getPlayerAdminRank(playerid), getName(playerid), newInt);
            }
            SFCM(playerid, COLOR_GREEN, "(( Átállítottad a saját interiorodat %d-ra/re! Régi érték: %d ))", newInt, oldInt);
        } else {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította %s interiorját %d-ra/re", getPlayerAdminRank(playerid), getName(playerid), getName(id), newInt);
            }
            SFCM(playerid, COLOR_GREEN, "(( Átállítottad %s interiorját %d-ra/re! Régi érték: %d ))", getName(id), newInt, oldInt);
            SFCM(id, COLOR_GREEN, "(( %s %s átállította az interiorodat %d-ra/re! ))", getPlayerAdminRank(playerid), getName(playerid), newInt);
        }
        SetPlayerInterior(id, newInt);
    } else SCM(playerid, -1, getStrMsg(STR_NPF));
    return 1;
}
CMD:setvw(playerid, params[]) {
    new id, newVW;
    if(sscanf(params, "uI(0)", id, newVW)) return SCM(playerid, COLOR_WHITE, "(( Használat: /setvw <id/név> [vw] ))");
    if(isValidPlayer(id)) {
        new oldVW = GetPlayerVirtualWorld(id);

        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s átállította %s virtualwordjét %d-ra/re (Régi = %d)", getPlayerAdminRank(playerid), getName(playerid), getName(id), newVW, oldVW);

        if(id == playerid) {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította a saját virtualwordjét %d-ra/re", getPlayerAdminRank(playerid), getName(playerid), newVW);
            }
            SFCM(playerid, COLOR_GREEN, "(( Átállítottad a saját virtualworldödet %d-ra/re! Régi érték: %d ))", newVW, oldVW);
        } else {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította %s virtualwordjét %d-ra/re", getPlayerAdminRank(playerid), getName(playerid), getName(id), newVW);
            }
            SFCM(playerid, COLOR_GREEN, "(( Átállítottad %s viurtalworldjét %d-ra/re! Régi érték: %d ))", getName(id), newVW, oldVW);
            SFCM(id, COLOR_GREEN, "(( %s %s átállította az virtualworldödet %d-ra/re! ))", getPlayerAdminRank(playerid), getName(playerid), newVW);
        }
        SetPlayerVirtualWorld(id, newVW);
    } else SCM(playerid, -1, getStrMsg(STR_NPF));
    return 1;
}
CMD:sethp(playerid, params[]) {
    new id, Float:newHP;
    if(sscanf(params, "uF(100.0)", id, newHP)) return SCM(playerid, COLOR_WHITE, "(( Használat: /sethp <id/név> [hp] ))");
    if(isValidPlayer(id)) {
        if(newHP >= 0.0 && newHP <= MAX_HP) {
            new Float:oldHP;
            GetPlayerHealth(id, oldHP);

            // serverLog
            serverLogFormatted(5, "*AdmCmd* %s %s átállította %s életerejét %.0f%s-ra/re (Régi = %.0f%s)", getPlayerAdminRank(playerid), getName(playerid), getName(id), newHP, "%%", oldHP, "%%");

            if(id == playerid) {
                if(!pInfo[playerid][P_TEMP][2]) {
                    SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította a saját életerejét %.0f%s-ra/re", getPlayerAdminRank(playerid), getName(playerid), newHP, "%%");
                }
                SFCM(playerid, COLOR_GREEN, "(( Átállítottad a saját életerõdet %.0f%s-ra/re! Régi érték: %.0f%s ))", newHP, "%%", oldHP);
            } else {
                if(!pInfo[playerid][P_TEMP][2]) {
                    SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította %s életerejét %.0f%s-ra/re", getPlayerAdminRank(playerid), getName(playerid), getName(id), newHP, "%%");
                }
                SFCM(playerid, COLOR_GREEN, "(( Átállítottad %s életerejét %.0f%s-ra/re! Régi érték: %.0f ))", getName(id), newHP, "%%", oldHP);
                SFCM(id, COLOR_GREEN, "(( %s %s átállította az életerõdet %.0f%s-ra/re! ))", getPlayerAdminRank(playerid), getName(playerid), newHP, "%%");
            }
            SetPlayerHealth(id, newHP);
            pInfo[id][pHP] = newHP;
        } else SCM(playerid, COLOR_ORANGE, "(( Hibás érték! ))");
    } else SCM(playerid, -1, getStrMsg(STR_NPF));
    return 1;
}
CMD:setap(playerid, params[]) {
    new id, Float:newAP;
    if(sscanf(params, "uF(100.0)", id, newAP)) return SCM(playerid, COLOR_WHITE, "(( Használat: /setap <id/név> [ap] ))");
    if(isValidPlayer(id)) {
        if(newAP >= 0.0 && newAP <= MAX_AP) {
            new Float:oldAP;
            GetPlayerArmour(id, oldAP);

            // serverLog
            serverLogFormatted(5, "*AdmCmd* %s %s átállította %s pajzsát %.0f%s-ra/re (Régi = %.0f%s)", getPlayerAdminRank(playerid), getName(playerid), getName(id), newAP, "%%", oldAP, "%%");

            if(id == playerid) {
                if(!pInfo[playerid][P_TEMP][2]) {
                    SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította a saját pajzsát %.0f%s-ra/re", getPlayerAdminRank(playerid), getName(playerid), newAP, "%%");
                }
                SFCM(playerid, COLOR_GREEN, "(( Átállítottad a saját pajzsodat %.0f%s-ra/re! Régi érték: %.0f%s))", newAP, "%%", oldAP);
            } else {
                if(!pInfo[playerid][P_TEMP][2]) {
                    SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította %s pajzsát %.0f%s-ra/re", getPlayerAdminRank(playerid), getName(playerid), getName(id), newAP, "%%");
                }
                SFCM(playerid, COLOR_GREEN, "(( Átállítottad %s pajzsát %.0f%s-ra/re! Régi érték: %.0f ))", getName(id), newAP, "%%", oldAP);
                SFCM(id, COLOR_GREEN, "(( %s %s átállította az pajzsodat %.0f%s-ra/re! ))", getPlayerAdminRank(playerid), getName(playerid), newAP, "%%");
            }
            SetPlayerArmour(id, newAP);
            pInfo[id][pAP] = newAP;
        } else SCM(playerid, COLOR_ORANGE, "(( Hibás érték! ))");
    } else SCM(playerid, -1, getStrMsg(STR_NPF));
    return 1;
}

CMD:makeadmin(playerid, params[]) {
    new id, newAdmin;
    if(sscanf(params, "uI(-1)", id, newAdmin)) return SCM(playerid, COLOR_WHITE, "(( Használat: /makeadmin <id / név> [adminszint] ))");
    if(isValidPlayer(id)) {
        if(newAdmin >= 0 && newAdmin <= getMaxAdminLevels()) {
            new oldAdminStr[64];
            format(oldAdminStr, sizeof(oldAdminStr), "%s", getPlayerAdminRank(id));
            pInfo[id][pAdmin] = newAdmin;

            // serverLog
            serverLogFormatted(5, "*AdmCmd* %s %s átállította %s adminszintjét %s-ra/re", getPlayerAdminRank(playerid), getName(playerid), getName(id));

            if(id == playerid) {
                if(!pInfo[playerid][P_TEMP][2]) {
                    SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította a saját adminszintjét %s-ra/re", oldAdminStr, getName(playerid), getPlayerAdminRank(playerid));
                }
                SFCM(playerid, COLOR_GREEN, "(( Átállítottad a saját adminszintedet %s-ra/re! ))", getPlayerAdminRank(id));
            } else {
                if(!pInfo[playerid][P_TEMP][2]) {
                    SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította %s adminszintjét %s-ra/re", getPlayerAdminRank(playerid), getName(playerid), getName(id), getPlayerAdminRank(id));
                }
                SFCM(playerid, COLOR_GREEN, "(( Átállítottad %s adminszintedet %s-ra/re! ))", getName(id), getPlayerAdminRank(id));
                SFCM(id, COLOR_GREEN, "(( %s %s átállította az adminszinted %s-ra/re! ))", getPlayerAdminRank(playerid), getName(playerid), getPlayerAdminRank(id));
            }
            doQuery("UPDATE users SET admin='%d' WHERE dbid='%d'", newAdmin, pInfo[id][pDBID]);
        } else if(newAdmin == -1) {
            SetPVarInt(playerid, "makeadmin_targetPlayerID", id);

            new dialogStr[1024];
            format(dialogStr, sizeof(dialogStr), "{FFFFFF}Szint\t{FFFFFF}Név\n");
            new dialogRow[128];
            new j = 0;
            for(new i = 0; i < MAX_ADMINLEVELS; i++) {
                if(alInfo[i][alExist]) {
                    format(dialogRow, sizeof(dialogRow), "%d\t{%s}%s\n", alInfo[i][alDBID], alInfo[i][alColor], alInfo[i][alName]);
                    strcat(dialogStr, dialogRow);
                    j++;
                }
            }
            if(j == 0) SCM(playerid, -1, getStrMsg(STR_TANAL));
            else ShowPlayerDialog(playerid, DIALOG_MAKEADMIN1, DIALOG_STYLE_TABLIST_HEADERS, "[ {77abff}Adminszintek{FFFFFF} ]", dialogStr, "Kinevez", "Mégsem");
        } else SCM(playerid, -1, getStrMsg(STR_NALF));
    }
    return 1;
}

CMD:bemutatkoz(playerid, params[]) {
    new closestPlayer = getClosestPlayer(playerid);
    if(getDistanceBetweenPlayers(playerid, closestPlayer) < 5.0) {
        if(!isPlayerIsFriend(playerid, closestPlayer)) {
            newFriend(closestPlayer, playerid);
            SCM(playerid, -1, getStrMsg(STR_SI1));
            SFCM(closestPlayer, -1, getStrMsg(STR_SI2), getName(playerid));
        } else SCM(playerid, -1, getStrMsg(STR_AI));
    } else SCM(playerid, -1, getStrMsg(STR_NIAY));
    return 1;
}

CMD:setskin(playerid, params[]) {
    new id, newSkinID, skinType;
    if(sscanf(params, "udI(0)", id, newSkinID, skinType)) return SCM(playerid, COLOR_WHITE, "(( Használat: /setskin <id / név> <skinid> [civil(0) / munka(1)] ))");
    if(isValidPlayer(id)) {
        if(isValidSkin(newSkinID)) {
            switch(skinType) {
                case 0: {

                    // serverLog
                    serverLogFormatted(5, "*AdmCmd* %s %s átállította %s civilruháját %d-ra/re (Régi = %d)", getPlayerAdminRank(playerid), getName(playerid), getName(id), newSkinID, pInfo[id][pSkin][0]);

                    if(!pInfo[playerid][P_TEMP][2]) {
                        SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította %s civilruháját %d-ra/re", getPlayerAdminRank(playerid), getName(playerid), getName(id), newSkinID);
                    }
                    SFCM(playerid, COLOR_GREEN, "(( Átállítottad %s civilruháját %d-ra/re! (régi %d) ))", getName(id), newSkinID, pInfo[id][pSkin][0]);
                    SFCM(id, COLOR_GREEN, "(( %s %s átállította a civilruhádat %d-ra/re! ))", getPlayerAdminRank(playerid), getName(playerid), newSkinID);
                    doQuery("UPDATE users SET skin0='%d' WHERE dbid='%d'", newSkinID, pInfo[id][pDBID]);
                    pInfo[id][pSkin][0] = newSkinID;
                    if(!pInfo[id][P_TEMP][6]) { // If the player is on-duty
                        SetPlayerSkin(id, newSkinID);
                    }
                } case 1: {

                    // serverLog
                    serverLogFormatted(5, "*AdmCmd* %s %s átállította %s munkaruháját %d-ra/re (Régi = %d)", getPlayerAdminRank(playerid), getName(playerid), getName(id), newSkinID, pInfo[id][pSkin][1]);

                    if(!pInfo[playerid][P_TEMP][2]) {
                        SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította %s munkaruháját %d-ra/re", getPlayerAdminRank(playerid), getName(playerid), getName(id), newSkinID);
                    }
                    SFCM(playerid, COLOR_GREEN, "(( Átállítottad %s munkaruháját %d-ra/re! (régi %d) ))", getName(id), newSkinID, pInfo[id][pSkin][1]);
                    SFCM(id, COLOR_GREEN, "(( %s %s átállította a munkaruhádat %d-ra/re! ))", getPlayerAdminRank(playerid), getName(playerid), newSkinID);
                    doQuery("UPDATE users SET skin1='%d' WHERE dbid='%d'", newSkinID, pInfo[id][pDBID]);
                    pInfo[id][pSkin][1] = newSkinID;
                    if(pInfo[id][P_TEMP][6]) { // If the player is on-duty
                        SetPlayerSkin(id, newSkinID);
                    }
                } default: {
                    SCM(playerid, COLOR_ORANGE, "(( Hibás érték! ))");
                }
            }
        } else SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen skin! ))");
    } else SCM(playerid, -1, getStrMsg(STR_NPF));
    return 1;
}

CMD:setvhp(playerid, params[]) {
    new vehicle[32], Float:newVHP;
    if(sscanf(params, "s[32]f", vehicle, newVHP)) return SCM(playerid, COLOR_WHITE, "(( Használat: /set hp <jármû> <vhp>");

    new vehicleDBID = getVehicleDBID(vehicle);
    if(vehicleDBID != -1) {
        if(newVHP >= 0.0 && newVHP <= MAX_VHP) {
            // serverLog
            serverLogFormatted(5, "*AdmCmd* %s %s beállította %s(%d) jármû életerejét %.0f%s-ra/re", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID, newVHP, "%%");

            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s beállította %s(%d) jármû életerejét %.0f%s-ra/re", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID, newVHP, "%%");
            }
            SFCM(playerid, COLOR_GREEN, "(( Beállítottad %s(%d) jármû életerejét %.0f%s-ra/re! ))", vInfo[vehicleDBID][vPlate], vehicleDBID, newVHP, "%%");
            SetVehicleHealth(vInfo[vehicleDBID][vID], newVHP);
            vInfo[vehicleDBID][vHP] = newVHP;
            doQuery("UPDATE vehicles SET hp='%f' WHERE dbid='%d'", newVHP, vehicleDBID);
        } else SCM(playerid, COLOR_ORANGE, "(( Hibás érték! ))");
    } else SCM(playerid, -1, getStrMsg(STR_NVF));
    return 1;
}

CMD:makeleader(playerid, params[]) {
    new id, newFraction;
    if(sscanf(params, "ud", id, newFraction)) return SCM(playerid, COLOR_WHITE, "(( Használat: /makeleader <id / név> <frakció> ))");
    if(isValidPlayer(id)) {
        if(isValidFraction(newFraction)) {
            new oldFraction = pInfo[id][pFraction];

            // serverLog
            serverLogFormatted(5, "*AdmCmd* %s %s kinevezte %s-t a(z) %s vezetõjének", getPlayerAdminRank(playerid), getName(playerid), getName(id), fInfo[newFraction][fName]);

            if(id == playerid) {
                if(!pInfo[playerid][P_TEMP][2]) {
                    SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s kinevezte magát a(z) %s vezetõjének", getPlayerAdminRank(playerid), getName(playerid), fInfo[newFraction][fName]);
                }

                SFCM(playerid, COLOR_GREEN, "(( Kinevezted magadat a(z) %s vezetõjének! Elõzõ frakció: %s ))", fInfo[newFraction][fName], fInfo[oldFraction][fName]);
            } else {
                if(!pInfo[playerid][P_TEMP][2]) {
                    SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s kinevezte %s-t a(z) %s vezetõjének", getPlayerAdminRank(playerid), getName(playerid), getName(id), fInfo[newFraction][fName]);
                }

                SFCM(playerid, COLOR_GREEN, "(( Kinevezted %s-t a(z) %s vezetõjének! Elõzõ frakció: %s ))", getName(id), fInfo[newFraction][fName], fInfo[oldFraction][fName]);
                SFCM(id, COLOR_GREEN, "(( %s %s kinevezett a(z) %s vezetõjének! ))", getPlayerAdminRank(playerid), getName(playerid), fInfo[newFraction][fName]);
            }
            pInfo[id][pFraction] = newFraction;
            pInfo[id][pDivision] = 0;
            pInfo[id][pLeader] = 2;
            pInfo[id][pRank] = getMaxFractionRankID(newFraction);
            pInfo[id][pSkin][1] = -1;
            doQuery("UPDATE users SET fraction='%d',division='0',leader='2',rank='%d',skin1='-1' WHERE dbid='%d'", newFraction, getMaxFractionRankID(newFraction), pInfo[id][pDBID]);
        } else SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen frakció! ))");
    } else SCM(playerid, -1, getStrMsg(STR_NPF));
    return 1;
}

CMD:setborn(playerid, params[]) {
    new id, newAge;
    if(sscanf(params, "ud", id, newAge)) return SCM(playerid, COLOR_WHITE, "(( Használat: /setborn <id / név> <életkor> ))");
    if(isValidPlayer(id)) {
        if(newAge >= 18 && newAge <= 80) {
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "UPDATE users SET born_time=NOW() - INTERVAL %d YEAR WHERE dbid='%d'", newAge, pInfo[id][pDBID]);
            inline q_setBornTime() {

                // serverLog
                serverLogFormatted(5, "*AdmCmd* %s %s átállította %s születési idejét: %s", getPlayerAdminRank(playerid), getName(playerid), getName(id), getPlayerInfo(id, "born_time"));

                if(!pInfo[playerid][P_TEMP][2]) {
                    SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította %s születési idejét: %s", getPlayerAdminRank(playerid), getName(playerid), getName(id), getPlayerInfo(id, "born_time"));
                }
                SFCM(playerid, COLOR_GREEN, "(( Átállítottad %s(%d) születési idejét %s(%d)-ra/re! ))", getName(id), id, getPlayerInfo(id, "born_time"), newAge);
                SFCM(id, COLOR_GREEN, "(( %s %s átállította a születési idõdet %s(%d)-ra/re! ))", getPlayerAdminRank(playerid), getName(playerid), getPlayerInfo(id, "born_time"), newAge);
            }
            mysql_tquery_inline(mysql_id, queryStr, using inline q_setBornTime, "");
        } else SCM(playerid, COLOR_ORANGE, "(( Érvénytelen életkor! (18 - 80) ))");
    } else SCM(playerid, -1, getStrMsg(STR_NPF));
    return 1;
}

CMD:megaphone(playerid, params[]) {
    if(fInfo[pInfo[playerid][pFraction]][fType] >= 0 && fInfo[pInfo[playerid][pFraction]][fType] <= 5) {
        new text[128];
        if(sscanf(params, "s[128]", text)) return SCM(playerid, COLOR_WHITE, "(( Használat: /m(egaphone) <szöveg> ))");

        if(strlen(text) <= 100) {
            if(pInfo[playerid][P_TEMP][6]) {
                if(IsPlayerInAnyVehicle(playerid)) {
                    new vehicleDBID = getVehicleDBIDFromID(GetPlayerVehicleID(playerid));
                    if(vInfo[vehicleDBID][vFraction] == pInfo[playerid][pFraction]) {
                        new Float:pPos[3];
                        GetPlayerPos(playerid, PosEx(pPos));
                        new Float:mRad = 30.0;

                        new fkString[64];
                        if(dInfo[pInfo[playerid][pDivision]][dType] == 0) format(fkString, sizeof(fkString), "%s", fInfo[pInfo[playerid][pFraction]][fSName]);
                        else format(fkString, sizeof(fkString), "%s %s", fInfo[pInfo[playerid][pFraction]][fSName], getDivSNameByDivID(pInfo[playerid][pFraction], pInfo[playerid][pDivision]));
                        new megaphoneStr[128];
                        format(megaphoneStr, sizeof(megaphoneStr), "[%s: o< %s]", fkString, text);
                        switch(fInfo[pInfo[playerid][pFraction]][fType]) {
                            case 1,4,5: Prox(playerid, mRad, megaphoneStr, COLOR_YELLOW);
                            case 2..3: Prox(playerid, mRad, megaphoneStr, 0xFF3366AA);
                        }
                    } else SCM(playerid, COLOR_ORANGE, "(( Ebben a jármûben nem használhatod! ))");
                } else SCM(playerid, COLOR_ORANGE, "(( Nem ülsz jármûben! ))");
            } else SCM(playerid, -1, getStrMsg(STR_NID));
        } else SCM(playerid, COLOR_WHITE, "(( Túl hosszú! ))");
    } else SCM(playerid, COLOR_ORANGE, "(( Nem használhatod ezt a parancsot! ))");
    return 1;
}
alias:megaphone("m");

CMD:ek(playerid) {
    if(fInfo[ pInfo[playerid][pFraction] ][fType] >= 1 && fInfo[ pInfo[playerid][pFraction] ][fType] <= 5) {
        if(pInfo[playerid][P_TEMP][6]) {
            new Float:pPos[3], pVW, pInt;
            GetPlayerPos(playerid, PosEx(pPos));
            pVW = GetPlayerVirtualWorld(playerid);
            pInt = GetPlayerInterior(playerid);
            if(GetPVarInt(playerid, "int_true")) {
                newCall(getRawName(playerid), 0, "Egység Kérés", GetPVarFloat(playerid, "int_posx"), GetPVarFloat(playerid, "int_posy"), GetPVarFloat(playerid, "int_posz"), pVW, pInt);
            } else newCall(getRawName(playerid), 0, "Egység Kérés", PosEx(pPos), pVW, pInt);
            SCM(playerid, COLOR_GREEN, "(( DISZPÉCSER: Megkaptuk a jelzését! Azonnal küldünk egy egységet! ))");

            new callID = getLatestCall();

            new msgStr[128];
            format(msgStr, sizeof(msgStr), "*** DISZPÉCSER: *%s* %s %s egységet kér. Hívád kódszáma: %d.", getPlayerFractionText(playerid), getPlayerRankName(playerid), getName(playerid), callID);
            sendFractionMsg(1, COLOR_CYAN, msgStr, true);
            sendFractionMsg(4, COLOR_CYAN, msgStr, true);
            sendFractionMsg(5, COLOR_CYAN, msgStr, true);
        } else SCM(playerid, -1, getStrMsg(STR_NID));
    } else SCM(playerid, COLOR_ORANGE, "(( Nem használhatod ezt a parancsot! ))");
    return 1;
}

CMD:g4s(playerid) {
    if(fInfo[ pInfo[playerid][pFraction] ][fType] == 7) {
        new Float:pPos[3], pVW, pInt;
        GetPlayerPos(playerid, PosEx(pPos));
        pVW = GetPlayerVirtualWorld(playerid);
        pInt = GetPlayerInterior(playerid);
        if(GetPVarInt(playerid, "int_true")) {
            newCall(getRawName(playerid), 0, "Elnök Veszélyben", GetPVarFloat(playerid, "int_posx"), GetPVarFloat(playerid, "int_posy"), GetPVarFloat(playerid, "int_posz"), pVW, pInt);
        } else newCall(getRawName(playerid), 0, "Elnök Veszélyben", PosEx(pPos), pVW, pInt);
        SCM(playerid, COLOR_GREEN, "(( DISZPÉCSER: Megkaptuk a jelzését! Azonnal küldünk egy egységet! ))");

        new callID = getLatestCall();

        new msgStr[128];
        format(msgStr, sizeof(msgStr), "*** DISZPÉCSER: *%s* %s %s veszélyben. Hívád kódszáma: %d.", getPlayerFractionText(playerid), getPlayerRankName(playerid), getName(playerid), callID);
        sendFractionMsg(1, COLOR_CYAN, msgStr, true, true);
        sendFractionMsg(4, COLOR_CYAN, msgStr, true, true);
    } else SCM(playerid, COLOR_ORANGE, "(( Nem használhatod ezt a parancsot! ))");
    return 1;
}

CMD:elm(playerid) {
    if(fInfo[ pInfo[playerid][pFraction] ][fType] >= 1 && fInfo[ pInfo[playerid][pFraction] ][fType] <= 5) {
        if(IsPlayerInAnyVehicle(playerid)) {
            new vehicleID = GetPlayerVehicleID(playerid);
            new vehicleDBID = getVehicleDBIDFromID(vehicleID);
            if(fInfo[ vInfo[vehicleDBID][vFraction] ][fType] >= 1 && fInfo[ vInfo[vehicleDBID][vFraction] ][fType] <= 5) {
                if(vInfo[vehicleDBID][vELM]) {
                    new panels, doors, lights, tires;
                    if(vInfo[vehicleDBID][vELM]) KillTimer(_:vInfo[vehicleDBID][vELMTimer]);
                    GetVehicleDamageStatus(vehicleID, panels, doors, lights, tires);
                    UpdateVehicleDamageStatus(vehicleID, panels, doors, 0, tires);
                    SCM(playerid, COLOR_DARKRED, "(( Emergency Lights kikapcsolva ))");
                    vInfo[vehicleDBID][vELM] = false;
                } else {
                    vInfo[vehicleDBID][vELMTimer] = repeat t_vehicleELM[50](vehicleDBID);
                    vInfo[vehicleDBID][vELM] = true;
                    SCM(playerid, COLOR_GREEN, "(( Emergency Lights bekapcsolva ))");
                }
            } else SCM(playerid, COLOR_ORANGE, "(( Ebben a jármûben nem használhatod! ))");
        } else SCM(playerid, -1, getStrMsg(STR_OAIV));
    } else SCM(playerid, COLOR_ORANGE, "(( Nem használhatod ezt a parancsot! ))");
    return 1;
}

CMD:department(playerid, params[]) {
    if(fInfo[pInfo[playerid][pFraction]][fType] >= 1 && fInfo[pInfo[playerid][pFraction]][fType] <= 5) {
        if(pInfo[playerid][P_TEMP][6]) {
            if(playerItem(playerid, 1) > 0) {
                new msg[100];
                if(sscanf(params, "s[128]", msg)) return SCM(playerid, COLOR_WHITE, "(( Használat: /d(epartment) <üzenet> ))");

                if(strlen(msg) <= 100) {
                    new msgStr[128];
                    format(msgStr, sizeof(msgStr), "*%s* %s %s: %s, vége **", getPlayerFractionText(playerid), getPlayerRankName(playerid), getName(playerid), msg);
                    sendFractionMsg(1, 0xf7655baa, msgStr, true, false, true);
                    sendFractionMsg(2, 0xf7655baa, msgStr, true, false, true);
                    sendFractionMsg(3, 0xf7655baa, msgStr, true, false, true);
                    sendFractionMsg(4, 0xf7655baa, msgStr, true, false, true);
                    sendFractionMsg(5, 0xf7655baa, msgStr, true, false, true);
                    format(msgStr, sizeof(msgStr), "*rádióba* %s: %s, vége", getName(playerid), msg);
                    Prox(playerid, 15.0, msgStr, COLOR_GRAY);
                } else SCM(playerid, -1, getStrMsg(STR_TL));
            } else SCM(playerid, COLOR_ORANGE, "(( Nincs rádiód! ))");
        } else SCM(playerid, -1, getStrMsg(STR_NID));
    } else SCM(playerid, COLOR_ORANGE, "(( Nem használhatod ezt a parancsot! ))");
    return 1;
}
alias:department("d");

CMD:rta(playerid) {
    if(fInfo[ pInfo[playerid][pFraction] ][fType] == 1 || (fInfo[ pInfo[playerid][pFraction] ][fType] >= 4 && fInfo[ pInfo[playerid][pFraction] ][fType] <= 5)) {
        if(pInfo[playerid][P_TEMP][6]) {
            new Float:pPos[3], pVW, pInt;
            GetPlayerPos(playerid, PosEx(pPos));
            pVW = GetPlayerVirtualWorld(playerid);
            pInt = GetPlayerInterior(playerid);
            if(GetPVarInt(playerid, "int_true")) {
                newCall(getRawName(playerid), 0, "Rendõr Tûz Alatt", GetPVarFloat(playerid, "int_posx"), GetPVarFloat(playerid, "int_posy"), GetPVarFloat(playerid, "int_posz"), pVW, pInt);
            } else newCall(getRawName(playerid), 0, "Rendõr Tûz Alatt", PosEx(pPos), pVW, pInt);
            SCM(playerid, COLOR_GREEN, "(( DISZPÉCSER: Megkaptuk a jelzését! Azonnal küldünk egy egységet! ))");

            new callID = getLatestCall();

            new msgStr[128];
            format(msgStr, sizeof(msgStr), "*** DISZPÉCSER: *%s* %s %s tûz alatt. Hívád kódszáma: %d.", getPlayerFractionText(playerid), getPlayerRankName(playerid), getName(playerid), callID);
            sendFractionMsg(1, COLOR_CYAN, msgStr, true, true);
            sendFractionMsg(4, COLOR_CYAN, msgStr, true, true);
            sendFractionMsg(5, COLOR_CYAN, msgStr, true, true);
        } else SCM(playerid, -1, getStrMsg(STR_NID));
    } else SCM(playerid, COLOR_ORANGE, "(( Nem használhatod ezt a parancsot! ))");
    return 1;
}

CMD:elfogad(playerid, params[]) {
    new t[12];
    if(sscanf(params, "s[12]{}", t)) return SCM(playerid, COLOR_WHITE, "(( Használat: /elfogad <típus> ))");

    if(equals(t, "rendor") || equals(t, "rendõr")) {
        if(fInfo[ pInfo[playerid][pFraction] ][fType] == 1 || fInfo[ pInfo[playerid][pFraction] ][fType] == 5 || fInfo[ pInfo[playerid][pFraction] ][fType] == 4) {
            if(pInfo[playerid][P_TEMP][6]) {
                new callID = -1;
                if(sscanf(params, "{s[12]}I(-1)", callID)) return SCM(playerid, COLOR_WHITE, "(( Használat: /elfogad rendor [hívás kódszáma] ))");

                if(callID >= -1) {
                    acceptCall(playerid, callID);
                } else SCM(playerid, COLOR_ORANGE, "(( Érvénytelen érték! ))");
            } else SCM(playerid, -1, getStrMsg(STR_NID));
        } else SCM(playerid, COLOR_ORANGE, "(( Nem használhatod ezt a típust! ))");
    }
    return 1;
}

CMD:cptorol(playerid) {
    SCM(playerid, COLOR_GREEN, "(( Checkpoint törölve! ))");
    DisablePlayerCheckpoint(playerid);
    DisablePlayerRaceCheckpoint(playerid);
    return 1;
}

CMD:gotopos(playerid, params[]) {
    new Float:pos[3], vw, int;
    if(sscanf(params, "fffI(0)I(0)", PosEx(pos), vw, int)) return SCM(playerid, COLOR_WHITE, "(( Használat: /gotopos <x> <y> <z> [vw] [int] ))");
    SetPlayerPos(playerid, PosEx(pos));
    SetPlayerInterior(playerid, vw);
    SetPlayerInterior(playerid, int);

    // serverLog
    serverLogFormatted(5, "*AdmCmd* %s %s elteleportált a(z) %.2f, %.2f, %.2f kordinátára! (VW = %d, Int = %d)", getPlayerAdminRank(playerid), getName(playerid), PosEx(pos), vw, int);

    SFCM(playerid, COLOR_GREEN, "(( Elteleportáltál a(z) %.2f, %.2f, %.2f kordinátára! (VW = %d, Int = %d) ))", PosEx(pos), vw, int);
    return 1;
}

CMD:label(playerid, params[]) {
    new t[12];
    if(sscanf(params, "s[12]{}", t)) return SCM(playerid, COLOR_WHITE, "(( Használat: /label <típus> ))"), SCM(playerid, COLOR_WHITE, "(( Típusok: add, remove, info, near, goto, colors ))");

    if(equals(t, "add")) {
        new text[256], color = 0, Float:dw, testLOS = 1;
        if(sscanf(params, "{s[12]}dfds[256]", color, dw, testLOS, text)) return SCM(playerid, COLOR_WHITE, "(( Használat: /label add <szín> <látótáv> <testLOS> <szöveg> ))");
        if(dw > 0.0) {
            if(testLOS == 0 || testLOS == 1) {
                new pVW = GetPlayerVirtualWorld(playerid);
                new Float:pPos[3];
                GetPlayerPos(playerid, PosEx(pPos));
                mysql_format(mysql_id, queryStr, sizeof(queryStr), "INSERT INTO labels (text, color, pos, draw_distance, vw, testLOS) VALUES ('%s', '%d', '%f,%f,%f', '%f', '%d', '%d')", text, color, PosEx(pPos), dw, pVW, testLOS);
                new Cache:result = mysql_query(mysql_id, queryStr);
                new labelDBID = cache_insert_id();

                if(!pInfo[playerid][P_TEMP][2]) {
                    SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s létrehozozz egy feliratot (DBID = %d)", getPlayerAdminRank(playerid), getName(playerid), labelDBID);
                }

                SFCM(playerid, COLOR_GREEN, "(( Létrehoztál egy feliratot! (DBID = %d) ))", labelDBID);

                loadLabel(labelDBID);
                cache_delete(result);
            } else SCM(playerid, COLOR_ORANGE, "(( Érvénytelen testLOS érték! ))");
        } else SCM(playerid, COLOR_ORANGE, "(( Érvénytelen látótáv érték! ))");
    } else if(equals(t, "remove") || equals(t, "rem")) {
        new labelDBID = -1;
        if(sscanf(params, "{s[12]}d", labelDBID)) return SCM(playerid, COLOR_WHITE, "(( Használat: /label remove <dbid> ))");

        if(lInfo[labelDBID][lExist]) {
            lInfo[labelDBID][lExist] = false;
            DestroyDynamic3DTextLabel(lInfo[labelDBID][lID]);
            doQuery("DELETE FROM labels WHERE dbid='%d'", labelDBID);

            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s törölt egy feliratot (DBID = %d)", getPlayerAdminRank(playerid), getName(playerid), labelDBID);
            }
            SFCM(playerid, COLOR_GREEN, "(( Töröltél egy feliratot! (DBID = %d) ))", labelDBID);
        } else SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen felirat! ))");
    } else if(equals(t, "info")) {

    } else if(equals(t, "near")) {
        SCM(playerid, COLOR_WHITE, "(( |__________________ Közeli feliratok: __________________| ))");
        new labelText[256];
        for(new i = 0; i < MAX_LABELS; i++) {
            if(lInfo[i][lExist]) {
                if(PlayerToPoint(playerid, lInfo[i][lDrawDistance], PosEx(lInfo[i][lPos]))) {
                    format(labelText, sizeof(labelText), lInfo[i][lText]);
                    if(strlen(labelText) >= 15) strdel(labelText, 15, strlen(labelText));
                    SFCM(playerid, COLOR_WHITE, "> %d. {%06x}%s{ffffff}%s, VW = %d, TestLOS = %d, DD = %.1f", lInfo[i][lDBID], convertLabelColor(lInfo[i][lColor]) >>> 8, labelText, strlen(lInfo[i][lText]) >= 15 ? ("..") : (""), lInfo[i][lVW], lInfo[i][lTestLOS], lInfo[i][lDrawDistance]);
                }
            }
        }
    } else if(equals(t, "colors")) {

    } else if(equals(t, "goto")) {
        new labelDBID = -1;
        if(sscanf(params, "{s[12]}d", labelDBID)) return SCM(playerid, COLOR_WHITE, "(( Használat: /label goto <dbid> ))");

        if(lInfo[labelDBID][lExist]) {
            SetPlayerPos(playerid, PosEx(lInfo[labelDBID][lPos]));
            SetPlayerVirtualWorld(playerid, lInfo[labelDBID][lVW]);
            SFCM(playerid, COLOR_GREEN, "(( Elteleportáltál egy felirathoz! (DBID = %d, VW = %d) )", labelDBID, lInfo[labelDBID][lVW]);
        } else SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen felirat! ))");
    }
    else SCM(playerid, -1, getStrMsg(STR_NTF));
    return 1;
}

CMD:settime(playerid, params[]) {
    new time = 0;
    if(sscanf(params, "d", time)) return SCM(playerid, COLOR_WHITE, "(( Használat: /settime <idõ(0-24)> ))");
    if(time >= 0 && time <= 24) {
        SetWorldTime(time);
        if(!pInfo[playerid][P_TEMP][2]) {
            SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s átállította az idõt %d órára", getPlayerAdminRank(playerid), getName(playerid), time);
        }
        SFCM(playerid, COLOR_GREEN, "(( Átállítottad az idõt %d órára! ))", time);
    } else SCM(playerid, COLOR_ORANGE, "(( Érvénytelen érték! ))");
    return 1;
}

CMD:testgun(playerid) {
    GivePlayerWeapon(playerid, 24, 14); // Deagle
    GivePlayerWeapon(playerid, 31, 60); // M4
    GivePlayerWeapon(playerid, 34, 10); // Sniper
    return 1;
}

CMD:respawn(playerid, params[]) {
    new id = -1;
    if(sscanf(params, "u", id)) return SCM(playerid, COLOR_WHITE, "(( Használat: /respawn <id / név> ))");
    if(isValidPlayer(id)) {

        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s respawnolta %s-t", getPlayerAdminRank(playerid), getName(playerid), getName(id));

        if(id != playerid) {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s respawnolta %s-t", getPlayerAdminRank(playerid), getName(playerid), getName(id));
            }
            SFCM(playerid, COLOR_GREEN, "(( Respawnoltad %s-t ))", getName(id));
            SFCM(id, COLOR_GREEN, "(( %s %s respawnolt! ))", getPlayerAdminRank(playerid), getName(playerid));
        } else {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s respawnolta saját magát", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_GREEN, "(( Respawnoltad magadat! ))");
        }

        loadPlayerData(id, true);
    } else return SCM(playerid, -1, getStrMsg(STR_NPF));
    return 1;
}

CMD:rsc(playerid, params[]) {
    if(IsPlayerInAnyVehicle(playerid)) {
        new vehicleID = GetPlayerVehicleID(playerid);
        new vehicleDBID = getVehicleDBIDFromID(vehicleID);

        saveVehicle(vehicleDBID, true);
        SFCM(playerid, COLOR_GREEN, "(( Respawnoltál egy jármûvet! (DBID = %d) ))", vehicleDBID);
    } else {
        new vehicle[32];
        if(sscanf(params, "s[32]", vehicle)) return SCM(playerid, COLOR_WHITE, "(( Használat: /rsc [jármû] ))");
        new vehicleDBID = getVehicleDBID(vehicle);
        if(vehicleDBID != -1) {
            saveVehicle(vehicleDBID, true);
            SFCM(playerid, COLOR_GREEN, "(( Respawnoltál egy jármûvet! (DBID = %d) ))", vehicleDBID);
        }
    }
    return 1;
}

CMD:rnc(playerid, params[]) {
    new Float:rad;
    if(sscanf(params, "F(30.0)", rad)) return SCM(playerid, COLOR_WHITE, "(( Használat: /rnc [hatótáv (alap 30)] ))");

    new j = 0;
    for(new i = 1; i < GetVehiclePoolSize()+1; i++) {
        if(!isVehicleOccupied(vInfo[i][vID])) {
		    if(getDistanceToCar(playerid, vInfo[i][vID]) <= rad) {
                saveVehicle(i, true);
                j++;
            }
        }
    }
    SFCM(playerid, COLOR_GREEN, "(( %d db jármû respawnolva %.1f-as hatótávban! ))", j, rad);
    return 1;
}

CMD:editcar(playerid, params[]) {
    if(IsPlayerInAnyVehicle(playerid)) {
        new vehicleID = GetPlayerVehicleID(playerid);
        new vehicleDBID = getVehicleDBIDFromID(vehicleID);
        if(vehicleDBID != -1) {
            new fk;
            if(sscanf(params, "d", fk)) return SCM(playerid, COLOR_WHITE, "(( Használat: /editcar <frakció dbid> ))");

            if(fk > 0 && fInfo[fk][fExist]) {
                vInfo[vehicleDBID][vFraction] = fk;
                SFCM(playerid, COLOR_GREEN, "(( Jármû módosítva! (DBID = %d, Frakció = %s(%d)) ))", vehicleDBID, fInfo[fk][fSName], fk);
                saveVehicle(vehicleDBID);
            } else SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen frakció! ))");
        } else SCM(playerid, -1, getStrMsg(STR_NVF));
    } else SCM(playerid, -1, getStrMsg(STR_OAIV));
    return 1;
}

CMD:carinfo(playerid, params[]) {
    if(IsPlayerInAnyVehicle(playerid)) {
        new vehicleID = GetPlayerVehicleID(playerid);
        new vehicleDBID = getVehicleDBIDFromID(vehicleID);
        if(vehicleDBID != -1) {
            SFCM(playerid, COLOR_GREEN, "(( DBID = %d, Rendszám = %s, Model = %s(%d), Szín = %d, %d ))", vehicleDBID, vInfo[vehicleDBID][vPlate], vehicleNames[vInfo[vehicleDBID][vModel]-400], vInfo[vehicleDBID][vModel], vInfo[vehicleDBID][vColor][0], vInfo[vehicleDBID][vColor][1]);
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT users.name, users.dbid FROM users WHERE users.dbid='%d'", vInfo[vehicleDBID][vOwner]);
            if(vInfo[vehicleDBID][vOwner] != -1 && vInfo[vehicleDBID][vFraction] == 0) {
                inline showVehOwner() {
                    if(cache_num_rows()) {
                        new playerDBID = -1;
                        new pName[MAX_PLAYER_NAME];
                        mysql_get_int(0, "dbid", playerDBID);
                        mysql_get_string(0, "name", pName);
                        SFCM(playerid, COLOR_GREEN, "(( Tulajdonos: %s (DBID = %d) ))", pName, playerDBID);
                    } else SFCM(playerid, COLOR_GREEN, "(( Tulajdonos: {c83250}Nincs játékos találat{%06x} ))", COLOR_GREEN >>> 8);
                }
                mysql_tquery_inline(mysql_id, queryStr, using inline showVehOwner, "");
            } else {
                if(fInfo[vInfo[vehicleDBID][vFraction]][fExist] && vInfo[vehicleDBID][vFraction] != 0) {
                    SFCM(playerid, COLOR_GREEN, "(( Tulajdonos: %s (DBID = %d) ))", fInfo[vInfo[vehicleDBID][vFraction]][fName], fInfo[vInfo[vehicleDBID][vFraction]][fDBID]);
                } else SFCM(playerid, COLOR_GREEN, "(( Tulajdonos: {c83250}Nincs játékos találat (se frakció){%06x} ))", COLOR_GREEN >>> 8);
            }
        } else SCM(playerid, -1, getStrMsg(STR_NVF));
    } else {
        new vehicle[32];
        if(sscanf(params, "s[32]", vehicle)) return SCM(playerid, COLOR_WHITE, "(( Használat: /carinfo <jármû> ))");

        new vehicleDBID = getVehicleDBID(vehicle);
        if(vehicleDBID != -1) {
            SFCM(playerid, COLOR_GREEN, "(( DBID = %d, Rendszám = %s, Model = %s(%d), Szín = %d, %d ))", vehicleDBID, vInfo[vehicleDBID][vPlate], vehicleNames[vInfo[vehicleDBID][vModel]-400], vInfo[vehicleDBID][vModel], vInfo[vehicleDBID][vColor][0], vInfo[vehicleDBID][vColor][1]);
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT users.name, users.dbid FROM users WHERE users.dbid='%d'", vInfo[vehicleDBID][vOwner]);
            if(vInfo[vehicleDBID][vOwner] != -1 && vInfo[vehicleDBID][vFraction] == 0) {
                inline showVehOwner() {
                    if(cache_num_rows()) {
                        new playerDBID = -1;
                        new pName[MAX_PLAYER_NAME];
                        mysql_get_int(0, "dbid", playerDBID);
                        mysql_get_string(0, "name", pName);
                        SFCM(playerid, COLOR_GREEN, "(( Tulajdonos: %s (DBID = %d) ))", pName, playerDBID);
                    } else SFCM(playerid, COLOR_GREEN, "(( Tulajdonos: {c83250}Nincs játékos találat{%06x} ))", COLOR_GREEN >>> 8);
                }
                mysql_tquery_inline(mysql_id, queryStr, using inline showVehOwner, "");
            } else {
                if(fInfo[vInfo[vehicleDBID][vFraction]][fExist] && vInfo[vehicleDBID][vFraction] != 0) {
                    SFCM(playerid, COLOR_GREEN, "(( Tulajdonos: %s (DBID = %d) ))", fInfo[vInfo[vehicleDBID][vFraction]][fName], fInfo[vInfo[vehicleDBID][vFraction]][fDBID]);
                } else SFCM(playerid, COLOR_GREEN, "(( Tulajdonos: {c83250}Nincs játékos találat (se frakció){%06x} ))", COLOR_GREEN >>> 8);
            }
        } else SCM(playerid, -1, getStrMsg(STR_NVF));
    }
    return 1;
}

CMD:kick(playerid, params[]) {
    new id = -1, reason[128];
    if(sscanf(params, "uS(Nincs indok)[128]", id, reason)) return SCM(playerid, COLOR_WHITE, "(( Használat: /kick <id / név> [indok] ))");

    if(isValidPlayer(id)) {
        KickPlayerEx(playerid, id, reason, true, true);
        SFCM(playerid, COLOR_GREEN, "(( Kirúgtad a szerverrõl %s-t! ))", getName(id));
    } else SCM(playerid, -1, getStrMsg(STR_NPF));
    return 1;
}

CMD:fixveh(playerid, params[]) {
    if(IsPlayerInAnyVehicle(playerid)) {
        new vehicleID = GetPlayerVehicleID(playerid);
        new vehicleDBID = getVehicleDBIDFromID(vehicleID);

        SetVehicleHealth(vInfo[vehicleDBID][vID], 1000);
        RepairVehicle(vInfo[vehicleDBID][vID]);

        vInfo[vehicleDBID][vHP] = 1000.0;
        vInfo[vehicleDBID][vConditions][0] = 0;
        vInfo[vehicleDBID][vConditions][1] = 0;
        vInfo[vehicleDBID][vConditions][2] = 0;
        vInfo[vehicleDBID][vConditions][3] = 0;
        saveVehicle(vehicleDBID);

        SFCM(playerid, COLOR_GREEN, "(( Megjavítottál egy jármûvet! (DBID = %d) ))", vehicleDBID);

        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s megjavította a(z) %s(%d) jármûvet", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID);
    } else {
        new inputVeh[32];
        if(sscanf(params, "s[32]", inputVeh)) return SCM(playerid, COLOR_WHITE, "(( Használat: /fixveh <jármû> ))");
        new vehicleDBID = getVehicleDBID(inputVeh);
        if(vehicleDBID != -1) {
            SetVehicleHealth(vInfo[vehicleDBID][vID], 1000);
            RepairVehicle(vInfo[vehicleDBID][vID]);
            vInfo[vehicleDBID][vHP] = 1000.0;
            vInfo[vehicleDBID][vConditions][0] = 0;
            vInfo[vehicleDBID][vConditions][1] = 0;
            vInfo[vehicleDBID][vConditions][2] = 0;
            vInfo[vehicleDBID][vConditions][3] = 0;
            saveVehicle(vehicleDBID);

            SFCM(playerid, COLOR_GREEN, "(( Megjavítottál egy jármûvet! (DBID = %d) ))", vehicleDBID);

            // serverLog
            serverLogFormatted(5, "*AdmCmd* %s %s megjavította a(z) %s(%d) jármûvet", getPlayerAdminRank(playerid), getName(playerid), vInfo[vehicleDBID][vPlate], vehicleDBID);
        } else SCM(playerid, -1, getStrMsg(STR_NVF));
    }
    return 1;
}

CMD:getcar(playerid, params[]) {
    new vehicle[32];
    if(sscanf(params, "s[32]", vehicle)) return SCM(playerid, COLOR_WHITE, "(( Használat: /getcar <jármû> ))");

    new vehicleDBID = getVehicleDBID(vehicle);

    if(vehicleDBID != -1) {
        new vehicleID = vInfo[vehicleDBID][vID];
        new Float:pPos[3];
        GetPlayerPos(playerid, PosEx(pPos));
        pPos[1] += 3.0;
        pPos[2] += 1.0;
        SetVehiclePos(vehicleID, PosEx(pPos));

        SFCM(playerid, COLOR_GREEN, "(( Madadhoz hívtál egy jármûvet! (DBID = %d) ))", vehicleDBID);
    } else SCM(playerid, -1, getStrMsg(STR_NVF));
    return 1;
}

CMD:report(playerid) {
    new dialogStr[1024];
    new dialogRow[128];
    new j = 0;
    for(new i = 0; i < MAX_REPORT_CATS; i++) {
        if(rInfo[i][rExist]) {
            if(rInfo[i][rType] != 2 && rInfo[i][rType] != 3) { // Not an AFK and ALL channel
                format(dialogRow, sizeof(dialogRow), "{%s}%s {FFFFFF}- %s\n", rInfo[i][rColor], rInfo[i][rSName], rInfo[i][rName]);
                strcat(dialogStr, dialogRow);
                j++;
            }
        }
    }
    if(j == 0) SCM(playerid, -1, getStrMsg(STR_TANRC));
    else ShowPlayerDialog(playerid, DIALOG_REPORT, DIALOG_STYLE_LIST, "[ {77abff}Jelentés kategóriák{FFFFFF} ]", dialogStr, "Kiválaszt", "Mégse");
    return 1;
}

CMD:areport(playerid) {
    new dialogStr[1024];
    new dialogRow[128];
    new j = 0;
    for(new i = 0; i < MAX_REPORT_CATS; i++) {
        if(rInfo[i][rExist]) {
            format(dialogRow, sizeof(dialogRow), "{%s}%s {FFFFFF}- %s\n", rInfo[i][rColor], rInfo[i][rSName], rInfo[i][rName]);
            strcat(dialogStr, dialogRow);
            j++;
        }
    }
    if(j == 0) SCM(playerid, -1, getStrMsg(STR_TANRC));
    else ShowPlayerDialog(playerid, DIALOG_AREPORT, DIALOG_STYLE_LIST, "[ {77abff}Jelentés kategóriák{FFFFFF} ]", dialogStr, "Kiválaszt", "Mégsem");
    return 1;
}

CMD:leader(playerid) {
    if(pInfo[playerid][pLeader] == 2) {
        new dialogStr[512];
        switch(fInfo[pInfo[playerid][pFraction]][fType]) {
            case 0: SCM(playerid, -1, getStrMsg(STR_NHEP));
            case 1: {
                format(dialogStr, sizeof(dialogStr), "{ffffff}Jelentkezõk\n{ffffff}Alkalmazottak listája\n{ffffff}Flotta kezelés\n{ffffff}Terrorelhárítási Központ\n");
                ShowPlayerDialog(playerid, DIALOG_LEADER1, DIALOG_STYLE_LIST, "{ffffff}Vezetõség", dialogStr, "Tovább", "Mégsem");
            } default: SCM(playerid, -1, getStrMsg(STR_FDSTF));
        }
    } else SCM(playerid, -1, getStrMsg(STR_NHEP));
}

CMD:muhold(playerid) {
    if(fInfo[ pInfo[playerid][pFraction] ][fType] == 1 && (dInfo[ pInfo[playerid][pDivision] ][dType] == 4 || dInfo[ pInfo[playerid][pDivision] ][dType] == 0)) {
        if(!IsPlayerInAnyVehicle(playerid)) {
            if(pInfo[playerid][P_TEMP][6]) { // On-Duty
                if(pInfo[playerid][P_TEMP][11]) { // In-Satellite
                    SCM(playerid, COLOR_DARKRED, "(( Kikapcsoltad a mûholdat! ))");
                    finishPlayerSatellite(playerid);
                } else {
                    new Float:pPos[3];
                    GetPlayerPos(playerid, PosEx(pPos));

                    new pInt = GetPlayerInterior(playerid);
                    new pVW = GetPlayerVirtualWorld(playerid);

                    new bool:foundPos = false; // To check if is dutypos near by
                    new bool:posWithLF = false; // To check if is there any dutypos with the player's fraction
                    for(new i = 0; i < MAX_POSITIONS; i++) {
                        if(posInfo[i][posType] == POS_TYPE_SATELLITE) {
                            if(posInfo[i][posLF] == pInfo[playerid][pFraction] && posInfo[i][posExist]) {
                                posWithLF = true;
                                if(posInfo[i][posInt] == pInt && posInfo[i][posVW] == pVW) {
                                    if(PlayerToPoint(playerid, posInfo[i][posRad], PosEx(posInfo[i][posPos]))) {
                                        foundPos = true;
                                        SCM(playerid, COLOR_GREEN, "(( Bekapcsoltad a mûholdat! ))");
                                        setPlayerInSatellite(playerid);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    if(!foundPos && posWithLF) SCM(playerid, COLOR_ORANGE, "(( Itt nem használhatod! ))");
                    if(!posWithLF) SCM(playerid, COLOR_ORANGE, "(( A frakciódnak nincs egyetlen poziciója se! ))");
                }
            } else SCM(playerid, -1, getStrMsg(STR_NID));
        } else SCM(playerid, COLOR_ORANGE, "(( Jármûben nem használhatod! ))");
    } else SCM(playerid, COLOR_ORANGE, "(( Nem használhatod ezt a parancsot! ))");
    return 1;
}

CMD:gotocar(playerid, params[]) {
    new vehicle[32], seat;
    if(sscanf(params, "s[32]I(-1)", vehicle, seat)) return SCM(playerid, COLOR_WHITE, "(( Használat: /gotocar <jármû> [ülés] ))");

    new vehicleDBID = getVehicleDBID(vehicle);

    if(vehicleDBID != -1) {
        new vehicleID = vInfo[vehicleDBID][vID];
        if(seat == -1) {
            new Float:vehiclePos[3] = {0.0, 0.0, 0.0};
            GetVehiclePos(vehicleID, PosEx(vehiclePos));
            vehiclePos[2] += 0.5;
            vehiclePos[1] += 1.0;
            SetPlayerPos(playerid, PosEx(vehiclePos));
        } else if(seat >= 0 && seat <= GetVehicleSeatCount(vehicleID)) {
            new bool:seatIsFree = true;
            new player = 0;

            while(seatIsFree && player < GetPlayerPoolSize()+1) {
                if(GetPlayerVehicleSeat(player) == seat && GetPlayerVehicleID(player) == vehicleID) {
                    seatIsFree = false;
                }
                player++;
            }

            if(seatIsFree) {
                PutPlayerInVehicle(playerid, vehicleID, seat);
            } else {
                SCM(playerid, COLOR_ORANGE, "(( Az ülés foglalt! ))");
            }
        } else SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen ülés a jármûben! ))");
    } else SCM(playerid, -1, getStrMsg(STR_NVF));
    return 1;
}

CMD:lookup(playerid, params[]) {
    new param[12];
    if(sscanf(params, "s[12]{}", param)) return SCM(playerid, COLOR_WHITE, "(( Használat: /lookup <típus> ))"), SCM(playerid, COLOR_WHITE, "(( Típusok: item ))");

    if(equals(param, "item")) {
        new itemName[64];
        if(sscanf(params, "{s[12]}s[64]", itemName)) return SCM(playerid, COLOR_WHITE, "(( Használat: /lookup item <tárgy név> ))");

        mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT * FROM items WHERE items.name LIKE '%%%e%%'", itemName);
        new Cache:result = mysql_query(mysql_id, queryStr);

        new id = -1;
        new name[64];
        new weight = 0;

        SFCM(playerid, COLOR_WHITE, "(( |_____ Találatok {77cdff}%s{FFFFFF}-ra/re a tárgyak között _____| ))", itemName);
        for(new i = 0; i < cache_num_rows(); i++) {
            mysql_get_int(i, "dbid", id);
            mysql_get_string(i, "name", name);
            mysql_get_int(i, "weight", weight);
            SFCM(playerid, COLOR_WHITE, "> %d. {77cdff}%s{FFFFFF} - %d g", id, name, weight);
        }
        cache_delete(result);
    } else SCM(playerid, -1, getStrMsg(STR_NTF));
    return 1;
}

CMD:lefoglal(playerid) {
    new closestVehicle = getClosestVehicle(playerid);
    if(getDistanceToCar(playerid, closestVehicle) < 5.0) {
        new vehicleDBID = getVehicleDBIDFromID(closestVehicle);
        PutPlayerInVehicle(playerid, closestVehicle, 0);
        vInfo[vehicleDBID][vEngine] = true;
        new engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(vInfo[vehicleDBID][vID], engine, lights, alarm, doors, bonnet, boot, objective);
        SetVehicleParamsEx(vInfo[vehicleDBID][vID], 1, lights, alarm, doors, bonnet, boot, objective);
        SFCM(playerid, COLOR_GREEN, "(( Lefoglaltál egy jármûvet! (DBID = %d) ))", vehicleDBID);
    } else SCM(playerid, COLOR_ORANGE, "(( Nincs jármû a közeledben! ))");
    return 1;
}

CMD:add(playerid, params[]) {
    new param[12];
    if(sscanf(params, "s[12]{}", param)) return SCM(playerid, COLOR_WHITE, "(( Használat: /add <típus> ))"), SCM(playerid, COLOR_WHITE, "(( Típusok: item, key ))");
    if(equals(param, "item")) {
        new id = -1;
        new itemDBID = -1;
        new itemAmount = 0;
        if(sscanf(params, "{s[12]}udd", id, itemAmount, itemDBID)) return SCM(playerid, COLOR_WHITE, "(( Használat: /add item <id / név> <darab> <tárgy id> ))");
        if(isValidPlayer(id)) {
            if(isValidItem(itemDBID)) {
                new result = addItem(id, itemDBID, itemAmount, -1);
                if(result) {
                    new itemName[64];
                    format(itemName, sizeof(itemName), getItemNameFromDBID(itemDBID));

                    SFCM(playerid, COLOR_GREEN, "(( Adtál %s-nak %d db %s-t! ))", getName(id), itemAmount, itemName);
                    SFCM(id, COLOR_GREEN, "(( %s %s adott neked %d db %s-t! ))", getPlayerAdminRank(playerid), getName(playerid), itemAmount, itemName);

                    serverLogFormatted(2, "%s kapott (%s %s-tól) %ddb %s-t", getRawName(id), getPlayerAdminRank(playerid), getRawName(playerid), itemAmount, itemName);
                } else SCM(playerid, COLOR_ORANGE, "(( Nem fér a táskájába ennyi! ))");
            } else SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen tárgy! ))");
        } else SCM(playerid, -1, getStrMsg(STR_NPF));
    } else if(equals(param, "key")) {
        new id = -1;
        new itemAmount = 0;
        new param1[32];
        if(sscanf(params, "{s[12]}uds[32]", id, itemAmount, param1)) return SCM(playerid, COLOR_WHITE, "(( Használat: /add key <id / név> <darab> <jármû> ))");
        if(isValidPlayer(id)) {
            if(isValidItem(2)) {
                new vdbid = getVehicleDBID(param1);
                if(vdbid != -1) {
                    addItem(id, 2, itemAmount, vdbid);

                    new itemName[64];
                    format(itemName, sizeof(itemName), getItemNameFromDBID(2));

                    SFCM(playerid, COLOR_GREEN, "(( Adtál %s-nak %d db %s(%s)-t! ))", getName(id), itemAmount, itemName, vInfo[vdbid][vPlate]);
                    SFCM(id, COLOR_GREEN, "(( %s %s adott neked %d db %s(%s)-t! ))", getPlayerAdminRank(playerid), getName(playerid), itemAmount, itemName, vInfo[vdbid][vPlate]);

                    serverLogFormatted(2, "%s kapott (%s %s-tól) %ddb %s(%s)-t", getRawName(id), getPlayerAdminRank(playerid), getRawName(playerid), itemAmount, itemName, vInfo[vdbid][vPlate]);
                } else SCM(playerid, -1, getStrMsg(STR_NVF));
            } else SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen tárgy! ))");
        } else SCM(playerid, -1, getStrMsg(STR_NPF));
    }
    return 1;
}

CMD:ahelp(playerid) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT al.name, cmd.command, cmd.permission, cmd.comment, col.color FROM adminlevels AS al JOIN commands AS cmd ON (cmd.permission = al.permission) JOIN colors AS col ON (al.color = col.name) WHERE (al.permission >= 1 AND al.permission <= '%d') ORDER BY cmd.permission DESC", getPlayerAdminPermission(playerid));
    inline q_showAhelp() {
        new rows = cache_num_rows();
        if(rows) {
            new dialogStr[4096];
            new dialogRow[256];
            new newLine[64];
            new al_Name[32], cmd_Command[32], cmd_Comment[128], cmd_Perm, col_Color[16];
            new lastPerm = 0;
            for(new i = 0; i < rows; i++) {
                // Getting data from cache
                mysql_get_string(i, "name", al_Name);
                mysql_get_string(i, "command", cmd_Command);
                mysql_get_string(i, "comment", cmd_Comment);
                mysql_get_int(i, "permission", cmd_Perm);
                mysql_get_string(i, "color", col_Color);

                // Formatting row
                if(lastPerm != cmd_Perm) {
                    format(newLine, sizeof(newLine), "\n{%s}%s{ffffff} parancsai:\n", col_Color, al_Name);
                    strcat(dialogStr, newLine);
                }
                format(dialogRow, sizeof(dialogRow), "{FFFFFF}/%s {AFAFAF}(%s) ", cmd_Command, cmd_Comment);
                strcat(dialogStr, dialogRow);
                if(i % 3 == 0 && lastPerm == cmd_Perm) strcat(dialogStr, "\n");
                lastPerm = cmd_Perm;
            }
            ShowPlayerDialog(playerid, DIALOG_AHELP, DIALOG_STYLE_MSGBOX, "[ {77abff}Adminhelp{FFFFFF} ]", dialogStr, "Oké", "");
        } else SCM(playerid, -1, getStrMsg(STR_NCF));
    }
    mysql_tquery_inline(mysql_id, queryStr, using inline q_showAhelp, "");
    return 1;
}

CMD:unban(playerid, params[]) {
    new name[25];
    if(sscanf(params, "s[25]", name)) return SCM(playerid, COLOR_WHITE, "(( Használat: /unban <teljes név / dbid> ))");
    if(isNumeric(name)) { // DBID
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT name FROM users WHERE dbid='%d'", strval(name));
        inline q_getPlayerNameUnban() {
            new rows = cache_num_rows();
            if(rows) {
                new bannedName[MAX_PLAYER_NAME];
                mysql_get_string(0, "name", bannedName);
                new bannedDBID = strval(name);
                mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT admin_dbid, banned_ip FROM bans WHERE banned_dbid='%d'", bannedDBID);
                inline q_checkBanStatusUnban() {
                    rows = cache_num_rows();
                    new adminDBID, bannedIP[16];
                    mysql_get_string(0, "banned_ip", bannedIP);
                    mysql_get_int(0, "admin_dbid", adminDBID);
                    if(rows) {
                        if(pInfo[playerid][pAdmin] >= 2 && pInfo[playerid][pAdmin] <= 6) {
                            if(adminDBID == pInfo[playerid][pDBID]) {
                                doQuery("DELETE FROM bans WHERE banned_dbid='%d'", bannedDBID);

                                if(!pInfo[playerid][P_TEMP][2]) {
                                    SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s feloldotta %s tíltását", getPlayerAdminRank(playerid), getName(playerid), bannedName);
                                }
                                SFCM(playerid, COLOR_GREEN, "(( %s(%d) tíltása feloldva! IP: %s ))", bannedName, bannedDBID, bannedIP);
                            } else SCM(playerid, COLOR_ORANGE, "(( Nem Te tíltottad ki a játékost! ))");
                        } else {
                            doQuery("DELETE FROM bans WHERE banned_dbid='%d'", bannedDBID);

                            if(!pInfo[playerid][P_TEMP][2]) {
                                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s feloldotta %s tíltását", getPlayerAdminRank(playerid), getName(playerid), bannedName);
                            }
                            SFCM(playerid, COLOR_GREEN, "(( %s(%d) tíltása feloldva! IP: %s ))", bannedName, bannedDBID, bannedIP);
                        }
                    } else SCM(playerid, -1, getStrMsg(STR_PNB));
                }
                mysql_tquery_inline(mysql_id, queryStr, using inline q_checkBanStatusUnban, "");
            } else SCM(playerid, -1, getStrMsg(STR_NPF));
        }
        mysql_tquery_inline(mysql_id, queryStr, using inline q_getPlayerNameUnban, "");
    } else { // Name
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT name, dbid FROM users WHERE name='%s'", name);
        inline q_getPlayerNameUnban() {
            new rows = cache_num_rows();
            if(rows) {
                new bannedDBID;
                new bannedName[MAX_PLAYER_NAME];
                mysql_get_int(0, "dbid", bannedDBID);
                mysql_get_string(0, "name", bannedName);
                mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT admin_dbid, banned_ip FROM bans WHERE banned_dbid='%d'", bannedDBID);
                inline q_checkBanStatusUnban() {
                    rows = cache_num_rows();
                    new adminDBID, bannedIP[16];
                    mysql_get_string(0, "banned_ip", bannedIP);
                    mysql_get_int(0, "admin_dbid", adminDBID);
                    if(rows) {
                        if(pInfo[playerid][pAdmin] >= 2 && pInfo[playerid][pAdmin] <= 6) {
                            if(adminDBID == pInfo[playerid][pDBID]) {
                                doQuery("DELETE FROM bans WHERE banned_dbid='%d'", bannedDBID);

                                if(!pInfo[playerid][P_TEMP][2]) {
                                    SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s feloldotta %s tíltását", getPlayerAdminRank(playerid), getName(playerid), bannedName);
                                }
                                SFCM(playerid, COLOR_ORANGE, "(( %s(%d) tíltása feloldva! IP: %s ))", bannedName, bannedDBID, bannedIP);
                            } else SCM(playerid, COLOR_ORANGE, "(( Nem Te tíltottad ki a játékost! ))");
                        } else {
                            doQuery("DELETE FROM bans WHERE banned_dbid='%d'", bannedDBID);

                            if(!pInfo[playerid][P_TEMP][2]) {
                                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s feloldotta %s tíltását", getPlayerAdminRank(playerid), getName(playerid), bannedName);
                            }
                            SFCM(playerid, COLOR_ORANGE, "(( %s(%d) tíltása feloldva! IP: %s ))", bannedName, bannedDBID, bannedIP);
                        }
                    } else SCM(playerid, -1, getStrMsg(STR_PNB));
                }
                mysql_tquery_inline(mysql_id, queryStr, using inline q_checkBanStatusUnban, "");
            } else SCM(playerid, -1, getStrMsg(STR_NPF));
        }
        mysql_tquery_inline(mysql_id, queryStr, using inline q_getPlayerNameUnban, "");
    }
    return 1;
}
CMD:asayn(playerid, params[]) {
    new asayMSG[128];
    if(sscanf(params, "s[128]", asayMSG)) return SCM(playerid, COLOR_WHITE, "(( Használat: /asay <üzenet> ))");
    if(strlen(asayMSG) <= 100) {
        SFCMToAll(COLOR_CYAN, "%s %s: %s", getPlayerAdminRank(playerid), getName(playerid), asayMSG);
    } else SCM(playerid, -1, getStrMsg(STR_TL));
    return 1;
}
CMD:asay(playerid, params[]) {
    new asayMSG[128];
    if(sscanf(params, "s[128]", asayMSG)) return SCM(playerid, COLOR_WHITE, "(( Használat: /asay <üzenet> ))");
    if(strlen(asayMSG) <= 100) {
        SFCMToAll(COLOR_CYAN, "Admin: %s", asayMSG);
    } else SCM(playerid, -1, getStrMsg(STR_TL));
    return 1;
}
CMD:elrak(playerid) {
    new count = 0;
   	new ammo, weaponid;
	new dialogStr[1024], rowStr[128];
    for(new c = 0; c < 13; c++) {
        GetPlayerWeaponData(playerid, c, weaponid, ammo);
        if (weaponid != 0 && ammo != 0) {
            count++;
        }
    }
    if(count > 0) {
        for (new c = 0; c < 13; c++) {
            GetPlayerWeaponData(playerid, c, weaponid, ammo);
            if (weaponid != 0 && ammo != 0) {
                format(rowStr, sizeof(rowStr), "%s\t%d\n", weaponNames[weaponid][0], ammo);
                strcat(dialogStr, rowStr);
            }
        }
        ShowPlayerDialog(playerid, DIALOG_PUTAWAY, DIALOG_STYLE_TABLIST, "[ {77abff}Elrakható tárgyak{FFFFFF} ]", dialogStr, "Elrak", "Mégse");
    } else SCM(playerid, COLOR_ORANGE, "(( Nincs nálad elrakható tárgy! ))");
    return 1;
}
CMD:awep(playerid,params[]) {
	new count = 0;
   	new ammo, weaponid, id;
	new s1[128], s2[128];
    if(sscanf(params, "u", id)) return SCM(playerid, COLOR_WHITE, "(( Használat: /awep <id / név> ))");
  	if(isValidPlayer(id)) {
        for(new c = 0; c < 13; c++) {
            GetPlayerWeaponData(id, c, weaponid, ammo);
            if (weaponid != 0 && ammo != 0) {
                count++;
            }
        }
        SFCM(playerid, COLOR_WHITE, "(( |_______ %s fegyverei: _______| ))", getName(id));
        if(count > 0) {
            new var = 0;
            for (new c = 0; c < 13; c++) {
                GetPlayerWeaponData(id, c, weaponid, ammo);
                if (weaponid != 0 && ammo != 0) {
					if(var == 0) format(s1,128,"%s(%d)", weaponNames[weaponid][0], ammo);
                    else format(s1,128,", %s(%d)", weaponNames[weaponid][0], ammo);
                    strcat(s2,s1);
                    var++;
                }
            }
            SFCM(playerid,COLOR_WHITE,"%s",s2);
       	} else {
            SCM(playerid, COLOR_WHITE,"Nincs fegyver a játékosnál");
        }
    } else SCM(playerid, -1, getStrMsg(STR_NPF));
    return 1;
}
CMD:givegun(playerid, params[]) {
    new id, ammo, wid[16];
    if(sscanf(params, "us[16]d", id, wid, ammo)) return SCM(playerid, COLOR_WHITE,"(( Használat: /givegun <id / név> <fegyvernév / id> <mennyiség> ))");
    if(isValidPlayer(id)) {
        new idx = -1;
        if(isNumeric(wid)) {
            idx = strval(wid);
            GivePlayerWeapon(id, idx, ammo);
        } else {
	        idx = getWeaponIDFromName(wid);
	        GivePlayerWeapon(id, idx, ammo);
		}
        if(!pInfo[playerid][P_TEMP][2]) {
            SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s adott %s-nak/nek egy %s-t %d tölténnyel", getPlayerAdminRank(playerid), getName(playerid), getName(id), weaponNames[idx][0], ammo);
        }
        SFCM(playerid, COLOR_GREEN, "(( Adtál %s-nak/nek egy %s-t %d tölténnyel! ))", getName(id), weaponNames[idx][0], ammo);
        SFCM(id, COLOR_GREEN, "(( %s %s adott neked egy %s-t %d tölténnyel! ))", getPlayerAdminRank(playerid), getName(playerid), weaponNames[idx][0], ammo);
    } else SCM(playerid, -1, getStrMsg(STR_NPF));
    return 1;
}
CMD:civilruha(playerid) {
    if(fInfo[ pInfo[playerid][pFraction] ][fType] == 1 || fInfo[ pInfo[playerid][pFraction] ][fType] == 5 || fInfo[ pInfo[playerid][pFraction] ][fType] == 4) {
        new divDBID = getDivDBIDByID(pInfo[playerid][pFraction], pInfo[playerid][pDivision]);
        if(dInfo[divDBID][dType] == 4 || dInfo[divDBID][dType] == 3) {
            if(pInfo[playerid][P_TEMP][6]) { // If the player is in duty
                new Float:pPos[3];
                GetPlayerPos(playerid, PosEx(pPos));

                new pInt = GetPlayerInterior(playerid);
                new pVW = GetPlayerVirtualWorld(playerid);

                new bool:foundPos = false; // To check if is a pos near by
                new bool:posWithLF = false; // To check if is there any pos with the player's fraction
                for(new i = 0; i < MAX_POSITIONS; i++) {
                    if(posInfo[i][posType] == POS_TYPE_DUTY) {
                        if(posInfo[i][posLF] == pInfo[playerid][pFraction] && posInfo[i][posExist]) {
                            posWithLF = true;
                            if(posInfo[i][posInt] == pInt && posInfo[i][posVW] == pVW) {
                                if(PlayerToPoint(playerid, posInfo[i][posRad], PosEx(posInfo[i][posPos]))) {
                                    foundPos = true;
                                    SetPlayerSkin(playerid, pInfo[playerid][pSkin][0]);
                                    playerMe(playerid, "felveszi a civilruháját");
                                    SCM(playerid, COLOR_GREEN, "(( Felvetted a civilruhádat! ))");
                                    break;
                                }
                            }
                        }
                    }
                }
                if(!foundPos && posWithLF) SCM(playerid, COLOR_ORANGE, "(( Itt nem öltözhetsz át! ))");
                if(!posWithLF) SCM(playerid, COLOR_ORANGE, "(( A frakciódnak nincs egyetlen öltözõje se! ))");
            } else SCM(playerid, -1, getStrMsg(STR_NID));
        } else SCM(playerid, -1, getStrMsg(STR_NHEP));
    } else SCM(playerid, -1, getStrMsg(STR_NHEP));
    return 1;
}
CMD:duty(playerid) {
    if(pInfo[playerid][pFraction] > 0) {
        new Float:pPos[3];
        GetPlayerPos(playerid, PosEx(pPos));

        new pInt = GetPlayerInterior(playerid);
        new pVW = GetPlayerVirtualWorld(playerid);

        new bool:foundPos = false; // To check if is a pos near by
        new bool:posWithLF = false; // To check if is there any pos with the player's fraction
        for(new i = 0; i < MAX_POSITIONS; i++) {
            if(posInfo[i][posType] == POS_TYPE_DUTY) {
                if(posInfo[i][posLF] == pInfo[playerid][pFraction] && posInfo[i][posExist]) {
                    posWithLF = true;
                    if(posInfo[i][posInt] == pInt && posInfo[i][posVW] == pVW) {
                        if(PlayerToPoint(playerid, posInfo[i][posRad], PosEx(posInfo[i][posPos]))) {
                            foundPos = true;
                            if(pInfo[playerid][P_TEMP][6]) { // If the player is in duty
                                pInfo[playerid][P_TEMP][6] = false;
                                pInfo[playerid][P_TEMP][14] = false;
                                SetPlayerSkin(playerid, pInfo[playerid][pSkin][0]);
                                playerMe(playerid, "kilépett a szolgálatból.");
                                SCM(playerid, COLOR_DARKRED, "(( Kiléptél a szolgálatból! ))");
                                ResetPlayerWeapons(playerid);
                            } else {
                                pInfo[playerid][P_TEMP][6] = true;
                                if(pInfo[playerid][pSkin][1] != -1) {
                                    SetPlayerSkin(playerid, pInfo[playerid][pSkin][1]);
                                } else {
                                    SCM(playerid, COLOR_WHITE, "(( Mivel még nincs kiválasztott munkaruhád, ezért skinváltóba kerültél! ))");
                                    setPlayerInSkinChanger(playerid);
                                }

                                playerMe(playerid, "szolgálatba lépett.");
                                SCM(playerid, COLOR_GREEN, "(( Szolgálatba léptél! ))");

                                // Fraction and rank specified weapons
                                switch(fInfo[pInfo[playerid][pFraction]][fType]) {
                                    case 1: { // Police
                                        switch(dInfo[getDivDBIDByID(pInfo[playerid][pFraction], pInfo[playerid][pDivision])][dType]) {
                                            case 4: { // Detective division
                                                GivePlayerWeapon(playerid, 43, 100); // Camera
                                                GivePlayerWeapon(playerid, 24, 14); // Deagle
                                            }
                                            default: {
                                                if(pInfo[playerid][pRank] == 1) {
                                                    GivePlayerWeapon(playerid, 3, 1); // Nitestick
                                                    GivePlayerWeapon(playerid, 41, 500); // Spray
                                                } else {
                                                    GivePlayerWeapon(playerid, 3, 1); // Nitestick
                                                    GivePlayerWeapon(playerid, 41, 500); // Spray
                                                    GivePlayerWeapon(playerid, 24, 14); // Deagle
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            break;
                        }
                    }
                }
            }
        }
        if(!foundPos && posWithLF) SCM(playerid, COLOR_ORANGE, "(( Itt nem állhatsz szolgálatba! ))");
        if(!posWithLF) SCM(playerid, COLOR_ORANGE, "(( A frakciódnak nincs egyetlen öltözõje se! ))");
    }
}
CMD:pos(playerid, params[]) {
    new param[12];
    if(sscanf(params, "s[12]{}", param)) return SCM(playerid, COLOR_WHITE, "(( Használat: /pos <típus> ))"), SCM(playerid, COLOR_WHITE, "(( Típusok: add, remove, info, goto, list, types ))");

    if(equals(param, "add")) {
        new pLF = -1;
        new Float:pRad = 5.0;
        new pComment[64];
        new pType = 0;

        if(sscanf(params, "{s[12]}ddF(5.0)s[64]", pType, pLF, pRad, pComment)) return SCM(playerid, COLOR_WHITE, "(( Használat: /pos add <típus> <frakció> [távolság=5.0] [megjegyzés] ))");
        createPosition(playerid, pType, pLF, pRad, pComment);
    } else if(equals(param, "remove") || equals(param, "rem")) {
        new posId = -1;
        if(sscanf(params, "{s[12]}d", posId)) return SCM(playerid, COLOR_WHITE, "(( Használat: /pos remove <dbid> ))");
        removePosition(playerid, posId);
    } else if(equals(param, "info")) {
        SendClientMessage(playerid, -1, "todo");
    } else if(equals(param, "list")) {
        SendClientMessage(playerid, -1, "todo");
    } else if(equals(param, "goto")) {
        new posId = -1;
        if(sscanf(params, "{s[12]}d", posId)) return SCM(playerid, COLOR_WHITE, "(( Használat: /pos goto <dbid> ))");

        if(isValidPosition(posId)) {
            SetPlayerPos(playerid, PosEx(posInfo[posId][posPos]));
            SetPlayerInterior(playerid, posInfo[posId][posInt]);
            SetPlayerVirtualWorld(playerid, posInfo[posId][posVW]);

            timePlayerFreeze(playerid);

            SFCM(playerid, COLOR_GREEN, "(( Elteleportáltál egy pozicíóhoz! (DBID = %d, Frakció = %s(%d), Típus = %s(%d) ))", posId, fInfo[posInfo[posId][posLF]][fSName], posInfo[posId][posLF], ptypeInfo[ posInfo[posId][posType] ][ptypeName], posInfo[posId][posType]);
        } else SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen pozició! ))");
    }
    else SCM(playerid, -1, getStrMsg(STR_NTF));
    return 1;
}
CMD:kulcs(playerid) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.param1, vehicles.model FROM inventory INNER JOIN vehicles ON vehicles.dbid=inventory.param1 WHERE inventory.userdbid='%d' AND inventory.itemdbid='2' AND inventory.amount>='1'", pInfo[playerid][pDBID]);
    mysql_tquery(mysql_id, queryStr, "showPlayerKeys", "d", playerid);
    return 1;
}
CMD:taska(playerid) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT inventory.amount as amount, inventory.param1 as param1, items.name as name FROM inventory INNER JOIN items ON items.dbid = inventory.itemdbid WHERE inventory.userdbid='%d'", pInfo[playerid][pDBID]);
    mysql_pquery(mysql_id, queryStr, "showPlayerInventory", "d", playerid);

    playerMe(playerid, "megnézi a táskája tartalmát");
    return 1;
}
CMD:aduty(playerid) {
    if(pInfo[playerid][P_TEMP][TEMP_ADUTY]) { // If the player already in adminduty
        pInfo[playerid][P_TEMP][TEMP_ADUTY] = false;

        if(!pInfo[playerid][P_TEMP][2]) {
            SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s kilépett az adminszolgálatból", getPlayerAdminRank(playerid), getName(playerid));
        }

        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s kilépett az adminszolgálatból", getPlayerAdminRank(playerid), getName(playerid));

        SCM(playerid, COLOR_DARKRED, "(( Kiléptél adminszolgálatból! ))");
        Delete3DTextLabel(pInfo[playerid][P_LABELS][0]);
    } else {
        pInfo[playerid][P_TEMP][TEMP_ADUTY] = true;

        if(!pInfo[playerid][P_TEMP][2]) {
            SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s adminszolgálatba lépett", getPlayerAdminRank(playerid), getName(playerid));
        }

        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s adminszolgálatba lépett", getPlayerAdminRank(playerid), getName(playerid));

        SCM(playerid, COLOR_GREEN, "(( Adminszolgálatba léptél! ))");

        new string[128];
        format(string, sizeof(string), "{FFFFFF}%s{%s} (%s)", getName(playerid), getPlayerAdminColor(playerid), getPlayerAdminRank(playerid));
	    pInfo[playerid][P_LABELS][0] = Create3DTextLabel(string, -1, 0, 0, 0, 50, 1, 1);
	    Attach3DTextLabelToPlayer(pInfo[playerid][P_LABELS][0], playerid, 0, 0, 0.4);
    }
    return 1;
}

CMD:motor(playerid) {
    if(IsPlayerInAnyVehicle(playerid)) {
        vehicleEngine(playerid);
    }
}

CMD:members(playerid, params[]) {
    new fkid = -1;
    if(sscanf(params, "d", fkid)) return SCM(playerid, COLOR_WHITE, "(( Használat: /members <frakció id> ))");

    if(fkid > 0 && fkid < MAX_FRACTIONS) {
        if(fInfo[fkid][fExist]) {
            format(queryStr, sizeof(queryStr), "SELECT users.name as uname, users.dbid, users.rank, users.division, users.last_online, users.leader, fraction_ranks.name as rname, divisions.name as dname FROM ");
            format(queryStr, sizeof(queryStr), "%s users INNER JOIN fraction_ranks ON fraction_ranks.rank_id=users.rank AND fraction_ranks.linked_fraction=users.fraction INNER JOIN divisions ON ", queryStr);
            format(queryStr, sizeof(queryStr), "%s divisions.division_id=users.division AND (divisions.linked_fraction=users.fraction OR divisions.linked_fraction=-1) WHERE users.fraction='%d' ORDER BY users.rank DESC, users.leader DESC", queryStr, fkid);
            inline showPlayerFcMembers() {
                if(cache_num_rows()) {
                    new userDBID = -1;
                    new userName[MAX_PLAYER_NAME];
                    new userRank = 0;
                    new userDiv = 0;
                    new userLeader = 0;
                    new userLO[128];
                    new rankName[32];
                    new divName[64];

                    new loText[sizeof(userLO)];

                    new dialogStr[4096] = "{FFFFFF}A {8fff84}zöld{ffffff} színnel jelölt rangú játékosok frakcióvezetõi joggal rendelkeznek!\n\n";
                    new dialogRow[256];
                    new dialogTitle[64];
                    format(dialogTitle, sizeof(dialogTitle), "[ {77abff}%s{ffffff}(%d) tagjai ]", fInfo[fkid][fName], fInfo[fkid][fDBID]);
                    for(new i = 0; i < cache_num_rows(); i++) {
                        mysql_get_int(i, "dbid", userDBID);
                        mysql_get_string(i, "uname", userName);
                        mysql_get_int(i, "rank", userRank);
                        mysql_get_int(i, "division", userDiv);
                        mysql_get_int(i, "leader", userLeader);
                        mysql_get_string(i, "last_online", userLO);
                        mysql_get_string(i, "rname", rankName);
                        mysql_get_string(i, "dname", divName);

                        if(isValidPlayer(ReturnUser(userName))) format(loText, sizeof(loText), "{8fff84}ONLINE");
                        else format(loText, sizeof(loText), "{%06x}%s", COLOR_YELLOW >>> 8, userLO);

                        if(userLeader == 1) {
                            format(dialogRow, sizeof(dialogRow), "{77cdff}%s{ffffff}(%d) - Rang: {8fff84}%s{ffffff}(%d) - Alosztály: {77cdff}%s{ffffff}(%d) - %s\n\n", userName, userDBID, rankName, userRank, divName, userDiv, loText);
                        } else {
                            format(dialogRow, sizeof(dialogRow), "{77cdff}%s{ffffff}(%d) - Rang: {77cdff}%s{ffffff}(%d) - Alosztály: {77cdff}%s{ffffff}(%d) - %s\n\n", userName, userDBID, rankName, userRank, divName, userDiv, loText);
                        }
                        strcat(dialogStr, dialogRow);
                    }
                    ShowPlayerDialog(playerid, DIALOG_MEMBERS, DIALOG_STYLE_MSGBOX, dialogTitle, dialogStr, "Oké", "");
                } else SCM(playerid, COLOR_ORANGE, "(( A frakció üres! ))");
            }
            mysql_tquery_inline(mysql_id, queryStr, using inline showPlayerFcMembers, "");
        } else SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen frakció! ))");
    } else SCM(playerid, COLOR_ORANGE, "(( A frakció id-nek 0 és "#MAX_FRACTIONS" között kell lennie! ))");
    return 1;
}

CMD:test(playerid, params[]) {
    new id = -1;
    if(sscanf(params, "d", id)) return SCM(playerid, -1, "/test id");

    SFCM(playerid, -1, "id = %d", id);
    PlayCrimeReportForPlayer(playerid, playerid, id);

    return 1;
}

CMD:valasz(playerid, params[]) {
    if(rInfo[pInfo[playerid][pSelectedReportCat]][rType] != 2) {
        new id = -1;
        new msg[128];
        if(sscanf(params, "us[128]", id, msg)) return SCM(playerid, COLOR_WHITE, "(( Használat: /va(lasz) <id / név> <válasz> ))");
        if(isValidPlayer(id)) {
            // serverLog
            serverLogFormatted(5, "*AdmCmd* %s %s válaszolt %s-nak/nek: %s", getPlayerAdminRank(playerid), getName(playerid), getName(id), id, msg);

            SFAM(pInfo[playerid][pAdmin], COLOR_OLIVE, "*AdmCmd* %s %s válaszolt %s(%d)-nak/nek: %s", getPlayerAdminRank(playerid), getName(playerid), getName(id), id, msg);
            SFCM(id, COLOR_YELLOW, "(( *%s* %s %s válasza: %s ))", rInfo[pInfo[playerid][pSelectedReportCat]][rSName], getPlayerAdminRank(playerid), getName(playerid), msg);
        } else SCM(playerid, -1, getStrMsg(STR_NPF));
    } else SCM(playerid, COLOR_ORANGE, "(( AFK kategóriában nem használhatod! ))");
    return 1;
}
alias:valasz("va");

CMD:adminok(playerid, params[]) { // Show online admins
    new myAdminRank = getPlayerAdminPermission(playerid);
    new iAdminRank = -1;
    SCM(playerid, COLOR_WHITE, "(( |__________ Online admin(ok): __________| ))");
    new j = 0;
    for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
        if(isValidPlayer(i)) {
            iAdminRank = getPlayerAdminPermission(i);
            if(iAdminRank > 0) {
                j++;
                if(pInfo[i][P_TEMP][7] && myAdminRank < iAdminRank) {
                    // TODO
                } else {
                    if(myAdminRank >= 1) { // If the player is an admin
                        SFCM(playerid, COLOR_WHITE, "(( Név: {77cdff}%s{ffffff} | Adminszint: {77cdff}%s{ffffff} [{%s}%s{ffffff}] ))", getName(i),  getPlayerAdminRank(i), rInfo[pInfo[i][pSelectedReportCat]][rColor], rInfo[pInfo[i][pSelectedReportCat]][rSName]);
                    } else { // If not
                        SFCM(playerid, COLOR_WHITE, "(( Név: {77cdff}%s{ffffff} | Adminszint: {77cdff}%s{ffffff} ))", getName(i), getPlayerAdminRank(i));
                    }
                }
            }
        }
    }

    // Why not? :D
    /*
    new i_to_str[4];
    valstr(i_to_str, i);
    sendFormattedMessage(playerid, MSG_INFO, srvInfo[SRV_NAME], "There %s {77cdff}%s{FFFFFF} online admin%s.", i == 1 || i == 0 ? ("is") : ("are"), i == 0 ? ("no") : i_to_str, i > 1 ? ("s") : (""));
    */
    if(j != 0)
        SFCM(playerid, COLOR_WHITE, "(( Összesen {77cdff}%d{FFFFFF} online admin van ))", j);
    else
        SCM(playerid, COLOR_WHITE, "(( Nincs online admin ))");
    return 1;
}
CMD:goto(playerid, params[]) {
    new id = -1;
    if(sscanf(params, "u", id)) return SCM(playerid, COLOR_WHITE, "(( Használat: /goto <id / név> ))");
    if(isValidPlayer(id)) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s elteleportált %s-hoz", getPlayerAdminRank(playerid), getName(playerid), getName(id));

        // Messages
        SFCM(playerid, COLOR_GREEN, "(( Elteleportáltál %s(%d)-hoz/hez! ))", getName(id), id);
        SFCM(id, COLOR_ORANGE, "(( %s %s hozzád teleportált! ))", getPlayerAdminRank(playerid), getName(playerid));

        // Get the selected player position and then set the position of the admin
        if(IsPlayerInAnyVehicle(id)) {
            new vehicleID = GetPlayerVehicleID(id);
            if(GetPlayerVehicleSeat(id) == 0) { // If the player is the driver
                PutPlayerInVehicle(playerid, vehicleID, 1);
            } else { // If the player is a passenger
                PutPlayerInVehicle(playerid, vehicleID, 0);
            }
        } else {
            new Float:tPos[3] = {0.0, 0.0, 6.0};
            GetPlayerPos(id, PosEx(tPos));
            SetPlayerPos(playerid, PosEx(tPos));
        }

        SetPlayerInterior(playerid, GetPlayerInterior(id));
        SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(id));
    } else SCM(playerid, -1, getStrMsg(STR_NPF));
    return 1;
}
CMD:get(playerid, params[]) {
    new id = -1;
    if(sscanf(params, "u", id)) return SCM(playerid, COLOR_WHITE, "(( Használat: /get <id / név> ))");
    if(isValidPlayer(id)) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s magához teleportálta %s-t", getPlayerAdminRank(playerid), getName(playerid), getName(id));

        // Messages
        SFCM(playerid, COLOR_GREEN, "(( Magadhoz teleportáltad %s(%d)-t! ))", getName(id), id);
        SFCM(id, COLOR_ORANGE, "(( %s %s magához teleportált téged! ))", getPlayerAdminRank(playerid), getName(playerid));

        // Get the selected player position and then set the position of the admin
        if(IsPlayerInAnyVehicle(playerid)) {
            new vehicleID = GetPlayerVehicleID(playerid);
            if(GetPlayerVehicleSeat(playerid) == 0) { // If the player is the driver
                PutPlayerInVehicle(id, vehicleID, 1);
            } else { // If the player is a passenger
                PutPlayerInVehicle(id, vehicleID, 0);
            }
        } else {
            new Float:tPos[3] = {0.0, 0.0, 6.0};
            GetPlayerPos(playerid, PosEx(tPos));
            SetPlayerPos(id, PosEx(tPos));
        }

        SetPlayerInterior(id, GetPlayerInterior(playerid));
        SetPlayerVirtualWorld(id, GetPlayerVirtualWorld(playerid));
    } else {
        SCM(playerid, -1, getStrMsg(STR_NPF));
    }
    return 1;
}

CMD:toggle(playerid, params[]) {
    new param[12];
    if(sscanf(params, "s[12]", param)) return SCM(playerid, COLOR_WHITE, "(( Használat: /toggle <típus> ))"), SCM(playerid, COLOR_WHITE, "(( Típusok: connects, admlog, cmds, bigear, ahide, maptele ))");
    if(equals(param, "admlog")) {
        if(pInfo[playerid][P_TEMP][2]) {
            pInfo[playerid][P_TEMP][2] = false;
            SCM(playerid, COLOR_DARKRED, "(( AdmLog rejtés kikapcsolva! ))");
        } else {
            pInfo[playerid][P_TEMP][2] = true;
            SCM(playerid, COLOR_GREEN, "(( AdmLog rejtés bekapcsolva! ))");
        }
    } else if(equals(param, "connects")) {
        if(pInfo[playerid][P_TEMP][3]) {
            pInfo[playerid][P_TEMP][3] = false;
            SCM(playerid, COLOR_DARKRED, "(( ConLog kikapcsolva! ))");
        } else {
            pInfo[playerid][P_TEMP][3] = true;
            SCM(playerid, COLOR_GREEN, "(( ConLog bekapcsolva! ))");
        }
    } else if(equals(param, "debug")) {
        if(pInfo[playerid][P_TEMP][15]) {
            pInfo[playerid][P_TEMP][15] = false;
            SCM(playerid, COLOR_DARKRED, "(( Debug kikapcsolva! ))");
        } else {
            pInfo[playerid][P_TEMP][15] = true;
            SCM(playerid, COLOR_GREEN, "(( Debug bekapcsolva! ))");
        }
    } else if(equals(param, "maptele")) {
        if(pInfo[playerid][P_TEMP][13]) {
            pInfo[playerid][P_TEMP][13] = false;
            SCM(playerid, COLOR_DARKRED, "(( MapTele kikapcsolva! ))");
        } else {
            pInfo[playerid][P_TEMP][13] = true;
            SCM(playerid, COLOR_GREEN, "(( MapTele bekapcsolva! ))");
        }
    } else if(equals(param, "cmds")) {
        if(pInfo[playerid][P_TEMP][5]) {
            pInfo[playerid][P_TEMP][5] = false;
            SCM(playerid, COLOR_DARKRED, "(( CmdLog kikapcsolva! ))");
        } else {
            pInfo[playerid][P_TEMP][5] = true;
            SCM(playerid, COLOR_GREEN, "(( CmdLog bekapcsolva! ))");
        }
    } else if(equals(param, "bigear")) {
        if(pInfo[playerid][P_TEMP][10]) {
            pInfo[playerid][P_TEMP][10] = false;
            SCM(playerid, COLOR_DARKRED, "(( BigEar kikapcsolva! ))");
        } else {
            pInfo[playerid][P_TEMP][10] = true;
            SCM(playerid, COLOR_GREEN, "(( BigEar bekapcsolva! ))");
        }
    } else if(equals(param, "ahide")) {
        if(pInfo[playerid][P_TEMP][7]) { // If the player already in hidden mode
            pInfo[playerid][P_TEMP][7] = false;
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s kilépett rejtett módból", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_DARKRED, "(( Kiléptél rejtett módból! ))");
        } else {
            pInfo[playerid][P_TEMP][7] = true;
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s rejtett módba lépett", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_GREEN, "(( Rejtett módba léptél! ))");
        }
    } else SCM(playerid, -1, getStrMsg(STR_NTF));
    return 1;
}

CMD:do(playerid,params[]) {
    new doStr[128];
    if(sscanf(params, "s[128]", doStr)) return SCM(playerid, COLOR_WHITE, "(( Használat: /do <történés> ))");

    playerDo(playerid, doStr);
	return 1;
}

CMD:sn(playerid) {
	SCM(playerid, COLOR_WHITE, "(( Közelben lévõ játékosok: ))");
    new Float:pPos[3];
    GetPlayerPos(playerid, PosEx(pPos));
    for(new i, j = GetPlayerPoolSize()+1; i < j; i++) {
        if(IsPlayerInRangeOfPoint(i, 20.0, PosEx(pPos))) {
            SFCM(playerid, COLOR_SPRINGGREEN, "> %s[%d]", getName(i), i);
            //ShowPlayerNameTagForPlayer(playerid, i, true);
        }
    }
    return 1;
}

CMD:me(playerid,params[]) {
    new me[128];
    if(sscanf(params, "s[128]", me)) return SCM(playerid, COLOR_WHITE, "(( Használat: /me <cselekvés> ))");

    playerMe(playerid, me);
	return 1;
}

CMD:try(playerid, params[]) {
    new szoveg[128];
    if(sscanf(params, "s[128]", szoveg)) return SCM(playerid, COLOR_WHITE, "(( Használat: /try <cselekvés> ))");

    new rand = randint(0,1);
    new formatString[sizeof(szoveg)];
    if(rand == 0) { // If not
        format(formatString, sizeof(formatString), "** %s megpróbál(ja) %s, de nem sikerül neki.", getName(playerid), szoveg);

        // serverLog
        serverLogFormatted(4, "** %s megpróbál(ja) %s, de nem sikerül neki.", getRawName(playerid), szoveg);
    } else {
        format(formatString, sizeof(formatString), "** %s megpróbál(ja) %s, és sikerül neki.", getName(playerid), szoveg);

        // serverLog
        serverLogFormatted(4, "** %s megpróbál(ja) %s, és sikerül neki.", getRawName(playerid), szoveg);
    }
    Prox(playerid, 15.0, formatString, COLOR_PURPLE2);

    new resultstring[128];
    format(resultstring, sizeof(resultstring), "%s", formatString);
    SetPlayerChatBubble(playerid, resultstring, COLOR_PURPLE2, 15.0, 8000);
    return 1;
}

CMD:b(playerid, params[]) {
    new szoveg[128];
	if(sscanf(params, "s[128]", szoveg)) return SCM(playerid, COLOR_WHITE, "(( Használat: /b <szöveg> ))");

    playerOOC(playerid, szoveg);
    return 1;
}

CMD:h(playerid, params[]) {
	new szoveg[128];
	if(sscanf(params, "s[128]", szoveg)) return SCM(playerid, COLOR_WHITE, "(( Használat: /h(halk) <szöveg> ))");

    if(!pInfo[playerid][P_TEMP][TEMP_ADUTY]) { // If the player is in aduty
        new Float:pPos[3];
        GetPlayerPos(playerid, PosEx(pPos));
        SetPlayerChatBubble(playerid, szoveg, COLOR_WHITE, 3.0, 8000);
        SFCM(playerid, COLOR_WHITE, "Te mondod halkan: %s", szoveg);
        for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
            if(isValidPlayer(i)) {
                if(PlayerToPoint(i, 3.0, PosEx(pPos)) && !pInfo[i][P_TEMP][10]) {
                    if(i != playerid) {
                        SFCM(i, COLOR_WHITE, "%s halkan mondja: %s", getName(playerid), szoveg);
                    }
                } else if(pInfo[i][P_TEMP][10]) {
                    SFCM(i, COLOR_YELLOW, "*BigEar*{FFFFFF} %s halkan mondja: %s", getName(playerid), szoveg);
                }
            }
        }
    } else {
        playerOOC(playerid, szoveg);
    }
	return 1;
}

CMD:o(playerid, params[]) {
	new szoveg[128];
	if(sscanf(params, "s[128]", szoveg)) return SCM(playerid, COLOR_WHITE, "(( Használat: /o(rdit) <szöveg> ))");

    if(!pInfo[playerid][P_TEMP][TEMP_ADUTY]) { // If the player is in aduty
        new Float:pPos[3];
        GetPlayerPos(playerid, PosEx(pPos));
        SetPlayerChatBubble(playerid, szoveg, COLOR_RED, 30.0, 8000);
        SFCM(playerid, COLOR_WHITE, "Te ordítod: %s", szoveg);
        for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
            if(isValidPlayer(i)) {
                if(PlayerToPoint(i, 30.0, PosEx(pPos)) && !pInfo[i][P_TEMP][10]) {
                    if(i != playerid) {
                        SFCM(i, COLOR_WHITE, "%s ordítja: %s", getName(playerid), szoveg);
                    }
                } else if(pInfo[i][P_TEMP][10]) {
                    SFCM(i, COLOR_YELLOW, "*BigEar*{FFFFFF} %s ordítja: %s", getName(playerid), szoveg);
                }
            }
        }
    } else {
        playerOOC(playerid, szoveg);
    }
	return 1;
}

CMD:k(playerid, params[]) {
	new szoveg[128];
	if(sscanf(params, "s[128]", szoveg)) return SCM(playerid, COLOR_WHITE, "(( Használat: /k(ozeli) <szöveg> ))");

    playerIC(playerid, szoveg);
	return 1;
}

CMD:reload(playerid, params[]) {
    new param[12];
    if(sscanf(params, "s[12]", param)) return SCM(playerid, COLOR_WHITE, "(( Használat: /reload <típus> ))"), SCM(playerid, COLOR_WHITE, "(( Típusok: config, position, fractions, divisions, reports, teleports, position_types ))");
    if(equals(param, "config")) {
        new result = loadServerConfig();
        if(bool:result) {
            // serverLog
            serverLogFormatted(5, "*AdmCmd* %s %s újratöltötte a szerver konfigurációt", getPlayerAdminRank(playerid), getName(playerid));

            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s újratöltötte a szerver konfigurációt", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_GREEN, "(( Szerver konfiguráció sikeresen újratöltve! ))");
        } else SCM(playerid, COLOR_DARKRED, "(( Hiba a szerver konfiguráció betöltése során (log)! ))");
    } else if(equals(param, "positions") || equals(param, "pos")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s újratöltötte a pozicíókat", getPlayerAdminRank(playerid), getName(playerid));

        new result = startPosLoad();
        if(bool:result) {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s újratöltötte a pozicíókat", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_GREEN, "(( Pozicíók sikeresen újratöltve! ))");
        } else SCM(playerid, COLOR_DARKRED, "(( Hiba a pozicíók betöltése során (log)! ))");
    } else if(equals(param, "adminlevels") || equals(param, "al")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s újratöltötte az adminszinteket", getPlayerAdminRank(playerid), getName(playerid));

        new result = startAdminLevelLoad();
        if(bool:result) {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s újratöltötte a pozicíókat", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_GREEN, "(( Adminszintek sikeresen újratöltve! ))");
        } else SCM(playerid, COLOR_DARKRED, "(( Hiba az adminszintek betöltése során (log)! ))");
    } else if(equals(param, "strings") || equals(param, "str")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s újratöltötte az stringeket", getPlayerAdminRank(playerid), getName(playerid));

        new result = startStringLoad();
        if(bool:result) {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s újratöltötte a stringeket", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_GREEN, "(( Stringek sikeresen újratöltve! ))");
        } else SCM(playerid, COLOR_DARKRED, "(( Hiba a stringek betöltése során (log)! ))");
    } else if(equals(param, "position_types") || equals(param, "ptype")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s újratöltötte a pozicíó típusokat", getPlayerAdminRank(playerid), getName(playerid));

        new result = startPosTypeLoad();
        if(bool:result) {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s újratöltötte a pozicíó típusokat", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_GREEN, "(( Pozicíó típusok sikeresen újratöltve! ))");
        } else SCM(playerid, COLOR_DARKRED, "(( Hiba a pozicíó típusok betöltése során (log)! ))");
    } else if(equals(param, "fractions") || equals(param, "fc")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s újratöltötte a frakciókat", getPlayerAdminRank(playerid), getName(playerid));

        new result = startFractionLoad();
        if(bool:result) {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s újratöltötte a frakciókat", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_GREEN, "(( Frakciók sikeresen újratöltve! ))");
        } else SCM(playerid, COLOR_DARKRED, "(( Hiba a frakciók betöltése során (log)! ))");
    } else if(equals(param, "divisions") || equals(param, "div")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s újratöltötte az alosztályokat", getPlayerAdminRank(playerid), getName(playerid));

        new result = startDivisionLoad();
        if(bool:result) {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s újratöltötte az alosztályokat", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_GREEN, "(( Alosztályok sikeresen újratöltve! ))");
        } else SCM(playerid, COLOR_DARKRED, "(( Hiba az alosztályok betöltése során (log)! ))");
    } else if(equals(param, "ranks") || equals(param, "ranks")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s újratöltötte a rangokat", getPlayerAdminRank(playerid), getName(playerid));

        new result = startRankLoad();
        if(bool:result) {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s újratöltötte a rangokat", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_GREEN, "(( Rangok sikeresen újratöltve! ))");
        } else SCM(playerid, COLOR_DARKRED, "(( Hiba a rangok betöltése során (log)! ))");
    } else if(equals(param, "reports") || equals(param, "rep")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s újratöltötte a report kategóriákat", getPlayerAdminRank(playerid), getName(playerid));

        new result = startReportCatLoad();
        if(bool:result) {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s újratöltötte a report kategóriákat", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_GREEN, "(( Report kategóriák sikeresen újratöltve! ))");
        } else SCM(playerid, COLOR_DARKRED, "(( Hiba a report kategóriák betöltése során (log)! ))");
    } else if(equals(param, "labels")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s újratöltötte a feliratokat", getPlayerAdminRank(playerid), getName(playerid));

        new result = startLabelsLoad();
        if(bool:result) {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s újratöltötte a feliratokat", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_GREEN, "(( Feliratok sikeresen újratöltve! ))");
        } else SCM(playerid, COLOR_DARKRED, "(( Hiba a feliratok betöltése során (log)! ))");
    } else if(equals(param, "teleports") || equals(param, "tp")) {
        // serverLog
        serverLogFormatted(5, "*AdmCmd* %s %s újratöltötte a teleportokat", getPlayerAdminRank(playerid), getName(playerid));

        new result = startTeleportsLoad();
        if(bool:result) {
            if(!pInfo[playerid][P_TEMP][2]) {
                SFAM(pInfo[playerid][pAdmin], COLOR_TOMATO, "*AdmCmd* %s %s újratöltötte a teleportokat", getPlayerAdminRank(playerid), getName(playerid));
            }
            SCM(playerid, COLOR_GREEN, "(( Teleportok sikeresen újratöltve! ))");
        } else SCM(playerid, COLOR_DARKRED, "(( Hiba a teleportok betöltése során (log)! ))");
    }
    else SCM(playerid, -1, getStrMsg(STR_NTF));
    return 1;
}
CMD:penztarca(playerid) {
    playerMe(playerid, "megnézi a pénztárcája tartalmát");
    SFCM(playerid, -1, getStrMsg(STR_SW), formatNumber(pInfo[playerid][pMoney]));
    return 1;
}
CMD:id(playerid, params[]) {
    new id = -1;
    if(sscanf(params, "u", id)) return SCM(playerid, COLOR_WHITE, "(( Használat: /id <id / név> ))");

    if(isValidPlayer(id)) SFCM(playerid, COLOR_WHITE, getStrMsg(STR_SI), getName(id), id);
    else SCM(playerid, -1, getStrMsg(STR_NPF));

    return 1;
}

CMD:item(playerid, params[]) {
    new param[12];
    if(sscanf(params, "s[12]{}", param)) return SCM(playerid, COLOR_WHITE, "(( Használat: /item <típus> ))"), SCM(playerid, COLOR_WHITE, "(( Típusok: add, remove, info, list ))");
    if(equals(param, "info")) {
        new item[64];
        if(sscanf(params, "{s[12]}s[64]", item)) return SCM(playerid, COLOR_WHITE, "(( Használat: /item info <dbid / név> ))");

        if(isNumeric(item)) { // If the player entered a DBID
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT * FROM items WHERE items.dbid='%d'", strval(item));
            new Cache:result = mysql_query(mysql_id, queryStr);
            if(cache_num_rows() == 1) {
                new weight;
                mysql_get_int(0, "weight", weight);
                new name[64];
                mysql_get_string(0, "name", name);
                SFCM(playerid, COLOR_WHITE, "> %d. {77cdff}%s{FFFFFF} - %d g", strval(item), name, weight);
            } else SCM(playerid, -1, getStrMsg(STR_NIF));
            cache_delete(result);
        } else { // .. item name
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT * FROM items WHERE items.name='%e'", item);
            new Cache:result = mysql_query(mysql_id, queryStr);
            if(cache_num_rows() == 1) {
                new weight, id;
                mysql_get_int(0, "dbid", id);
                mysql_get_int(0, "weight", weight);
                new name[64];
                mysql_get_string(0, "name", name);
                SFCM(playerid, COLOR_WHITE, "> %d. {77cdff}%s{FFFFFF} - %d g", id, name, weight);
            } else SCM(playerid, -1, getStrMsg(STR_NIF));
            cache_delete(result);
        }
    } else if(equals(param, "remove") || equals(param, "rem")) {
        new item[64];
        if(sscanf(params, "{s[12]}s[64]", item)) return SCM(playerid, COLOR_WHITE, "(( Használat: /item remove <dbid / név> ))");

        if(isNumeric(item)) { // If the player entered a DBID
            new itemDBID = strval(item);
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT items.dbid WHERE items.dbid='%d'", itemDBID);
            new Cache:result = mysql_query(mysql_id, queryStr);
            if(cache_num_rows() == 1) { // Check if the item even exist..
                mysql_format(mysql_id, queryStr, sizeof(queryStr), "DELETE FROM items WHERE items.dbid='%d'", itemDBID);
                result = mysql_query(mysql_id, queryStr);
                if(result) {
                    SFCM(playerid, COLOR_GREEN, "(( Tárgy sikeresen törölve az adatbázisból! (DBID = %d) ))", itemDBID);
                } else {
                    SCM(playerid, COLOR_DARKRED, "(( Hiba történt a törlés közben (log)! ))");
                }
                cache_delete(result);
            } else SCM(playerid, -1, getStrMsg(STR_NIF));
            cache_delete(result);
        } else { // .. item name
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT items.dbid FROM items WHERE items.name='%e'", item);
            new Cache:result = mysql_query(mysql_id, queryStr);
            if(cache_num_rows() == 1) { // Success
                new itemDBID;
                mysql_get_int(0, "dbid", itemDBID);
                mysql_format(mysql_id, queryStr, sizeof(queryStr), "DELETE FROM items WHERE items.dbid='%d'", itemDBID);
                result = mysql_query(mysql_id, queryStr);
                if(result) {
                    SFCM(playerid, COLOR_GREEN, "(( Tárgy sikeresen törölve az adatbázisból! (DBID = %d) ))", itemDBID);
                } else {
                    SCM(playerid, COLOR_DARKRED, "(( Hiba történt a törlés közben (log)! ))");
                }
                cache_delete(result);
            } else SCM(playerid, -1, getStrMsg(STR_NIF));
            cache_delete(result);
        }
    }
    return 1;
}

CMD:command(playerid, params[]) {
    new type[12];
    if(sscanf(params, "s[12]{}", type)) return SCM(playerid, COLOR_WHITE, "(( Használat: /command <típus> ))"), SCM(playerid, COLOR_WHITE, "(( Típusok: list, add, remove, info ))");
    if(equals(type, "list")) {
        //new Cache:result = mysql_query(mysql_id, "SELECT * FROM commands");
        new Cache:result = mysql_query(mysql_id, "SELECT c.dbid, c.command, c.comment, c.permission, al.name, col.color FROM commands AS c JOIN adminlevels AS al ON (c.permission = al.permission) JOIN colors AS col ON (col.name = al.color) ORDER BY dbid");
        if(cache_num_rows() > 0) {
            // Variables for displaying the records
            new id = -1;
            new cmd[64];
            new name[64];
            new color[16];
            new perm = -1;
            new comment[128];
            //
            SCM(playerid, COLOR_WHITE, "(( |________________ Parancs lista ________________| ))");
            for(new i = 0; i < cache_num_rows(); i++) {
                //
                mysql_get_int(i, "dbid", id); // Command DBID
                mysql_get_int(i, "permission", perm); // Command permission
                mysql_get_string(i, "command", cmd); // Command name
                mysql_get_string(i, "color", color); // Adminlevel color
                mysql_get_string(i, "name", name); // Adminlevel name
                mysql_get_string(i, "comment", comment); // Command comment
                //
                SFCM(playerid, COLOR_WHITE, "> %d. (/{77cdff}%s{FFFFFF}) - Hozzáférés: {%s}%s{FFFFFF}(%d) - %s", id, cmd, color, name, perm, comment);
            }
        } else {
            SCM(playerid, COLOR_ORANGE, "(( Nincsenek parancsok! ))");
        }
        cache_delete(result);
    } else if(equals(type, "add")) {
        new command[64], perm, comment[128];
        if(sscanf(params, "{s[12]}s[64]I(0)S(No comment defined.)[128]", command, perm, comment)) return SCM(playerid, COLOR_WHITE, "(( Használat: /command add <parancs> [jog] [leírás] ))");

        mysql_format(mysql_id, queryStr, sizeof(queryStr), "INSERT INTO commands (`command`, `permission`, `comment`) VALUES ('%e', '%d', '%e')", command, perm, comment);
    	new Cache:result = mysql_query(mysql_id, queryStr);

        if(result) {
            SFCM(playerid, COLOR_GREEN, "(( Parancs sikeresen hozzáadva az adatbázishoz! (DBID = %d) ))", cache_insert_id());
        } else {
            SCM(playerid, COLOR_DARKRED, "(( Hiba történt a hozzáadás közben (log)! ))");
        }
        cache_delete(result);
    } else if(equals(type, "remove") || equals(type, "rem")) {
        new input[64];
        if(sscanf(params, "{s[12]}s[64]", input)) return SCM(playerid, COLOR_WHITE, "(( Használat: /command remove <parancs / dbid> ))");
        new commandDBID = -1;
        if(isNumeric(input)) {
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT dbid FROM commands WHERE command='%e'", input);
            new Cache:result = mysql_query(mysql_id, queryStr);

            if(cache_num_rows() == 1) { // If the command even exist..
                commandDBID = strval(input);
                mysql_format(mysql_id, queryStr, sizeof(queryStr), "DELETE FROM commands WHERE dbid='%d'", commandDBID);
            	result = mysql_query(mysql_id, queryStr);

                if(result) {
                    SFCM(playerid, COLOR_GREEN, "(( Parancs sikeresen törölve az adatbázisból! (DBID = %s) ))", commandDBID);
                } else {
                    SCM(playerid, COLOR_DARKRED, " ((Hiba történt a törlés közben (log)! ))");
                }
                cache_delete(result);
            } else SCM(playerid, -1, getStrMsg(STR_NCF));
        } else {
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT dbid FROM commands WHERE command='%e'", input);
            new Cache:result = mysql_query(mysql_id, queryStr);

            if(cache_num_rows() == 1) {
                mysql_get_int(0, "dbid", commandDBID);
                cache_delete(result);

                mysql_format(mysql_id, queryStr, sizeof(queryStr), "DELETE FROM commands WHERE dbid='%d'", commandDBID);
                result = mysql_query(mysql_id, queryStr);

                if(result) {
                    SFCM(playerid, COLOR_GREEN, "(( Parancs sikeresen törölve az adatbázisból! (DBID = %s) ))", commandDBID);
                } else {
                    SCM(playerid, COLOR_DARKRED, "(( Hiba történt a törlés közben (log)! ))");
                }
            } else SCM(playerid, -1, getStrMsg(STR_NCF));
            cache_delete(result);
        }
    } else if(equals(type, "info") || equals(type, "information")) {
        new input[64];
        if(sscanf(params, "{s[12]}s[64]", input)) return SCM(playerid, COLOR_WHITE, "(( Használat: /command info <parancs / dbid> ))");
        if(isNumeric(input)) {
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT c.dbid, c.command, c.comment, c.permission, al.name, col.color FROM commands AS c JOIN adminlevels AS al ON (c.permission = al.permission) JOIN colors AS col ON (col.name = al.color) WHERE commands.dbid='%d' LIMIT 1", strval(input));
        	new Cache:result = mysql_query(mysql_id, queryStr);
            if(cache_num_rows() > 0) {
                // Variables
                new id = -1;
                new cmd[64];
                new name[64];
                new color[16];
                new perm = -1;
                new comment[128];
                //
                mysql_get_int(0, "dbid", id); // Command DBID
                mysql_get_int(0, "permission", perm); // Command permission
                mysql_get_string(0, "color", color); // Adminlevel color
                mysql_get_string(0, "name", name); // Adminlevel name
                mysql_get_string(0, "command", cmd); // Command name
                mysql_get_string(0, "comment", comment); // Command comment
                //
                SFCM(playerid, COLOR_WHITE, "> %d. (/{77cdff}%s{FFFFFF}) - Hozzáférés: {%s}%s{FFFFFF}(%d) - %s", id, cmd, color, name, perm, comment);
            } else SCM(playerid, -1, getStrMsg(STR_NCF));
            cache_delete(result);
        } else {
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT c.dbid, c.command, c.comment, c.permission, al.name, col.color FROM commands AS c JOIN adminlevels AS al ON (c.permission = al.permission) JOIN colors AS col ON (col.name = al.color) WHERE commands.command='%e' LIMIT 1", input);
        	new Cache:result = mysql_query(mysql_id, queryStr);

            if(cache_num_rows() > 0) {
                // Variables
                new id = -1;
                new cmd[64];
                new name[64];
                new color[16];
                new perm = -1;
                new comment[128];
                //
                mysql_get_int(0, "dbid", id); // Command DBID
                mysql_get_int(0, "permission", perm); // Command permission
                mysql_get_string(0, "color", color); // Adminlevel color
                mysql_get_string(0, "name", name); // Adminlevel name
                mysql_get_string(0, "command", cmd); // Command name
                mysql_get_string(0, "comment", comment); // Command comment
                //
                SFCM(playerid, COLOR_WHITE, "> %d. (/{77cdff}%s{FFFFFF}) - Hozzáférés: {%s}%s{FFFFFF}(%d) - %s", id, cmd, color, name, perm, comment);
            } else SCM(playerid, -1, getStrMsg(STR_NCF));
            cache_delete(result);
        }
    }
    return 1;
}
CMD:anim(playerid, params[]) {
    new param[12];
    if(sscanf(params, "s[12]{}", param)) return SCM(playerid, COLOR_WHITE, "(( Használat: /anim <anim / lista> ))");
    if(equals(param, "lista")) {
        SCM(playerid, COLOR_WHITE, "(( |________________ Anim lista ________________| ))");
        SCM(playerid, COLOR_WHITE, "(( walk(1-5), dance(1-4), ))");
    } else if(equals(param, "stop")) {
        ClearAnimations(playerid);
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        TogglePlayerControllable(playerid, 1);
        SCM(playerid, COLOR_GREEN, "(( Befejezted az animot! ))");
    } else if(equals(param, "walk")) {
        new type = -1;
        if(sscanf(params, "{s[12]}d", type)) return SCM(playerid, COLOR_WHITE, "(( Használat: /anim walk <típus> ))");

        switch(type) {
            case 1: {
                ApplyAnim(playerid, "PED", "WALK_drunk", 4.1, 1, 1, 1, 1, 1, 1);
                showPlayerHint(playerid, "~w~Anim befejezesehez hasznald a(z) ~y~~k~~PED_LOCK_TARGET~~w~-t vagy az ~y~/anim stop~w~ parancsot.", 5000);
            } case 2: {
                ApplyAnim(playerid, "PED", "WALK_fat", 4.1, 1, 1, 1, 1, 1, 1);
                showPlayerHint(playerid, "~w~Anim befejezesehez hasznald a(z) ~y~~k~~PED_LOCK_TARGET~~w~-t vagy az ~y~/anim stop~w~ parancsot.", 5000);
            } case 3: {
                ApplyAnim(playerid, "PED", "WALK_gang1", 4.1, 1, 1, 1, 1, 1, 1);
                showPlayerHint(playerid, "~w~Anim befejezesehez hasznald a(z) ~y~~k~~PED_LOCK_TARGET~~w~-t vagy az ~y~/anim stop~w~ parancsot.", 5000);
            } case 4: {
                ApplyAnim(playerid, "PED", "WALK_gang2", 4.1, 1, 1, 1, 1, 1, 1);
                //SCM(playerid, COLOR_GREEN, "(( Aktiváltál egy animot! Megállításhoz használd a jobb klikket vagy az '/anim stop' parancsot! ))");
                showPlayerHint(playerid, "~w~Anim befejezesehez hasznald a(z) ~y~~k~~PED_LOCK_TARGET~~w~-t vagy az ~y~/anim stop~w~ parancsot.", 5000);
            } default: SCM(playerid, -1, getStrMsg(STR_NTF));
        }
    } else if(equals(param, "dance") || equals(param, "tánc") || equals(param, "tanc")) {
        new type = -1;
        if(sscanf(params, "{s[12]}d", type)) return SCM(playerid, COLOR_WHITE, "(( Használat: /anim dance <típus> ))");

        switch(type) {
            case 1: {
                SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE1);
                showPlayerHint(playerid, "~w~Anim befejezesehez hasznald a(z) ~y~~k~~PED_LOCK_TARGET~~w~-t vagy az ~y~/anim stop~w~ parancsot.", 5000);
            } case 2: {
                SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE2);
                showPlayerHint(playerid, "~w~Anim befejezesehez hasznald a(z) ~y~~k~~PED_LOCK_TARGET~~w~-t vagy az ~y~/anim stop~w~ parancsot.", 5000);
            } case 3: {
                SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE3);
                showPlayerHint(playerid, "~w~Anim befejezesehez hasznald a(z) ~y~~k~~PED_LOCK_TARGET~~w~-t vagy az ~y~/anim stop~w~ parancsot.", 5000);
            } case 4: {
                SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE4);
                showPlayerHint(playerid, "~w~Anim befejezesehez hasznald a(z) ~y~~k~~PED_LOCK_TARGET~~w~-t vagy az ~y~/anim stop~w~ parancsot.", 5000);
            } default: SCM(playerid, -1, getStrMsg(STR_NTF));
        }
    } else if(equals(param, "sit") || equals(param, "leül") || equals(param, "leul")) {
        ApplyAnim(playerid, "PED", "SEAT_idle", 4.1, 1, 0, 0, 0, 0, 1);
        showPlayerHint(playerid, "~w~Anim befejezesehez hasznald a(z) ~y~~k~~PED_LOCK_TARGET~~w~-t vagy az ~y~/anim stop~w~ parancsot.", 5000);
    }
    else SCM(playerid, COLOR_ORANGE, "(( Nincs ilyen anim! ))");
    return 1;
}

// Admin chats
CMD:suc(playerid, params[]) {
    if(IsSpecialUser(playerid)) {
        new sucMSG[128];
        if(sscanf(params, "s[128]", sucMSG)) return SCM(playerid, COLOR_WHITE, "(( Használat: /suc <üzenet> ))");

        // serverLog
        serverLogFormatted(5, "*SUC* %s %s: %s", getPlayerAdminRank(playerid), getName(playerid), sucMSG);

        if(strlen(sucMSG) <= 100) {
            for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
                if(isValidPlayer(i)) {
                    if(IsSpecialUser(i)) {
                        SFCM(i, COLOR_LAWNGREEN, "*SUC* %s %s: %s", getPlayerAdminRank(playerid), getName(playerid), sucMSG);
                    }
                }
            }
        } else SCM(playerid, -1, getStrMsg(STR_TL));
    } else SCM(playerid, -1, getStrMsg(STR_NHEP));
    return 1;
}
CMD:asc(playerid, params[]) {
    if(pInfo[playerid][P_TEMP][16] || pInfo[playerid][pAdmin] >= 1) {
        new ascMSG[128];
        if(sscanf(params, "s[128]", ascMSG)) return SCM(playerid, COLOR_WHITE, "(( Használat: /asc <üzenet> ))");

        // serverLog
        serverLogFormatted(5, "*ASC* %s %s: %s", getPlayerAdminRank(playerid), getName(playerid), ascMSG);

        if(strlen(ascMSG) <= 100) {
            for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
                if(isValidPlayer(i)) {
                    if(pInfo[i][P_TEMP][16] || pInfo[playerid][pAdmin] >= 1) {
                        SFCM(i, COLOR_BURLYWOOD, "*ASC* %s %s: %s", getPlayerAdminRank(playerid), getName(playerid), ascMSG);
                    }
                }
            }
        } else SCM(playerid, -1, getStrMsg(STR_TL));
    } else SCM(playerid, -1, getStrMsg(STR_NHEP));
    return 1;
}
CMD:mc(playerid, params[]) {
    new mcMSG[128];
    if(sscanf(params, "s[128]", mcMSG)) return SCM(playerid, COLOR_WHITE, "(( Használat: /mc <üzenet> ))");

    // serverLog
    serverLogFormatted(5, "*MC* %s %s: %s", getPlayerAdminRank(playerid), getName(playerid), mcMSG);

    if(strlen(mcMSG) <= 100) {
        for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
            if(isValidPlayer(i)) {
                if(pInfo[i][pAdmin] >= 1) {
                    SFCM(i, COLOR_YELLOW, "*MC* %s %s: %s", getPlayerAdminRank(playerid), getName(playerid), mcMSG);
                }
            }
        }
    } else SCM(playerid, -1, getStrMsg(STR_TL));
    return 1;
}
CMD:ac(playerid, params[]) {
    new acMSG[128];
    if(sscanf(params, "s[128]", acMSG)) return SCM(playerid, COLOR_WHITE, "(( Használat: /ac <üzenet> ))");

    // serverLog
    serverLogFormatted(5, "*AC* %s %s: %s", getPlayerAdminRank(playerid), getName(playerid), acMSG);

    if(strlen(acMSG) <= 100) {
        for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
            if(isValidPlayer(i)) {
                if(pInfo[i][pAdmin] >= 2) {
                    SFCM(i, 0xba8f57aa, "*AC* %s %s: %s", getPlayerAdminRank(playerid), getName(playerid), acMSG);
                }
            }
        }
    } else SCM(playerid, -1, getStrMsg(STR_TL));
    return 1;
}
CMD:vac(playerid, params[]) {
    new vcMSG[128];
    if(sscanf(params, "s[128]", vcMSG)) return SCM(playerid, COLOR_WHITE, "(( Használat: /vac <üzenet> ))");

    // serverLog
    serverLogFormatted(5, "*VAC* %s %s: %s", getPlayerAdminRank(playerid), getName(playerid), vcMSG);

    if(strlen(vcMSG) <= 100) {
        for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
            if(isValidPlayer(i)) {
                if(pInfo[i][pAdmin] >= 7) {
                    SFCM(i, 0xba7057aa, "*VAC* %s %s: %s", getPlayerAdminRank(playerid), getName(playerid), vcMSG);
                }
            }
        }
    } else SCM(playerid, -1, getStrMsg(STR_TL));
    return 1;
}
CMD:fc(playerid, params[]) {
    new fcMSG[128];
    if(sscanf(params, "s[128]", fcMSG)) return SCM(playerid, COLOR_WHITE, "(( Használat: /fc <üzenet> ))");

    // serverLog
    serverLogFormatted(5, "*FC* %s %s: %s", getPlayerAdminRank(playerid), getName(playerid), fcMSG);

    if(strlen(fcMSG) <= 100) {
        for(new i = 0; i < GetPlayerPoolSize()+1; i++) {
            if(isValidPlayer(i)) {
                if(pInfo[i][pAdmin] >= 7) {
                    SFCM(i, COLOR_RED, "*FC* %s %s: %s", getPlayerAdminRank(playerid), getName(playerid), fcMSG);
                }
            }
        }
    } else SCM(playerid, -1, getStrMsg(STR_TL));
    return 1;
}
