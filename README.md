# InsideRPG

| Latest release | Last commit | Total downloads |
| :---: | :---: | :---: |
| [<img src="https://img.shields.io/github/v/release/AronDev/insiderpg?include_prereleases&style=flat-square">](https://github.com/AronDev/insiderpg/releases) | [<img src="https://img.shields.io/github/last-commit/master/AronDev/insiderpg.svg?style=flat-square">](https://github.com/AronDev/insiderpg/commits/master) | [<img src="https://img.shields.io/github/downloads/AronDev/insiderpg/total?style=flat-square">](https://github.com/AronDev/insiderpg/release)

Introduction
---
The project was first started in the summer of 2015, rewrited several times. The first release (not on GitHub yet) didn't contain any MySQL, instead of it had used Dini and Y_INI and also it wasn't modular, so it was a single big file. In Janury, 2019 I got to know git and I started using it. In May, 2019 I started this project and also created a repo for it. This was my first bigger project.

Build instructions
---
1. Create a file called `credentials.pwn` in `/gamemodes/core/sql`.

    *Note: You can adjust `MYSQL_HOST`'s value in `/gamemodes/settings.pwn`.*
    
    Here's an example of how it should look.
    ```C
    #if MYSQL_HOST == 0 // localhost
        #define MYSQL_HOST "localhost"
        #define MYSQL_USER "root"
        #define MYSQL_PASSWORD ""
        #define MYSQL_DATABASE "insiderpg"
    #elseif MYSQL_HOST == 1 // vps
        #define MYSQL_HOST "1.2.3.4"
        #define MYSQL_USER "admin"
        #define MYSQL_PASSWORD "admin"
        #define MYSQL_DATABASE "insiderpg"
    #endif
    ```
2. Install the required includes for compiling.
    * a_samp
    * crashdetect
    * YSI\y_hooks
    * YSI\y_timers
    * YSI\y_inline
    * callbacks
    * a_mysql_r39-6
    * gvar
    * a_players
    * a_zones
    * strlib
    * sscanf2
    * Pawn.CMD
    * mapandreas
    * streamer
    * vfunc
    * fixchars
    * opvd
    * filemanager

3. Build the amx file with your pawn compiler.

Thanks to
---
- [Zivon](https://github.com/peteriadamgabor) (suggestions/hosting/coding support)
- [Nico](https://github.com/SwannMorin) (suggestions/hosting/testing/wiki documentation)
