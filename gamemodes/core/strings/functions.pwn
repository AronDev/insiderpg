getStrMsg(dbid) {
    new getStrMsg_str[255+16+2];
    format(getStrMsg_str, sizeof(getStrMsg_str), "{%s}%s", strInfo[dbid][strColor], strInfo[dbid][strMsg]);
    return getStrMsg_str;
}
