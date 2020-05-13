#include "core/sql/credentials.pwn"
/*
credentials.pwn example

// localhost
#if MYSQL_HOST == 0
    #define MYSQL_HOST "localhost"
    #define MYSQL_USER "root"
    #define MYSQL_PASSWORD ""
    #define MYSQL_DATABASE "insiderpg"
// vps
#elseif MYSQL_HOST == 1
    #define MYSQL_HOST "1.2.3.4"
    #define MYSQL_USER "admin"
    #define MYSQL_PASSWORD "admin"
    #define MYSQL_DATABASE "insiderpg"
#endif

*/

new mysql_id;

// For future queries
new queryStr[1024];

#include <YSI\y_hooks>
hook OnGameModeInit() {
	mysql_id = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DATABASE, MYSQL_PASSWORD);
	if(mysql_errno() != 0) {
		printf("[SERVER - MYSQL] Connection failed! (Error code: %d)", mysql_errno());
	} else {
		printf("[SERVER - MYSQL] Connection successful! %s@%s -> %s", MYSQL_USER, MYSQL_HOST, MYSQL_DATABASE);
        mysql_log(LOG_ERROR|LOG_WARNING);
	}
	return 1;
}
