@echo off

copy "initrom\base.smc" "a2xtgaidengaiden.smc"

"LM\Lunar Magic.exe" -ImportGFX "a2xtgaidengaiden.smc"
"LM\Lunar Magic.exe" -ImportExGFX "a2xtgaidengaiden.smc"
"LM\Lunar Magic.exe" -ImportAllMap16 "a2xtgaidengaiden.smc" "Map16\AllMap16.map16"
"LM\Lunar Magic.exe" -ImportSharedPalette "a2xtgaidengaiden.smc" "initrom\shared.pal"
echo.

"LM\Lunar Magic.exe" -TransferLevelGlobalExAnim "a2xtgaidengaiden.smc" "initrom\transplantrom.smc"
"LM\Lunar Magic.exe" -TransferOverworld "a2xtgaidengaiden.smc" "initrom\transplantrom.smc"
"LM\Lunar Magic.exe" -TransferTitleScreen "a2xtgaidengaiden.smc" "initrom\transplantrom.smc"
"LM\Lunar Magic.exe" -TransferCredits "a2xtgaidengaiden.smc" "initrom\transplantrom.smc"
echo.
echo.

@echo | call "Insert Sprite.bat"
echo.
echo.

"LM\Lunar Magic.exe" -ImportMultLevels "a2xtgaidengaiden.smc" "Levels"
echo.
echo.

@echo | call "Insert Block.bat"
echo.
echo.
@echo | call "Insert Music.bat"
echo.
echo.
@echo | call "Insert Patch.bat"
echo.
echo.
@echo | call "Insert UberASM.bat"
echo.
echo.

echo.
@echo Finished
pause