newCall(callerName[], callType, callMsg[], Float:callPosX, Float:callPosY, Float:callPosZ, callVW = 0, callInt = 0) {
    new callID = newCallID();
    cInfo[callID][cExist] = true;
    cInfo[callID][cID] = callID;
    format(cInfo[callID][cCallerName], MAX_PLAYER_NAME, callerName);
    format(cInfo[callID][cCallMsg], 128, callMsg);
    cInfo[callID][cType] = callType;
    cInfo[callID][cPos][0] = callPosX;
    cInfo[callID][cPos][1] = callPosY;
    cInfo[callID][cPos][2] = callPosZ;
    cInfo[callID][cVW] = callVW;
    cInfo[callID][cInt] = callInt;

    new date[3], time[3];
    gettime(time[0], time[1], time[2]);
    getdate(date[0], date[1], date[2]);
    format(cInfo[callID][cTimestamp], 128, "%02d-%02d-%02d %02d:%02d:%02d", date[0], date[1], date[2], time[0], time[1], time[2]);
    return 1;
}

newCallID() {
    new _callID = -1;
    for(new i = 0; i < MAX_CALLS; i++) {
        if(!cInfo[i][cExist]) {
            _callID = i;
            break;
        }
    }
    return _callID;
}

getLatestCall() {
    new _latestCallID = -1;
    for(new i = 0; i < MAX_CALLS; i++) {
        if(cInfo[i][cExist]) {
            _latestCallID = i;
        }
    }
    return _latestCallID;
}
