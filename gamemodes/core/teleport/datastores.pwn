enum teleportInfo {
    bool:tpExist,
    tpDBID,
    Float:tpPos[6],
    Float:tpRad[2],
    tpInt[2],
    tpVW[2],
    tpPickup[2],
};
new tpInfo[MAX_TELEPORTS][teleportInfo];
