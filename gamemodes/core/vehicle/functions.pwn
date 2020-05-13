// ELM
timer t_vehicleELM[50](vehicleDBID) {
    new vehicleID = vInfo[vehicleDBID][vID];
    new panels, doors, lights, tires;
    GetVehicleDamageStatus(vehicleID, panels, doors, lights, tires);

    switch(vInfo[vehicleDBID][vELMFlash]) {
        case 0: UpdateVehicleDamageStatus(vehicleID, panels, doors, 2, tires);
        case 1: UpdateVehicleDamageStatus(vehicleID, panels, doors, 2, tires);
        case 2: UpdateVehicleDamageStatus(vehicleID, panels, doors, 4, tires);
        case 3: UpdateVehicleDamageStatus(vehicleID, panels, doors, 4, tires);
    }
    if(vInfo[vehicleDBID][vELMFlash] >= 3) vInfo[vehicleDBID][vELMFlash] = 0;
    else vInfo[vehicleDBID][vELMFlash] ++;
    return 1;
}
//

parkCar(vehicleDBID) {
    new vehicleID = vInfo[vehicleDBID][vID];
    GetVehiclePos(vehicleID, PosEx(vInfo[vehicleDBID][vPos]));
    GetVehicleZAngle(vehicleID,vInfo[vehicleDBID][vPos][3]);
    // more stuff..

    new vPosStr[64];
    format(vPosStr, sizeof(vPosStr), "%f,%f,%f,%f", PosEx(vInfo[vehicleDBID][vPos]), vInfo[vehicleDBID][vPos][3]);

    doQuery("UPDATE vehicles SET pos='%s' WHERE dbid='%d'", vPosStr, vehicleDBID);
    saveVehicle(vehicleDBID);
}

saveVehicle(vehicleDBID, bool:respawn = false) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "UPDATE vehicles SET hp='%f',cond='%d,%d,%d,%d',locked='%d',fraction='%d',owner='%d' WHERE dbid='%d'",\
    vInfo[vehicleDBID][vHP], vInfo[vehicleDBID][vConditions][0], vInfo[vehicleDBID][vConditions][1], vInfo[vehicleDBID][vConditions][2], vInfo[vehicleDBID][vConditions][3],\
    vInfo[vehicleDBID][vLocked] ? (1) : (0), vInfo[vehicleDBID][vFraction], vInfo[vehicleDBID][vOwner], vehicleDBID);
    inline q_saveVehicleRespawn() {
        if(respawn) spawnVehicle(vehicleDBID);
    }
    mysql_tquery_inline(mysql_id, queryStr, using inline q_saveVehicleRespawn, "");
    return 1;
}

spawnVehicle(vehicleDBID) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT * FROM vehicles WHERE dbid='%d' LIMIT 1", vehicleDBID);
    mysql_pquery(mysql_id, queryStr, "query_spawnVehicle", "");
    return 1;
}

