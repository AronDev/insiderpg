loadServerConfig() {
    mysql_pquery(mysql_id, "SELECT * FROM server_properties", "q_loadServerConf", "");
    return 1;
}

function q_loadServerConf() {
    new rows = cache_num_rows();
    if(rows > 0) {
        // Vars
        new ident[64];
        //new value[256];

        new _sHostname[64];
        new _sName[16];
        new _sWeburl[64];
        new _sPassword[128];
        new _sLanguage[16];
        new _sWhitelist;
        new _sGamemode[64];

        for(new i = 0; i < rows; i++) {
            mysql_get_string(i, "ident", ident, sizeof(ident));
            if(equals(ident, "server_hostname")) {
                mysql_get_string(i, "value", _sHostname, sizeof(_sHostname));
            } else if(equals(ident, "server_name")) {
                mysql_get_string(i, "value", _sName, sizeof(_sName));
            } else if(equals(ident, "server_language")) {
                mysql_get_string(i, "value", _sLanguage, sizeof(_sLanguage));
            } else if(equals(ident, "server_weburl")) {
                mysql_get_string(i, "value", _sWeburl, sizeof(_sWeburl));
            } else if(equals(ident, "server_password")) {
                mysql_get_string(i, "value", _sPassword, sizeof(_sPassword));
            } else if(equals(ident, "server_gamemode")) {
                mysql_get_string(i, "value", _sGamemode, sizeof(_sGamemode));
            } else if(equals(ident, "server_whitelist")) {
                mysql_get_int(i, "value", _sWhitelist);
            }
        }

        // Formatting values before sending it to the server
        format(_sHostname, sizeof(_sHostname), "hostname %s", _sHostname);
        format(_sLanguage, sizeof(_sLanguage), "language %s", _sLanguage);
        format(_sWeburl, sizeof(_sWeburl), "weburl %s", _sWeburl);
        format(_sPassword, sizeof(_sPassword), "password %s", _sPassword);

        // Setting value
        format(srvInfo[SRV_NAME], sizeof(srvInfo[SRV_NAME]), _sName);
        srvInfo[SRV_WHITELIST] = _sWhitelist == 1 ? true : false;
        SendRconCommand(_sHostname);
        SetGameModeText(_sGamemode);
        SendRconCommand(_sLanguage);
        SendRconCommand(_sWeburl);
        SendRconCommand(_sPassword);

        // Finally
        print("[SERVER] Config has been changed!");
    }
    return 1;
}
