#include <YSI\y_hooks>
hook OnVehicleDeath(vehicleid, killerid) {
    new vehicleDBID = getVehicleDBIDFromID(vehicleid);
    vInfo[vehicleDBID][vHP] = 250.0;
    saveVehicle(vehicleDBID);
    defer tVehicleSpawnDelay[300](vehicleDBID);
    return 1;
}

timer tVehicleSpawnDelay[300](vehicleDBID) {
    spawnVehicle(vehicleDBID);
    return 1;
}

#include <YSI\y_hooks>
hook OnVehicleSpawn(vehicleid) {
    new vehicleDBID = getVehicleDBIDFromID(vehicleid);

    // ELM
    vInfo[vehicleDBID][vELM] = false;
    vInfo[vehicleDBID][vELMFlash] = 0;

    new panels, doors, lights, tires;
    if(vInfo[vehicleDBID][vELM]) KillTimer(_:vInfo[vehicleDBID][vELMTimer]);
    GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
    UpdateVehicleDamageStatus(vehicleid, panels, doors, 0, tires);
    //
    return 1;
}
