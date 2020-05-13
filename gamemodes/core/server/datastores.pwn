enum serverInfo {
    SRV_PORT,
    SRV_NAME[16],
    bool:SRV_WHITELIST,
};
new srvInfo[serverInfo];

new weaponNames[][]=
{
    "Ököl",
    "Boxxer",
    "Golf ütõ",
    "Gumibot",
    "Kés",
    "Baseball ütõ",
    "Ásó",
    "Billiárd dákó",
    "Katana",
    "Láncfûrész",
    "Rózsaszín dildó",
    "Fehér vibrátor",
    "Nagy fehér vibrátor",
    "Ezüst vibrátor",
    "Virágcsokor",
    "Járóbot",
    "Gránát",
    "Füstgránát",
    "Molotov koktél",
    "",
    "",
    "",
    "Colt45",
    "Hangtompítós Colt45",
    "Deagle",
    "Sörétes puska",
    "Lefûrészelt csövû sörétes puska",
    "Automata sörétes puska", // SPAS-12
    "Uzi", //MAC-10
    "MP5",
    "AK-47",
    "M4A1", //M4A1
    "Tec9",
    "Puska",
    "Mesterlövész puska",
    "Rakétavetõ",
    "Nyomkövetõs rakétavetõ",
    "Lángszóró",
    "Minigun",
    "C4",
    "Detonátor",
    "Spray",
    "Tûzoltókészülék",
    "Kamera",
    "Éjjellátó",
    "Hõkamera",
    "Ejtõernyõ"
};

