#include <YSI\y_hooks>
hook OnGameModeInit() {
    CreateDynamicObject(966, 972.96582, -1100.39966, 22.82850,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(967, 973.49298, -1098.82031, 22.83270,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(16001, 1000.57977, -1083.39050, 22.82200,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(17950, 1044.45667, -1084.97424, 24.92200,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(17950, 1037.41125, -1084.97424, 24.92200,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(17950, 1030.29175, -1084.97424, 24.92200,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(17950, 1023.14648, -1084.97424, 24.92200,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(17950, 1016.03552, -1084.97424, 24.92200,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2960, 1045.13501, -1105.54419, 22.76560,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2960, 1041.73523, -1105.54419, 22.76560,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2960, 1038.25513, -1105.54419, 22.76560,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2960, 1034.74365, -1105.54419, 22.76560,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2960, 1031.04834, -1105.54419, 22.76560,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2960, 1009.48022, -1083.01501, 22.76560,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2960, 996.50885, -1107.51355, 22.76560,   0.00000, 0.00000, 90.00000);
    return Y_HOOKS_CONTINUE_RETURN_1;
}
#include <YSI\y_hooks>
hook OnPlayerConnect(playerid) {
    RemoveBuildingForPlayer(playerid, 726, 1013.0938, -1078.1719, 26.0859, 0.25);
    return Y_HOOKS_CONTINUE_RETURN_1;
}
