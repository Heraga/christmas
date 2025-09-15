@echo off

pushd patch

asar.exe "Tweaks\TWEAKS.asm" "..\a2xtgaidengaiden.smc"


asar.exe "Patches\ExtraSave\extra_save.asm" "..\a2xtgaidengaiden.smc"


asar.exe "Fixes\BallChainYoshiFix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\bg_candle_flames_fix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\circle_fix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\ConveyorFireFix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\fireberryfix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\FireFix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\fixmush.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\HammerBroFix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\netkoopafix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\No Sprite Interaction Fix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\PIR.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\RolloverFix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\scrollfix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\slopepassfix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\spinspinspinaaaaaugghh.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\SpriteScrollFix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\tidefix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\walljumpnoteblockglitchfix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\YoshiSpriteInteractionsFix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Fixes\yourfatface.asm" "..\a2xtgaidengaiden.smc"
:: asar.exe "Fixes\.asm" "..\a2xtgaidengaiden.smc"


asar.exe "Patches\auto.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\custom_hud.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\DarkenPause.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\deathcounter.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\ExtendedSpriteDespawnRangeFix.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\extendnstl.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\flagfreescroll.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\footballlol.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\InlineLayer3Message.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\m_sprites.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\No Silent Bullet.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\optimize_2132_store.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\playerpalupdate.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\side_exit_goal.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\simpleHP.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\Spotlight.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\SSPFixes.asm" "..\a2xtgaidengaiden.smc"
asar.exe "Patches\ticking.asm" "..\a2xtgaidengaiden.smc"
:: asar.exe "Patches\.asm" "..\a2xtgaidengaiden.smc"

popd
pause