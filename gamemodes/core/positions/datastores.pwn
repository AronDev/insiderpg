enum positionInfo {
    bool:posExist,
    posDBID,
    Float:posPos[3],
    Float:posRad,
    posInt,
    posVW,
    posType,
    posLF,
    posComment[64],
};
new posInfo[MAX_POSITIONS][positionInfo];

enum position_typeInfo {
    bool:ptypeExist,
    ptypeDBID,
    ptypeName[64],
}
new ptypeInfo[MAX_POS_TYPES][position_typeInfo];
