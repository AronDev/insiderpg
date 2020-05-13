enum adminlevelInfo {
    bool:alExist,
    alDBID,
    alName[32],
    alPerm,
    alColor[16],
}

new alInfo[MAX_ADMINLEVELS][adminlevelInfo];
