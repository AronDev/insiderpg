getDivSNameByDivID(divLF, divID) {
    new divName[32];
    for(new i = 0; i < MAX_DIVISIONS; i++) {
        if(dInfo[i][dExist]) {
            if(dInfo[i][dLF] == divLF) {
                if(dInfo[i][dID] == divID) {
                    format(divName, sizeof(divName), dInfo[i][dSName]);
                    break;
                }
            }
        }
    }
    return divName;
}

getDivDBIDByID(divLF, divID) {
    new divDBID = -1;
    for(new i = 0; i < MAX_DIVISIONS; i++) {
        if(dInfo[i][dExist]) {
            if(dInfo[i][dLF] == divLF) {
                if(dInfo[i][dID] == divID) {
                    divDBID = i;
                    break;
                }
            }
        }
    }
    return divDBID;
}
