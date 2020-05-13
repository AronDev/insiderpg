enum labelInfo {
    bool:lExist,
    lDBID,
    Text3D:lID,
    lText[256],
    lColor,
    Float:lPos[3],
    Float:lDrawDistance,
    lVW,
    lTestLOS,
};
new lInfo[MAX_LABELS][labelInfo];
