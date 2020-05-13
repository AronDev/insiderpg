enum vehicleInfo {
    bool:vExist,
    vDBID,
    vID,
    vModel,
    vColor[2],
    vPlate[32],
    Float:vPos[4],
    Float:vHP,
    vConditions[4],
    vOwner,
    vFraction,
    bool:vSiren,
    bool:vEngine,
    bool:vLights,
    bool:isEngineStarting,
    bool:vTrunk,
    bool:vLocked,
    // ELM
    Timer:vELMTimer,
    bool:vELM,
    vELMFlash,
    //
};
new vInfo[MAX_VEHICLES][vehicleInfo];