function query_spawnVehicle() {
    if(cache_num_rows()) {
        new vehDBID = -1;
        new vehModel = 400;
        new Float:vehPos[4] = {0.0, 0.0, 0.0, 0.0}; // x,y,z,a
        new vehPosStr[128];
        new vehColorStr[8];
        new vehColor[2] = {1, 1};
        new vehSiren = 0;
        new vehPlate[32];
        new Float:vehHP = 1000.0;
        new vehCond[4];
        new vehCondStr[512];
        new vehLocked = 0;
        new vehOwner = -1;
        new vehFraction = 0;


        mysql_get_int(0, "dbid", vehDBID);
        mysql_get_int(0, "model", vehModel);
        mysql_get_string(0, "color", vehColorStr);
        sscanf(vehColorStr, "p<,>dd", vehColor[0], vehColor[1]);
        mysql_get_string(0, "pos", vehPosStr);
        sscanf(vehPosStr, "p<,>ffff", PosEx(vehPos), vehPos[3]);
        mysql_get_string(0, "plate", vehPlate);
        mysql_get_int(0, "siren", vehSiren);
        mysql_get_float(0, "hp", vehHP);
        mysql_get_string(0, "cond", vehCondStr);
        sscanf(vehCondStr, "p<,>dddd", vehCond[0], vehCond[1], vehCond[2], vehCond[3]);
        mysql_get_int(0, "locked", vehLocked);
        mysql_get_int(0, "owner", vehOwner);
        mysql_get_int(0, "fraction", vehFraction);

        vInfo[vehDBID][vExist] = true;
        vInfo[vehDBID][vDBID] = vehDBID;
        vInfo[vehDBID][vModel] = vehModel;
        vInfo[vehDBID][vColor][0] = vehColor[0];
        vInfo[vehDBID][vColor][1] = vehColor[1];
        format(vInfo[vehDBID][vPlate], 32, vehPlate);
        vInfo[vehDBID][vPos][0] = vehPos[0];
        vInfo[vehDBID][vPos][1] = vehPos[1];
        vInfo[vehDBID][vPos][2] = vehPos[2];
        vInfo[vehDBID][vPos][3] = vehPos[3];
        vInfo[vehDBID][vHP] = vehHP;
        vInfo[vehDBID][vConditions][0] = vehCond[0];
        vInfo[vehDBID][vConditions][1] = vehCond[1];
        vInfo[vehDBID][vConditions][2] = vehCond[2];
        vInfo[vehDBID][vConditions][3] = vehCond[3];
        vInfo[vehDBID][vOwner] = vehOwner;
        vInfo[vehDBID][vFraction] = vehFraction;
        vInfo[vehDBID][vSiren] = (vehSiren == 1 ? true : false);
        vInfo[vehDBID][vEngine] = false;
        vInfo[vehDBID][vLights] = false;
        vInfo[vehDBID][isEngineStarting] = false;
        vInfo[vehDBID][vTrunk] = false;
        vInfo[vehDBID][vLocked] = (vehLocked == 1 ? true : false);
        vInfo[vehDBID][vELM] = false;
        vInfo[vehDBID][vELMFlash] = 0;
        KillTimer(_:vInfo[vehDBID][vELMTimer]);

        DestroyVehicle(vInfo[vehDBID][vID]);
        vInfo[vehDBID][vID] = CreateVehicle(vInfo[vehDBID][vModel], PosEx(vInfo[vehDBID][vPos]), vInfo[vehDBID][vPos][3], vInfo[vehDBID][vColor][0], vInfo[vehDBID][vColor][1], 0, vInfo[vehDBID][vSiren]);
        SetVehicleNumberPlate(vInfo[vehDBID][vID], vInfo[vehDBID][vPlate]);
        SetVehicleHealth(vInfo[vehDBID][vID], vInfo[vehDBID][vHP]);
        UpdateVehicleDamageStatus(vInfo[vehDBID][vID], vInfo[vehDBID][vConditions][0], vInfo[vehDBID][vConditions][1], vInfo[vehDBID][vConditions][2], vInfo[vehDBID][vConditions][3]);

        new engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(vInfo[vehDBID][vID], engine, lights, alarm, doors, bonnet, boot, objective);
        SetVehicleParamsEx(vInfo[vehDBID][vID], 0, 0, alarm, vInfo[vehDBID][vLocked], bonnet, boot, objective);

        /*printf("[SERVER] Vehicle spawned! (dbid = %d, id = %d)", vID, vInfo[vehicleDBID][veh]);*/
    } /*else printf("[SERVER] spawnVehicle(%d) -> vehicle not found", vehicleDBID);*/
    return 1;
}

addTrunkItem(vehicleDBID, item, amount, param1 = -1, playerid = -1) {
    // Get the used space
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT SUM(vehicle_trunks.amount) as used_space FROM vehicle_trunks WHERE vehicle_trunks.vehicledbid='%d'", vehicleDBID);
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
    if(usedSpace + itemWeight > MAX_TRUNK_SPACE) { // Not enough inventory space for the item
        SFCM(playerid, COLOR_ORANGE, "(( %d darab %s nem fér el a csomagtartóban! ))", amount, itemName);
    } else { // Player has enough space
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_trunks.amount FROM vehicle_trunks WHERE vehicle_trunks.vehicledbid='%d' AND vehicle_trunks.itemdbid='%d' AND vehicle_trunks.param1 = '%d'", vehicleDBID, item, param1);
        result = mysql_query(mysql_id, queryStr);
        new currentAmount;
        mysql_get_int(0, "amount", currentAmount);
        if(cache_num_rows() == 1) { // Already owning that item
            cache_delete(result);
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "UPDATE vehicle_trunks SET vehicle_trunks.amount='%d' WHERE vehicle_trunks.vehicledbid='%d' AND vehicle_trunks.itemdbid='%d' AND vehicle_trunks.param1 = '%d'", amount+currentAmount, vehicleDBID, item, param1);
            result = mysql_query(mysql_id, queryStr);
            if(result) {
                cache_delete(result);
                return true;
            } else { // query error
                cache_delete(result);
                return false;
            }
        } else { // New item in the inventory
            cache_delete(result);
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "INSERT INTO vehicle_trunks (vehicledbid, itemdbid, amount, param1) VALUES ('%d', '%d', '%d', '%d')", vehicleDBID, item, amount, param1);
            result = mysql_query(mysql_id, queryStr);
            if(result) {
                cache_delete(result);
                return true;
            } else {
                cache_delete(result);
                return false;
            }
        }
    }
    return true;
}

