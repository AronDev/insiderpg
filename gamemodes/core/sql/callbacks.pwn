public OnQueryError(errorid, error[], callback[], query[], connectionHandle) {
	switch(errorid) {
		case CR_SERVER_GONE_ERROR: {
			printf("[SERVER - MYSQL] Connection failure");
			mysql_reconnect();
		}
        case ER_SYNTAX_ERROR: {
			printf("[SERVER - MYSQL] Error in SQL query (Query: %s)", query);
		}
	}
	return 1;
}
