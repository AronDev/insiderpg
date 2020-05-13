enum callInfo {
    bool:cExist,
    cID,
    cCallerName[MAX_PLAYER_NAME],
    cCallMsg[128],
    cType,
    Float:cPos[3],
    cVW,
    cInt,
    cTimestamp[128],
};
new cInfo[MAX_CALLS][callInfo];
