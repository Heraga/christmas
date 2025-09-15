; This file is where you set Retry's level-specific settings.
; Supported settings:
; - %checkpoint(level, value)
; - %retry(level, value)
; - %checkpoint_retry(level, checkpoint, retry)
; - %sfx_echo(level)
; - %no_reset_rng(level)
; - %no_room_cp_sfx(level)
; - %no_lose_lives(level)
; - %settings(level, checkpoint, retry, sfx_echo, no_reset_rng, no_room_cp_sfx, no_lose_lives)
; For details, check out "docs/settings_local.html".

%retry($106, 2)
%retry($197, 1)
%sfx_echo($009)