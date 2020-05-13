#include <YSI\y_hooks>
hook OnGameModeInit() {
    printf("[SERVER] Started at port: %d", GetConsoleVarAsInt("port"));
    srvInfo[SRV_PORT] = GetConsoleVarAsInt("port");
    // Disabling some default things
    DisableInteriorEnterExits();
    UsePlayerPedAnims();
    EnableStuntBonusForAll(0);
    ShowPlayerMarkers(false);
    ManualVehicleEngineAndLights();
    return 1;
}