new vehicleColors[][] = {
	{"fekete"}, // 0
	{"fehér"}, // 1
	{"azúr"}, // 2
	{"piros"}, // 3
	{"zuzmózöld"}, // 4
	{"korallrózsaszín"}, // 5
	{"sárga"}, // 6
	{"hidegkék"}, // 7
	{"piszkosfehér"}, // 8
	{"aszfaltszürke"}, // 9
	{"szederkék"}, // 10
	{"palaszürke"}, // 11
	{"bronz-zöld"}, // 12
	{"ólomszürke"}, // 13
	{"törtfehér"}, // 14
	{"gémszürke"}, // 15
	{"dinnyezöld"}, // 16
	{"bársonyvörös"}, // 17
	{"áfonyavörös"}, // 18
	{"csukaszürke"}, // 19
	{"szederkék"}, // 20
	{"mustvörös"}, // 21
	{"salakvörös"}, // 22
	{"dolomitszürke"}, // 23
	{"grafitszürke"}, // 24
	{"vakondszürke"}, // 25
	{"cementszürke"}, // 26
	{"iszapszürke"}, // 27
	{"viharkék"}, // 28
	{"hamuszürke"}, // 29
	{"csokoládébarna"}, // 30
	{"nugátbarna"}, // 31
	{"acélkék"}, // 32
	{"krómszín"}, // 33
	{"pocsolyaszín"}, // 34
	{"sötétszürke"}, // 35
	{"éjfekete"}, // 36
	{"szurokfekete"}, // 37
	{"atlasszürke"}, // 38
	{"palakék"}, // 39
	{"ébenfekete"}, // 40
	{"csontfekete"}, // 41
	{"bordó"}, // 42
	{"paprikavörös"}, // 43
	{"hagymazöld"}, // 44
	{"gránitvörös"}, // 45
	{"dohánybarna"}, // 46
	{"bronzbarna"}, // 47
	{"vaddisznóbarna"}, // 48
	{"higanyszürke"}, // 49
	{"vasfekete"}, // 50
	{"cinkzöld"}, // 51
	{"antracitfekete"}, // 52
	{"eurokék"}, // 53
	{"szederkék"}, // 54
	{"mazsolabarna"}, // 55
	{"ezüstszürke"}, // 56
	{"mandulabarna"}, // 57
	{"pecsétvörös"}, // 58
	{"denimkék"}, // 59
	{"alumíniumszürke"}, // 60
	{"dióbarna"}, // 61
	{"angolvörös"}, // 62
	{"galambszürke"}, // 63
	{"krómszín"}, // 64
	{"salétromsárga"}, // 65
	{"mangánbarna"}, // 66
	{"kõszürke"}, // 67
	{"gyékénysárga"}, // 68
	{"mandulabarna"}, // 69
	{"mikulásvörös"}, // 70
	{"viharkék"}, // 71
	{"ónszürke"}, // 72
	{"higanyszürke"}, // 73
	{"gránátalmavörös"}, // 74
	{"fagyalkék"}, // 75
	{"delfinszürke"}, // 76
	{"teveszín"}, // 77
	{"lávavörös"}, // 78
	{"vonatkék"}, // 79
	{"törökvörös"}, // 80
	{"pontyszürke"}, // 81
	{"áfonyavörös"}, // 82
	{"csókafekete"}, // 83
	{"nugátbarna"}, // 84
	{"galagonyavörös"}, // 85
	{"lombzöld"}, // 86
    {"tengerkék"}, // 87
    {"rózsavörös"}, // 88
    {"verébszürke"}, // 89
    {"platinaszürke"}, // 90
    {"atlantikék"}, // 91
    {"patkányszürke"}, // 92
    {"??"}, // 93
    {"??"}, // 94
    {"zafírkék"}, // 95
    {"sirályszürke"}, // 96
    {"hematiszürke"}, // 97
    {"betonszürke"}, // 98
    {"rézsárga"}, // 99
    {"napoleonkék"}, // 100
    {"mazarinkék"}, // 101
    {"zsemleszín"}, // 102
    {"egyiptomi-kék"}, // 103
    {"körteszín"}, // 104
    {"osztrigaszürke"}, // 105
    {"fecskekék"}, // 106
    {"márgasárga"}, // 107
    {"zománckék"}, // 108
    {"kányafekete"}, // 109
    {"mókusbarna"}, // 110
    {"gránitszürke"}, // 111
    {"napoleon-kék"}, // 112
    {"mokkafekete"}, // 113
    {"ponyvazöld"}, // 114
    {"kakasvörös"}, // 115
    {"vadgalambkék"}, // 116
    {"bécsivörös"}, // 117
    {"fakófehér"}, // 118
    {"szamárszürke"}, // 119
    {"homokszín"}, // 120
    {"bordó"}, // 121
    {"egérszürke"}, // 122
    {"jódbarna"}, // 123
    {"vérnarancs"}, // 124
    {"matrózkék"}, // 125
    {"pink"}, // 126
    {"fekete"}, // 127 (bugos??)
    {"tengeri zöld"}, // 128
    {"sötétbarna"}, // 129
    {"kékeszöld"}, // 130
    {"mogyoró barna"}, // 131
    {"égetett barna"}, // 132
    {"fekete"}, // 133 (bugos??)
    {"indigó"}, // 134
    {"acélkék"}, // 135
    {"ibolya"}, // 136
    {"kiwi zöld"}, // 137
    {"hamu szürke"}, // 138
    {"szürkés kék"}, // 139
    {"grafitszürke"}, // 140
    {"hódbarna"}, // 141
    {"olivazöld"}, // 142
    {"mályva"}, // 143
    {"orgona"}, // 144
    {"menta zöld"}, // 145
    {"szilva"}, // 146
    {"korall"}, // 147
    {"csokoládé barna"}, // 148
    {"fatörzs"}, // 149
    {"kávébarna"}, // 150
    {"vadász zöld"}, // 151
    {"zafír"}, // 152
    {"tavasz zöld"}, // 153
    {"pigment zöld"}, // 154
    {"persza zöld"}, // 155
    {"oroszlán barna"}, // 156
    {"palaszürke"}, // 157
    {"téglapiros"}, // 158
    {"rózsafa"}, // 159
    {"erdõzöld"}, // 160
    {"cseresznye"}, // 161
    {"farmerkék"}, // 162
    {"fenyõzöld"}, // 163
    {"sötétzöld"}, // 164
    {"dzsungelzöld"}, // 165
    {"égszínkék"}, // 166
    {"lila"} // 167
};

