/*
*
* P_TEMP
*   0: Hintbox (textdraw) showing
*   1: Footer (textdraw) showing [not in use atm]
*   2: AdmLog toggle (if turned on the player won't see any AdmLog at all)
*   3: Connect log (login, disconnect)
*   4: AdminDuty
*   5: CmdLog (to see executed commands by everyone)
*   6: Fraction duty
*   7: Hidden admin
*   8: Show names
*   9: In skinchanger
*   10: BigEar
*   11: Satellite
*   12: In hospital
*   13: MapTele
*   14: -
*   15: Debug mode
*   16: AdminHelper rank
*
*/

#define TEMP_ADUTY 4

/*
*
* P_LABELS
*   0: AdminDuty label
*   1:
*   2:
*
*/

/*
*
* P_TEXTDRAWS
*   0: Hintbox td
*   1: Footer td
*   2:
*
*/

/*
*
* P_TIMERS
*   0: Hintbox timer
*   1: Footer timer
*   2: timeFreeze timer
*
*/

enum playerInfo {
    pDBID, // Store the players DBID from the MySQL Server
    pMoney,
    pAdmin,
    pFraction,
    pLeader,
    pRank,
    pDivision,
    pJob,
    pSkin[2],
    pSex,
    pHouse,
    pLoginTries, // Stores the login tries
    Float:pHP,
    Float:pAP,
    PlayerText:P_TEXTDRAWS[300], // Contains player textdraws
    Timer:P_TIMERS[300], // Contains player timers
    Text3D:P_LABELS[300], // 3D Text labels
    bool:P_TEMP[32], // Contains some true-false variables
    bool:logged, // Store if the player logged in
    pSelectedReportCat,
};
new pInfo[MAX_PLAYERS][playerInfo];