removeTrunkItem(vehicleDBID, item, amount, param1 = -1) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_trunks.amount FROM vehicle_trunks WHERE (vehicle_trunks.itemdbid='%d' AND vehicle_trunks.vehicledbid='%d' AND vehicle_trunks.param1='%d') LIMIT 1", item, vehicleDBID, param1);
    new Cache:result = mysql_query(mysql_id, queryStr);
    new itemAmount;
    mysql_get_int(0, "amount", itemAmount);
    cache_delete(result);
    if(itemAmount - amount > 0) {
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "UPDATE vehicle_trunks SET vehicle_trunks.amount='%d' WHERE (vehicle_trunks.itemdbid='%d' AND vehicle_trunks.vehicledbid='%d' AND vehicle_trunks.param1='%d') LIMIT 1", (itemAmount-amount), item, vehicleDBID, param1);
        result = mysql_query(mysql_id, queryStr);
        cache_delete(result);
        return true;
    } else {
        clearTrunkItem(vehicleDBID, item, param1);
        return false;
    }
}

clearTrunkItem(vehicleDBID, item, param1 = -1) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "DELETE FROM vehicle_trunks WHERE (vehicle_trunks.itemdbid='%d' AND vehicle_trunks.vehicledbid='%d' AND vehicle_trunks.param1='%d')", item, vehicleDBID, param1);
    new Cache:result = mysql_query(mysql_id, queryStr);
    if(result) {
        cache_delete(result);
        return true;
    } else {
        cache_delete(result);
        return false;
    }

}
//
addGloveCompItem(vehicleDBID, item, amount, param1 = -1, playerid = -1) {
    // Get the used space
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT SUM(vehicle_glove_comp.amount) as used_space FROM vehicle_glove_comp WHERE vehicle_glove_comp.vehicledbid='%d'", vehicleDBID);
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
    if(usedSpace + itemWeight > MAX_TRUNK_SPACE) { // Not enough inventory space for the item
        SFCM(playerid, COLOR_ORANGE, "(( %d darab %s nem fér el a csomagtartóban! ))", amount, itemName);
    } else { // Player has enough space
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_glove_comp.amount FROM vehicle_glove_comp WHERE vehicle_glove_comp.vehicledbid='%d' AND vehicle_glove_comp.itemdbid='%d' AND vehicle_glove_comp.param1 = '%d'", vehicleDBID, item, param1);
        result = mysql_query(mysql_id, queryStr);
        new currentAmount;
        mysql_get_int(0, "amount", currentAmount);
        if(cache_num_rows() == 1) { // Already owning that item
            cache_delete(result);
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "UPDATE vehicle_glove_comp SET vehicle_glove_comp.amount='%d' WHERE vehicle_glove_comp.vehicledbid='%d' AND vehicle_glove_comp.itemdbid='%d' AND vehicle_glove_comp.param1 = '%d'", amount+currentAmount, vehicleDBID, item, param1);
            result = mysql_query(mysql_id, queryStr);
            if(result) {
                cache_delete(result);
                return true;
            } else { // query error
                cache_delete(result);
                return false;
            }
        } else { // New item in the inventory
            cache_delete(result);
            mysql_format(mysql_id, queryStr, sizeof(queryStr), "INSERT INTO vehicle_glove_comp (vehicledbid, itemdbid, amount, param1) VALUES ('%d', '%d', '%d', '%d')", vehicleDBID, item, amount, param1);
            result = mysql_query(mysql_id, queryStr);
            if(result) {
                cache_delete(result);
                return true;
            } else {
                cache_delete(result);
                return false;
            }
        }
    }
    return true;
}

removeGloveCompItem(vehicleDBID, item, amount, param1 = -1) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "SELECT vehicle_glove_comp.amount FROM vehicle_glove_comp WHERE (vehicle_glove_comp.itemdbid='%d' AND vehicle_glove_comp.vehicledbid='%d' AND vehicle_glove_comp.param1='%d') LIMIT 1", item, vehicleDBID, param1);
    new Cache:result = mysql_query(mysql_id, queryStr);
    new itemAmount;
    mysql_get_int(0, "amount", itemAmount);
    cache_delete(result);
    if(itemAmount - amount > 0) {
        mysql_format(mysql_id, queryStr, sizeof(queryStr), "UPDATE vehicle_glove_comp SET vehicle_glove_comp.amount='%d' WHERE (vehicle_glove_comp.itemdbid='%d' AND vehicle_glove_comp.vehicledbid='%d' AND vehicle_glove_comp.param1='%d') LIMIT 1", (itemAmount-amount), item, vehicleDBID, param1);
        result = mysql_query(mysql_id, queryStr);
        cache_delete(result);
        return true;
    } else {
        clearGloveComp(vehicleDBID, item, param1);
        return false;
    }
}

clearGloveComp(vehicleDBID, item, param1 = -1) {
    mysql_format(mysql_id, queryStr, sizeof(queryStr), "DELETE FROM vehicle_glove_comp WHERE (vehicle_glove_comp.itemdbid='%d' AND vehicle_glove_comp.vehicledbid='%d' AND vehicle_glove_comp.param1='%d')", item, vehicleDBID, param1);
    new Cache:result = mysql_query(mysql_id, queryStr);
    if(result) {
        cache_delete(result);
        return true;
    } else {
        cache_delete(result);
        return false;
    }

}
