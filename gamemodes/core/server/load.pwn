#include <YSI\y_hooks>
hook OnGameModeInit() {
    loadServerConfig();

    //MapAndreas
    new Float:mapunit;
    MapAndreas_FindZ_For2DCoord(0.0, 0.0, mapunit);
    if(mapunit <= 0.0) {
        MapAndreas_Init(MAP_ANDREAS_MODE_FULL);
    }
    MapAndreas_FindZ_For2DCoord(0.0, 0.0, mapunit);
    if(mapunit <= 0.0) {
        print("[SERVER] MapAndreas failed to load");
    } else {
        print("[SERVER] MapAndreas loaded successfuly");
    }
    return 1;
}
