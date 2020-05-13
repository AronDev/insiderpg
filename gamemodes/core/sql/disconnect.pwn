#include <YSI\y_hooks>
hook OnGameModeExit() {
	mysql_close();
	return 1;
}