new vehicleNames[212][] = {
        {"Landstalker"},
        {"Bravura"},
        {"Buffalo"},
        {"Linerunner"},
        {"Perrenial"},
        {"Sentinel"},
        {"Dumper"},
        {"Firetruck"},
        {"Trashmaster"},
        {"Stretch"},
        {"Manana"},
        {"Infernus"},
        {"Voodoo"},
        {"Pony"},
        {"Mule"},
        {"Cheetah"},
        {"Ambulance"},
        {"Leviathan"},
        {"Moonbeam"},
        {"Esperanto"},
        {"Taxi"},
        {"Washington"},
        {"Bobcat"},
        {"Mr.Whoopie"},
        {"BF Injection"},
        {"Hunter"},
        {"Premier"},
        {"Enforcer"},
        {"Securicar"},
        {"Banshee"},
        {"Predator"},
        {"Bus"},
        {"Rhino"},
        {"Barracks"},
        {"Hotknife"},
        {"Trailer 1"},
        {"Previon"},
        {"Coach"},
        {"Cabbie"},
        {"Stallion"},
        {"Rumpo"},
        {"RC Bandit"},
        {"Romero"},
        {"Packer"},
        {"Monster"},
        {"Admiral"},
        {"Squalo"},
        {"Seasparrow"},
        {"Pizzaboy"},
        {"Tram"},
        {"Trailer 2"},
        {"Turismo"},
        {"Speeder"},
        {"Reefer"},
        {"Tropic"},
        {"Flatbed"},
        {"Yankee"},
        {"Caddy"},
        {"Solair"},
        {"Topfun Van"},
        {"Skimmer"},
        {"PCJ-600"},
        {"Faggio"},
        {"Freeway"},
        {"RC Baron"},
        {"RC Raider"},
        {"Glendale"},
        {"Oceanic"},
        {"Sanchez"},
        {"Sparrow"},
        {"Patriot"},
        {"Quad"},
        {"Coastguard"},
        {"Dinghy"},
        {"Hermes"},
        {"Sabre"},
        {"Rustler"},
        {"ZR-350"},
        {"Walton"},
        {"Regina"},
        {"Comet"},
        {"BMX"},
        {"Burrito"},
        {"Camper"},
        {"Marquis"},
        {"Baggage"},
        {"Dozer"},
        {"Maverick"},
        {"News Chopper"},
        {"Rancher"},
        {"FBIRancher"},
        {"Virgo"},
        {"Greenwood"},
        {"Jetmax"},
        {"Hotring"},
        {"Sandking"},
        {"Blista Compact"},
        {"CopcarMaverick"},
        {"Boxville"},
        {"Benson"},
        {"Mesa"},
        {"RC Goblin"},
        {"Hotring Racer A"},
        {"Hotring Racer B"},
        {"Bloodring"},
        {"Rancher"},
        {"Super GT"},
        {"Elegant"},
        {"Journey"},
        {"Bike"},
        {"Mountain"},
        {"Beagle"},
        {"Cropdust"},
        {"Stunt"},
        {"Tanker"},
        {"Roadtrain"},
        {"Nebula"},
        {"Majestic"},
        {"Buccaneer"},
        {"Shamal"},
        {"Hydra"},
        {"FCR-900"},
        {"NRG-500"},
        {"HPV1000"},
        {"Cement"},
        {"TowTruck"},
        {"Fortune"},
        {"Cadrona"},
        {"FBITruck"},
        {"Willard"},
        {"Forklift"},
        {"Tractor"},
        {"Combine"},
        {"Feltzer"},
        {"Remington"},
        {"Slamvan"},
        {"Blade"},
        {"Freight"},
        {"Streak"},
        {"Vortex"},
        {"Vincent"},
        {"Bullet"},
        {"Clover"},
        {"Sadler"},
        {"FiretruckLA"},
        {"Hustler"},
        {"Intruder"},
        {"Primo"},
        {"Cargobob"},
		{"Tampa"},
        {"Sunrise"},
        {"Merit"},
        {"Utility"},
        {"Nevada"},
        {"Yosemite"},
        {"Windsor"},
        {"MonsterA"},
        {"MonsterB"},
        {"Uranus"},
        {"Jester"},
        {"Sultan"},
        {"Stratum"},
        {"Elegy"},
        {"Raindance"},
        {"RC Tiger"},
        {"Flash"},
        {"Tahoma"},
        {"Savanna"},
        {"Bandito"},
        {"Freight Flat"},
        {"Streak Carriage"},
        {"Kart"},
        {"Mower"},
        {"Duneride"},
        {"Sweeper"},
        {"Broadway"},
        {"Tornado"},
        {"AT-400"},
        {"DFT-30"},
        {"Huntley"},
        {"Stafford"},
        {"BF-400"},
        {"Newsvan"},
        {"Tug"},
        {"Trailer 3"},
        {"Emperor"},
        {"Wayfarer"},
        {"Euros"},
        {"Hotdog"},
        {"Club"},
        {"Freight Carriage"},
        {"Trailer 3"},
        {"Andromada"},
        {"Dodo"},
        {"RC Cam"},
        {"Launch"},
        {"CopcarLS"},
        {"CopcarSF"},
        {"CopcarLV"},
        {"CopcarRU"},
        {"Picador"},
        {"SWAT"},
        {"Alpha"},
        {"Phoenix"},
        {"Glendale"},
        {"Sadlershit"},
        {"Luggage Trailer A"},
        {"Luggage Trailer B"},
        {"Stair Trailer"},
        {"Boxville"},
        {"Farm Plow"},
        {"Utility Trailer"}
};
