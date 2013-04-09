--[[ 
  @file       oqueue.lua
  @brief      warcraft addon for finding and queuing premade groups for bgs

  @author     rmcinnis
  @date       april 06, 2012
  @copyright  Solid ICE Technologies
              this file may be distributed so long as it remains unaltered
              if this file is posted to a web site, credit must be given to me along with a link to my web page
              no code in this file may be used in other works without expressed permission  
]]--
local addonName, OQ = ... ;

local OQ_MAJOR                 = 1 ;
local OQ_MINOR                 = 1 ;
local OQ_REVISION              = 6 ;
local OQ_BUILD                 = 116 ;
local OQ_SPECIAL_TAG           = "" ;
local OQUEUE_VERSION           = tostring(OQ_MAJOR) ..".".. tostring(OQ_MINOR) ..".".. OQ_REVISION ;
local OQUEUE_VERSION_SHORT     = tostring(OQ_MAJOR) ..".".. tostring(OQ_MINOR) .."".. OQ_REVISION ;
local OQ_VERSION               = tostring(OQ_MAJOR) .."".. tostring(OQ_MINOR) .."".. tostring(OQ_REVISION) ;
local OQ_VER_STR               = OQUEUE_VERSION ;
local OQ_VER                   = "0W"  ;  -- just removing the dot
local OQSK_VER                 = "0C"  ;  
local OQSK_HEADER              = "OQSK" ;
local OQUEUE_CHECK             = "oQueue capability check.  Sorry for the message during testing" ;
local OQUEUE_OLD_CHECK         = "oQueue capability check.  sorry for the spam during testing" ;
local OQUEUE_RESP_OK           = "oqueue enabled" ;
local OQUEUE_RESP_GTFO         = "oqueue stop" ;
local OQUEUE_RESP_GTFO2        = "oq stop" ;
local OQUEUE_RESP_GTFO3        = "oqstop" ;
local OQ_RESPONSE_NEWVERSION   = "NEW VERSION!! oQueue v".. OQ_VER_STR .." is now available on curse.com" ;
local OQ_RESPONSE_NEWVERSION2  = "The new version removes the compatibility check (no spam!  much better)" ;
local OQ_DAILY_CAPABILITYCHECK = 24 * 60 * 60 ;  -- daily check for toons that are OQ enabled
local OQ_NEXT_CAPABILITYCHECK  = 7 * 24 * 60 * 60 ;  -- 7 days until next check (unless forced)
local OQ_NOTIFICATION_CYCLE    = 2 * 60 * 60 ; -- every 2 hrs
local OQ_VERSION_SWAP_TM       = 24 * 60 * 60 ;  -- daily check for toons that are OQ enabled
local OQ_REALISTIC_MAX_GAMELEN = 8*60*60 ;  -- classic AV no longer exists
local OQ_NOEMAIL               = "." ;
local OQ_OLDBNHEADER           = "[OQ] " ;
local OQ_BNHEADER_TAG          = "(OQ)" ;
local OQ_BNHEADER              = OQ_BNHEADER_TAG .." " ;
local OQ_SKHEADER              = "[SK] " ;
local OQ_HEADER                = "OQ" ;
local OQ_MSGHEADER             = OQ_HEADER .."," ;
local OQ_FLD_TO                = "#to:" ;
local OQ_FLD_FROM              = "#fr:" ;
local OQ_FLD_REALM             = "#rlm:" ;
local OQ_TTL                   = 5 ;
local OQ_PREMADE_STAT_LIFETIME = 15*60 ; -- 15 minutes
local OQ_GROUP_TIMEOUT         = 2*60 ; -- 2 minutes (matches raid-timeout) if no response will remove group 
local OQ_GROUP_RECOVERY_TM     = 5*60 ; -- 5 minutes 
local OQ_SEC_BETWEEN_ADS       = 25 ; 
local OQ_SEC_BETWEEN_PROMO     = 25 ;
local OQ_BOOKKEEPING_INTERVAL  = 10 ;
local OQ_BRIEF_INTERVAL        = 30 ;
local HAILTOTHEKINGBABY        = 2*3600 ;
local OQ_MAX_ATOKEN_LIFESPAN   = 120 ; -- 120 seconds before token removed from ATOKEN list
local OQ_MIN_ATOKEN_RELAY_TM   = 30 ; -- do not relay atokens more then once every 30 seconds
local OQ_MAX_HONOR_WARNING     = 3600 ;
local OQ_MAX_HONOR             = 4000 ;
local OQ_MAX_SUBMIT_ATTEMPTS   = 20 ;
local OQ_MAX_WAITLIST          = 40 ;
local OQ_TOTAL_BGS             = 10 ;
local OQ_MIN_RUNAWAY_TM        = 40 ; 
local OQ_MIN_CONNECTION        = 8 ;
local OQ_MAX_BNFRIENDS         = 85 ;
local OQ_FINDMESH_CD           = 7 ; -- seconds
local OQ_CREATEPREMADE_CD      = 5 ; -- seconds
local OQ_BTAG_SUBMIT_INTERVAL  = 4*24*60*60 ;
local last_runaway             = 0 ;
local last_stat_tm             = 0 ;
local my_group                 = 0 ;
local my_slot                  = 0 ;
local next_bn_check            = 0 ;
local next_check               = 0 ;
local next_invite_tm           = 0 ;
local last_ident_tm            = 0 ;
local last_stats_tm            = 0 ;
local skip_stats               = 0 ;
local last_stats               = "" ;
local player_name              = nil ;
local player_class             = nil ;
local player_realm             = nil ;
local player_realm_id          = 0 ;
local player_realid            = nil ;
local player_faction           = nil ;
local player_level             = 1 ;
local player_ilevel            = 1 ;  
local player_resil             = 1 ;  
local player_role              = 3 ;
local player_deserter          = nil ;
local player_queued            = nil ;
local player_online            = 1 ;
local _source                  = nil ;
local _sender                  = nil ;
local _sender_pid              = nil ;
local _msg_token               = nil ;
local _debug                   = nil ;
local _inc_channel             = nil ;
local _received                = nil ;
local _error_ignore_tm         = 0 ;
local _ok2relay                = 1 ;
local _ok2decline              = true ;
local _local_msg               = nil ;
local _last_find_tm            = 0 ;
local _inside_bg               = nil ;
local _bg_shortname            = nil ;
local _bg_zone                 = nil ;
local _winner                  = nil ;
local _msg                     = nil ;
local _msg_type                = nil ;
local _msg_id                  = nil ;
local _oq_note                 = nil ;
local _oq_msg                  = nil ;
local _last_grp_stats          = nil ;
local _dest_realm              = nil ;
local _core_msg                = nil ;
local _to_name                 = nil ;
local _to_realm                = nil ;
local _from                    = nil ;
local _lucky_charms            = nil ;
local _last_lust               = nil ;
local _last_report             = nil ;
local _last_tops               = nil ;
local _last_bg                 = nil ;
local _last_crc                = nil ;
local _pkt_sent                = 0 ;
local _pkt_recv                = 0 ;
local _pkt_processed           = 0 ;
local _pkt_sent_persec         = 0 ;
local _pkt_recv_persec         = 0 ;
local _pkt_processed_persec    = 0 ;
local _map_open                = nil ;
local _ui_open                 = nil ;
local _oqgeneral_id            = nil ;
local _flags                   = nil ;
local _enemy                   = nil ;
local _nrage                   = 0 ;
local _nkbs                    = 0 ;
local _hailtiny                = 0 ;
local _next_flag_check         = 0 ;
local _announcePremades        = nil ;
local _arg                     = nil ;
local _vars                    = nil ;
local _hop                     = 0 ;
local player_away              = nil ;
local oq_ascii                 = {} ;
local oq_mime64                = {} ;

local function initialize_OQ_toon()
  if (OQ_toon ~= nil) then
    return ;
  end
  OQ_toon = { last_tm = 0,
              auto_role = 1,
              class_portrait = 1,
              shout_kbs = 1,
              shout_caps = 1,
              shout_ragequits = 1,
              say_sapped = 1,
              who_popped_lust = 1,
              ok2gc = 1,
            } 
end

if (OQ_toon == nil) then initialize_OQ_toon() ; end
--[[ OQ_toon used to help save group information if disconnected, reloaded, or quickly logged out
  my_group = 0 ;
  my_slot = 0 ;
  last_tm = 0 ;  -- if within 1 minute from now, try to re-establish
  raid = {} ; -- copied from oq on_logout
]]

local oq = { my_tok = nil, ui = {}, channels = {}, premades = {}, raid = {}, waitlist = {}, pending = {} } ;
--[[
  raid = {
    name         = 'the raid'
    leader       = 'bigdk'
    leader_realm = 'magtheridon'
    leader_rid   = 'joebob@someaddress.com'
    level_range  = '80-84'
    faction      = 'H'
    min_ilevel   = 380 ;
    min_resil    = 3000 ;
    bgs          = 'IoC,AV,AB,EotS'
    notes        = 'nothing much here' 
    raid_token   = 'OQ10002xxx'
    type         = OQ.TYPE_BG (D dungeon, A rated bgs, B battlegrounds(def))
    group        = { 
      [1] = { status = 'queued'                                                       -- group[1].member[1] is always the raid leader
              member = { 
                [1] = { name = 'bigman', class = 'dk'   , realm = '', bgroup = '', realid = nil, level = 0, hp = 0, flags = 0, bg[1]{ type,status } }, -- member[1] is always the group leader
                [2] = { name = 'jack'  , class = 'rogue', realm = '', bgroup = '', realid = nil }, -- realid is nil all but the raid leader
              }
      },
    }
    channel = 'oq00010022'
    pword   = 'pw00050001'
  },

  pending_invites = {
         [ name-realm ] = { raid_tok = oq.raid.raid_token, gid = group_id, slot = slot_, rid = rid_ } 
  },

  premades = {
    [1] = { raid_token = '', name = '', leader = '', leader_rid = '', level_range = '', faction = '', min_ilevel = '', min_resil = '', bgs = '' },
  },
  
  -- non-nil only for raid leader
  waitlist = {
    [1] = { name = 'slash', class = 'pally', realm = '', realid = '', level = '84', ilevel = '390', resil = '4200', realid = '' },
    [2] = { name = 'hack' , class = 'rogue', realm = '', realid = '', level = '84', ilevel = '390', resil = '4200', realid = '' },
  },
]]

local function initialize_OQ_data()
  if (OQ_data ~= nil) then
    return ;
  end
  OQ_data = {  
    bn_friends = {}, 
    autoaccept_mesh_request = 1,
    ok2submit_tag = 1,
    show_premade_ads = 1,
  } ;
  OQ_data.stats = {
    nGames      = 0 ;
    nWins       = 0 ;
    nLosses     = 0 ;
    start_tm    = 0 ; -- time() when this raid was created
    avg_honor   = 0 ; -- total per game stat.  avg_honor/game calc'd then added to total honor
    avg_hks     = 0 ; -- total per game stat.  avg_hk/game calc'd then added to total hks
    avg_deaths  = 0 ; -- total per game stat.  avg_deaths/game calc'd then added to total deaths
    avg_down_tm = 0 ; -- total per game stat.  avg time between games (seconds). 
    avg_bg_len  = 0 ; -- total per game stat.  avg game length (seconds). 
    bg_start    = 0 ; -- place holder - time() of bg start
    bg_end      = 0 ; -- place holder - time() of bg end
    tm          = 0 ; -- time of last update from source.  able to know which data is the latest
  } ;
end

if (OQ_data == nil) then initialize_OQ_data() ; end
--[[
  -- OQ enabled BN friends
  bn_friends = {
    [toonName-realm] = { presenceID, givenName, surName, toonName, realm, isOnline, oq_enabled } ;
  }
]]

-------------------------------------------------------------------------------
--   local defines
-------------------------------------------------------------------------------
oq.old_bncustommsg        = nil ;
oq.old_bn_msg             = nil ;
oq.WhoPoppedList_Ids = 
{
  [ 2825] = "Bloodlust",
  [32182] = "Heroism",
  [80353] = "Time Warp",
  [90355] = "Ancient Hysteria",
} ;


local OQ_FLAG_ONLINE      = 0x01 ;
local OQ_FLAG_DESERTER    = 0x02 ;
local OQ_FLAG_QUEUED      = 0x04 ;
local OQ_FLAG_BRB         = 0x08 ;
local OQ_FLAG_TANK        = 0x10 ;
local OQ_FLAG_HEALER      = 0x20 ;

local OQ_FLAG_CLEAR       = 0x00 ;
local OQ_FLAG_READY       = 0x01 ;
local OQ_FLAG_NOTREADY    = 0x02 ;
local OQ_FLAG_WAITING     = 0x04 ;

local OQ_LOCK          = "|TInterface\\BUTTONS\\UI-Button-KeyRing.blp:28:20:0:0:20:24:0:16:0:16|t";
local OQ_KEY           = "Interface\\BUTTONS\\UI-Button-KeyRing" ;

local OQ_STAR_ICON     = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcons.blp:16:16:0:0:64:64:0:16:0:16|t";
local OQ_CIRCLE_ICON   = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcons.blp:16:16:0:0:64:64:16:32:0:16|t";
local OQ_DIAMOND_ICON  = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcons.blp:10:10:0:0:64:64:32:48:0:16|t";
local OQ_BIGDIAMOND_ICON  = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcons.blp:16:16:0:0:64:64:32:48:0:16|t";
local OQ_TRIANGLE_ICON = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcons.blp:16:16:0:0:64:64:48:64:0:16|t";

local OQ_MOON_ICON     = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcons.blp:16:16:0:0:64:64:0:16:16:32|t";
local OQ_SQUARE_ICON   = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcons.blp:16:16:0:0:64:64:16:32:16:32|t";
local OQ_REDX_ICON     = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcons.blp:16:16:0:0:64:64:32:48:16:32|t";
local OQ_LILREDX_ICON  = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcons.blp:8:8:0:0:64:64:32:48:16:32|t";
local OQ_SKULL_ICON    = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcons.blp:16:16:0:0:64:64:48:64:16:32|t";

OQ.ICON_NONE        = 0 ;
OQ.ICON_STAR        = 1 ;
OQ.ICON_CIRCLE      = 2 ;
OQ.ICON_DIAMOND     = 3 ;
OQ.ICON_TRIANGLE    = 4 ;
OQ.ICON_MOON        = 5 ;
OQ.ICON_SQUARE      = 6 ;
OQ.ICON_REDX        = 7 ;
OQ.ICON_SKULL       = 8 ;

OQ.ICON_STRINGS = {
  [ OQ.ICON_NONE      ] = nil,
  [ OQ.ICON_STAR      ] = OQ_STAR_ICON,
  [ OQ.ICON_CIRCLE    ] = OQ_CIRCLE_ICON,
  [ OQ.ICON_DIAMOND   ] = OQ_DIAMOND_ICON,
  [ OQ.ICON_TRIANGLE  ] = OQ_TRIANGLE_ICON,
  [ OQ.ICON_MOON      ] = OQ_MOON_ICON,
  [ OQ.ICON_SQUARE    ] = OQ_SQUARE_ICON,
  [ OQ.ICON_REDX      ] = OQ_REDX_ICON,
  [ OQ.ICON_SKULL     ] = OQ_SKULL_ICON,
} ;

OQ.ICON_COORDS = {
  [ OQ.ICON_NONE      ] = { 0.00, 0.00, 0.00, 0.00 },
  [ OQ.ICON_STAR      ] = { 0.00, 0.25, 0.00, 0.25 },
  [ OQ.ICON_CIRCLE    ] = { 0.25, 0.50, 0.00, 0.25 },
  [ OQ.ICON_DIAMOND   ] = { 0.50, 0.75, 0.00, 0.25 },
  [ OQ.ICON_TRIANGLE  ] = { 0.75, 1.00, 0.00, 0.25 },
  [ OQ.ICON_MOON      ] = { 0.00, 0.25, 0.25, 0.50 },
  [ OQ.ICON_SQUARE    ] = { 0.25, 0.50, 0.25, 0.50 },
  [ OQ.ICON_REDX      ] = { 0.50, 0.75, 0.25, 0.50 },
  [ OQ.ICON_SKULL     ] = { 0.75, 1.00, 0.25, 0.50 },
} ;

-------------------------------------------------------------------------------
local OQ_versions = 
{ [ "1.0.2"    ] =  1,
  [ "1.0.3"    ] =  2,
  [ "1.0.4"    ] =  3,
  [ "1.0.5"    ] =  4,
  [ "1.0.6"    ] =  5,
  [ "1.0.7"    ] =  6,
  [ "1.0.8"    ] =  7,
  [ "1.0.9"    ] =  8,
  [ "1.1.0"    ] =  9,
  [ "1.1.1"    ] = 10,
  [ "1.1.2"    ] = 11,
  [ "1.1.3"    ] = 12,
  [ "1.1.4"    ] = 13,
  [ "1.1.5"    ] = 14,
  [ "1.1.6"    ] = 15,
  [ "1.1.7"    ] = 16,
  [ "1.1.8"    ] = 17,
  [ "1.1.9"    ] = 18,
  [ "1.2.0"    ] = 19,
  [ "1.2.1"    ] = 20,
  [ "1.2.2"    ] = 21,
  [ "1.2.3"    ] = 22,
  [ "1.2.4"    ] = 23,
  [ "1.2.5"    ] = 24,
  [ "1.2.6"    ] = 25,
} ;

function oq.get_version_id()
  return OQ_versions[OQ_VER_STR] or 0 ;
end

function oq.get_version_str( id )
  if (id == 0) then
    return "" ;
  end
  for i,v in pairs(OQ_versions) do
    if (v == id) then
      return i ;
    end
  end
  return "" ;
end
-------------------------------------------------------------------------------
--   slash commands
-------------------------------------------------------------------------------

SLASH_OQUEUE1 = '/oqueue' ;
SLASH_OQUEUE2 = '/oq' ;
SlashCmdList["OQUEUE"] = function (msg, editbox)
  if (msg == nil) or (msg == "") then
    oq.ui_toggle() ;
    return ;
  end
  local arg1 = msg ;
  local opts = nil ;
  if (msg ~= nil) and (msg:find(" ") ~= nil) then
    arg1 = msg:sub(1,msg:find(" ")-1) ;
    opts = msg:sub(msg:find(" ")+1,-1) ;
  end
  if (oq.options[ arg1 ] ~= nil) then
    oq.options[ arg1 ]( opts ) ;
  end
end

--------------------------------------------------------------------------
-- class portrait to replace normal portrait
--------------------------------------------------------------------------
function OQ_ClassPortrait( self ) 
  if (OQ_toon.class_portrait == 0) then
    if (self.portrait ~= nil) then
      self.portrait:SetTexCoord(0,1,0,1)
    end
    return ;
  end
  if (self.portrait ~= nil) then
    if UnitIsPlayer(self.unit) and ((self.unit == "target") or (self.unit == "focus") or (self.unit:sub(1,5) == "party")) then
      local t = CLASS_ICON_TCOORDS[select(2,UnitClass(self.unit))]
      if t then
        self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        self.portrait:SetTexCoord(unpack(t))
      end
    else
      self.portrait:SetTexCoord(0,1,0,1)
    end
  end
end

hooksecurefunc("UnitFramePortrait_Update",OQ_ClassPortrait ) ;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
function oq.hook_options()
  oq.options = {} ;
  oq.options[ "?"           ] = oq.usage ; 
  oq.options[ "adds"        ] = oq.show_adds ;
  oq.options[ "ban"         ] = oq.ban_user ;
  oq.options[ "blam"        ] = oq.blam ;
  oq.options[ "j2tw"        ] = oq.j2tw_now ;
  oq.options[ "bnclear"     ] = oq.bn_clear ; 
  oq.options[ "brb"         ] = oq.brb ;
  oq.options[ "cb"          ] = oq.color_blind_mode ;
  oq.options[ "check"       ] = oq.bn_force_verify ;
  oq.options[ "cp"          ] = oq.toggle_class_portraits ;
  oq.options[ "debug"       ] = oq.debug_toggle ;
  oq.options[ "dg"          ] = oq.leave_party ;  -- drop group
  oq.options[ "dp"          ] = oq.leave_party ;  -- drop party
  oq.options[ "fixui"       ] = oq.reposition_ui ;  
  oq.options[ "refresh"     ] = oq.raid_find ;
  oq.options[ "godark"      ] = oq.godark ;
  oq.options[ "harddrop"    ] = oq.harddrop ; 
  oq.options[ "help"        ] = oq.usage ; 
  oq.options[ "log"         ] = oq.log_start ; 
  oq.options[ "logdeep"     ] = oq.log_deep ; 
  oq.options[ "logstop"     ] = oq.log_stop ; 
  oq.options[ "logclear"    ] = oq.log_clear ; 
  oq.options[ "lust"        ] = oq.last_lust ;   
  oq.options[ "mbsync"      ] = oq.mbsync ;
  oq.options[ "mycrew"      ] = oq.mycrew ;
  oq.options[ "mini"        ] = oq.toggle_mini ;
  oq.options[ "now"         ] = oq.show_now ;
  oq.options[ "pnow"        ] = oq.show_now2party ;
  oq.options[ "partynow"    ] = oq.show_now2party ;
  oq.options[ "off"         ] = oq.oq_off ;
  oq.options[ "on"          ] = oq.oq_on ;
  oq.options[ "pending"     ] = oq.bn_show_pending ;
  oq.options[ "ping"        ] = oq.ping_toon ;
  oq.options[ "purge"       ] = oq.remove_OQadded_bn_friends ;
  oq.options[ "rage"        ] = oq.report_rage ;
  oq.options[ "rc"          ] = oq.start_role_check ;
  oq.options[ "reset"       ] = oq.data_reset ;
  oq.options[ "show"        ] = oq.show_data ;
  oq.options[ "spy"         ] = oq.battleground_spy ;
  oq.options[ "stats"       ] = oq.dump_statistics ;
  oq.options[ "timers"      ] = oq.timer_dump ;  
  oq.options[ "toggle"      ] = oq.toggle_option ;  
  oq.options[ "version"     ] = oq.show_version ;
  oq.options[ "-v"          ] = oq.show_version ;
  oq.options[ "who"         ] = oq.show_bn_enabled ;
end

local ticker = 55585 ;
local bg_points = { [1] = "AB"  ,
                    [2] = "AV"  ,
                    [3] = "BFG" ,
                    [4] = "EotS",
                    [5] = "IoC" ,
                    [6] = "SotA",
                    [7] = "TP"  ,
                    [8] = "WSG" ,
                    [9] = "SSM" ;
                    [10] = "ToK" ;
                  } ;

function oq.toggle_mini()
  if (OQ_MinimapButton:IsVisible()) then
    OQ_MinimapButton:Hide() ;
    OQ_toon.mini_hide = true ;
    print( OQ_MINIMAP_HIDDEN ) ;
  else
    OQ_MinimapButton:Show() ;
    OQ_toon.mini_hide = nil ;
    print( OQ_MINIMAP_SHOWN ) ;
  end
end

function oq.blam( n )
  local spice = { "bells", "jolly", "sing" } ;
  n = tonumber(n) ;
  if (n == nil) or (n > #spice) then
    n = random(1,#spice) ;
  end
  PlaySoundFile("Interface\\Addons\\oqueue\\sounds\\".. spice[n] ..".mp3") ;
end

-- joy to the world 
-- randomly plays on Christmas, 45-90 min interval
-- (tip: type this a few times for a preview: /oq blam)
function oq.j2tw(queue_it)
  local mon = tonumber(date("%m")) ;
  local day = tonumber(date("%d")) ;
  if (mon ~= 12) or ((day < 21) and (day > 29)) then
    return ;
  end
  if (queue_it == nil) then
    oq.j2tw_now()
  end
  oq.timer_oneshot( random(45*60, 90*60), oq.j2tw ) ;
end

function oq.j2tw_now()
  -- Merry Christmas!
  -- i love Christmas and if you don't like it, i'll gy-camp yer ass ;)
  oq.timer_oneshot( 1.0, oq.blam, 3 ) ;  
  oq.timer_oneshot( 1.5, oq.blam, 1 ) ;  
  oq.timer_oneshot( 2.0, oq.blam, 2 ) ;  
end

function oq.reposition_ui()
  local f = OQMainFrame ;
  if (not f:IsVisible()) then
    oq.ui_toggle() ;
  end  
  f:SetWidth( 800 ) ;
  f:SetHeight( 425 ) ;
  f:SetPoint("TOPLEFT", UIParent,"TOPLEFT", 100, -100 ) ;
end

function oq.color_blind_mode( opt )
  if (not OQColorBlindShader:IsVisible()) then
    return nil ;
  end
  if (OQ_data.colorblindshader == nil) then
    OQ_data.colorblindshader = 0 ;
  end
  if (opt ~= nil) and (opt == "?") then
    print( "OQ: color-blind-shader: ".. OQ.COLORBLINDSHADER[ OQ_data.colorblindshader ] ) ;
    return nil ;
  end
  if (opt ~= nil) and (opt == "next") then
    OQ_data.colorblindshader = (OQ_data.colorblindshader + 1) % 9 ;
  elseif (opt == nil) or (type(tonumber(opt)) ~= "number") then
    OQ_data.colorblindshader = 0 ;
  else
    OQ_data.colorblindshader = (tonumber(opt) % 9) ;
  end
  ConsoleExec( "colorblindshader ".. tostring( OQ_data.colorblindshader ) ) ;
  
  if (oq.tab5_colorblindshader ~= nil) then
    ToggleDropDownMenu(1, nil, oq.tab5_colorblindshader ) ;
    UIDropDownMenu_SetSelectedID( oq.tab5_colorblindshader, ((OQ_data.colorblindshader or 0) + 1) ) ;
    CloseDropDownMenus() ;
  end
  return 1 ;
end

function oq.show_data( opt )
  if (opt == nil) or (opt == "?") then
    print( "oQueue v".. OQUEUE_VERSION .."  build ".. OQ_BUILD .." (".. tostring(OQ.REGION) ..")" ) ;
    print( " usage:  /oq show <option>" ) ;
    print( "   remove       list all the battle-tags that will be removed with 'remove now'" ) ;
    print( "   report       show battleground reports yet to be filed" ) ;
    print( "   stats        list various stats" ) ;
  elseif (opt == "remove") then
    oq.remove_OQadded_bn_friends( "show" ) ;
  elseif (opt == "report") then
    oq.show_reports() ;
  elseif (opt == "stats") then
    oq.dump_statistics() ;
  end
end

function oq.show_reports()
end

function oq.toggle_option( opt )
  if (opt == nil) or (opt == "?") then
    print( "oQueue v".. OQUEUE_VERSION .."  build ".. OQ_BUILD .." (".. tostring(OQ.REGION) ..")" ) ;
    print( " usage:  /oq toggle <option>" ) ;
    print( "   ads          toggle the premade advertisements" ) ;
    print( "   mini         toggle the minimap icon" ) ;    
  elseif (opt == "mini") then 
    oq.toggle_mini() ;
  elseif (opt == "ads") then
    if (OQ_data.show_premade_ads == nil) or (OQ_data.show_premade_ads == 0) then
      OQ_data.show_premade_ads = 1 ;
      print( "premade advertisements are now ON" ) ;
    else
      OQ_data.show_premade_ads = 0 ;
      print( "premade advertisements are now OFF" ) ;
    end
  end  
end

function oq.harddrop()
  oq.raid_init() ;
end

function oq.leave_party()
  if (oq.iam_raid_leader()) then
    oq.raid_disband() ;
  else
    oq.raid_init() ;
  end
  LeaveParty() ;
  oq.raid_cleanup() ;
end

function oq.ban_user( tag )
  if (tag == nil) then
    return ;
  end
  local dialog = StaticPopup_Show("OQ_BanUser", tag ) ;
  if (dialog ~= nil) then
    dialog.data2 = { flag = 3, btag = tag } ;
  end
end

function oq.last_lust()
  if (_last_lust ~= nil) then
    print( _last_lust ) ;
  else
    print( "nothing to report" ) ;
  end
end

function oq.usage()
  print( "oQueue v".. OQUEUE_VERSION .."  build ".. OQ_BUILD .." (".. tostring(OQ.REGION) ..")" ) ;
  print(" usage:  /oq [command]" ) ;
  print( "command such as:" ) ;
  print( "  adds            show the list of OQ added b.net friends" ) ;
  print( "  ban [b-tag]     manually add battle-tag to your ban list" ) ;
  print( "  bnclear         clear OQ enabled battle-net associations" ) ;
  print( "  brb             signal to the group that you'll be-right-back" ) ;
  print( "  check           force OQ capability check" ) ;
  print( "  cp              toggle class portraits to normal portrait" ) ;
  print( "  dg              drop group.  same as /script LeaveParty()" ) ;
  print( "  fixui           will reposition the UI to upper left area" ) ;
  print( "  godark          send 'oq stop' to all your OQ enabled friends" ) ;
  print( "  lust            re-display the last lust message" ) ;
  print( "  mini            toggle the minimap button" ) ;
  print( "  mycrew [clear]  for boxers, populate the alt list" ) ;
  print( "  now             print the current utc time (only visible to user)" ) ;
  print( "  off             turn off OQ messaging" ) ;
  print( "  on              turn on OQ messaging" ) ;
  print( "  pnow            print the current utc time to party chat" ) ;
  print( "  purge           purge friends list of OQ added b.net friends" ) ;
  print( "  rage            report the number of rage-quitters (in BG only)" ) ;
  print( "  rc              start role check (OQ premade leader only)" ) ;
  print( "  refresh         sends out a request to refresh find-premade list" ) ;
  print( "  show <opt>      show various information" ) ;
  print( "  stats           various statistics about the player" ) ;
  print( "  spy [on|off]    display summary of enemy class types" ) ;
  print( "  toggle <opt>    toggle specific option" ) ;
  print( "  who             list of OQ enabled battle-net friends" ) ;    
end

function oq.data_reset()
    oq = { my_tok = nil, ui = {}, channels = {}, premades = {}, raid = {}, waitlist = {} } ;
    OQ_data = { bn_friends = {} } ;
    oq.init_stats_data() ;
    OQ_toon = { last_tm = 0,
                auto_role = 1,
                class_portrait = 1,
                shout_kbs = 1,
                shout_caps = 1,
                shout_ragequits = 1,
                say_sapped = 1,
                who_popped_lust = 1,
                ok2gc = 1,
                reports = {},
              } ;
    print( "oQueue data reset.  for it to take effect, type /reload" ) ;
end

function oq.debug_toggle()
  if (_debug) then
    _debug = nil ; 
    print( "debug off" ) ;
  else
    _debug = true ; 
    print( "debug on" ) ;
  end
end

function oq.godark()
  -- send msg to stop sending data
  for i,v in pairs(OQ_data.bn_friends) do
    if (v.isOnline and v.oq_enabled) then
      BNSendWhisper( v.presenceID, OQUEUE_RESP_GTFO2 ) ;    
    end
  end
  -- clear out bn friends
  oq.bn_clear() ;
  -- turn it off
  oq.oq_off() ;
  -- update OQ friends count
  oq.n_connections() ;
end

function oq.oq_off() 
  OQ_toon.disabled = true ;
  oq.reset_bn_custom_msg() ;
  print( OQ.DISABLED ) ;
end

function oq.oq_on() 
  OQ_toon.disabled = nil ;
  oq.init_bn_custom_msg() ;
  print( OQ.ENABLED ) ;
end

function oq.GetNumPartyMembers()
  return GetNumGroupMembers() ;
end

function oq.CRC32(s)
   local bit_band, bit_bxor, bit_rshift, str_byte, str_len = bit.band, bit.bxor, bit.rshift, string.byte, string.len
   local consts = { 0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F, 0xE963A535, 0x9E6495A3, 0x0EDB8832, 
                    0x79DCB8A4, 0xE0D5E91E, 0x97D2D988, 0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2, 
                    0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7, 0x136C9856, 0x646BA8C0, 0xFD62F97A, 
                    0x8A65C9EC, 0x14015C4F, 0x63066CD9, 0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172, 
                    0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, 0x42B2986C, 0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 
                    0x45DF5C75, 0xDCD60DCF, 0xABD13D59, 0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423, 
                    0xCFBA9599, 0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924, 0x2F6F7C87, 0x58684C11, 0xC1611DAB, 
                    0xB6662D3D, 0x76DC4190, 0x01DB7106, 0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433, 
                    0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D, 0x91646C97, 0xE6635C01, 0x6B6B51F4, 
                    0x1C6C6162, 0x856530D8, 0xF262004E, 0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, 0x12B7E950, 
                    0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65, 0x4DB26158, 0x3AB551CE, 0xA3BC0074, 
                    0xD4BB30E2, 0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0, 
                    0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086, 0x5768B525, 
                    0x206F85B3, 0xB966D409, 0xCE61E49F, 0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81, 
                    0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A, 0xEAD54739, 0x9DD277AF, 0x04DB2615, 
                    0x73DC1683, 0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1, 
                    0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB, 0x196C3671, 0x6E6B06E7, 0xFED41B76, 
                    0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC, 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8, 0xA1D1937E, 
                    0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B, 0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 
                    0x41047A60, 0xDF60EFC3, 0xA867DF55, 0x316E8EEF, 0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236, 
                    0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 
                    0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D, 0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F, 
                    0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38, 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 
                    0x0BDBDF21, 0x86D3D2D4, 0xF1D4E242, 0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777, 
                    0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45, 0xA00AE278, 
                    0xD70DD2EE, 0x4E048354, 0x3903B3C2, 0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC, 
                    0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9, 0xBDBDF21C, 0xCABAC28A, 0x53B39330, 
                    0x24B4A3A6, 0xBAD03605, 0xCDD70693, 0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94, 
                    0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D }
   
   local crc, l, i = 0xFFFFFFFF, str_len(s)
   for i = 1, l, 1 do
      crc = bit_bxor(bit_rshift(crc, 8), consts[bit_band(bit_bxor(crc, str_byte(s, i)), 0xFF) + 1])
   end
   return bit_bxor(crc, -1)
end

function oq.mycrew( arg )
  -- use the current raid/party to poulate the OQ_data.my_toons
  if (arg == "clear") then
    oq.clear_alt_list() ;
    return ;
  end
  if (not UnitInParty("player")) then
    return ;
  end
  oq.clear_alt_list() ;
  local n = GetNumGroupMembers() ;
  if (n > 0) then
    for i=1,n do
      local name = select( 1, GetRaidRosterInfo(i) ) ;
      oq.add_toon( name ) ;
    end
  else
    n = oq.GetNumPartyMembers() ;
    oq.add_toon( player_name ) ;
    for i=1,n do
      local name = GetUnitName( "party".. i ) ;
      oq.add_toon( name ) ;
    end
  end
end

-- this will return utc time in seconds
--
function utc_time( arg )
  if (arg == nil) then
    local now = time() ;
    return time(date("!*t")) + difftime(now, time(date("!*t", now) )) ;
  else
    return time(date("!*t")) ;
  end
end

function oq.reset_portrait( f, player, show_default )
  if (f == nil) or (f.portrait == nil) then
    return ;
  end
  if (show_default) then
    SetPortraitTexture( f.portrait, player ) ;
    f.portrait:SetTexCoord(0,1,0,1) ;
  else
    OQ_ClassPortrait( f ) ;
  end
end

function oq.toggle_class_portraits()
  if (OQ_toon.class_portrait == 1) then
    OQ_toon.class_portrait = 0 ;
  else
    OQ_toon.class_portrait = 1 ;
  end
  oq.reset_portrait( PlayerFrame      , "player", (OQ_toon.class_portrait == 0) ) ;
  oq.reset_portrait( TargetFrame      , "target", (OQ_toon.class_portrait == 0) ) ;
  oq.reset_portrait( PartyMemberFrame1, "party1", (OQ_toon.class_portrait == 0) ) ;
  oq.reset_portrait( PartyMemberFrame2, "party2", (OQ_toon.class_portrait == 0) ) ;
  oq.reset_portrait( PartyMemberFrame3, "party3", (OQ_toon.class_portrait == 0) ) ;
  oq.reset_portrait( PartyMemberFrame4, "party4", (OQ_toon.class_portrait == 0) ) ;
  oq.reset_portrait( PartyMemberFrame5, "party5", (OQ_toon.class_portrait == 0) ) ;
end

function oq.render_tm( dt )
  if (dt > 0) then
    local dsec, dmin, dhr, ddays, dyrs, dstr ;
    ddays = floor(dt / (24*60*60)) ;
    dt = dt % (24*60*60) ;
    dyrs = floor( ddays / 365 ) ;
    ddays = ddays % 365 ;
    dhr = floor(dt / (60*60)) ;
    dt = dt % (60*60) ;
    dmin = floor(dt / 60) ;
    dt = dt % 60 ;
    dsec = dt ;
    dstr = "" ;
    if (dyrs > 0) then
      dstr = dyrs .."y ".. ddays .."d ".. string.format("%02d:%02d:%02d", dhr, dmin, dsec ) ;
    elseif (ddays > 0) then
      dstr = ddays .."d ".. string.format("%02d:%02d:%02d", dhr, dmin, dsec ) ;
    elseif (dhr > 0) then
      dstr = string.format("%02d:%02d:%02d", dhr, dmin, dsec ) ;
    elseif (dmin > 0) then
      dstr = string.format("%02d:%02d", dmin, dsec ) ;
    else
      dstr = string.format("00:%02d", dsec ) ;
    end
    return dstr ;
  else
    return "xx:xx" ;
  end
end

function oq.show_now( arg )
  local msg = string.format( OQ.THETIMEIS, utc_time( arg )) ;
  local now = utc_time( arg ) ;
  print( string.format( OQ.THETIMEIS, now ) ) ;
  
  -- show difference from scorekeeper time
  if (oq._sktime_last_tm == nil) then
    return ;
  end
  local dt = abs(oq._sktime_last_dt) ;
  if (dt > 0) then
    local dsec, dmin, dhr, ddays, dyrs, dstr ;
    ddays = floor(dt / (24*60*60)) ;
    dt = dt % (24*60*60) ;
    dyrs = floor( ddays / 365 ) ;
    ddays = ddays % 365 ;
    dhr = floor(dt / (60*60)) ;
    dt = dt % (60*60) ;
    dmin = floor(dt / 60) ;
    dt = dt % 60 ;
    dsec = dt ;
    dstr = "local time varies from scorekeeper by: " ;
    if (dyrs > 0) then
      dstr = dstr .." ".. dyrs .." yrs ".. ddays .." days ".. dhr ..":".. dmin ..":".. dsec ;
    elseif (ddays > 0) then
      dstr = dstr .." ".. ddays .." days ".. dhr ..":".. dmin ..":".. dsec ;
    elseif (dhr > 0) then
      dstr = dstr .." ".. dhr ..":".. dmin ..":".. dsec .." hours" ;
    elseif (dmin > 0) then
      dstr = dstr .." ".. dmin ..":".. dsec .." minutes" ;
    else
      dstr = dstr .." ".. dsec .." seconds" ;
    end
    print( dstr ) ;
  end
end

function oq.show_now2party( arg )
  local msg = string.format( OQ.THETIMEIS, utc_time( arg )) ;
  SendChatMessage( msg, "PARTY", nil ) ;  
end
-------------------------------------------------------------------------------
-- token functions
-------------------------------------------------------------------------------
local OQ_atoken = {} ;
function oq.atok_last_seen( token )
  if (token == nil) or (OQ_atoken[ token ] == nil) then
    return 0 ;
  end
  return OQ_atoken[ token ] ;
end

function oq.atok_seen( token )
  if (token ~= nil) then
    OQ_atoken[ token ] = utc_time() ;
  end
end

-- will register token as seen if ok to process
--
function oq.atok_ok2process( token )
  local last_seen = oq.atok_last_seen( token ) ;
  local now = utc_time() ;
  if ((now - last_seen) > OQ_MIN_ATOKEN_RELAY_TM) then
    oq.atok_seen( now ) ;
    return true ;
  end
end

function oq.atok_clear_old()
  local now = utc_time() ;
  for i,v in pairs(OQ_atoken) do
    if ((now - v) > OQ_MAX_ATOKEN_LIFESPAN) then
      OQ_atoken[i] = nil ;
    end
  end
end

function oq.atok_clear()
  OQ_atoken = {} ;
end

function oq.token_gen()
  local tm = floor( GetTime() * 1000 ) ;
  local r = random( 0, 10000 ) ;
  local token = (tm % 100000) * 10000 + r ;
-- was producing a 9 digit token, now will produce only 5 (needed the room)
--  return tostring(token) ;
-- 
  return oq.encode_mime64_5digit(token) ;
end

local OQ_recent_tokens = {} ;
local OQ_recent_keys = {} ;
local OQ_tok_cnt = 0 ;
function oq.token_list_init()
  for i=1,500 do
    OQ_recent_tokens[i] = i ;
    OQ_recent_keys[i] = i ;
  end
  OQ_tok_cnt = 501 ;
end

function oq.token_was_seen( token )
  return (OQ_recent_keys[ token ] ~= nil) ;
end

--
--  remove one from the front, push one to the back
--
function oq.token_push( token_ )
  local key = table.remove( OQ_recent_tokens, 1 ) ;
  if (OQ_recent_keys == nil) then
    OQ_recent_keys = {} ;
  end
  if (OQ_recent_tokens == nil) then
    OQ_recent_tokens = {} ;
  end
  if (key ~= nil) then
    OQ_recent_keys[ key ] = nil ;
  end

  OQ_tok_cnt = OQ_tok_cnt + 1 ;
  OQ_recent_tokens[ OQ_tok_cnt ] = token_ ;
  OQ_recent_keys  [ token_     ] = OQ_tok_cnt ;
end

-------------------------------------------------------------------------------
--   
-------------------------------------------------------------------------------
function oq.tremove_value( t, val )
  for i,v in pairs(t) do
    if (v == val) then
      tremove( t, i ) ;
      return ;
    end
  end
end

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function tprint_col (tbl, indent, key )
   if not indent then indent = 0 end
   local ln = string.rep(" ", indent) ;
   for k, v in pairs(tbl) do
      if type(v) == "table" then
         formatting = string.rep(" ", indent) ;
         tprint_col(v, indent+1, k)
      elseif (k ~= "leader_rid") then
         ln = ln .." ".. k ..": ".. tostring(v) ;
      end
   end
   if (key ~= nil) then
      print( tostring(key) ..": ".. ln ) ;
   else
      print( ln ) ;
   end
end

function oq.n_rows(t)
  local n = 0 ;
  for i,v in pairs(t) do
    n = n + 1 ;
  end
  return n ;
end

function oq.n_premades()
  local nShown, nPremades = 0, 0 ;
  if (oq.tab2_raids ~= nil) then
    for n,v in pairs(oq.tab2_raids) do 
      local p = oq.premades[ v.token ] ;
      if (p ~= nil) then
        if (v._isvis) then
          nShown = nShown + 1 ;
        end
        if (p.type ~= OQ.TYPE_ARENA) or (p.leader_realm == player_realm) then
          nPremades = nPremades + 1 ;
        end
      end
    end
  end
  return nShown, nPremades ;
end

function oq.dump_statistics()
  local s = OQ_data.stats ;
  if ((s == nil) or (s.nGames == 0)) then
    print( "OQ:  no statistics available" ) ;
  else
    print( "oQueue premade stats" ) ;
    print( "---" ) ;
    if (s ~= nil) then
      print( " nGames          : ".. s.nGames     ) ;
      print( " nWins           : ".. s.nWins      ) ;
      print( " nLosses         : ".. s.nLosses    ) ;
      print( " nTears          : ".. s.tears      ) ;
      print( " running time    : ".. floor((utc_time() - s.start_tm)/60) .." minutes" ) ;
      print( " avg honor/game  : ".. (s.avg_honor or 0)  ) ;
      print( " avg hks/game    : ".. (s.avg_hks or 0)   ) ;
      print( " avg deaths/game : ".. (s.avg_deaths or 0) ) ;
      print( " avg down time   : ".. floor( s.avg_down_tm / 60) .." minutes" ) ;
      print( " avg game length : ".. floor( s.avg_bg_len / 60) .." minutes" ) ;
    end
  end
  print( "  my_region        : ".. tostring(OQ.REGION) ) ;
  print( "  my_realmlist     : ".. tostring(GetCVar("realmlist")) ) ;
  print( "  my_realm         : ".. tostring(player_realm)  .." (".. tostring(oq.realm_cooked(player_realm)) ..")" ) ;
  print( "  my_realid        : ".. tostring( player_realid ) ) ;
  print( "  my_role          : ".. tostring( OQ.ROLES[player_role] ) ) ;
  if (oq.raid.raid_token == nil) then
    print( "  my_group:  not in an OQ premade" ) ;
  else
    print( "  my_group: ".. tostring( oq.raid.type ) ..".".. tostring( oq.raid.raid_token ) .." . ".. tostring( my_group ) .." . ".. tostring( my_slot ) .."  ".. tostring(oq.raid.leader) .."-".. tostring(oq.raid.leader_realm) ) ;
    if (oq.iam_related_to_boss()) then
      print( "    --  i am related to the boss" ) ;
    end
  end
  if (_inside_bg) then
    print( " inside bg       : yes   [".. tostring(_bg_zone) ..". ".. tostring(_bg_shortname) .."]" ) ;
  else
    print( " inside bg       : no" ) ;
  end
  if (OQ_toon.disabled) then
    print( "  OQ messaging is DISABLED" ) ;
  else
    print( "  OQ messaging is ENABLED" ) ;
  end
  local nShown, nPremades = oq.n_premades() ;
  print( "  # of premades     : ".. nShown .." / ".. nPremades ) ;
  print( "  # of BN friends   : ".. select( 1, BNGetNumFriends() ) ) ;
  print( "  packets sent      : ".. _pkt_sent .." (".. string.format( "%5.3f", _pkt_sent_persec ) .." per sec)  ".. #oq.send_q .." q'd" ) ;
  print( "  packets recv      : ".. _pkt_recv .." (".. string.format( "%5.3f", _pkt_recv_persec ) .." per sec)" ) ;
  print( "  packets processed : ".. _pkt_processed .." (".. string.format( "%5.3f", _pkt_processed_persec ) .." per sec)" ) ;
  print( "---" ) ;
end

function oq.show_member(m)
  print( "-- [".. tostring(m.name) .."][".. tostring(m.realm) .."]" ) ;
end

function oq.in_btag_cache( tag )
  if (OQ_data.btag_cache == nil) then
    OQ_data.btag_cache = {} ;
    return nil ;
  end
  if (tag == nil) or (OQ_data.btag_cache[ tag ] == nil) then
    return nil ;
  end
  return true ;
end

function oq.show_adds()
  local ntotal, nonline = BNGetNumFriends() ;
  local cnt = 0 ;
  print( "---  OQ added friends" ) ;
  for friendId=1,ntotal do
    local f = { BNGetFriendInfo( friendId ) } ;
    local presenceID = f[1] ;
    local givenName  = f[2] ;
    local btag       = f[3] ;
    local client     = f[7] ;
    local online     = f[8] ;
    local noteText   = f[13] ;
    if (noteText ~= nil) and ((noteText:find( "OQ," ) == 1) or (noteText:find( "REMOVE OQ" ) == 1)) then
      print( presenceID ..".  ".. givenName .." ".. btag .."   [".. noteText .."]" ) ;
      cnt = cnt + 1 ;
    elseif ((noteText == nil) or (noteText == "")) and oq.in_btag_cache( tag ) then
      print( presenceID ..".  ".. givenName .." ".. btag .."   [".. noteText .."]" ) ;
      cnt = cnt + 1 ;
    end
  end  
  print( "---  total :  ".. cnt ) ;
end

function oq.show_bn_enabled() 
  local cnt = 0 ;

  oq.bn_force_verify() ;
  print( "--[ OQ enabled ]--" ) ;
  for i,v in pairs(OQ_data.bn_friends) do
    if (v.isOnline and (v.oq_enabled or v.sk_enabled)) then
      print( tostring(v.presenceID) ..".  ".. tostring(v.toonName) .."-".. tostring(v.realm) ) ;
      cnt = cnt + 1 ;
    end
  end
  print( cnt .." bn friends OQ enabled" ) ;
  print( tostring( oq.n_channel_members( "OQgeneral" ) ) .." OQ enabled locals" ) ;
  
  oq.n_connections() ;  
end

function oq.raid_init()
  oq.raid = {} ;
  oq.raid.group = {} ;
  for i = 1,8 do
    oq.raid.group[i] = {} ;
    oq.raid.group[i].member = {} ;
    for j=1,5 do
      oq.raid.group[i].member[j] = {} ;
      oq.raid.group[i].member[j].flags = 0 ;
      oq.raid.group[i].member[j].bg = {} ;
      oq.raid.group[i].member[j].bg[1] = {} ;
      oq.raid.group[i].member[j].bg[2] = {} ;
    end
  end
  oq.raid.raid_token = nil ;
  oq.raid.type = OQ.TYPE_BG ;
  oq.waitlist  = {} ;
  oq.pending   = {} ;
  my_group     = 0 ;
  my_slot      = 0 ;
  
  oq.procs_no_raid() ;
end

function oq.channel_isregistered( chan_name )
  local n = strlower( chan_name ) ;
  return (oq.channels[ n ]) ;
end

function oq.buildChannelList(...)
   local tbl = {}
   for i = 1, select("#", ...), 2 do
      local id, name = select(i, ...)
      tbl[id] = strlower(name)
   end
   return tbl
end

function oq.channel_join( chan_name, pword )
  local n = strlower( chan_name ) ;

  JoinTemporaryChannel( n, pword ) ;
  local id, chname = GetChannelName( n ) ;

  oq.channels[ n ]       = {} ;
  oq.channels[ n ].id    = id ;
  oq.channels[ n ].pword = pword ;
end

function oq.hook_roster_update(chan_name)
  local n = strlower( chan_name ) ;
  local nchannels = GetNumDisplayChannels() ;
  for i=1,nchannels do
    local name, header, collapsed, channelNumber, count, active, category, 
          voiceEnabled, voiceActive = GetChannelDisplayInfo(i) ;
    if (name ~= nil) and (strlower(name) == n) then
      _oqgeneral_id = i ;
      SetSelectedDisplayChannel( _oqgeneral_id ) ;
      return true ;
    end
  end
end

function oq.n_channel_members( chan_name )
  local n = strlower( chan_name ) ;  
  local nchannels = GetNumDisplayChannels() ;
  for i=1,nchannels do
    local name, header, collapsed, channelNumber, count, active, category, voiceEnabled, voiceActive = GetChannelDisplayInfo(i) ;
      
    if (name ~= nil) and (n == strlower(name)) then
      return count or 0 ;
    end
  end
  return 0 ;
end

function oq.channel_leave( chan_name )
  local n = strlower( chan_name ) ;
  LeaveChannelByName( n ) ;
  oq.channels[ n ] = nil ;
end

function oq.log_clear() 
  OQ_data.log = {} ;
  OQ_data.log.enabled = nil ;
  OQ_data.log.n       = 0 ;
  OQ_data.log.deep    = nil ;
  OQ_data.log.msg     = {} ;
end

function oq.log_debug( msg_ )
  local log = OQ_data.log ;
  
  if (log.enabled and (log.deep ~= nil)) then
    local now = GetTime() ;
    log.n = log.n + 1 ;
    log.msg[ log.n ] = { msg = msg_, tm = now } ;
  end
end

function oq.log_deep()
  if (OQ_data.log == nil) then
    OQ_data.log = {} ;
  end
  OQ_data.log.deep = true ;
  oq.log_start() ;  
end

function oq.log_msg( method_, msg_ )
  local log = OQ_data.log ;
  
  if (not log.enabled) then
    return ;
  end
  
  local now = GetTime() ;
  log.n = log.n + 1 ;
  log.msg[ log.n ] = { d="sent", method = method_, msg = msg_, tm = now } ;
end

function oq.log_recv( method_, from_, msg_ )
  local log = OQ_data.log ;
  
  if (not log.enabled) then
    return ;
  end
  
  local now = GetTime() ;
  log.n = log.n + 1 ;
  log.msg[ log.n ] = { d="recv", method = method_, from = from_, msg = msg_, tm = now } ;
end

function oq.log_start()
  if (OQ_data.log == nil) then
    OQ_data.log = {} ;
  end
  OQ_data.log.enabled = true ;
end

function oq.log_stop()
  if (OQ_data.log == nil) then
    OQ_data.log = {} ;
  end
  OQ_data.log.enabled = nil ;
  OQ_data.log.deep    = nil ;
end

function oq.channel_say( chan_name, msg )
  local n = strlower( chan_name ) ;
  if ((n ~= nil) and (oq.channels[n] ~= nil)) then
    SendChatMessage( msg, "CHANNEL", nil, oq.channels[ n ].id ) ;
    _pkt_sent = _pkt_sent + 1 ;
  end
end

function oq.channel_general( msg ) 
  oq.channel_say( "OQGeneral", msg ) ;
end

function oq.iam_in_a_party()
  if (GetNumGroupMembers() > 0) then
    return true ;
  end
  return nil ;
end

function oq.BNSendFriendInvite( id, msg, note )
  if (id == nil) or (id == player_realid) then
    return ;
  end
  if (msg ~= nil) and (#msg > 127) then
    msg = msg:sub(1,127) ;
  end
  BNSendFriendInvite( id, msg ) ;
  oq.cache_btag( id, note ) ;
  _pkt_sent = _pkt_sent + 1 ;
end

function oq.SendAddonMessage( channel, msg, type, to_name )
  if (msg == nil) then
    return ;
  end
  if (#msg > 254) then
    msg = msg:sub(1,254) ;
  end
  if (type == "PARTY") and ((oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID)) then
    oq.BNSendQ_push( SendAddonMessage, channel, msg, "RAID", nil ) ;
  else
    if (string.find(msg, ",premade,") == nil) then
      oq.BNSendQ_push( SendAddonMessage, channel, msg, type, to_name ) ;
    end
  end  
end

function oq.channel_party( msg ) 
  if (msg == nil) then
    return ;
  end
  if (oq.iam_in_a_party()) then
    oq.SendAddonMessage( "OQ", msg, "PARTY" ) ;
  end
end

--------------------------------------------------------------------------
--  communications
--------------------------------------------------------------------------
--[[
    http://www.wowpedia.org/API_GetCombatRating
    
    CR_WEAPON_SKILL = 1;
    CR_DEFENSE_SKILL = 2;
    CR_DODGE = 3;
    CR_PARRY = 4;
    CR_BLOCK = 5;
    CR_HIT_MELEE = 6;
    CR_HIT_RANGED = 7;
    CR_HIT_SPELL = 8;
    CR_CRIT_MELEE = 9;
    CR_CRIT_RANGED = 10;
    CR_CRIT_SPELL = 11;
    CR_HIT_TAKEN_MELEE = 12;
    CR_HIT_TAKEN_RANGED = 13;
    CR_HIT_TAKEN_SPELL = 14;
    COMBAT_RATING_RESILIENCE_CRIT_TAKEN = 15;
    COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN = 16;
    CR_CRIT_TAKEN_SPELL = 17;
    CR_HASTE_MELEE = 18;
    CR_HASTE_RANGED = 19;
    CR_HASTE_SPELL = 20;
    CR_WEAPON_SKILL_MAINHAND = 21;
    CR_WEAPON_SKILL_OFFHAND = 22;
    CR_WEAPON_SKILL_RANGED = 23;
    CR_EXPERTISE = 24;
    CR_ARMOR_PENETRATION = 25;
    CR_MASTERY = 26; 
    CR_PVP_POWER = 27; 
]]
function oq.get_pvppower()
  return (GetCombatRating(27) or 0) ;
end

function oq.on_player_mmr_change()
  oq.get_mmr() ;
end

function oq.get_mmr()
  local m = GetPersonalRatedBGInfo() ;
  return m or 0 ;
end

function oq.get_resil()
  return (GetCombatRating(16) or 0) ;
end

function oq.debug_report( ... )
  if (_debug) then
    print( ... ) ;
    oq.log_debug( ... ) ;
  end
end

function oq.get_ilevel()
  return floor( select( 2, GetAverageItemLevel() )) ;
end

function oq.iam_party_leader() 
  if (oq.iam_in_a_party()) then
    return ((my_group ~= 0) and (my_slot == 1)) ;
  else
    return (my_slot == 1) ;
  end
end

function oq.iam_raid_leader() 
  return ((oq.raid.leader ~= nil) and (player_name == oq.raid.leader)) ;
end

function oq.is_raid()
  if (oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID) then
    return true ;
  end
  return nil ;
end

function oq.find_bgroup( realm )
  for bgroup,realms in pairs(OQ.BGROUPS) do
    for i,r in pairs(realms) do
      if (realm == r) then
        return bgroup ;
      end
    end
  end
  return nil ;
end

function oq.is_in_raid( name )
  for i,grp in pairs(oq.raid.group) do
    for j,mem in pairs(grp.member) do
      local n = mem.name ;
      if ((n ~= nil) and (n ~= "") and (n ~= "-")) then
        if ((mem.realm ~= nil) and (mem.realm ~= player_realm)) then
          n = n .."-".. mem.realm ;
        end
        if (name == n) then
          return true ;
        end
      end
    end
  end
  return nil ;
end

function oq.mark_currency()
  -- clear the wallet
  player_wallet = {} ;
  -- mark currency
  local n = GetCurrencyListSize() ;
  for index = 1,n do
     local name, isHeader, isExpanded, isUnused, isWatched, count, 
           extraCurrencyType, icon, itemID = GetCurrencyListInfo(index) ;
     if (name ~= nil) then
       player_wallet[ name ] = count ;
     end
  end
  -- mark rep
  for factionIndex = 1, GetNumFactions() do
    name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
    canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex)
    if (name ~= nil) then
      player_wallet[ name ] = earnedValue ;
    end
  end
  -- mark xp
  player_wallet[ "xp"    ] = UnitXP   ("player") or 0 ;
  player_wallet[ "maxxp" ] = UnitXPMax("player") or 0 ;
  
  -- mark hks  
  player_wallet[ "hks"   ] = GetStatistic(588) or 0 ;
end

function oq.check_currency()
  -- precaution
  if (OQ_data.stats.bg_length == nil) or (OQ_data.stats.bg_length == 0) then
    -- invalidates the rate calculation, but keeps it sane(ish)
    OQ_data.stats.bg_length = 1 ;
  end
  
  -- check for gains in currency
  local n = GetCurrencyListSize() ;
  for index = 1,n do
     local name, isHeader, isExpanded, isUnused, isWatched, count, 
           extraCurrencyType, icon, itemID = GetCurrencyListInfo(index) ;
     if (name ~= nil) and (player_wallet[ name ] ~= nil) then
       if (player_wallet[ name ] ~= count) then
         local delta = count - player_wallet[name] ;
         local rate = floor( (delta / OQ_data.stats.bg_length) * 60 * 60 ) ; -- bg_length is seconds * 60*60 --> delta/hr
         if (delta > 0) then
           if (name == OQ.HONOR_PTS) and (count == OQ_MAX_HONOR) then -- honor capped
             print( name .."  ".. OQ_LILREDX_ICON .." ".. OQ.CAPPED .." ".. OQ_REDX_ICON ) ;
           elseif (name == OQ.HONOR_PTS) and (count >= OQ_MAX_HONOR_WARNING) then -- approaching honor capped
             print( "gained ".. delta .." ".. name .."  (".. rate .." per hour)  ".. OQ_LILREDX_ICON .." ".. OQ.APPROACHING_CAP .." ".. OQ_LILREDX_ICON ) ;
           else
             print( "gained ".. delta .." ".. name .."  (".. rate .." per hour)" ) ;
           end
         elseif (delta < 0) then
           print( "lost ".. delta .." ".. name .."  (".. rate .." per hour)" ) ;
         end
       elseif (player_wallet[ name ] == count) and (name == OQ.HONOR_PTS) and (count == OQ_MAX_HONOR) then
         print( name .."  ".. OQ_LILREDX_ICON .." ".. OQ.CAPPED .." ".. OQ_LILREDX_ICON ) ;
       end
     end
  end
  
  -- check for gains in reputation
  for factionIndex = 1, GetNumFactions() do
    local name, description, standingId, bottomValue, topValue, count, atWarWith,
          canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex)
    if (name ~= nil) and (player_wallet[ name ] ~= nil) then
      local delta = count - player_wallet[name] ;
      local rate = floor( (delta / OQ_data.stats.bg_length) * 60 * 60 ) ; -- bg_length is seconds * 60*60 --> delta/hr
      if (delta > 0) then
        print( "gained ".. delta .." with ".. name .."  (".. rate .." per hour)" ) ;
      elseif (delta < 0) then
        print( "lost ".. delta .." with ".. name .."  (".. rate .." per hour)" ) ;
      end
    end
  end
  
  -- check for gains in xp
  local xp = UnitXP("player") ;
  local maxxp = UnitXPMax("player") ;
  local delta = 0 ;
  if (maxxp ~= player_wallet[ "maxxp" ]) then
    -- gained level
    -- note: won't handle gaining more then one level per bg.  not sure that's even possible
    delta = (player_wallet[ "maxxp" ] - player_wallet[ "xp" ]) + xp ;
  elseif (xp ~= player_wallet[ "xp" ]) then
    delta = xp - player_wallet[ "xp" ] ;
  end
  if (delta > 0) then
    -- report gained xp
    local rate = floor( (delta / OQ_data.stats.bg_length) * 60 * 60 ) ; -- bg_length is seconds * 60*60 --> delta/hr
    print( "gained ".. delta .." XP  (".. rate .." per hour)" ) ;
  end
  
  -- check for gains in hks
  local hks = GetStatistic(588) ;
  delta = hks - player_wallet[ "hks" ] ;
  if (delta > 0) then
    -- report gained hks
    local rate = floor( (delta / OQ_data.stats.bg_length) * 60 * 60 ) ; -- bg_length is seconds * 60*60 --> delta/hr
    print( "gained ".. delta .." HKs  (".. rate .." per hour)" ) ;
  end

  oq.report_rage() ;
  
  if (oq.iam_party_leader()) then
    oq.timer_oneshot( 15, oq.force_stats ) ; -- force stats to refresh 15 seconds after coming out
  else
    oq.timer_oneshot( 10, oq.force_stats ) ; -- force stats to refresh 10 seconds after coming out
  end
  
  if (_last_report ~= nil) then
    oq.submit_report( _last_report, _last_tops, _last_bg, _last_crc, OQ_data.stats.bg_end ) ;
  end
end

function oq.flag_watcher()
  if (not _inside_bg) or (_winner ~= nil) then
    return ;
  end
  local now = utc_time() ;
  if (now < _next_flag_check) then
    return ;
  end
  _next_flag_check = now + 4 ; -- minimal
  
  local p_faction = 0 ; -- 0 == horde, 1 == alliance, -1 == offline
  if (player_faction == "A") then
    p_faction = 1 ;
  end
  if (_flags == nil) then
    _flags = {} ;
  end
  if (_enemy == nil) then
    _enemy = {} ;
  end
  if (WorldStateScoreFrame:IsVisible()) then
    return ;
  end
  -- clear faction
  SetBattlefieldScoreFaction( nil ) ;
  
  local nplayers = GetNumBattlefieldScores() ;
  
  if (nplayers == 0) then
    -- not inside or the call failed
    return ;
  end
  for i=1, nplayers do
    local name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class = GetBattlefieldScore(i);
    if (name) and (faction) and (faction == p_faction) then
      local nstats = GetNumBattlefieldStats() ;
      if (_flags[name] == nil) then
        _flags[name] = {} ;
      end
      for statndx = 1,nstats do
        local stat = GetBattlefieldStatData(i, statndx);
        if (_flags[name][statndx] == nil) then
          _flags[name][statndx] = 0 ;
        end
        if (_flags[name][statndx] ~= stat) then
          local stat_name = GetBattlefieldStatInfo( statndx ) ;
          local str = stat_name ..":  ".. name ;
          if (OQ.BG_STAT_COLUMN[ stat_name ] ~= nil) then
            str = OQ.BG_STAT_COLUMN[stat_name] ..":  ".. name ;
          end
          -- don't print to bg-chat... too spammy.  
          -- dump for each OQ player to see
          --
          if (OQ_toon.shout_caps == 1) then
            print( OQ_DIAMOND_ICON .." ".. str ) ;
          end
        end
        _flags[name][statndx] = stat ;
      end
    elseif (name) and (faction) and (faction ~= p_faction) then
      if (_enemy[name] == nil) then
        _enemy[name] = { appearance = now } ;
     end
      _enemy[name].last_seen = now ; -- always updating, last time seen ~= now... player left
      _enemy[name].strike    = 0 ;
    end
  end
  
  -- report rage-quitters
  if (OQ_data.stats.tears == nil) then
    OQ_data.stats.tears = 0 ;
  end
  if (OQ_data.stats.total_tears == nil) then
    OQ_data.stats.total_tears = 0 ;
  end
  if (nplayers >= 10) then -- just incase the GetBattlefieldScore was wonky
    for i,e in pairs(_enemy) do
      if (e.last_seen ~= nil) then
        if (e.last_seen ~= now) and (e.reported == nil) then
          if (e.strike >= 1) then
            -- don't report until the 2nd strike.  the scorecard can be flaky
            e.reported = true ;
            e.ragequit = true ;
            _nrage = _nrage + 1 ;
            OQ_data.stats.tears = OQ_data.stats.tears + 1 ;
            OQ_data.stats.total_tears = OQ_data.stats.total_tears + 1 ;

            if (OQ_toon.shout_ragequits == 1) then
              local diff = e.last_seen - e.appearance ;
              local min = floor((diff)/60) ;
              local sec = diff % 60 ;
              print( OQ_STAR_ICON .."".. string.format( OQ.RAGEQUITSOFAR, i, min, sec, _nrage or 0 ) ) ;
              -- play sound
              if ((now - last_runaway) > OQ_MIN_RUNAWAY_TM) then
                last_runaway = now ;
                PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav") ;
              end
            end
          else
            e.strike = e.strike + 1 ;
          end
        end
      end
    end
  end
end

function oq.entering_bg() 
  _inside_bg    = true ;
  _lucky_charms = nil ;
  _winner       = nil ;
  _nrage        = 0 ;
  _nkbs         = 0 ;
  _last_lust    = nil ;
  _last_report  = nil ;
  _last_bg      = nil ;
  _last_crc     = nil ;
  _bg_zone      = nil ;
  _bg_shortname = nil ;
  
  oq.get_zone_info() ;
  
  UnitSetRole( "player", OQ.ROLES[ player_role ] ) ;
  oq.mark_currency() ;

  oq.timer( "flag_watcher" ,  5, RequestBattlefieldScoreData, true ) ; -- requesting score info
  
  local s = oq.init_stats_data() ;
  
  s.bg_start = utc_time() ;
  s.bg_end   = 0 ;
  _winner    = nil ;

  if (not oq.iam_raid_leader()) then
    return ;
  end
  -- calc average downtime between games (seconds)
  if (s.down_tm == nil) then
    s.down_tm = 0 ;
  end
  if (s.nGames > 1) then
    local  wait_tm = utc_time() - s.bg_end ;  -- seconds
    if (wait_tm < (30*60)) then
      local  down_total = (s.down_tm * (s.nGames - 1)) ;
      s.down_tm = floor((down_total + wait_tm) / s.nGames) ;
    end
  end
  
  oq.timer( "bg_spy_report", 30, oq.battleground_spy ) ;
  
  -- send one last message before entering
  oq.send_my_premade_info() ;
end

function oq.game_ended()
  _winner = GetBattlefieldWinner() ;
  oq.calc_game_stats() ;
  oq.announce_nquitters() ;
  oq.calc_player_stats() ;
  
  -- for test, report on all players... otherwise only premade leader
  oq.calc_game_report() ;
end

function oq.leaving_bg()
  _inside_bg    = nil ;
  _lucky_charms = nil ;

  oq.raid._last_lag = utc_time() + 60 ; -- give them some time to leave the BG 
  
  -- post game clean up
  oq.gather_my_stats() ;

  -- reset queue status
  for i=1,8 do
    for j=1,5 do
      local m = oq.raid.group[ i ].member[ j ] ;
      m.check = OQ_FLAG_CLEAR ;
      m.bg[1].status = "0" ;
      m.bg[2].status = "0" ;
    end
    oq.tab1_group[i].status[1]:SetText( "-" ) ;
    oq.tab1_group[i].dtime [1]:SetText( "" ) ; 
    oq.tab1_group[i].status[2]:SetText( "-" ) ;
    oq.tab1_group[i].dtime [2]:SetText( "" ) ; 
  end
  
  -- reset ping timers
  if (oq.iam_raid_leader()) then
    for i=2,8 do
      oq.raid.group[i]._last_ping = nil ;
    end
  end
  
  if (oq.iam_raid_leader()) then
    local now = utc_time() ;
    local raid = oq.premades[ oq.raid.raid_token ] ;
    raid.last_seen   = now ;
    raid.next_advert = now + (OQ_SEC_BETWEEN_PROMO / 2) ;
  end
  oq.timer_oneshot(  5, oq.check_currency ) ;
  oq.timer( "flag_watcher" ,  5, nil ) ;
  
  _flags = nil ; -- clearing out score flags
  _enemy = nil ;
  
  -- update my slot
  if (my_group > 0) and (my_slot > 0) then
    oq.set_textures( my_group, my_slot ) ;
  end
end

function oq.game_in_process()
  oq.pass_bg_leader() ;
end

function oq.get_spec()
  local class = select(1, UnitClass("player")) ;
  local primaryTalentTree = GetSpecialization() ;
  local spec = nil ;
  if (primaryTalentTree) then
    local id, name, description, icon, background, role = GetSpecializationInfo(primaryTalentTree) ;
    spec = name ;
  end
  return class, spec ;
end

function oq.get_role()
   local class, spec = oq.get_spec() ;
   if (spec == nil) then
     return "None" ;
   end
   return OQ.BG_ROLES[ class ][ spec ] ;
end

function oq.auto_set_role()
  if (OQ_toon.auto_role == 0) then
    return ;
  end
  
  local role = oq.get_role() ;
  local role_id = 1 ;
  -- 1  dps
  -- 2  healer
  -- 3  none 
  -- 4  tank
  if (role == "Healer") then
    role_id = 2 ;
  elseif (role == "Tank") then
    role_id = 4 ;
  end
  if (role_id ~= player_role) then
    player_role = role_id ;
    -- insure UI update
    oq.set_role( my_group, my_slot, player_role ) ;
  end
  UnitSetRole( "player", OQ.ROLES[ player_role ] ) ;
end

function oq.battleground_spy( opt )
  if (opt == "on") then
    OQ_data.announce_spy = 1 ;
  elseif (opt == "off") then
    OQ_data.announce_spy = 0 ;
  end
  if (OQ_data.announce_spy == 0) then
    return ;
  end
  SetBattlefieldScoreFaction( nil ) ;
  
  local numScores = GetNumBattlefieldScores()
  local numHorde = 0
  local numAlliance = 0
  local f = {} ;
  local p_faction = 0 ; -- 0 == horde, 1 == alliance, -1 == offline
  local e_faction = 1 ;
  if (player_faction == "A") then
    p_faction = 1 ;
    e_faction = 0 ;
  end
  f[0] = { num = 0, roles = {}, stealthies = 0 } ; -- horde
  f[1] = { num = 0, roles = {}, stealthies = 0 } ; -- alliance
  
  for i=1, numScores do
    local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, 
          healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec = GetBattlefieldScore(i) ;
    if ( faction ) and (OQ.BG_ROLES[ class ] ~= nil) and (OQ.BG_ROLES[ class ][ talentSpec ] ~= nil) then
      f[ faction ].num = f[ faction ].num + 1 ;
      if (class == "Druid") or (class == "Rogue") then
        f[ faction ].stealthies = f[ faction ].stealthies + 1 ;
      end
      local role = OQ.BG_ROLES[ class ][ talentSpec ] ;
      if (role ~= nil) then
        if (f[ faction ].roles[ role ] == nil) then
          f[ faction ].roles[ role ] = 1 ;
        else
          f[ faction ].roles[ role ] = f[ faction ].roles[ role ] + 1 ;
        end
      end
    end
  end  
  str = "OQ BG-Spy:" ;
  if (f[ e_faction ].roles[ "Healer" ]) then
    str = str .."  ".. f[ e_faction ].roles[ "Healer" ] .." Healers." ;
  end
  if (f[ e_faction ].roles[ "Tank" ]) then
    str = str .."  ".. f[ e_faction ].roles[ "Tank" ] .." Tanks." ;
  end
  if (f[ e_faction ].roles[ "Melee" ]) then
    str = str .."  ".. f[ e_faction ].roles[ "Melee" ] .." Melee." ;
  end
  if (f[ e_faction ].roles[ "Ranged" ]) then
    str = str .."  ".. f[ e_faction ].roles[ "Ranged" ] .." Ranged." ;
  end
  if (f[ e_faction ].roles[ "Knockback" ]) then
    str = str .."  ".. f[ e_faction ].roles[ "Knockback" ] .." Knockback." ;
  end
  if (f[ e_faction ].stealthies > 0) then
    str = str .."  ".. f[ e_faction ].stealthies .." Stealthies." ;
  end
  if (oq.iam_raid_leader() and _inside_bg) then
    SendChatMessage( str, "INSTANCE_CHAT", nil ) ;
  elseif (_inside_bg) then
    print( str ) ;
  else
    print( "OQ BG-Spy:  You are not in a battleground" ) ;
  end
end

local pps_last = 0 ;
local pps_last_recv = 0 ;
local pps_last_processed = 0 ;
local pps_last_sent = 0 ;

function oq.calc_pkt_stats()
  local now = GetTime() ;
  if (pps_last ~= 0) then
    local dRecv = _pkt_recv - pps_last_recv ;
    local dProc = _pkt_processed - pps_last_processed ;
    local dSent = _pkt_sent - pps_last_sent ;
    local dTime = now - pps_last ;
    _pkt_sent_persec = floor( (dSent / dTime) * 1000 ) / 1000 ;
    _pkt_recv_persec = floor( (dRecv / dTime) * 1000 ) / 1000 ;
    _pkt_processed_persec = floor( (dProc / dTime) * 1000 ) / 1000 ;

    -- update ui
    oq.tab5_oq_pktrecv     :SetText( string.format( "%7.2f", _pkt_recv_persec ) ) ;
    oq.tab5_oq_pktprocessed:SetText( string.format( "%7.2f", _pkt_processed_persec ) ) ;
    oq.tab5_oq_pktsent     :SetText( string.format( "%7.2f", _pkt_sent_persec ) ) ;
  end
  
  pps_last      = now ;
  pps_last_recv = _pkt_recv ;
  pps_last_sent = _pkt_sent ;
  pps_last_processed = _pkt_processed ;
  
  oq.populate_dtime() ;
end

function oq.check_bg_status()
  local instance, instanceType = IsInInstance() ;
  if (instance and (instanceType == "pvp")) then
    if (not _inside_bg) then
      -- transition
      oq.entering_bg() ;
    end
  elseif (not instance and _inside_bg) then
    oq.leaving_bg() ;
  end
  
  oq.group_lead_bookkeeping() ;
  
  -- if ui close, make sure flag is set (for display and redisplaying map)
  if (not oq.ui:IsVisible()) then
    _ui_open = nil ;
  end
end

function oq.on_world_map_change()
  -- check map
  if (not _map_open) and (WorldMapFrame:IsVisible()) then
    _map_open = true ;
  elseif _map_open and not WorldMapFrame:IsVisible() then
    _map_open = nil ;
    -- map closing ... open the UI if it was open
    if (_ui_open) then
      oq.ui:Show() ;
    end
  end
end

function oq.report_premades()
  if (OQ_data.show_premade_ads == 0) then
    return ;
  end
  _announcePremades = true ;
  local npremades = #oq.tab2_raids ;
  if (npremades == 0) then
    return ;
  end
  print( OQ_DIAMOND_ICON .."  ".. string.format( OQ.ANNOUNCE_PREMADES, npremades )) ;
end

function oq.announce_new_premade( name, name_change, raid_token )
  if (OQ_data.show_premade_ads == 0) then
    return ;
  end
  if (not _announcePremades) then
    return ;
  end

  -- don't announce if interested in qualified or certain premade types
  if (raid_token ~= nil) then
    if (oq.premade_filter_qualified == 1) and (not oq.qualified(raid_token)) then
      return ;
    end
    local p = oq.premades[ raid_token ] ;
    if (oq.premade_filter_type ~= OQ.TYPE_NONE) and (p.type ~= oq.premade_filter_type) then
      return ;
    end
    if (p.type == OQ.TYPE_ARENA) and (p.leader_realm ~= player_realm) then
      return ;
    end
  end  
  
  local hlink = "|Hoqueue:".. tostring(raid_token) .."|h".. OQ_DIAMOND_ICON ;
  local premade = oq.premades[ raid_token ] ;

  if (premade == nil) then
    return ;
  end
  
  local nShown, nPremades = oq.n_premades() ;
  if (name_change) then
    print( hlink .."  ".. string.format( OQ.PREMADE_NAMEUPD, nShown, premade.leader, name, premade.bgs ) .."|h " ) ;
  else
    print( hlink .."  ".. string.format( OQ.NEW_PREMADE, nShown, premade.leader, name, premade.bgs ) .."|h " ) ;
  end
end

function oq.announce_nquitters()
  if (OQ_toon.shout_ragequits == 1) and (_enemy ~= nil) then
    local cnt = 0 ;
    for i,e in pairs(_enemy) do
      if (e.ragequit ~= nil) then
        cnt = cnt + 1 ;
      end
    end
    if (cnt > 0) then
      local min = floor((OQ_data.stats.bg_length)/60) ;
      local sec = OQ_data.stats.bg_length % 60 ;
      print( OQ_STAR_ICON .." ".. string.format( OQ.RAGEQUITTERS, cnt, min, sec ) ) ;
    end
  end
end

function oq.calc_player_stats()
  if ((my_group == 0) or (my_slot == 0) or (IsRatedBattleground() == true)) then
    return ;
  end

  -- function to hold player stat info
  -- bg name, time of start, hks, dmg, heals, kbs
  -- other player names and their stats
  local winner = GetBattlefieldWinner() ;
  local p_faction = 0 ; -- horde
  if (player_faction == "A") then
    p_faction = 1 ;
  end
  if (winner) then
    if (winner == p_faction) then
      OQ_toon.wins = (OQ_toon.wins or 0) + 1 ;
    elseif (winner ~= 255) then
      OQ_toon.losses = (OQ_toon.losses or 0) + 1 ;
    end
  end
end

function oq.calc_game_stats()
  if (IsRatedBattleground() == true) then
    -- rated BGs shouldn't impact stats
    return ;
  end
  local  s = OQ_data.stats ;
  local  total_tm     = s.nGames * oq.numeric_sanity(s.avg_bg_len) ;
  local  total_hks    = s.nGames * oq.numeric_sanity(s.avg_hks) ;
  local  total_honor  = s.nGames * oq.numeric_sanity(s.avg_honor)  ;
  local  total_deaths = s.nGames * oq.numeric_sanity(s.avg_deaths)  ;
  
  s.bg_end   = utc_time() ;
  s.bg_length = s.bg_end - s.bg_start ;
  
  if (s.bg_start == 0) or ((s.bg_end - s.bg_start) > OQ_REALISTIC_MAX_GAMELEN) then
    -- game never started.  clean up data and leave
    s.bg_start = 0 ;
    s.bg_end   = 0 ;
    return ;
  end

  if (not oq.iam_raid_leader()) then
    return ;
  end
  
  s.nGames   = oq.numeric_sanity(s.nGames) + 1 ;
  
  -- calc average game length (seconds)
  s.avg_bg_len  = floor((total_tm + (s.bg_end - s.bg_start)) / s.nGames) ; 
  
  -- clear faction
  SetBattlefieldScoreFaction( nil ) ;
  -- get game stats 
  local numScores    = GetNumBattlefieldScores() ;
  local bg_winner    = GetBattlefieldWinner() ;
  local nMembers     = 0 ;
  local hks          = 0 ;
  local honor        = 0 ;
  local deaths       = 0 ;
  for i=1, numScores do
    name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class, filename, damageDone, healingDone = GetBattlefieldScore(i);
    if (faction and (faction == 0)) then
      faction = "H" ;
    elseif (faction) then
      faction = "A" ;
    end
    if (faction and (faction == player_faction)) then
      if (oq.is_in_raid( name )) then
        nMembers = nMembers + 1 ;
        hks      = hks      + honorableKills ;
        honor    = honor    + honorGained ;
        deaths   = deaths   + deaths ;
      end
    end
  end  
  
  s.avg_hks    = floor( (total_hks    + (hks    / nMembers)) / s.nGames ) ;
  s.avg_honor  = floor( (total_honor  + (honor  / nMembers)) / s.nGames ) ;
  s.avg_deaths = floor( (total_deaths + (deaths / nMembers)) / s.nGames ) ;
  
  -- get winner   
  if (bg_winner) then
    if (bg_winner == 0) then
      bg_winner = "H" ;
    elseif (bg_winner ~= 255) then
      bg_winner = "A" ;
    end
  end
  if (bg_winner and (bg_winner == player_faction)) then
    s.nWins = s.nWins + 1 ;
  elseif (bg_winner) then
    s.nLosses = s.nLosses + 1 ;
  end
end

function oq.calc_game_report()
  -- go through the in-game scorecard
  -- clear faction
  SetBattlefieldScoreFaction( nil ) ;
  local numScores    = GetNumBattlefieldScores() ;
  local bg_winner    = GetBattlefieldWinner() ;
  local scores       = {} ;
  local tops         = { ["H"] = { heals = { n = 0 }, dps = { n = 0 } },
                         ["A"] = { heals = { n = 0 }, dps = { n = 0 } },
                       } ;
  for i=1, numScores do
--    local name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class, filename, damageDone, healingDone = GetBattlefieldScore(i);
    local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, 
          classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, 
          mmrChange, talentSpec = GetBattlefieldScore(i) ;
          
    if (faction and (faction == 0)) then
      faction = "H" ;
    elseif (faction) then
      faction = "A" ;
    end
    local n = name ;
    if (n:find("-") == nil) then
      n = n .."-".. player_realm ;
    end
    scores[n] = { fact = faction, dmg = damageDone, heal = healingDone } ;
    local realm ;
    name, realm = oq.crack_name( n ) ;
    if (tops[faction].heals.n < healingDone) then
      tops[faction].heals.n     = healingDone ;
      tops[faction].heals.name  = name ;
      tops[faction].heals.realm = realm ;
      tops[faction].heals.class = class ;
      tops[faction].heals.rank  = rank ;
    end
    if (tops[faction].dps.n < damageDone) then
      tops[faction].dps.n     = damageDone ;
      tops[faction].dps.name  = name ;
      tops[faction].dps.realm = realm ;
      tops[faction].dps.class = class ;
      tops[faction].dps.rank  = rank ;
    end
  end  
  -- get winner   
  if (bg_winner and (bg_winner == 0)) then
    bg_winner = "H" ;
  elseif (bg_winner) then
    bg_winner = "A" ;
  end
  
  oq.report_score( bg_winner, scores, tops ) ;
end

function oq.pairsByKeys(t, f)
  if (t == nil) then
    return nil ;
  end
   local a = {}
   for n in pairs(t) do table.insert(a, n) end
   table.sort(a, f)
   local i = 0      -- iterator variable
   local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
   end
   return iter
end

function oq.send_report( report, submit_token, tm )
  if (player_realid == nil) then
    oq.get_battle_tag() ;
    if (player_realid == nil) then
      return ;
    end
  end
  if (player_realm == nil) then
    player_realm = oq.GetRealmName() ;
  end
  
  local msg = OQSK_HEADER ..",".. 
              OQSK_VER ..","..
              "W1,"..
              "bg_report,"..
              report ..","..
              tostring(player_name) ..",".. 
              tostring(oq.realm_cooked(player_realm)) ..",".. 
              tostring(player_faction) ..",".. 
              tostring(player_realid) ..","..
              submit_token ..","..
              oq.encode_mime64_2digit(_nrage or 0 ) ;
  oq.send_to_scorekeeper( msg ) ;
end

function oq.send_top_dps( tops, submit_token, bg, crc )
  if (tops == nil) then
    return ;
  end
  if (player_realid == nil) then
    oq.get_battle_tag() ;
    if (player_realid == nil) then
      return ;
    end
  end
  if (player_realm == nil) then
    player_realm = oq.GetRealmName() ;
  end
  local msg = OQSK_HEADER ..",".. 
              OQSK_VER ..","..
              "W1,"..
              "bg_top_dps" ;
  msg = msg ..","..
        tostring(player_name) ..",".. 
        tostring(oq.realm_cooked(player_realm)) ..",".. 
        tostring(player_realid) ;

  local f = tops["H"] ;
  local divisor = 1000 ;
  if (player_level < 30) then
    divisor = 1 ;
  end
  msg = msg ..",".. 
        (f.dps.name or "none") .."|"..
        oq.encode_mime64_2digit( OQ.SHORT_BGROUPS[ f.dps.realm or "Aegwynn" ] ) ..""..
        oq.encode_mime64_3digit( floor(f.dps.n / divisor) ) ..""..
        OQ.SHORT_CLASS[ strupper(f.dps.class or "none") ] ;

  f = tops["A"] ;
  msg = msg ..",".. 
        (f.dps.name or "none") .."|"..
        oq.encode_mime64_2digit( OQ.SHORT_BGROUPS[ f.dps.realm or "Aegwynn" ] ) ..""..
        oq.encode_mime64_3digit( floor(f.dps.n / divisor) ) ..""..
        OQ.SHORT_CLASS[ strupper(f.dps.class or "none") ] ;

  msg = msg ..","..
        player_faction ..""..
        oq.encode_mime64_1digit( bg ) .."".. 
        oq.encode_mime64_1digit( oq.get_player_level_id() ) ..""..
        oq.encode_mime64_6digit( tonumber(crc) ) ..",".. 
        submit_token ;

  oq.send_to_scorekeeper( msg ) ;
end

function oq.send_top_heals( tops, submit_token, bg, crc )
  if (tops == nil) then
    return ;
  end
  if (player_realid == nil) then
    oq.get_battle_tag() ;
    if (player_realid == nil) then
      return ;
    end
  end
  if (player_realm == nil) then
    player_realm = oq.GetRealmName() ;
  end
  local msg = OQSK_HEADER ..",".. 
              OQSK_VER ..","..
              "W1,"..
              "bg_top_heals" ;
  msg = msg ..","..
        tostring(player_name) ..",".. 
        tostring(oq.realm_cooked(player_realm)) ..",".. 
        tostring(player_realid) ;

  local f = tops["H"] ;
  local divisor = 1000 ;
  if (player_level < 30) then
    divisor = 1 ;
  end
  msg = msg ..",".. 
        (f.heals.name or "none") .."|"..
        oq.encode_mime64_2digit( OQ.SHORT_BGROUPS[ f.heals.realm or "Aegwynn"] ) ..""..
        oq.encode_mime64_3digit( floor(f.heals.n / divisor) ) ..""..
        OQ.SHORT_CLASS[ strupper(f.heals.class or "none") ] ;

  f = tops["A"] ;
  msg = msg ..",".. 
        (f.heals.name or "none") .."|"..
        oq.encode_mime64_2digit( OQ.SHORT_BGROUPS[ f.heals.realm or "Aegwynn"] ) ..""..
        oq.encode_mime64_3digit( floor(f.heals.n / divisor) ) ..""..
        OQ.SHORT_CLASS[ strupper(f.heals.class or "none") ] ;

  msg = msg ..","..
        player_faction ..""..
        oq.encode_mime64_1digit( bg ) .."".. 
        oq.encode_mime64_1digit( oq.get_player_level_id() ) ..""..
        oq.encode_mime64_6digit( tonumber(crc) ) ..",".. 
        submit_token ;

  oq.send_to_scorekeeper( msg ) ;
end

function oq.cleanup_bnfriends()
  for i,v in pairs(OQ_data.bn_friends) do
    if (v.realm == nil) or (v.realm == "") then
      OQ_data.bn_friends[i] = nil ;
    end
  end
end

function oq.clear_sk_ignore()
  local sk = strlower(OQ.SK_NAME) ;
  if (player_realm ~= OQ.SK_REALM) then
    sk = sk .."-".. strlower(OQ.SK_REALM) ;
  end
  local n = GetNumIgnores() ;
  for i=1,n do
    local ignored = strlower( GetIgnoreName(i) ) ;
    if (sk == ignored) then
      DelIgnore( sk ) ;
      return ;
    end
  end
end

function oq.send_to_scorekeeper( msg )
  oq.clear_sk_ignore() ;
  local pid, online = oq.is_bnfriend(OQ.SK_BTAG) ;
  if (pid ~= 0) then
    if (online) then
      oq.BNSendWhisper( pid, msg, OQ.SK_NAME, OQ.SK_REALM ) ;
      return ;
    else
      -- no way to leave a note... should resend when no reply recv'd
      return ;
    end
  end

  if (player_realm == OQ.SK_REALM) and (player_faction == "H") then
    oq.SendAddonMessage( "OQSK", msg, "WHISPER", OQ.SK_NAME ) ;
    return ;
  end
 
  oq.BNSendFriendInvite( OQ.SK_BTAG, msg ) ;
end

function oq.submit_report( str, tops, bg, crc, bg_end_tm )
  if (str == nil) then
    return ;
  end
  
  local submit_token = "S".. oq.token_gen() ;
  if (OQ_toon.reports == nil) then
    OQ_toon.reports = {} ;
  end
  OQ_toon.reports[submit_token] = { tok = submit_token, last_tm = utc_time(), report = str } ;
  OQ_toon.reports[submit_token].tops = copyTable( tops ) ;
  OQ_toon.reports[submit_token].bg = bg ;
  OQ_toon.reports[submit_token].crc = crc ;
  OQ_toon.reports[submit_token].end_tm = bg_end_tm ;
end

function oq.submit_btag_info()
  local now = utc_time() ;
  if (OQ_data.btag_submittal_tm ~= nil) and (OQ_data.btag_submittal_tm > now) then
    return ;
  end
  local f = oq.submit_btag ;
  if (OQ_data.ok2submit_tag ~= nil) and (OQ_data.ok2submit_tag == 0) then
    f = oq.submit_still_kickin ; -- not submitting for mesh, just saying user still here
  end
  if (f() ~= nil) then
    OQ_data.btag_submittal_tm = now + OQ_BTAG_SUBMIT_INTERVAL ;
  end
end

function oq.timed_submit_report()
  oq.submit_btag_info() ;
  
  if (OQ_toon.reports == nil) then
    return ;
  end
  local now = utc_time() ;
  for i,v in pairs(OQ_toon.reports) do
    if (v.end_tm == nil) or (v.end_tm < oq.scores.start_round_tm) then
      -- this score is old and hasn't been reported for some reason.  
      -- remove it
      OQ_toon.reports[i] = nil ;
    elseif ((now - v.last_tm) >= 10) and (not v.submit_failed) then
      v.last_tm = now ;
      if (not v.report_recvd) then
        oq.send_report( v.report, v.tok, v.last_tm ) ;   
      elseif (v.tops ~= nil) and (not v.top_dps_recvd) then
        oq.send_top_dps( v.tops, v.tok, v.bg, v.crc ) ;   
      elseif (v.tops ~= nil) and (not v.top_heals_recvd) then
        oq.send_top_heals( v.tops, v.tok, v.bg, v.crc ) ;   
      end
      if (v.attempt == nil) then
        v.attempt = 1 ;
      else
        v.attempt = v.attempt + 1 ;
      end
      if (v.attempt > OQ_MAX_SUBMIT_ATTEMPTS) then
        v.submit_failed = true ;
      end
      return ; -- can only send out one report at a time, otherwise subsequent msgs will overwrite 
    end
  end
end

function oq.report_score( winner, scores, tops )
  if (not oq.iam_raid_leader() or (IsRatedBattleground() == true)) then
    return ;
  end
  if (OQ_data.stats.bg_start == 0) or (OQ_data.stats.bg_end == 0) then
    -- game time not properly recorded, do not report
    return ;
  end

  local str = "" ;
  if (scores == nil) then
    return ;
  end
  for i,v in oq.pairsByKeys( scores, nil ) do
    str = str .."|".. i ..",".. v.fact ..",".. v.dmg ..",".. v.heal ;
  end
  str = str .."|" ;
  _last_crc = oq.CRC32(str) ;

  oq.get_zone_info() ;
  
  local bg        = oq.encode_mime64_1digit( OQ.BG_SHORT_NAME[ _bg_shortname ] ) ;
  local crc       = oq.encode_mime64_6digit( _last_crc ) ;
  local end_tm    = oq.encode_mime64_6digit( OQ_data.stats.bg_end ) ;
  local start_tm  = oq.encode_mime64_6digit( OQ_data.stats.bg_start ) ;
  
  _last_report = bg .."".. winner .."".. crc .."".. end_tm .."".. start_tm .."".. oq.encode_mime64_1digit(oq.nMembers()) ;
  _last_bg     = OQ.BG_NAMES[ _bg_zone ].type_id ;
  _last_tops   = copyTable( tops ) ;
end

function oq.report_rage()
  if (_inside_bg) then
    print( string.format( OQ.RAGEQUITS, _nrage ) ) ;
  else
    local min = floor((OQ_data.stats.bg_length)/60) ;
    local sec = OQ_data.stats.bg_length % 60 ;
    print( string.format( OQ.RAGELASTGAME, _nrage, min, sec ) ) ;
  end
end

local ad = 0 ;
function oq.get_ab_text( txt )
  if (txt == nil) then
    return "" ;
  end
  -- Resources: 400/1600
  local points = txt:match( "Resources: (%d+)" ) ;
  return points ;
end

function oq.get_av_text( txt )
  if (txt == nil) then
    return "" ;
  end
  -- Reinforcements: 400
  local points = txt:match( "Reinforcements: (%d+)" ) ;
  return points ;
end

function oq.get_bfg_text( txt )
  if (txt == nil) then
    return "" ;
  end
  -- Resources: 400/2000
  local points = txt:match( "Resources: (%d+)" ) ;
  return points ;
end

function oq.get_eots_text( txt )
  if (txt == nil) then
    return "" ;
  end
  -- Bases: 3  Victory Points:  1600/2000
  local bases, points  = txt:match( "Bases: (%d+)  Victory Points: (%d+)" ) ;
  return points ;
end

function oq.get_ioc_text( txt )
  if (txt == nil) then
    return "" ;
  end
  -- Reinforcements: 400
  local points = txt:match( "Reinforcements: (%d+)" ) ;
  return points or "" ;
end

function oq.get_sota_text( txt )
  if (txt == nil) then
    return "" ;
  end
  -- time
  -- End of Round: 02:01
  local tm = txt:match( "End of Round: (%d+:%d+)" ) ;  
  if (tm == nil) or (tm == "") then
    return "" ;
  else
    return "round (".. tm ..")" ;
  end
end

function oq.get_ssm_text( txt )
  if (txt == nil) then
    return "" ;
  end
  -- Resources: 400/1600
  local points = txt:match( "Resources: (%d+)" ) ;
  return points ;
end

function oq.get_tok_text( txt )
  if (txt == nil) then
    return "" ;
  end
  -- Victory Points: 400/1600
  local points = txt:match( "Victory Points: (%d+)" ) ;
  return points ;
end

function oq.get_tp_text( txt )
  if (txt == nil) then
    return "" ;
  end
  -- Bases: 3  Victory Points:  1600/1600
  local points = txt:match( "%d+" ) ;
  return points or "" ;
end

function oq.get_wsg_text( txt )
  if (txt == nil) then
    return "" ;
  end
  -- 0/3
  local points = txt:match( "%d+" ) ;
  return points or "" ;
end

function oq.get_ad_text()
  ad = ad + 1 ;
  local zone = OQ.BG_SHORT_NAME[ GetZoneText() ] ;
  local bg = zone ;
  if (bg == nil) then
    bg = "BG" ;
  end
  local aText = "" ;
  local hText = "" ;
  local line1 = "" ;
  if (AlwaysUpFrame1Text ~= nil) then
    line1 = AlwaysUpFrame1Text:GetText()
  end
  local line2 = "" ;
  if (AlwaysUpFrame2Text ~= nil) then
    line2 = AlwaysUpFrame2Text:GetText()
  end
  local tm = "" ;
  if (zone == "AB") then
    aText = oq.get_ab_text( line1 ) ;
    hText = oq.get_ab_text( line2 ) ;
  elseif (zone == "AV") then
    aText = oq.get_av_text( line1 ) ;
    hText = oq.get_av_text( line2 ) ;
  elseif (zone == "BFG") then
    aText = oq.get_bfg_text( line1 ) ;
    hText = oq.get_bfg_text( line2 ) ;
  elseif (zone == "EotS") then
    aText = oq.get_eots_text( line1 ) ;
    hText = oq.get_eots_text( line2 ) ;
  elseif (zone == "IoC") then
    aText = oq.get_ioc_text( line1 ) ;
    hText = oq.get_ioc_text( line2 ) ;
  elseif (zone == "SotA") then
    local line3 = "" ;
    if (AlwaysUpFrame3Text ~= nil) then
      line3 = AlwaysUpFrame3Text:GetText() ;
    end
    aText = oq.get_sota_text( line3 ) ;
  elseif (zone == "SSM") then
    aText = oq.get_ssm_text( line1 ) ;
    hText = oq.get_ssm_text( line2 ) ;
  elseif (zone == "ToK") then
    aText = oq.get_tok_text( line1 ) ;
    hText = oq.get_tok_text( line2 ) ;
  elseif (zone == "TP") then
    tm    = line1:match( "Remaining: (%d+)" ) ;  
    local line3 = AlwaysUpFrame3Text:GetText() ;
    aText = oq.get_tp_text( line2 ) ;
    hText = oq.get_tp_text( line3 ) ;
  elseif (zone == "WSG") then
    tm    = line1:match( "Remaining: (%d+)" ) ;  
    local line3 = AlwaysUpFrame3Text:GetText() ;
    aText = oq.get_wsg_text( line2 ) ;
    hText = oq.get_wsg_text( line3 ) ;
  else
    return "" ;
  end

  if (zone == "SotA") then
    bg = bg ..": ".. aText ;
  elseif (zone == "TP") or (zone == "WSG") then
    if (player_faction == "A") then
      bg = bg ..": ".. aText .." - ".. hText ;
    else
      bg = bg ..": ".. hText .." - ".. aText ;
    end      
    bg = bg .." (".. tm .." min)" ;
  else
    if (player_faction == "A") then
      bg = bg ..": ".. (aText or "") .." - ".. (hText or "") ;
    else
      bg = bg ..": ".. (hText or "") .." - ".. (aText or "") ;
    end      
  end
  
  return bg ;
end

function oq.init_stats_data()
  if (OQ_data.stats == nil) then
    OQ_data.stats = {} ;
    local s       = OQ_data.stats ;
    s.nGames      = 0 ;
    s.nWins       = 0 ;
    s.nLosses     = 0 ;
    s.avg_honor   = 0 ; -- total per game stat.  avg_honor/game calc'd then added to total honor
    s.avg_hks     = 0 ; -- total per game stat.  avg_hk/game calc'd then added to total hks
    s.avg_deaths  = 0 ; -- total per game stat.  avg_deaths/game calc'd then added to total deaths
    s.avg_down_tm = 0 ; -- total per game stat.  avg time between games (seconds). 
    s.avg_bg_len  = 0 ; -- total per game stat.  avg game length (seconds). 
    s.bg_length   = 0 ;
    s.bg_end      = 0 ;
    s.bg_start    = 0 ;
    s.tears       = 0 ;
    s.total_tears = 0 ;
  end
  
  return OQ_data.stats ;
end

function oq.send_my_premade_info()
  if ((not oq.iam_raid_leader()) or OQ_toon.disabled) then
    return ;
  end

  -- announce new raid on main channel
  local s        = OQ_data.stats ;
  local nMembers, avg_resil, avg_ilevel = oq.calc_raid_stats() ;
  local nWaiting = oq.n_waiting() ;
  local now      = utc_time() ;
  
  oq.raid.pdata  = oq.get_pdata() ;

  s = oq.init_stats_data() ;
  
  s.status = 0 ;
  if (_inside_bg) then
    s.status = 2 ;
  elseif (player_queued) then
    s.status = 1 ;
  end

  if (player_realm == nil) then
    player_realm = oq.GetRealmName() ;
  end

  local raid = oq.premades[ oq.raid.raid_token ] ;
  local enc_data = oq.encode_data( "abc123", player_name, player_realm, player_realid ) ;
  if (raid ~= nil) then
    raid.stats = copyTable( OQ_data.stats ) ; -- make sure to copy stats
  end
  oq.process_premade_info( oq.raid.raid_token, oq.encode_name( oq.raid.name ), oq.raid.faction, 
                           oq.raid.level_range, oq.raid.min_ilevel, oq.raid.min_resil, oq.raid.min_mmr, enc_data, oq.encode_bg( oq.raid.bgs ),
                           nMembers, avg_resil, avg_ilevel, s.nWins, s.nLosses, s.avg_honor, s.avg_hks, s.avg_deaths, 
                           s.avg_down_tm, s.avg_bg_len, 1, now, s.status, nWaiting, oq.raid.has_pword, oq.raid.is_realm_specific, 
                           oq.raid.type, oq.raid.pdata ) ;

  if (raid == nil) then
    -- would have just been created, ok2send
    raid = oq.premades[ oq.raid.raid_token ] ;
    raid.stats = copyTable( OQ_data.stats ) ; -- make sure to copy stats
  elseif (raid.next_advert > now) then
    return ;
  end
  
  if (player_realm == nil) then
    player_realm = oq.GetRealmName() ;
  end
  raid.leader         = player_name ;
  raid.leader_realm   = player_realm ;
  raid.leader_rid     = player_realid ;
  raid.last_seen      = now ;
  raid.next_advert    = now + OQ_SEC_BETWEEN_PROMO ;
  
  local ad_text = nil ;
  if (_inside_bg) then
    ad_text = oq.get_ad_text() ;
  else
    ad_text = oq.raid.bgs ;
  end
  
  local stat = s.status or 0 ;
  if _inside_bg then
    stat = 2 ;
  end

  local is_realm_specific = nil ;
  local is_source = 1 ;
  oq.announce( "premade,".. 
               oq.raid.raid_token ..",".. 
               oq.encode_name( oq.raid.name ) ..",".. 
               oq.encode_premade_info( oq.raid.raid_token, avg_ilevel, avg_resil, stat, now, oq.raid.has_pword, is_realm_specific, is_source ) ..","..
               enc_data ..","..
               oq.encode_bg( ad_text ) ..","..
               oq.raid.type ..","..
               oq.raid.pdata
             ) ;
end

function oq.advertise_my_raid()
  if ((not oq.iam_raid_leader()) or (oq.raid.raid_token == nil)) then
    return ;
  end
  oq._ad_ticker = (oq._ad_ticker or 0) + 1 ;
  if ((oq._ad_ticker % 2) == 1) then
    if (not _inside_bg) then
      -- this will produce premade ads every 30 seconds when not in a bg and every 15 seconds when inside
      return ;
    end
  end
  
  if (not _inside_bg) then
    -- send the raid token to everyone in the party
    oq.party_announce( "party_update,".. oq.raid.raid_token ) ;
  end
  -- even if inside a bg, the leader will continue to send premade info
  oq.send_my_premade_info() ;
end

function oq.on_charm( raid_token, g_id, slot, icon ) 
  if (raid_token == nil) or (raid_token ~= oq.raid.raid_token) then
    return ;
  end
  oq.set_charm( g_id, slot, icon ) ;
end

function oq.leader_set_charm( g_id, slot, icon ) 
  if (not oq.iam_raid_leader()) then
    return ;
  end
  oq.raid_announce( "charm,".. oq.raid.raid_token ..",".. tostring(g_id) ..",".. tostring(slot) ..",".. tostring(icon) ) ;
  oq.set_charm( g_id, slot, icon ) ;
end

function oq.group_charm_clear( g_id )
  g_id = tonumber( g_id ) ;
  for i=1,5 do
    oq.raid.group[g_id].member[i].charm = 0 ;    
    oq.raid.group[g_id].member[i].check = OQ_FLAG_CLEAR ;
  end
end

function oq.set_charm( g_id, slot, icon ) 
  g_id = tonumber( g_id ) ;
  slot = tonumber( slot ) ;
  icon = tonumber( icon or 0 ) or 0 ;
  if (icon > 0) then
    for i=1,8 do
      for j=1,5 do
        local m = oq.raid.group[i].member[j] ;
        if (m.name ~= nil) and (m.name ~= "-") and (m.name ~= "") and (m.charm == icon) then
          m.charm = 0 ;
          oq.set_textures( i, j ) ;
        end
      end
    end
  end
  oq.raid.group[ g_id ].member[ slot ].charm = icon ;
  oq.set_textures( g_id, slot ) ;
  
  -- set the charm if currently in the bg
  if (g_id == my_group) and (slot == my_slot) then
    SetRaidTarget( "player", icon ) ;
  end
  if (_inside and oq.IsRaidLeader()) then
    local m = oq.raid.group[ g_id ].member[ slot ] ;
    if (m.name == player_name) then
      SetRaidTarget( "player", icon ) ;
    else
      local n = m.name ;
      if (m.realm ~= player_realm) then
        n = n .."-".. m.realm ;
      end
      SetRaidTarget( n, icon ) ;
    end
  end
end

function oq.numeric_sanity( n )
  if (n == nil) or (n == "") or (tostring(n) == "-1.#IND") then
    return 0 ;
  end
  return tonumber( n or 0 ) or 0 ;
end

function oq.raid_create()
  if (oq.raid.raid_token ~= nil) then
    print( OQ.STILL_IN_PREMADE ) ;
    return ;
  end
  -- check information to make sure it's all filled in

  -- generate token
  oq.raid.raid_token = "G".. oq.token_gen() ;
  if (not oq.valid_rid( player_realid )) then
    message( OQ.BAD_REALID .." ".. tostring(player_realid) ) ;
    return ;
  end
  
  if (player_level < 10) then
    message( OQ.MSG_CANNOTCREATE_TOOLOW ) ;
    return ;
  end

  OQ_data.realid = player_realid ;

  if (player_realm == nil) then
    player_realm = oq.GetRealmName() ;
  end
  -- set raid info
  my_group                 = 1 ;
  my_slot                  = 1 ;
  oq.raid.name             = oq.rtrim( oq.tab3_raid_name:GetText() ) ;
  oq.raid.leader           = player_name ;
  oq.raid.leader_class     = player_class ;
  oq.raid.leader_realm     = player_realm ;
  oq.raid.leader_rid       = player_realid ;
  oq.raid.level_range      = oq.tab3_level_range ;
  oq.raid.faction          = player_faction ; 
  oq.raid.min_ilevel       = oq.numeric_sanity( oq.tab3_min_ilevel:GetText() ) ;
  oq.raid.min_resil        = oq.numeric_sanity( oq.tab3_min_resil:GetText() ) ;
  oq.raid.min_mmr          = oq.numeric_sanity( oq.tab3_min_mmr:GetText() ) ;
  oq.raid.notes            = (oq.tab3_notes.str or "") ;
  oq.raid.bgs              = string.gsub( oq.tab3_bgs:GetText() or ".", ",", ";" ) ;
  oq.raid.pword            = oq.tab3_pword:GetText() or "" ;

  if (oq.is_qualified( player_level, player_faction, oq.get_resil(), oq.get_ilevel(), player_role, oq.get_mmr() ) == nil) then
    oq.raid_cleanup() ;
    StaticPopup_Show("OQ_DoNotQualifyPremade") ;
    return ;
  end

  if (oq.raid == nil) or (oq.raid.type == nil) then
    oq.set_premade_type( OQ.TYPE_BG ) ;
  else
    oq.set_premade_type( oq.raid.type ) ;
  end

  if (oq.raid.pword == nil) or (oq.raid.pword == "") then
    oq.raid.has_pword = nil ;
  else
    oq.raid.has_pword = true ;
  end
  
  local s = oq.init_stats_data() ;
  s.start_tm   = utc_time() ;
  s.bg_start   = 0 ; -- place holder - time() of bg start
  s.bg_end     = 0 ; -- place holder - time() of bg end

  oq.raid.notes      = oq.raid.notes or "" ;
  oq.raid.bgs        = oq.raid.bgs or "" ;

  -- enable premade leader only controls
  oq.ui_raidleader() ;

  oq.set_group_lead( 1, player_name, player_realm, player_class, player_realid ) ;
  oq.set_charm( my_group, my_slot, OQ.ICON_SKULL ) ;
  oq.raid.group[1].member[1].resil  = player_resil ;
  oq.raid.group[1].member[1].ilevel = player_ilevel ;
  oq.raid.group[1].member[1].level  = player_level ;

  -- update tab_1
  oq.tab1_name :SetText( oq.raid.name ) ;
  oq.tab1_notes:SetText( oq.raid.notes ) ;

  oq.update_tab1_stats() ;
  oq.get_group_hp() ;
  oq.check_for_deserter() ;
  
  -- remove myself from other waitlists
  oq.clear_pending() ;

  -- assign slots to the party members
  local enc_data = oq.encode_data( "abc123", oq.raid.leader, oq.raid.leader_realm, oq.raid.leader_rid ) ;
  oq.party_assign_slots( my_group, enc_data ) ;
  
  -- activate in-raid only procs
  oq.procs_join_raid() ;

  -- tell the world 
  oq.advertise_my_raid() ;
  
  return 1 ;
end

-- if same realm, will whisper
-- if real-id friend, will bnwhisper
-- if not same realm and not friend, will bnfriendinvite with msg in note
--
function oq.realid_msg( to_name, to_realm, real_id, msg ) 
  if (msg == nil) then
    return ;
  end
  local rc = 0 ;
  if ((to_name == nil) or (to_name == "-") or (to_realm == nil)) then
    return ;
  end
  if ((to_name == player_name) and (to_realm == player_realm)) then
    -- sending to myself?
    return ;
  end
  if (not oq.well_formed_msg( msg )) then
      local msg_tok = "W".. oq.token_gen() ;
      oq.token_push( msg_tok ) ;
      msg = "OQ,".. 
            OQ_VER ..",".. 
            msg_tok ..","..
            OQ_TTL ..",".. 
            msg ;
  end
        
  if (to_realm == player_realm) then
    oq.SendAddonMessage( "OQ", msg, "WHISPER", to_name ) ;
    return ;
  end

  local pid, online = oq.is_bnfriend(real_id) ;
  if (pid ~= 0) then
    if (online) then
      oq.BNSendWhisper( pid, msg, to_name, to_realm ) ;
      return ;
    else
      -- no way to leave a note... should resend when no reply recv'd
      return ;
    end
  end

  oq.BNSendFriendInvite( real_id, msg ) ;
end

function oq.bnbackflow( msg, to_pid )
  if (_sender_pid ~= to_pid) then
    return nil ;
  end
  -- ie: "OQ,0A,P477389297,G17613410,name,1,3,Tinymasher,Magtheridon"
  local tok = msg:sub(7,16) ;
  if (_msg_token ~= tok) then
    return nil ;
  end
  return true ;
end

function oq.iknow_scorekeeper()
  for i,v in pairs(OQ_data.bn_friends) do
    if ((v.presenceID ~= 0) and v.isOnline and v.sk_enabled) then
      return v.presenceID ;
    end
  end
  return nil ;
end

function oq.bn_ok2send( msg, pid )
  if (oq.bnbackflow( msg, pid )) then
    return nil ;
  end
  for i,v in pairs(OQ_data.bn_friends) do
    if ((v.presenceID == pid) and v.isOnline and v.oq_enabled) then
      return true ;
    end
  end
  return nil ;
end

function oq.well_formed_msg( m )
  if (m == nil) then
    return nil ;
  end
  local str = OQ_MSGHEADER .."".. OQ_VER .."," ;
  if (m:sub(1,#str) == str) then
    return true ;
  end
  str = OQSK_HEADER ..",".. OQSK_VER .."," ;
  if (m:sub(1,#str) == str) then
    return true ;
  end
  return nil ;
end

function oq.BNSendQ_push( func_, pid_, msg_, name_, realm_ )
  if (pid_ == 0) or (msg_ == nil) or (OQ_toon.disabled) then
    return ;
  end
  if (oq.send_q == nil) then
    oq.send_q = {} ;
  end
  table.insert( oq.send_q, { func = func_, pid = pid_, msg = msg_, name = name_, realm = realm_ } ) ;  
end

function oq.BNSendQ_pop() 
  if (oq.send_q == nil) or (#oq.send_q == 0) then
    return ;
  end
  local t = table.remove( oq.send_q, 1 ) ;
  if (t == nil) then
    return ;
  end
  -- have an entry... process
  t.func( t.pid, t.msg, t.name, t.realm ) ;
  _pkt_sent = _pkt_sent + 1 ;
end

function oq.BNSendWhisper( pid, msg, name, realm )
  oq.BNSendQ_push( oq.BNSendWhisper_now, pid, msg, name, realm ) ;
end

function oq.BNSendWhisper_now( pid, msg, name, realm )
  if (pid == 0) or (msg == nil) or (OQ_toon.disabled) then
    return ;
  end
  if (name == nil) or (realm == nil) or (msg:find( ",".. OQ_FLD_TO ) ~= nil) then
    if (#msg > 254) then
      msg = msg:sub(1,254) ;
    end
    BNSendWhisper( pid, msg ) ;
    return ;
  end
  if (player_realm == nil) then
    player_realm = oq.GetRealmName() ;
  end
  local x_msg = msg ..",".. 
                OQ_FLD_TO .."".. name ..",".. 
                OQ_FLD_REALM .."".. tostring(oq.realm_cooked( realm )) ..",".. 
                OQ_FLD_FROM .."".. player_name .."-".. tostring(oq.realm_cooked( player_realm ))  ;
  if (#x_msg > 254) then
    x_msg = x_msg:sub(1,254) ;
  end
  BNSendWhisper( pid, x_msg ) ;  
end

function oq.get_field( m, fld )
  if (m == nil) or (fld == nil) then
    return nil ;
  end
  -- not found, leave
  local p1 = m:find( fld ) ;
  if (p1 == nil) then
    return nil ;
  end
  
  -- find end, either the next ',' or eos
  local p2 = m:find( ",", p1 ) ;
  if (p2 == nil) then
    p2 = -1 ;
  else
    p2 = p2 - 1 ;
  end
  return m:sub( p1 + #fld, p2 ) ;
end

-- takes name-realm and returns name,realm
-- if there is no realm, player_realm assumed
--
function oq.crack_name( n )
  if (n == nil) then
    return nil, nil ;
  end
  if (player_realm == nil) then
    player_realm = oq.GetRealmName() ;
  end
  local name = n ;
  local realm = player_realm ;
  local p = n:find("-") ;
  if (p) then
    name  = n:sub( 1, p-1 ) ;
    realm = n:sub( p+1, -1 ) ;
  end
  return name, realm ;
end

function oq.is_number(s)
  if (s == nil) then
    return nil ;
  end
  if (type(s) == "number") then
    return true ;
  end
  if (tonumber(s) ~= nil) then
    return true ;
  end
  return nil ;
end

function oq.space_it( s ) 
   local x = string.find( s:sub(2,-1), OQ.PATTERN_CAPS ) ;
   if (x == nil) or (s:sub(x,x) == "'") then
      return s ;
   end
   return s:sub( 1, x ) .." ".. s:sub( x+1, -1 ) ;
end

function oq.realm_cooked(realm)
  if (realm == nil) or (realm == "-") or (realm == "nil") or (realm == "n/a") or (realm == "") then
    return 0 ;
  end
  if (oq.is_number(realm)) then
    return realm ;
  end
  if (OQ.SHORT_BGROUPS[ realm ] ~= nil) then
    return OQ.SHORT_BGROUPS[ realm ] ;
  end
  local r = realm ;
  if (OQ.REALMNAMES_SPECIAL[ realm ] ~= nil) then
    r = OQ.REALMNAMES_SPECIAL[ realm ] ;
  elseif (OQ.REALMNAMES_SPECIAL[ strlower( realm ) ] ~= nil) then
    r = OQ.REALMNAMES_SPECIAL[ strlower(realm) ] ;
  end
  
  if (OQ.SHORT_BGROUPS[ r ] == nil) then
    -- for some reason, realms like "Bleeding Hollow" will come from blizz as "BleedingHollow".. sometimes
    r = oq.space_it( r ) ; 
    if (OQ.SHORT_BGROUPS[ r ] == nil) then
      print( OQ_REDX_ICON .." unable to locate realm id.  realm[".. tostring(realm) .."]" ) ;
      print( OQ_REDX_ICON .." please report this to tiny on wow.publicvent.org : 4135" ) ;
      return 0 ;
    end
  end
 
  return OQ.SHORT_BGROUPS[ r ] ;
end

function oq.realm_uncooked(realm)
  if (oq.is_number(realm)) then
    realm = OQ.SHORT_BGROUPS[ tonumber(realm) ] ;
  elseif (realm == "nil") then
    realm = nil ;
  end
  return realm ;
end

--  local m, name_, realm_ = oq.crack_bn_msg( msg ) ;
function oq.crack_bn_msg( msg )
   if (msg:find( OQ_FLD_TO ) == nil) then
      return msg, nil, nil, nil ;
   end
   
   local m, name, realm, from ;
   m     = msg:sub( 1, msg:find( ",".. OQ_FLD_TO )-1 ) ;
   name  = oq.get_field( msg, OQ_FLD_TO ) ;
   realm = oq.get_field( msg, OQ_FLD_REALM ) ;
   realm = oq.realm_uncooked(realm) ;
   from  = oq.get_field( msg, OQ_FLD_FROM ) ;
   local from_name, from_realm = oq.crack_name( from ) ;
   from_realm = oq.realm_uncooked(from_realm) ;
   return m, name, realm, from ;
end

function oq.whisper_msg( to_name, to_realm, msg ) 
  if (msg == nil) then
    return ;
  end
  local rc = 0 ;
  if ((to_name == nil) or (to_name == "-")) then
    return ;
  end
  if ((to_name == player_name) and (to_realm == player_realm)) then
    return ;
  end
  if (not oq.well_formed_msg( msg )) then
      local msg_tok = "W".. oq.token_gen() ;
      oq.token_push( msg_tok ) ;
      msg = "OQ,".. 
            OQ_VER ..",".. 
            msg_tok ..","..
            OQ_TTL ..",".. 
            msg ;
  end
  if (to_realm == player_realm) then
    if ((_sender == nil) or (_sender ~= to_name)) then
      oq.SendAddonMessage( "OQ", msg, "WHISPER", to_name ) ;
    end
    return ;
  elseif (to_realm ~= nil) then
    -- check to see if we have BN access
    local presenceID = oq.bnpresence( to_name .."-".. to_realm ) ;
    if (presenceID == 0) then
      local msg_sent = nil ;
      -- send to real-id list for ppl not in the raid (hoping they will forward to their local OQGeneral channel)
      return ;
--    elseif (oq.bn_ok2send( msg, presenceID )) then
    else
      oq.BNSendWhisper( presenceID, msg, to_name, to_realm ) ;
    end
  end
end

function oq.whisper_party_leader( msg ) 
  if ((my_group <= 0) or (oq.raid.group[my_group].member[1].name == nil) or (msg == nil)) then
    return ;
  end
  if ((oq.raid.leader == nil) or (oq.raid.leader_realm == nil)) then
    return ;
  end
  local lead = oq.raid.group[my_group].member[1] ;
  local name = lead.name ;
  if (lead.realm ~= player_realm) then
    name = name .."-".. lead.realm ;
  end
  -- make sure the msg is well formed
  if (not oq.well_formed_msg( msg )) then
      local msg_tok = "W".. oq.token_gen() ;
      oq.token_push( msg_tok ) ;
      msg = "OQ,".. 
            OQ_VER ..",".. 
            msg_tok ..","..
            OQ_TTL ..",".. 
            msg ;
  end
  oq.SendAddonMessage( "OQ", msg, "WHISPER", name ) ;
end

function oq.whisper_raid_leader( msg ) 
  if (msg == nil) then
    return ;
  end

  if ((oq.raid.leader == nil) or (oq.raid.leader_realm == nil)) then
    return ;
  end
  -- make sure the msg is well formed
  if (not oq.well_formed_msg( msg )) then
      local msg_tok = "W".. oq.token_gen() ;
      oq.token_push( msg_tok ) ;
      msg = "OQ,".. 
            OQ_VER ..",".. 
            msg_tok ..","..
            OQ_TTL ..",".. 
            msg ;
  end
  if (oq.raid.leader_realm == player_realm) then
    oq.SendAddonMessage( "OQ", msg, "WHISPER", oq.raid.leader ) ;
  else
    oq.whisper_msg( oq.raid.leader, oq.raid.leader_realm, msg ) ; 
  end
end

function oq.send_invite_accept( raid_token, group_id, slot, name, class, realm, realid, req_token ) 
  -- the 'W' stands for 'whisper' and should not be echo'd far and wide
  local msg_tok = "W".. oq.token_gen() ;
  oq.token_push( msg_tok ) ;

  local enc_data = oq.encode_data( "abc123", player_name, player_realm, player_realid ) ;
  local m = "OQ,".. 
            OQ_VER ..",".. 
            msg_tok ..","..
            OQ_TTL ..",".. 
            "invite_accepted,".. 
            raid_token ..",".. 
            group_id ..","..
            slot ..","..
            class ..","..
            enc_data ..","..
            req_token ;

  oq.whisper_raid_leader( m ) ;
end

function oq.check_for_dead_group()
  if ((oq.raid.raid_token == nil) or _inside_bg or (not oq.iam_raid_leader())) then
    return ;
  end
  if (oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID) then
    oq.assign_raid_seats() ;
    return ;
  end
  local now = utc_time() ;
  
  if (not oq.iam_raid_leader()) then
    -- group 1 cannot lag out
    if (my_group > 1) and ((now - oq.raid._last_lag) >= OQ_GROUP_TIMEOUT) then
      -- group leader lost conn or just left
      oq.quit_raid_now() ;
    end
    return ;
  end  
  
  -- remove a group if its been more end OQ_GROUP_TIMEOUT since last ping response
  for i=2,8 do
    local grp  = oq.raid.group[i] ;
    local lead = grp.member[1] ;
    if (lead.name ~= nil) and (lead.name ~= "-") then 
      if (grp._last_ping ~= nil) and ((now - grp._last_ping) >= OQ_GROUP_TIMEOUT) then
        oq.remove_group( i ) ;
      elseif (grp._last_ping == nil) then
        grp._last_ping = now ;
      end
    end
  end
  -- ping all leaders
  oq.raid_ping() ;
end

local _auras = nil ;
function oq.check_for_deserter() 
--  local v = { UnitAura("player", "Deserter", nil, "PLAYER|HARMFUL") } ;
  _auras = { UnitAura("player", "Deserter", nil, "PLAYER|HARMFUL") } ;
  if (player_deserter and (_auras[1] == nil)) then
    player_deserter = nil ;
    oq.set_status( my_group, my_slot, player_deserter, player_queued, player_online ) ;
    oq.update_status_txt() ;
  elseif (not player_deserter and (_auras[1] ~= nil)) then
    player_deserter = true ;
    oq.set_status( my_group, my_slot, player_deserter, player_queued, player_online ) ;
    oq.update_status_txt() ;
  end
  return player_deserter ;
end

function oq.check_my_role( changedPlayer, changedBy, oldRole, newRole ) 
  if (changedPlayer == player_name) then
    local role = OQ.ROLES[ newRole ] ;
    if (role ~= player_role) then  
      player_role = role ;
    end
    -- insure UI update
    oq.set_role( my_group, my_slot, role ) ;
  end
end

function oq.brief_player( slot, name )
  if (not oq.iam_party_leader() or (my_group == 0) or (my_slot ~= 1)) then
    return ;
  end
  local enc_data = oq.encode_data( "abc123", oq.raid.leader, oq.raid.leader_realm, oq.raid.leader_rid ) ;
  oq.party_announce( "party_join,".. 
                      my_group ..","..
                      oq.encode_name( oq.raid.name ) ..",".. 
                      oq.raid.leader_class ..",".. 
                      enc_data ..",".. 
                      oq.raid.raid_token  ..",".. 
                      oq.encode_note( oq.raid.notes )
                   ) ;
  oq.party_announce( "party_slot,".. 
                     name ..","..
                     my_group ..","..
                     slot
                   ) ;
end

function oq.check_the_dead() 
  if (not oq.iam_party_leader() or (my_group == 0) or (my_slot ~= 1) or _inside_bg) then
    return ;
  end
  for i=2,5 do
    -- check the members of my party to see if they are online
    local m = oq.raid.group[ my_group ].member[ i ] ;
    if (m.name and (m.name ~= "-") and (m.realm ~= nil)) then
      local n = m.name ;
      if (m.realm ~= player_realm) then
        n = n .."-".. m.realm ;
      end
      local hp = UnitHealthMax( n ) ;
      if (((hp == 0) and m.online) or ((hp > 0) and not m.online)) then
        m.online = (hp > 0) ;
        oq.set_status_online( my_group, i, m.online ) ;

        -- push info to newly re-logged player
        if (m.online) then
          oq.brief_player( i, m.name ) ;
        end
        
        if (m.hp == nil) or (m.hp == 0) then
          m.hp = floor(UnitHealthMax(n) / 1000) ;
        end

        local stats = oq.encode_stats( my_group, i, m.level, player_faction, m.class, m.race, m.gender,
                                       m.bg[1].type, m.bg[1].status, m.bg[2].type, m.bg[2].status, 
                                       m.resil, m.ilevel, m.flags, m.hp, m.role, m.charm, m.check, 
                                       m.wins, m.losses, m.hks, m.oq_ver, m.tears, m.pvppower, m.mmr ) ;
        if (oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID) then
          oq.raid_announce( "stats,".. 
                            m.name ..",".. 
                            tostring(oq.realm_cooked(m.realm)) ..","..
                            stats 
                          ) ;
        else
          oq.party_announce( "stats,".. 
                             m.name ..",".. 
                             tostring(oq.realm_cooked(m.realm)) ..","..
                             stats 
                           ) ;
        end
      end
    end
  end
end

function oq.bntoons()
  local now = utc_time() ;
  if (next_bn_check > now) then
    return ;
  end
  next_bn_check = now + 5 ; -- refresh presence ids every 5 seconds (was 30, but the numbers were getting re-issued more frequently then that)
  if (OQ_data.bn_friends) then
    for i,v in pairs(OQ_data.bn_friends) do
      v.presenceID = 0 ;
      v.isOnline   = nil ;
      v.oq_enabled = nil ;
    end
  end
  local p_faction = 0 ; -- 0 == horde, 1 == alliance, -1 == offline
  if (player_faction == "A") then
    p_faction = 1 ;
  end

  local ntotal, nonline = BNGetNumFriends() ;
  for friendId=1,ntotal do
    local f = { BNGetFriendInfo( friendId ) } ;
    local presenceID = f[1] ;
    local givenName  = f[2] ;
    local surName    = f[3] ;
    local client     = f[7] ;
    local online     = f[8] ;
    local broadcast  = f[12] ;
    local nToons = BNGetNumFriendToons( friendId ) ;
    if (nToons > 0) and online and (client == "WoW") then
      for toonIndx=1,nToons do
        local toon = { BNGetFriendToonInfo( friendId, toonIndx ) } ;
        local toonName   = toon[2] ;
        local realmName  = toon[4] ;
        local faction    = 1 ;
        if (toon[6] == "Horde") then
          faction = 0 ;
        end

        if (faction == p_faction) then
          local name = toonName .."-".. realmName ;
          local friend = OQ_data.bn_friends[ name ] ;
          if (friend == nil) then
            OQ_data.bn_friends[ name ] = {} ;
            friend = OQ_data.bn_friends[ name ] ;
          end
          friend.isOnline   = true ;
          friend.toonName   = toonName ;
          friend.realm      = realmName ;
          friend.presenceID = presenceID ;
          friend.oq_enabled = nil ;
          if (broadcast ~= nil) and (broadcast:sub(1, #OQ_BNHEADER ) == OQ_BNHEADER) then
            friend.oq_enabled = true ;
          end
          if (broadcast ~= nil) and (broadcast:sub(1, #OQ_SKHEADER ) == OQ_SKHEADER) then
            friend.sk_enabled = true ;
          end          
        end
      end
    end  
  end  

  -- update ui elements  
  oq.n_connections() ;
end

function oq.is_bnfriend(btag_) 
  local ntotal, nonline = BNGetNumFriends() ;
  for friendId=1,ntotal do
    local f = { BNGetFriendInfo( friendId ) } ;
    local presenceID = f[1] ;
    local givenName  = f[2] ;
    local btag       = f[3] ;
    local client     = f[7] ;
    local online     = f[8] ;
    local noteText   = f[13] ;
    if (btag == btag_) then
      if (client == "WoW") and online then
        return presenceID, true ;
      else
        return presenceID, nil ;
      end
    end
  end
  return 0, nil ;
end

function oq.get_nConnections()
  local cnt = 0 ;
  
  oq.bntoons() ;
  for name,v in pairs(OQ_data.bn_friends) do
    if (v.isOnline and (v.presenceID ~= 0) and v.oq_enabled) then
      cnt = cnt + 1 ;
    end
  end
  
  -- update the label on tab 5
  local nlocals = oq.n_channel_members( "OQgeneral" ) ;
  if (nlocals > 0) then
    nlocals = nlocals - 1 ; -- subtract player
  end
  ntotal, nonline = BNGetNumFriends() ;
  return nlocals, cnt, ntotal ;
end

function oq.n_connections()
  local nOQlocals, nOQfriends, nBNfriends = oq.get_nConnections() ;
  if (oq.loaded) then
    oq.tab2_nfriends:SetText( string.format( OQ.BNET_FRIENDS, nBNfriends ) ) ; 
    oq.tab2_connection:SetText( string.format( OQ.CONNECTIONS, nOQlocals, nOQfriends )) ;
  end
end

function oq.bnpresence( name )
  oq.bntoons() ;
  local friend = OQ_data.bn_friends[ name ] ;
  if (friend == nil) or ((not friend.oq_enabled) and (not friend.sk_enabled)) or (not friend.isOnline) then
    return 0 ;
  end
  return friend.presenceID or 0 ;
end

function oq.mbsync_toons( to_name )
  for ndx,friend in pairs( OQ_data.bn_friends ) do
    if ((friend.presenceID ~= 0) and friend.isOnline and friend.oq_enabled) then
      local m = "OQ,".. 
                OQ_VER ..",".. 
                "W1,"..
                OQ_TTL ..","..
                "mbox_bn_enable,".. 
                friend.toonName ..","..
                tostring(oq.realm_cooked( friend.realm )) ..","..
                tostring(1) ;
      oq.whisper_msg( to_name, player_realm, m ) ;
    end
  end
end

function oq.mbsync_single( toonName, toonRealm ) 
  for i,v in pairs(OQ_toon.my_toons) do
    local m = "OQ,".. 
              OQ_VER ..",".. 
              "W1,"..
              OQ_TTL ..","..
              "mbox_bn_enable,".. 
              toonName ..","..
              tostring(oq.realm_cooked( toonRealm )) ..","..
              tostring(1) ;
    oq.whisper_msg( v.name, player_realm, m ) ;
  end
end

function oq.mbsync()
  for i,v in pairs(OQ_toon.my_toons) do
    oq.mbsync_toons( v.name ) ;
  end
end

function oq.on_mbox_bn_enable( name, realm, is_enabled )
  oq.bntoons() ;
  if (is_enabled == "0") then
    is_enabled = nil ;
  else
    is_enabled = true ;
  end
  realm = oq.realm_uncooked(realm) ;
  local friend = OQ_data.bn_friends[ name .."-".. realm ] ;
  if (friend == nil) then
    OQ_data.bn_friends[ name .."-".. realm ] = {} ;
    friend = OQ_data.bn_friends[ name .."-".. realm ] ;
    friend.isOnline      = nil ;
    friend.toonName      = name ;
    friend.realm         = realm ;
    friend.presenceID    = 0 ;
    return ;
  end
  friend.oq_enabled    = is_enabled ;
end

-- notify multi-box toons on same b-net that the toon is bn-enabled
--
function oq.mbnotify_bn_enable( name, realm, is_enabled ) 
  if (OQ_toon.my_toons == nil) or (#OQ_toon.my_toons == 0) then
    return ;
  end

  local m = "OQ,".. 
            OQ_VER ..",".. 
            "W1,"..
            OQ_TTL ..","..
            "mbox_bn_enable,".. 
            name ..","..
            tostring(oq.realm_cooked( realm )) ..","..
            (is_enabled or 1) ;

  for i,v in pairs(OQ_toon.my_toons) do
    oq.whisper_msg( v.name, player_realm, m ) ;
  end
end

-- returns first pid of a toon on the desired realm
function oq.bnpresence_realm( realm ) 
  if (realm == nil) then
    return nil ;
  end
  for i,v in pairs(OQ_data.bn_friends) do
    if (v.realm == realm) and (v.oq_enabled) and (v.isOnline) then
      return v.pid ;
    end
  end
  return 0 ;
end

function oq.bn_echo_msg( name, realm, msg )
  local pid = oq.bnpresence( name .."-".. realm ) ;
  if (pid == 0) then
    return ;
  end
  if (oq.bn_ok2send( msg, pid )) then
    oq.BNSendWhisper( pid, msg, name, realm ) ;
  end
end

function oq.bn_echo_raid( msg )
  for gid,g in pairs(oq.raid.group) do
    if (gid ~= my_group) then
      for slot,m in pairs( g.member ) do
        if (m.realm ~= nil) and (m.realm ~= player_realm) then
          oq.bn_echo_msg( m.name, m.realm, msg ) ;
        end
      end
    end
  end
end

function oq.check_pending_invites()
  if ((oq.pending_invites == nil) or _inside_bg) then
    return ;
  end
  
  for name,v in pairs(oq.pending_invites) do
    local friend = OQ_data.bn_friends[ name ] ;
    if (friend ~= nil) then
      if (not friend.oq_enabled) then
        oq.mbnotify_bn_enable( friend.toonName, friend.realm, 1 ) ; 
      end
      friend.oq_enabled = true ; -- they got on the invite-list, must be enabled
      InviteUnit( name ) ;
      oq.timer_oneshot( 2.0, oq.brief_group_members ) ;  
      oq.pending_invites[ name ] = nil ;
    end
  end
end

function oq.bn_check_online()
  next_bn_check = 0 ; -- force check
  oq.bntoons() ; 
  oq.n_connections() ; -- should update the connection info on the find-premade tab
end

function oq.set_bn_enabled( pid ) 
  -- find author in OQ_data.bn_friends and set him oq_enabled
  -- lot of work per msg.  how to reduce?  (another table??)
  -- 
  oq.bntoons() ;
  if (OQ_data.bn_friends == nil) then
    return ;
  end
  
  for name,friend in pairs(OQ_data.bn_friends) do
    if (friend.presenceID == pid) then
      if (not friend.oq_enabled) then 
        oq.mbnotify_bn_enable( friend.toonName, friend.realm, 1 ) ;      
      end
      friend.oq_enabled = true ;
    end
  end
end

function oq.bn_clear()
  OQ_data.bn_friends = {} ;
  next_bn_check = 0 ;
  oq.bntoons() ; -- have lost all OQ enabled friends
end

function oq.bn_force_verify()
  next_bn_check = 0 ; -- force the check
  oq.bntoons() ;  
end

function oq.remove_friend_by_pid( pid, btag, givenName, option, why )
  if (option == "show") or (option == "list") then
    print( OQ_DIAMOND_ICON .."  ".. tostring(btag or givenName) .."  (".. tostring(why) ..")" ) ;
    return ;
  end
  print( OQ_DIAMOND_ICON .."  removing ".. btag or givenName .."  (".. tostring(why) ..")" ) ;
  if (OQ_data.bn_friends ~= nil) then
    for n,friend in pairs(OQ_data.bn_friends) do
      if (friend.presenceID == pid) then
        friend = {} ;
      end
    end
  end
  BNSetFriendNote( pid, "" ) ;
  BNRemoveFriend( pid ) ;
end

function oq.remove_OQadded_bn_friends( option )
  local ntotal, nonline = BNGetNumFriends() ;
  local now = utc_time() ;
  local removal_text = "REMOVE ".. OQ_HEADER ;
  for i=ntotal,1,-1 do
    local f = { BNGetFriendInfo( i ) } ;
    local presenceID = f[1] ;
    local givenName  = f[2] ;
    local btag       = f[3] ;
    local noteText   = f[13] or "" ;
    -- remove this friend from OQ_data if noted
    if (noteText == "REMOVE OQ") or (noteText == "OQ,mesh node") then
      oq.remove_friend_by_pid( presenceID, btag, givenName, option, "group member" ) ;
    elseif (noteText == "OQ,leader") and (oq.raid.raid_token == nil) then
      oq.remove_friend_by_pid( presenceID, btag, givenName, option, "group leader" ) ;
    elseif ((noteText == "") and oq.in_btag_cache( btag )) then
      oq.remove_friend_by_pid( presenceID, btag, givenName, option, "mesh auto-add" ) ;
    end
  end  
  if (option ~= "show") and (option ~= "list") then
    oq.clear_btag_cache() ; -- clear the btag cache so it can start fresh
  end
  oq.bn_check_online() ;
end

function oq.is_enabled(toonName, realm)
  local n = toonName .."-".. realm ;
  if (OQ_data.bn_friends[ n ] == nil) then
    return nil ;
  end
  return OQ_data.bn_friends[ n ].oq_enabled ;
end

function oq.bn_show_pending()
  if (oq.pending_invites == nil) then
    print( "pending list is empty" ) ;
    oq.pending_invites = {} ;
  else
    print( "pending ---" ) ;
    for i,v in pairs(oq.pending_invites) do
      print( i .." raid( ".. i ..".".. v.gid ..".".. v.slot ..") ".. v.rid ) ;
    end
    print( "--- total: ".. #oq.pending_invites ) ;
  end

  if (oq.waitlist == nil) then
    print( "wait list is empty" ) ;
    oq.waitlist = {} ;
  else  
    print( "waiting ---" ) ;
    for i,v in pairs(oq.waitlist) do
      print( "[".. i .."] [".. v.name .."-".. v.realm .."] [".. v.realid .."]" ) ;
    end
    print( "--- total: ".. #oq.waitlist ) ;
  end
end

function oq.announce( msg, to_name, to_realm )
  if ((msg == nil) or OQ_toon.disabled) then
    return ;
  end
  if (to_name ~= nil) then
    if (to_realm == player_realm) then
      local msg_tok = "W".. oq.token_gen() ;
      oq.token_push( msg_tok ) ;
      m = "OQ,".. OQ_VER ..",".. msg_tok ..",".. OQ_TTL ..",".. msg ;
      oq.SendAddonMessage( "OQ", m, "WHISPER", to_name ) ;
      return ;
    end
    -- try to go direct if pid exists
    local pid = oq.bnpresence( to_name .."-".. to_realm ) ;
    if (pid ~= 0) then
      local msg_tok = "W".. oq.token_gen() ;
      oq.token_push( msg_tok ) ;
      m = "OQ,".. OQ_VER ..",".. msg_tok ..",".. OQ_TTL ..",".. msg ;
      oq.BNSendWhisper( pid, m, to_name, to_realm ) ;
      return ;
    end
    -- if i have a bn-friend on the target realm, bnsend it to them and return
    pid = oq.bnpresence_realm( to_realm ) ;
    if (pid ~= 0) then
      local msg_tok = "A".. oq.token_gen() ;
      oq.token_push( msg_tok ) ;
      m = "OQ,".. OQ_VER ..",".. msg_tok ..",".. OQ_TTL ..",".. msg ;
      oq.BNSendWhisper( pid, m, to_name, to_realm ) ;
      return ;
    end

    msg = msg ..",".. OQ_FLD_TO .."".. to_name ..",".. OQ_FLD_REALM .."".. tostring(oq.realm_cooked( to_realm )) ;
  end
  local msg_tok = "A".. oq.token_gen() ;
  oq.token_push( msg_tok ) ;

  local m = "OQ,".. OQ_VER ..",".. msg_tok ..",".. OQ_TTL ..",".. msg ;

  -- send to raid (which sends to local channel and real-id ppl in the raid)
  oq.announce_relay( m ) ;
end

--
-- message relays
--
function oq.announce_relay( m )
  if (OQ_toon.disabled) then
    return ;
  end
  -- send to general channel
  if (_inc_channel ~= "oqgeneral") then
    oq.channel_general( m ) ;
  end

  -- send to raid channels
  if (oq.raid.raid_token ~= nil) then
    oq.raid_announce_relay( m ) ;
  end

  -- send to real-id list for ppl not in the raid (hoping they will forward to their local OQGeneral channel)
  if (_dest_realm == nil) or (_dest_realm ~= player_realm) then
    oq.bnfriends_relay( m ) ;
  end
end

--local OQ_last_sent = {} ;

function oq.bnfriends_relay( m )
  oq.bntoons() ; -- just incase the information has changed 
  if (OQ_data.bn_friends == nil) then
    return ;
  end
  local dt = 0.1 ;
  local tags = {} ;
  local realms = {} ;
  local cnt = 1 ;
  for i,v in pairs(OQ_data.bn_friends) do
    if (v.isOnline and v.oq_enabled and v.toonName and v.realm and (v.realm ~= player_realm) and (realms[v.realm] == nil)) then
      tags[cnt] = v ;
      cnt = cnt + 1 ;
      realms[v.realm] = true ;
    end
  end
  if (cnt <= 10) then
    for i,v in pairs(tags) do
--      oq.timer_oneshot( dt, oq.BNSendWhisper, v.presenceID, m, v.toonName, v.realm ) ;
--      dt = dt + 0.25 ;
      oq.BNSendWhisper( v.presenceID, m, v.toonName, v.realm ) ;
    end
  else
    local names = {} ;
    for i=1,10 do
      local ndx = random(1,cnt) ;
      local v = tags[ndx] ;
      if (v ~= nil) and (v.toonName ~= nil) and (names[v.toonName] == nil) then 
        names[v.toonName] = true ;
--        oq.timer_oneshot( dt, oq.BNSendWhisper, v.presenceID, m, v.toonName, v.realm ) ;
--        dt = dt + 0.25 ;
        oq.BNSendWhisper( v.presenceID, m, v.toonName, v.realm ) ;
      end
    end
  end
end

--
--  send to local OQRaid channel then to real-id friends in the raid
--
function oq.raid_announce( msg, msg_tok )
  if (oq.raid.raid_token == nil) then
    -- no raid token means not in a raid
    return ;
  end

  if (msg_tok == nil) then
    -- the 'R' stands for 'raid' and should not be echo'd far and wide
    msg_tok = "R".. oq.token_gen() ;
    oq.token_push( msg_tok ) ;
  end

  local m = "OQ,".. OQ_VER ..",".. msg_tok ..",".. oq.raid.raid_token ..",".. msg ;
  oq.raid_announce_relay( m ) ;
--  oq.bn_echo_raid( m ) ;
end

function oq.raid_announce_relay( m )
  -- if we get here then the message must have come from OUTSIDE the raid/party
  -- 
  if (_inside_bg) or (oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID) then
    oq.SendAddonMessage( "OQ", m, "RAID" ) ;
    return ;
  end  
  
  if (oq.iam_raid_leader() == true) then
    -- send to party leaders
    if (oq.raid.group ~= nil) then
      for i,grp in pairs(oq.raid.group) do
        local lead = grp.member[1] ;
        if ((lead.name ~= nil) and (lead.name ~= "-") and (lead.name ~= player_name) and (lead.realm ~= nil)) then
          oq.whisper_msg( lead.name, lead.realm, m ) ;
        end
      end
    end
  elseif (oq.iam_party_leader() == true) then
    -- send to raid_leader
    oq.whisper_raid_leader( m ) ;
  else
  end
  -- send to my own party
  oq.channel_party( m ) ;
end

function oq.raid_announce_member( group_id, slot, name, realm, class ) 
  if ((name == nil) or (name == "-")) then
    return ;
  end
  oq.raid_announce( "member,".. group_id ..",".. slot ..",".. tostring(class) ..",".. tostring(name) ..",".. tostring(oq.realm_cooked( realm )) ) ;
end

function oq.party_announce( msg )
  if (oq.raid.raid_token == nil) or (not oq.iam_in_a_party()) then
    return ;
  end
  -- the 'P' stands for 'party' and should not be echo'd far and wide
  msg_tok = "P".. oq.token_gen() ;
  oq.token_push( msg_tok ) ;

  local m = "OQ,".. OQ_VER ..",".. msg_tok ..",".. oq.raid.raid_token ..",".. msg ;
  
  -- send to party channel
  oq.channel_party( m ) ;
end

function oq.send_to_group_leads( m ) 
  if (oq.iam_raid_leader()) then  
    for i=2,8 do
      local grp = oq.raid.group[i] ;
      if ((grp.member ~= nil) and (grp.member[1].name ~= nil) and (grp.member[1].name ~= "-") and (grp.member[1].realm ~= nil)) then
        oq.whisper_msg( grp.member[1].name, grp.member[1].realm, m ) ;
      end
    end
  end
end

function oq.boss_announce( msg )
  if (not oq.iam_raid_leader() and not oq.iam_party_leader()) then  
    if (oq.raid.type ~= OQ.TYPE_RBG) and (oq.raid.type ~= OQ.TYPE_RAID) then
      return ;
    end
  end

  -- the 'B' stands for 'bosses' and should not be echo'd 
  local msg_tok = "B".. oq.token_gen() ;
  oq.token_push( msg_tok ) ;

  local m = "OQ,".. OQ_VER ..",".. msg_tok ..",".. oq.raid.raid_token ..",".. msg ;
  
  if (oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID) then
    oq.SendAddonMessage( "OQ", m, "RAID" ) ;
    return ;
  end  
  -- send to bosses
  if (oq.iam_raid_leader()) then  
    oq.send_to_group_leads( m ) ;
  elseif (oq.iam_party_leader()) then
    oq.whisper_raid_leader( m ) ;
  end
end

--
--  ONLY sent by raid leader
--
function oq.raid_disband()
  if (oq.iam_raid_leader()) then
    local token = oq.token_gen() ;
    oq.token_push( token ) ;
    oq.announce( "disband,".. oq.raid.raid_token ..",".. token  ) ;
    oq.on_disband( oq.raid.raid_token, token, true ) ;
  end
end

function oq.raid_find()
  local now = utc_time() ;
  if ((_last_find_tm + 8) > now) then
    return ; -- too soon.  no more then 1 find per 8 seconds
  end
  _last_find_tm = now ;

  local subtok = string.format( "%04d", utc_time() % 10000 ) ;
  oq.announce( "find,"..
               oq.my_tok .."".. subtok ..","..
               player_faction ..","..
               oq.get_player_level_range() ..","..
               player_realm
             ) ;
end

function oq.raid_join( ndx, bg_type )
  oq.raid_announce( "join,".. ndx ..",".. bg_type ) ;
end

function oq.raid_leave( ndx )
  oq.raid_announce( "leave,".. ndx ) ;
end

function oq.raid_ping()
  oq.boss_announce( "ping,".. oq.my_tok ..",".. GetTime()*1000 ) ;
end

function oq.raid_ping_ack( tok, tm )
  if (my_group == 0) then
    local name = _from ;
    local realm = nil ;
    if (_from:find("-")) then
      name  = _from:sub( 1, _from:find("-")-1 ) ;
      realm = _from:sub( _from:find("-")+1, -1 ) ;
      realm = oq.realm_uncooked(realm) ;
    end
    local msg = "ping_ack,".. tok ..",".. tm ..",".. (my_group or 0) ;
    oq.whisper_msg( name, realm, msg ) ;
  else
    oq.boss_announce( "ping_ack,".. tok ..",".. tm ..",".. (my_group or 0) ) ;
  end
end

function oq.ping_toon( toon )
  local name = toon ;
  local realm = player_realm ;
  if (toon:find("-")) then
    name = toon:sub( 1, toon:find("-")-1 ) ;
    realm = toon:sub( toon:find("-")+1, -1 ) ;
    realm = oq.realm_uncooked(realm) ;
  end
  oq.whisper_msg( name, realm, "ping,".. oq.my_tok ..",".. GetTime()*1000 ) ;
end

function oq.remove_all_premades()
  oq.premades = {} ;
  for i,v in pairs(oq.tab2_raids) do
    v:Hide() ;
    oq.tab2_raids[i] = nil ; -- erased, but not cleaned up... should be reclaimed
  end
  oq.reshuffle_premades() ;
end

function oq.remove_dead_premades()
  if (_inside_bg) then
    return ;
  end
  
  local now = utc_time() ;
  for i,v in pairs(oq.premades) do
    -- don't remove my own premade
    if (v.raid_token ~= oq.raid.raid_token) then
      -- time since last update 
      if ((now - v.tm) > OQ_PREMADE_STAT_LIFETIME) then
        oq.remove_premade( i ) ;
      end
    end
  end
end

function oq.remove_premade( token )
  if (oq.premades[ token ] ~= nil) then
    -- hold onto the token & b-tag combo incase the user wants to ban the group lead
    if (oq.old_raids == nil) then
      oq.old_raids = {} ;
    end
    if (oq.old_raids[token] == nil) and (oq.premades[token].leader_rid ~= nil) then
      oq.old_raids[token] = { btag = oq.premades[token].leader_rid } ;
    end
    oq.premades[ token ] = nil ;
  end
  local reshuffle = nil ;
  for i,v in pairs(oq.tab2_raids) do
    if (v.token == token) then
      reshuffle = true ;
      v:Hide() ;
      oq.tab2_raids[i] = nil ;   -- erased, but not cleaned up... should be reclaimed
      oq.premades[token] = nil ; -- erased
      break ;
    end
  end

  if (reshuffle) then
    oq.reshuffle_premades() ;
  end
end

function oq.compare_premades(a,b)
  if (a == nil) then
    return false ;
  elseif (b == nil) then
    return true ;
  end
  local v1 = oq.tab2_raids[a] ;
  local v2 = oq.tab2_raids[b] ;
  local p1 = oq.premades[ v1.raid_token ] ;
  local p2 = oq.premades[ v2.raid_token ] ;
  if (oq.premade_sort_ascending == nil) then
    p1 = oq.premades[ v2.raid_token ] ;
    p2 = oq.premades[ v1.raid_token ] ;
  end
  if (p1 == nil) then
    return false ;
  elseif (p2 == nil) then
    return true ;
  end
  if (oq.premade_sort == "name") then
    return (strlower(p1.name) < strlower(p2.name)) ;
  end
  if (oq.premade_sort == "lead") then
    return (p1.leader < p2.leader) ;
  end
  if (oq.premade_sort == "level") then
    return (p1.level_range < p2.level_range) ;
  end
  if (oq.premade_sort == "ilevel") then
    return (p1.min_ilevel < p2.min_ilevel) ;
  end
  if (oq.premade_sort == "resil") then
    return (p1.min_resil < p2.min_resil) ;
  end
  if (oq.premade_sort == "mmr") then
    return (p1.min_mmr < p2.min_mmr) ;
  end
  return true ;
end

function oq.qualified( token )
  if (token == nil) then
    return false ;
  end
  local p = oq.premades[ token ] ;
  if (p == nil) then
    return false ;
  end
  if (oq.get_player_level_id() ~= OQ.SHORT_LEVEL_RANGE[p.level_range]) then
    return false ;
  end
  if (p.type == OQ.TYPE_ARENA) and (p.leader_realm ~= player_realm) then
    return ;
  end
  if (oq.get_ilevel() < p.min_ilevel) then
    return false ;
  end
  if (oq.get_resil() < p.min_resil) then
    return false ;
  end
  if (oq.get_mmr() < p.min_mmr) then
    return false ;
  end
  return true ;
end

function oq.reshuffle_premades() 
  local x, y, cx, cy ;
  x  = 20 ;
  y  = 10 ;
  cy = 25 ;
  cx = oq.tab2_list:GetWidth() - 2*x ;

  local items = {} ;
  for n,v in pairs(oq.tab2_raids) do 
    v._isvis = nil ;
    if (oq.premade_filter_qualified == 1) and (not oq.qualified(v.raid_token)) then
      v:Hide() ;
    else
      local p = oq.premades[ v.raid_token ] ;
      if (p ~= nil) and (p.type == OQ.TYPE_ARENA) and (p.leader_realm ~= player_realm) then
        v:Hide() ;
      elseif (p ~= nil) and ((oq.premade_filter_type == OQ.TYPE_NONE) or (p.type == oq.premade_filter_type)) then
        v:Show() ;
        v._isvis = true ; 
        table.insert(items, n) ;
      else
        v:Hide() ;
      end
    end
  end
  table.sort(items, oq.compare_premades) ;
  oq._npremades = 0 ;
  for i,v in pairs(items) do
    oq.setpos( oq.tab2_raids[v], x, y, cx, cy ) ;
    y = y + cy + 2 ;
    oq._npremades = oq._npremades + 1 ;
  end
  
  local max_y = y + cy ;
  local default_max = 340 ;
  if (max_y < default_max) then
    max_y = default_max ;
  end
  oq.tab2_list:SetHeight( max_y ) ;
  
  oq.update_premade_count() ;
end

function oq.n_waiting()
  local n = 0 ;
  if (oq.tab7_waitlist ~= nil) then
    for i,v in pairs(oq.tab7_waitlist) do
      n = n + v.nMembers ;
    end
  end
  return n ;
end

function oq.find_premade_entry( raid_token )
  local n = 0 ;
  if (oq.tab2_raids ~= nil) then
    for i,v in pairs(oq.tab2_raids) do
      if (v.raid_token == raid_token) then
        return v ;
      end
    end
  end
end

--
-- ban list
-- 
function oq.create_ban_listitem( parent, x, y, cx, cy, btag, reason )
  oq.nthings = (oq.nthings or 0) + 1 ;
  local n = "Banned".. oq.nthings ;
  local f = oq.panel( parent, n, x, y, cx, cy ) ;
  
  f.texture:SetTexture( 0.0, 0.0, 0.0, 1 ) ;

  local x2 = 0 ;
  f.remove_but = oq.button( f, x2, 2,  23, cy-2, "x", function(self) oq.remove_banlist_item( self:GetParent().btag:GetText() ) ; end ) ;
  x2 = x2 + 40 + 2 ;
  f.btag   = oq.label ( f, x2, 2, 125, cy, btag ) ;
  f.btag:SetFont(OQ.FONT, 10, "") ;
  x2 = x2 + 125 + 2 ;
  f.reason = oq.label ( f, x2, 2, 450, cy, reason ) ;
  f.reason:SetFont(OQ.FONT, 10, "") ;
  f.reason:SetTextColor( 0.9, 0.9, 0.9 ) ;
  f:Show() ;
  return f ;         
end

function oq.populate_ban_list() 
  if (OQ_data.banned == nil) then
    OQ_data.banned = {} ;
  end
  local x, y, cx, cy ;
  x = 1 ;
  y = 1 ;
  cx = 200 ;
  cy = 22 ;
  for i,v in pairs(OQ_data.banned) do
    local f = oq.create_ban_listitem( oq.tab6_list, x, y, cx, cy, i, v.reason ) ;
    table.insert( oq.tab6_banlist, f ) ;
    y = y + cy ;
  end
  oq.reshuffle_banlist() ;  
end

function oq.reshuffle_banlist() 
  local x, y, cx, cy, n ;
  x  = 20 ;
  y  = 10 ;
  cy = 25 ;
  cx = oq.tab6_list:GetWidth() - 2*x ;
    
  oq._nbanlist = 0 ;
  for i,v in pairs(oq.tab6_banlist) do
    oq.setpos( v, x, y, cx, cy ) ;
    y = y + cy + 2 ;
    oq._nbanlist = oq._nbanlist + 1 ;
  end
  
  local max_y = y + cy ;
  local default_max = 340 ;
  if (max_y < default_max) then
    max_y = default_max ;
  end
  oq.tab6_list:SetHeight( max_y ) ;  
end

function oq.remove_all_banlist()
  oq.ban_clearall() ;
  for i,v in pairs(oq.tab6_banlist) do
    v:Hide() ;
    oq.tab6_banlist[i] = nil ; -- erased, but not cleaned up... should be reclaimed
  end
  oq.reshuffle_banlist() ;
end

function oq.remove_banlist_item( btag )
  local reshuffle = nil ;
  for i,v in pairs(oq.tab6_banlist) do
    if (v.btag:GetText() == btag) then
      reshuffle = true ;
      v:Hide() ;
      oq.tab6_banlist[i] = nil ; -- erased, but not cleaned up... should be reclaimed
      break ;
    end
  end

  if (reshuffle) then
    oq.reshuffle_banlist() ;
  end

  oq.ban_remove( btag ) ;
end

--
-- wait list
--
function oq.compare_waitlist(a,b)
  if (a == nil) then
    return false ;
  elseif (b == nil) then
    return true ;
  end
  local v1 = oq.tab7_waitlist[a] ;
  local v2 = oq.tab7_waitlist[b] ;
  local p1 = oq.waitlist[ v1.token ] ;
  local p2 = oq.waitlist[ v2.token ] ;
  if (oq.waitlist_sort_ascending == nil) then
    v1 = oq.tab7_waitlist[b] ;
    v2 = oq.tab7_waitlist[a] ;
    p1 = oq.waitlist[ v1.token ] ;
    p2 = oq.waitlist[ v2.token ] ;
  end
  if (oq.waitlist_sort == "bgrp") then
    return (strlower(oq.find_bgroup(p1.realm)) < strlower(oq.find_bgroup(p2.realm))) ;
  end
  if (oq.waitlist_sort == "name") then
    return (strlower(p1.name) < strlower(p2.name)) ;
  end
  if (oq.waitlist_sort == "rlm") then
    return (strlower(p1.realm) < strlower(p2.realm)) ;
  end
  if (oq.waitlist_sort == "level") then
    return (p1.level < p2.level) ;
  end
  if (oq.waitlist_sort == "ilevel") then
    return (p1.ilevel < p2.ilevel) ;
  end
  if (oq.waitlist_sort == "resil") then
    return (p1.resil < p2.resil) ;
  end
  if (oq.waitlist_sort == "mmr") then
    return (p1.mmr < p2.mmr) ;
  end
  if (oq.waitlist_sort == "power") then
    return (p1.pvppower < p2.pvppower) ;
  end
  if (oq.waitlist_sort == "time") then
    return (v1.create_tm < v2.create_tm) ;
  end
  return true ;
end

function oq.reshuffle_waitlist() 
  local x, y, cx, cy, n ;
  x  = 20 ;
  y  = 10 ;
  cy = 25 ;
  cx = oq.tab7_list:GetWidth() - 2*x ;
  n  = 0 ;

  local items = {} ;
  for n,v in pairs(oq.tab7_waitlist) do 
    if (n ~= nil) then 
      table.insert(items, n) ; 
    end
  end
  table.sort(items, oq.compare_waitlist) ;
  oq._nwaitlist = 0 ;
  for i,v in pairs(items) do
    oq.setpos( oq.tab7_waitlist[v], x, y, cx, cy ) ;
    y = y + cy + 2 ;
    n = n + oq.tab7_waitlist[v].nMembers ;
    oq._nwaitlist = oq._nwaitlist + 1 ;
  end
    
  local max_y = y + cy ;
  local default_max = 340 ;
  if (max_y < default_max) then
    max_y = default_max ;
  end
  oq.tab7_list:SetHeight( max_y ) ;  
  if (n > 0) then
    OQMainFrameTab7:SetText( string.format( OQ.TAB_WAITLISTN, n ) ) ;
  else
    OQMainFrameTab7:SetText( OQ.TAB_WAITLIST ) ;
  end
end

function oq.remove_all_waitlist()
  oq.waitlist = {} ;
  for i,v in pairs(oq.tab7_waitlist) do
    v:Hide() ;
    oq.tab7_waitlist[i] = nil ; -- erased, but not cleaned up... should be reclaimed
  end
  oq.reshuffle_waitlist() ;
end

function oq.remove_waitlist( token )
  local reshuffle = nil ;
  for i,v in pairs(oq.tab7_waitlist) do
    if (v.token == token) then
      reshuffle = true ;
      v:Hide() ;
      oq.tab7_waitlist[i] = nil ; -- erased, but not cleaned up... should be reclaimed
      break ;
    end
  end

  if (reshuffle) then
    oq.reshuffle_waitlist() ;
  end

  -- now tell the remote user he has been removed
  local r = oq.waitlist[ token ] ;
  if (r ~= nil) then
    oq.timer_oneshot( 2, oq.realid_msg, r.name, r.realm, r.realid, 
                      OQ_MSGHEADER .."".. 
                      OQ_VER ..","..
                      "W1,"..
                      "0,"..
                      "removed_from_waitlist,"..
                      oq.raid.raid_token ..","..
                      token
                    ) ;
  end
  
  -- clean up the waitlist  
  if (oq.waitlist[ token ] ~= nil) then
    oq.waitlist[ token ] = nil ;
  end
end

function oq.on_removed_from_waitlist( raid_token, req_token )
  -- set the premade button from 'pending' back to 'waitlist'
  local f = oq.find_premade_entry( raid_token ) ;
  if (f ~= nil) then
    f.req_but:SetText( OQ.BUT_WAITLIST ) ;
    f.req_but:SetBackdropColor( 0.5, 0.5, 0.5, 1 ) ;
    f.pending = nil ;
    if (oq.raid.raid_token == nil) then
      -- sad sound if no group and leaving wait list
      PlaySound( "igQuestFailed" ) ;
    end
  end
  
  -- remove from oq.pending
  oq.pending[ raid_token ] = nil ;
end

function oq.on_leave_waitlist( raid_token, req_token )
  if (raid_token ~= oq.raid.raid_token) then
    -- not for me
    return ;
  end
  oq.remove_waitlist( req_token ) ;  
end

function oq.send_leave_waitlist( raid_token )
  if (raid_token == nil) then
    return ;
  end
  local now = utc_time() ;
  local req = oq.pending[ raid_token ] ;
  local raid = oq.premades[ raid_token ] ;
  if (req == nil) or (raid == nil) or (req.next_msg_tm > now) or (req.req_token == nil) then
    return ;
  end
  req.next_msg_tm = now + 5 ;
  
  if (raid_token == oq.raid.raid_token) then
    -- i've joined the raid.  just remove the entry
    oq.pending[ raid_token ] = nil ;
    local f = oq.find_premade_entry( raid_token ) ;
    if (f ~= nil) then
      f.req_but:SetText( OQ.BUT_WAITLIST ) ;
      f.req_but:SetBackdropColor( 0.5, 0.5, 0.5, 1 ) ;
      f.pending = nil ;
      if (oq.raid.raid_token == nil) then
        -- sad sound if no group and leaving wait list
        PlaySound( "igQuestFailed" ) ;
      end
    end
  else
    oq.realid_msg( raid.leader, raid.leader_realm, raid.leader_rid, 
                   OQ_MSGHEADER .."".. 
                   OQ_VER ..","..
                   "W1,"..
                   "0,"..
                   "leave_waitlist,"..                 
                   raid_token ..","..
                   req.req_token 
                 ) ;
  end
end

--
-- this is called to remove the player from all waitlists they may have put themselves on
--
function oq.clear_pending()
  for raid_token,req in pairs( oq.pending ) do
    oq.send_leave_waitlist( raid_token ) ;
  end
end

function oq.check_and_send_request( raid_token )
  local in_party = (oq.GetNumPartyMembers() > 0) ;
  if (in_party and not UnitIsGroupLeader("player")) then
    StaticPopup_Show("OQ_NotPartyLead", nil, nil, ndx ) ;
    return ;
  end
  
  local raid  = oq.premades[ raid_token ] ;
  if (raid ~= nil) then
    if (raid.has_pword ~= nil) then
      PlaySoundFile( "Sound\\interface\\KeyRingOpen.wav" ) ;
      local dialog = StaticPopup_Show("OQ_EnterPword") ;
      dialog.data = raid_token ;
    else
      oq.send_req_waitlist( raid_token, "" ) ;
    end
  end
end

function oq.send_req_waitlist( raid_token, pword ) 
  local in_party = (oq.GetNumPartyMembers() > 0) ;
  
  local now = utc_time() ;
  local req = oq.pending[ raid_token ] ;
  if (req == nil) then
    oq.pending[ raid_token ] = {} ;
    req = oq.pending[ raid_token ] ;
  elseif (req.next_msg_tm > now) then
    -- too soon for resend. no more then once every 5 seconds
    return ;
  end
  req.next_msg_tm = now + 5 ;

  local req_token = req.req_token ;

  if (req_token == nil) then
    req_token = "Q".. oq.token_gen() ;
    req.req_token = req_token ;
    oq.token_push( req_token ) ;  -- hang onto it for return
  end

  oq.gather_my_stats() ;
  local flags = OQ_FLAG_ONLINE ;
  local raid  = oq.premades[ raid_token ] ;
  _dest_realm = raid.leader_realm ;
  
  if (player_realm ~= _dest_realm) and (not oq.valid_rid( player_realid )) then
    message( OQ.BAD_REALID .." ".. tostring(player_realid) ) ;
    return ;
  end

  if (in_party) then
    -- must be party leader.  
    local party_avg_ilevel = 0 ;
    local party_avg_resil  = 0 ;  
    local mmr = oq.get_mmr() ;
    local pvppower = oq.get_pvppower() ;
    local stats = oq.encode_short_stats( player_level, player_faction, player_class, party_avg_resil, party_avg_ilevel, player_role, mmr, pvppower ) ;
    local enc_data = oq.encode_data( "abc123", player_name, player_realm, player_realid ) ;
    oq.realid_msg( raid.leader, raid.leader_realm, raid.leader_rid, 
                   OQ_MSGHEADER .."".. 
                   OQ_VER ..","..
                   "W1,"..
                   "0,"..
                   "req_invite,"..                 
                   raid_token ..","..
                   tostring(oq.GetNumPartyMembers()) ..","..
                   req_token ..","..
                   enc_data ..","..
                   stats ..","..
                   oq.encode_pword( pword ) 
                 ) ;
  else
    local mmr = oq.get_mmr() ;
    local pvppower = oq.get_pvppower() ;
    local stats = oq.encode_short_stats( player_level, player_faction, player_class, player_resil, player_ilevel, player_role, mmr, pvppower ) ;
    local enc_data = oq.encode_data( "abc123", player_name, player_realm, player_realid ) ;

    oq.realid_msg( raid.leader, raid.leader_realm, raid.leader_rid, 
                   OQ_MSGHEADER .."".. 
                   OQ_VER ..","..
                   "W1,"..
                   "0,"..
                   "req_invite,"..                 
                   raid_token ..","..
                   "1,"..
                   req_token ..","..
                   enc_data ..","..
                   stats ..","..
                   oq.encode_pword( pword ) 
                 ) ;
  end
end

-------------------------------------------------------------------------------
--   
-------------------------------------------------------------------------------
function oq.bg_name( tid )
  for i,v in pairs(OQ.BG_NAMES) do
    if (v.type_id == tid) then
      return i ;
    end
  end
end

function oq.bg_type_id( name ) 
  if (name == nil) then
    return -1 ;
  end
  if (OQ.BG_NAMES[ name ] == nil) then
    return -2 ;
  end
  return OQ.BG_NAMES[ name ].type_id ;
end

function oq.get_player_level_id() 
  if (player_level == 90) then
    return OQ.SHORT_LEVEL_RANGE[ "90" ] ;
  elseif (player_level < 10) then
    return OQ.SHORT_LEVEL_RANGE[ "unavailable" ] ;
  end
  local minlevel = floor( player_level / 5) * 5 ;
  local maxlevel = floor((player_level + 5) / 5) * 5 - 1 ;
  return OQ.SHORT_LEVEL_RANGE[ string.format( "%d - %d", minlevel, maxlevel ) ] ;
end

function oq.get_player_level_range() 
  if (player_level == 90) then
    return 90, 90 ;
  elseif (player_level < 10) then
    return 0,0 ;
  end
  local minlevel, maxlevel ;

  minlevel = floor(player_level / 5) * 5 ;
  maxlevel = floor((player_level + 5) / 5) * 5 - 1 ;

  return minlevel, maxlevel ;
end


function oq.make_frame_moveable( f )
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)
  f:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not self.isMoving then
     self:StartMoving();
     self.isMoving = true;
    end
  end)
  f:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" and self.isMoving then
     self:StopMovingOrSizing();
     self.isMoving = false;
    end
  end)
  f:SetScript("OnHide", function(self)
    if ( self.isMoving ) then
    self:StopMovingOrSizing();
    self.isMoving = false;
    end
  end)
end

function oq.moveto( f, x, y ) 
  if (y >= 0) then
    if (x >= 0) then 
      f:SetPoint("TOPLEFT",f:GetParent(),"TOPLEFT", x, -1 * y)
    else
      f:SetPoint("TOPRIGHT",f:GetParent(),"TOPRIGHT", x, -1 * y)
    end
  else
    if (x >= 0) then 
      f:SetPoint("BOTTOMLEFT",f:GetParent(),"BOTTOMLEFT", x, -1 * y)
    else
      f:SetPoint("BOTTOMRIGHT",f:GetParent(),"BOTTOMRIGHT", x, -1 * y)
    end
  end
end

function oq.setpos( f, x, y, cx, cy )
  oq.moveto( f, x, y ) ;
  if (cx ~= nil) and (cx > 0) then
    f:SetWidth(cx) ;
  end
  if (cy ~= nil) and (cy > 0) then
    f:SetHeight(cy) ;
  end
  return f ;
end

function oq.set_tab_order( a, b )
  a.next_edit = b ;
  a:SetScript( "OnTabPressed", 
               function(self) 
                 if (self.next_edit ~= nil) then  
                   self.next_edit:SetFocus()  
                 end  
                end 
             ) ;
end

function oq.CreateFrame( type, name, parent, template )
  local f = CreateFrame( type, name, parent, template ) ;
  if (parent ~= nil) then
    f:SetFrameLevel( parent:GetFrameLevel() + 1 ) ;
  end
  return f ;
end

function oq.editline( parent, name, x, y, cx, cy, max_chars )
  oq.nthings = (oq.nthings or 0) + 1 ;
  local n = "OQ_".. name .."".. oq.nthings ;
  local e = oq.CreateFrame("EditBox", n, parent, "InputBoxTemplate" )
  e:SetPoint("TOPLEFT", parent, "TOPLEFT", 0,0 ) ; 
  e:SetText( "" ) ;
  e:SetAutoFocus(false)
  e:SetFontObject("GameFontNormal")
  e:SetMaxLetters(max_chars or 30)
  e:SetCursorPosition(0) ;
  e:SetTextColor( 0.9, 0.9, 0.9, 1 ) ;
  e.str = "" ;
  e:SetScript( "OnTextChanged"  , function(self) self.str = self:GetText() or "" ; if (self.func ~= nil) then self.func(self.str) ; end end ) ;
  e:SetScript( "OnEscapePressed", function(self) self:ClearFocus() end ) ;
  oq.setpos( e, x, y, cx, cy ) ;
  e:Show() ;
  return e ;
end

function oq.editbox( parent, name, x, y, cx, cy, max_chars, func, init_val )
  oq.nthings = (oq.nthings or 0) + 1 ;
  local n = "OQ_".. name .."".. oq.nthings ;
  local e = oq.CreateFrame("EditBox", n, parent ) ;
  e:SetMultiLine(true) ;
  e:SetPoint("TOPLEFT", parent, "TOPLEFT", x,-y ) ; 
  e:SetPoint("BOTTOMRIGHT", parent, "TOPLEFT", x+cx,-y-cy ) ; 
  e.str = init_val or "" ;
  e.func = func ;
  e:SetScript( "OnTextChanged"  , function(self) self.str = self:GetText() or "" ; if (self.func ~= nil) then self.func(self.str) ; end end ) ;
  e:SetScript( "OnEscapePressed", function(self) self:ClearFocus() end ) ;
  e:SetText(init_val or "" ) ;
  e:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                 edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                 tile=true, tileSize = 16, edgeSize = 16,
                 insets = { left = 1, right = 1, top = 1, bottom = 1 }
                 })

  e:SetBackdropColor(0.0,0.0,0.0,1.0);
  e:SetAlpha( 0.8 ) ;
  e:SetAutoFocus(false) ;
  e:SetFontObject("GameFontNormal") ;
  e:SetMaxLetters(max_chars or 30) ;
  e:SetCursorPosition(0) ;
  e:SetTextColor( 0.9, 0.9, 0.9, 1 ) ;
  e:SetTextInsets(5, 5, 5, 5) ;
  oq.setpos( e, x-4, y, cx, cy ) ;
  e:Show() ;
  return e ;
end

function oq.checkbox( parent, x, y, cx, cy, text_cx, text, is_checked, on_click_func )
  oq.nthings = (oq.nthings or 0) + 1 ;
  local n = "OQ_Check".. oq.nthings ;
  button = oq.CreateFrame("CheckButton", n, parent, "UICheckButtonTemplate")
  button:SetWidth(cx)
  button:SetHeight(cy)
  button.string = button:CreateFontString()
  button.string:SetWidth(text_cx)
  button.string:SetJustifyH("LEFT")
  button.string:SetPoint("LEFT", 24, 1)
  button:SetFontString(button.string)
  button:SetNormalFontObject("GameFontNormalSmall")
  button:SetHighlightFontObject("GameFontHighlightSmall")
  button:SetDisabledFontObject("GameFontDisableSmall")
  button:SetText(text)
  button:SetScript("OnClick", on_click_func )
  button:SetChecked( is_checked ) ;
  oq.moveto( button, x, y ) ;
  button:Show() 
  button:SetScript("OnEnter", function(self, ...) oq.hint(self, self.tt, true) ; end ) ;
  button:SetScript("OnLeave", function(self, ...) oq.hint(self, self.tt, nil ) ; end ) ;
  return button ;
end

function oq.radiobutton( parent, x, y, cx, cy, text_cx, text, value, on_click_func )
  oq.nthings = (oq.nthings or 0) + 1 ;
  local n = "OQ_RadioButton".. oq.nthings ;
  button = oq.CreateFrame("CheckButton", n, parent, "UIRadioButtonTemplate")
  button:SetWidth(cx)
  button:SetHeight(cy)
  button.value = value ;
  button.string = button:CreateFontString()
  button.string:SetWidth(text_cx)
  button.string:SetJustifyH("LEFT")
  button.string:SetPoint("LEFT", 24, 1)
  button:SetFontString(button.string)
  button:SetNormalFontObject("GameFontNormalSmall")
  button:SetHighlightFontObject("GameFontHighlightSmall")
  button:SetDisabledFontObject("GameFontDisableSmall")
  button:SetText(text)
  button:SetScript("OnClick", function(self) on_click_func( self ) ; end )
  button:SetChecked( nil ) ;
  oq.moveto( button, x, y ) ;
  button:Show() 
  return button ;
end

function oq.click_label( parent, x, y, cx, cy, text, justify_v, justify_h, font, template )
  oq.nthings = (oq.nthings or 0) + 1 ;
  local name = "OQClikLabel".. oq.nthings ;
  local f = oq.CreateFrame("Button", name, parent, template )
  f:SetWidth (cx) ; -- Set these to whatever height/width is needed 
  f:SetHeight(cy) ; -- for your Texture
  f:SetBackdropColor(0.2,0.9,0.2,1.0); -- transparent

  f:SetPoint( "TOPLEFT", x, -1 * y) ;
  f.label = oq.label( f, 0, 0, cx, cy, text, justify_v, justify_h, font ) ;
  f:Show()
  return f ;
end

function oq.label( parent, x, y, cx, cy, text, justify_v, justify_h, font )
  local label = parent:CreateFontString( nil, "BACKGROUND", font or "GameFontNormalSmall")
  label:SetWidth( cx ) ;
  label:SetHeight(cy or 25)
  label:SetJustifyV( justify_v or "CENTER" )
  label:SetJustifyH( justify_h or "LEFT" )
  label:SetText( text )
  label:Show() 
  oq.moveto( label, x, y ) ;
  return label ;
end

function oq.nVisible( type )
  if (type == "banlist") then
    return oq._nbanlist or 0 ;
  elseif (type == "waitlist") then
    return oq._nwaitlist or 0 ;
  elseif (type == "premades") then
    return oq._npremades or 0 ;
  end
  return 0 ;
end

function OQ_ModScrollBar_Update(f)
  local nItems = max( 14, oq.nVisible(f._type) ) ;
  FauxScrollFrame_Update( f, nItems, 5, 25 ) ;
end

function oq.show_version()
  print( "oQueue v".. OQUEUE_VERSION .."  build ".. OQ_BUILD .." (".. tostring(OQ.REGION) ..")".. tostring(OQ_SPECIAL_TAG or "") ) ;
end

function oq.panel( parent, name, x, y, cx, cy, no_texture )
  local f = oq.CreateFrame("FRAME", "$parent".. name, parent )
  f:SetWidth (cx) ; -- Set these to whatever height/width is needed 
  f:SetHeight(cy) ; -- for your Texture
  f:SetBackdropColor(0.2,0.2,0.2,1.0);

  if (not no_texture) then
    local t = f:CreateTexture(nil,"BACKGROUND") ;
    t:SetAllPoints(f) ;
    t:SetDrawLayer("BACKGROUND") ;
    f.texture = t ;
  end

  f:SetPoint( "TOPLEFT", x, -1 * y) ;
  return f ;
end

function oq.texture( parent, x, y, cx, cy, texture )
  oq.nthings = (oq.nthings or 0) + 1 ;
  local name = "OQ_Texture".. oq.nthings ;

  f = oq.CreateFrame("FRAME", name, parent )
  f:SetWidth(cx) ;
  f:SetHeight(cy) ;
  f:SetBackdropColor(0.2,0.2,0.2,1.0) ;

  local t = f:CreateTexture( nil, "BACKGROUND" ) ;
  t:SetTexture( texture ) ;
  t:SetAllPoints( f ) ;
  t:SetAlpha( 1.0 ) ;
  f.texture = t ;

  f:SetPoint( "TOPLEFT", x, -1 * y ) ;
  f:Show() ;
  return f ;
end

function oq.hint( button, txt, show )
  if (not show) or (txt == nil) or (txt == "") then
    -- clear & hide the tooltip
    oq.gen_tooltip_hide() ;
    return ;
  end
  oq.gen_tooltip_set( button, txt ) ;
end

function oq.button( parent, x, y, cx, cy, text, on_click_func )
  oq.nthings = (oq.nthings or 0) + 1 ;
  local button = oq.CreateFrame("Button", "$parent".. "Button".. oq.nthings, parent, "UIPanelButtonTemplate")

  button:SetWidth(cx)
  button:SetHeight(cy)
  button:SetNormalFontObject("GameFontNormalSmall")
  button:SetHighlightFontObject("GameFontHighlightSmall")
  button:SetDisabledFontObject("GameFontDisableSmall")
  button:SetText( text )
  button:SetScript("OnClick", on_click_func )
  oq.moveto( button, x, y ) ;
  button:Show() 
  button:SetScript("OnEnter", function(self, ...) oq.hint(self, self.tt, true) ; end ) ;
  button:SetScript("OnLeave", function(self, ...) oq.hint(self, self.tt, nil ) ; end ) ;

  return button ;
end

function oq.button2( parent, x, y, cx, cy, text, font_sz, on_click_func )
  oq.nthings = (oq.nthings or 0) + 1 ;
  local button = oq.CreateFrame("Button", "$parent".. "Button".. oq.nthings, parent, "UIPanelButtonTemplate")

  button:SetWidth(cx)
  button:SetHeight(cy)
  button.string = button:CreateFontString()
  button.string:SetJustifyH("CENTER")
  button.string:SetPoint("CENTER", 0, 0)
  button.font_sz = font_sz or 11 ;
--  button.string:SetFont("Fonts\\MORPHEUS.TTF", button.font_sz, "MONOCHROME") ;
  button.string:SetFont(OQ.FONT, button.font_sz, "") ;
  button:SetFontString(button.string)
  button:SetText( text )
  button:SetScript("OnClick", on_click_func )
  oq.moveto( button, x, y ) ;
  button:Show() ;
  button:SetScript("OnEnter", function(self, ...) oq.hint(self, self.tt, true) ; end ) ;
  button:SetScript("OnLeave", function(self, ...) oq.hint(self, self.tt, nil ) ; end ) ;
  return button ;
end

function oq.closebox( parent, on_close )
  oq.nthings = (oq.nthings or 0) + 1 ;
  closepb = oq.CreateFrame("Button","$parent".. "Close".. oq.nthings, parent, "UIPanelCloseButton") ;
  closepb:SetWidth(25) ;
  closepb:SetHeight(25) ;
  closepb:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -7, -7) ;
  if (on_close == nil) then
    closepb:SetScript("OnClick", function(self) self:GetParent():Hide() ; end) ;
  else
    closepb:SetScript("OnClick", on_close ) ;
  end
  closepb:Show() ;
  return closepb ;
end

function oq.battleground_join( ndx, bg_type )
  if (oq.iam_party_leader()) then
    if (GetNumGroupMembers() == 0) then
      oq.make_big( PVPFrameLeftButton or HonorFrameSoloQueueButton ) ; -- queue up as solo toon
    else
      oq.make_big( PVPFrameRightButton or HonorFrameGroupQueueButton ) ;
    end
  end
end

function oq.normalize_static_button_height()
  if (PVPFrameLeftButton and (not PVPFrameLeftButton:IsVisible())) or 
     (HonorFrameSoloQueueButton and (not HonorFrameSoloQueueButton:IsVisible())) then
    oq.reset_button( PVPFrameLeftButton or HonorFrameSoloQueueButton ) ;
  end
  if (PVPFrameRightButton and (not PVPFrameRightButton:IsVisible())) or 
     (HonorFrameGroupQueueButton and (not HonorFrameGroupQueueButton:IsVisible())) then
    oq.reset_button( PVPFrameRightButton or HonorFrameGroupQueueButton ) ;
  end
  if (not StaticPopup1Button2:IsVisible()) then
    oq.reset_button( StaticPopup1Button2 ) ;
  end
  if (not StaticPopup1Button1:IsVisible()) then
    oq.reset_button( StaticPopup1Button1 ) ;
  end
end

function oq.battleground_leave( ndx )
  if (_inside_bg or (my_group == 0) or (my_slot == 0)) then
    return ;
  end

  -- are we still in a bg?
  if (GetBattlefieldStatInfo(1)) then
    return ;
  end

  local s1 = select(1, GetBattlefieldStatus(ndx)) ;
  if (s1 == "none") then
    -- nothing to do
    return ;
  end
  
  if (s1 == "confirm") then
    -- queue popped, move button to be clicked
    StaticPopup1Button2:Enable() ;
    StaticPopup1Button2:SetText( OQ.DLG_LEAVE ) ;
    if (oq.leaveQ:IsVisible()) then
      oq.reset_button( oq.leaveQ ) ;
      oq.leaveQ:Hide() ;
    end
    oq.reset_button( StaticPopup1Button2 ) ;
    oq.make_big( StaticPopup1Button2 ) ;
  else
    -- queue not popped, move macro button into position
    oq.make_big( oq.leaveQ ) ;
  end

  --
  --  leaving queue now requires a hardware event
  --  pop up a box for the user to hit ok or esc (any input)
  --
  
  -- so sad.. i liked the angry little button  (OQ)
--  oq.leave_queue_dlg( ndx ) ;
end

function oq.battleground_leave_now( ndx )
  last_stat_tm = 0 ; -- force the status send
end

function oq.create_alt_listitem( parent, x, y, cx, cy, name )
  oq.nthings = (oq.nthings or 0) + 1 ;
  local n = "Alt".. oq.nthings ;
  local f = oq.panel( parent, n, x, y, cx, cy ) ;

  f.name = name ;
  f.texture:SetTexture( 0.0, 0.0, 0.0, 1 ) ;

  local x2 = 1 ;
  f.remove_but = oq.button( f, x2, 2,  18, cy-2, "x", function(self) oq.remove_alt_listitem( self:GetParent().name ) ; end ) ;
  x2 = x2 + 18+4 ;
  f.toonName  = oq.label ( f, x2, 2, 150, cy, toonName ) ;
  f:Show() ;
  return f ;         
end

function oq.clear_alt_list()
  for i,v in pairs(oq.tab5_alts) do
    v:Hide() ;
    oq.tab5_alts[i] = nil ;   -- erased, but not cleaned up... should be reclaimed
  end
  OQ_toon.my_toons = {} ;
end

function oq.remove_alt_listitem( name )
  local reshuffle = nil ;
  for i,v in pairs(oq.tab5_alts) do
    if (v.name == name) then
      reshuffle = true ;
      v:Hide() ;
      oq.tab5_alts[i] = nil ;   -- erased, but not cleaned up... should be reclaimed
      break ;
    end
  end
  
  for i,v in pairs(OQ_toon.my_toons) do
    if (v.name == name) then
      OQ_toon.my_toons[i] = nil ;
      break ;
    end
  end

  if (reshuffle) then
    oq.reshuffle_alts() ;
  end
end

function oq.reshuffle_alts() 
  if (oq.tab5_alts == nil) then
    oq.tab5_alts = {} ;
    return ;
  end
    
  local x, y, cx, cy ;
  x  = 20 ;
  y  = 10 ;
  cy = 20 ;
  cx = oq.tab5_list:GetWidth() - 2*x ;
  for i,v in pairs(oq.tab5_alts) do
    oq.setpos( v, x, y, cx, cy ) ;
    y = y + cy + 2 ;
  end
  
  local max_y = y ;
  if (max_y < 150) then
    max_y = 150 ;
  end
  oq.tab5_list:SetHeight( max_y ) ;
end

function oq.add_toon( toonName ) 
  if (toonName == nil) or (toonName == "") then
    return ;
  end
  if (OQ_toon.my_toons == nil) then
    OQ_toon.my_toons = {} ;
  end
  for i,v in pairs(OQ_toon.my_toons) do
    if (v.name == toonName) then
      return ;
    end
  end

  local d = { name = toonName ; }
  table.insert( OQ_toon.my_toons, d ) ;
  
  -- now update ui
  local f = oq.create_alt_listitem( oq.tab5_list, 1, 1, 200, 22, toonName ) ;
  f.toonName:SetText( toonName ) ;
  table.insert( oq.tab5_alts, f ) ;
  oq.reshuffle_alts() ;  
end

function oq.populate_alt_list() 
  if (OQ_toon.my_toons == nil) then
    OQ_toon.my_toons = {} ;
  end
  local x, y, cx, cy ;
  x = 1 ;
  y = 1 ;
  cx = 200 ;
  cy = 22 ;
  for i,v in pairs(OQ_toon.my_toons) do
    local f = oq.create_alt_listitem( oq.tab5_list, x, y, cx, cy, v.name ) ;
    f.toonName:SetText( v.name ) ;
    y = y + cy ;
    table.insert( oq.tab5_alts, f ) ;
  end
  oq.reshuffle_alts() ;  
end

function oq.populate_waitlist()
  local x, y, cy ;
  x  = 2 ;
  cy = 25 ;
  y  = 10 ;
  for req_token,v in pairs(oq.waitlist) do
    local f = oq.insert_waitlist_item( x, y, req_token, v.n_members, v.name, v.realm, v.role, v.level, v.ilevel, v.resil, v.class, v.mmr, v.pvppower ) ;
    table.insert( oq.tab7_waitlist, f ) ;
    y = y + cy ;
  end
  oq.reshuffle_waitlist() ;
end

--------------------------------------------------------------------------
--  dialog definitions
--------------------------------------------------------------------------
StaticPopupDialogs["OQ_AddToonName"] = {
  text = OQ.DLG_01,
  button1 = OQ.DLG_OK,
  button2 = OQ.DLG_CANCEL,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
    self.editBox:SetText("") ;
    self.editBox:SetFocus() ;
  end,
  OnAccept = function (self, data, data2)
    local text = self.editBox:GetText()
    oq.add_toon( text ) ;
  end,
  EditBoxOnEnterPressed = function(self)
    local text = self:GetText()
    oq.add_toon( text ) ;
    self:GetParent():Hide() ;
  end,
  EditBoxOnEscapePressed = function(self)
    self:GetParent():Hide() ;
  end,
  hasEditBox = true
}

StaticPopupDialogs["OQ_BanBTag"] = {
  text = OQ.DLG_17,
  button1 = OQ.DLG_OK,
  button2 = OQ.DLG_CANCEL,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
    self.editBox:SetText("") ;
    self.editBox:SetFocus() ;
  end,
  OnAccept = function (self, data, data2)
    local text = self.editBox:GetText()
    oq.ban_user( text ) ;
  end,
  EditBoxOnEnterPressed = function(self)
    local text = self:GetText()
    oq.ban_user( text ) ;
    self:GetParent():Hide() ;
  end,
  EditBoxOnEscapePressed = function(self)
    self:GetParent():Hide() ;
  end,
  hasEditBox = true
}

StaticPopupDialogs["OQ_BanUser"] = {
  text = OQ.DLG_15,
  button1 = OQ.DLG_OK,
  button2 = OQ.DLG_CANCEL,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data, data2)
    self.editBox:SetText("") ;
    self.editBox:SetFocus() ;
  end,
  OnAccept = function (self, data, data2)
    reason = self.editBox:GetText() ;
    local d = self.data2 ;
    if (d.flag == 1) then
      local m = oq.raid.group[d.gid].member[d.slot_] ;
      oq.ban_add( m.realid, reason ) ;
      oq.remove_member( d.gid, d.slot_ ) ;
    elseif (d.flag == 2) then
      oq.ban_add( d.btag, reason ) ;
      oq.remove_waitlist( d.req_token ) ;
    elseif (d.flag == 3) then
      oq.ban_add( d.btag, reason ) ;
    elseif (d.flag == 4) then
      oq.ban_add( d.btag, reason ) ;
      oq.remove_premade( d.raid_tok ) ;
    end
    self:Hide() ;
  end,
  EditBoxOnEnterPressed = function(self, data, data2)
    local reason = self:GetText() ;
    local d = self:GetParent().data2 ;
    if (d.flag == 1) then
      local m = oq.raid.group[d.gid].member[d.slot_] ;
      oq.ban_add( m.realid, reason ) ;
      oq.remove_member( d.gid, d.slot_ ) ;
    elseif (d.flag == 2) then
      oq.ban_add( d.btag, reason ) ;
      oq.remove_waitlist( d.req_token ) ;
    elseif (d.flag == 3) then
      oq.ban_add( d.btag, reason ) ;
    elseif (d.flag == 4) then
      oq.ban_add( d.btag, reason ) ;
      oq.remove_premade( d.raid_tok ) ;
    end
    self:GetParent():Hide() ;
  end,
  EditBoxOnEscapePressed = function(self)
    self:GetParent():Hide() ;
  end,
  hasEditBox = true
}

local _brb_dlg = nil ;
function oq.brb_dlg()
  if (_brb_dlg == nil) then
    local cx = 300 ;
    local cy = 200 ;
    local x  = (UIParent:GetWidth()-cx)/2 ;
    local y  = 300 ;
    local f = oq.CreateFrame("FRAME", "OQBRBDialog", UIParent ) ;
    oq.setpos( f, x, y, cx, cy ) ;
    f:SetBackdropColor(0.2,0.2,0.2,1.0);
    f:SetPoint( "TOPLEFT", x, -1 * y) ;
    f:SetBackdrop({bgFile="Interface/FrameGeneral/UI-Background-Rock", 
                   edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                   tile=true, tileSize = 16, edgeSize = 16,
                   insets = { left = 4, right = 3, top = 4, bottom = 3 }
                  })
    f:SetBackdropColor(0.2,0.2,0.2,1.0);
    f:SetFrameStrata("DIALOG") ;
    f:SetFrameLevel(99) ;
    f:SetAlpha( 1.0 ) ;
    f.ok = oq.button2( f, 20, 20, cx-2*20, cy-2*20, OQ.IAM_BACK, 15, function(self) self:GetParent():Hide() ; end ) ;
    
    f:SetScript( "OnShow", function(self)
                             self.init(self) ;
                           end 
               ) ;
    f:SetScript( "OnHide", function(self)
                             oq.iam_back() ;
                             oq.tremove_value( UISpecialFrames, self:GetName() ) ;
                             tinsert( UISpecialFrames, oq.ui:GetName() ) ;
                           end
               ) ;
    f.center = function(self)
                 oq.moveto( self, 
                            (GetScreenWidth ()-self:GetWidth ())/2,
                            (GetScreenHeight()-self:GetHeight())/2 - 100
                          ) ;
               end
    f.init = function(self)
               local cx = 300 ;
               local cy = 200 ;
               local x  = (UIParent:GetWidth()-cx)/2 ;
               local y  = 200 ;
               oq.setpos( self, 10, 10, 300, 200 ) ;
               self.center( self ) ;
             end ;
    _brb_dlg = f ;
  end

  tinsert( UISpecialFrames, _brb_dlg:GetName() ) ;
  oq.tremove_value( UISpecialFrames, oq.ui:GetName() ) ;

  _brb_dlg:Show() ;
  return _brb_dlg ;
end
 
StaticPopupDialogs["OQ_EnterBattle"] = {
  text = OQ.DLG_02,
  button1 = OQ.DLG_OK,
  timeout = 30,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
  end,
  OnAccept = function (self, data, data2)
    if (data == nil) then
      data = 1 ;
    end
    self:Hide() ;
  end,
  OnCancel = function (self, data, data2)
    if (data == nil) then
      data = 1 ;
    end
    self:Hide() ;
  end,
  hasEditBox = false
}

StaticPopupDialogs["OQ_EnterPremadeName"] = {
  text = OQ.DLG_03,
  button1 = OQ.DLG_OK,
  button2 = OQ.DLG_CANCEL,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
    self.editBox:SetText("") ;
    self.editBox:SetFocus() ;
  end,
  OnAccept = function (self, data, data2)
    if (data2) then
      data2(data) ;
    end
    self:Hide() ;
  end,
  EditBoxOnEnterPressed = function(self)
    if (data2) then
      data2(data) ;
    end
    self:GetParent():Hide() ;
  end,
  EditBoxOnEscapePressed = function(self)
    self:GetParent():Hide() ;
  end,
  hasEditBox = true
}

StaticPopupDialogs["OQ_EnterRealID"] = {
  text = OQ.DLG_04,
  button1 = OQ.DLG_OK,
  button2 = OQ.DLG_CANCEL,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
    self.editBox:SetText(player_realid or "") ;
    self.editBox:SetFocus() ;
  end,
  OnAccept = function (self, data, data2)
    player_realid  = self.editBox:GetText() ;
    OQ_data.realid = player_realid ;
    if (data2) then
      data2(data) ;
    end
    self:Hide() ;
  end,
  EditBoxOnEnterPressed = function(self)
    player_realid  = self:GetText() ;
    OQ_data.realid = player_realid ;
    if (data2) then
      data2(data) ;
    end
    self:GetParent():Hide() ;
  end,
  EditBoxOnEscapePressed = function(self)
    self:GetParent():Hide() ;
  end,
  hasEditBox = true
}

StaticPopupDialogs["OQ_EnterPword"] = {
  text = OQ.DLG_05,
  button1 = OQ.DLG_OK,
  button2 = OQ.DLG_CANCEL,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
    self.editBox:SetText("") ;
    self.editBox:SetFocus() ;
  end,
  OnAccept = function (self, data, data2)
    oq.send_req_waitlist( data, self.editBox:GetText() ) ;
    self:Hide() ;
  end,
  EditBoxOnEnterPressed = function(self, data, data2)
    oq.send_req_waitlist( data, self:GetText() ) ;
    self:GetParent():Hide() ;
  end,
  EditBoxOnEscapePressed = function(self)
    self:GetParent():Hide() ;
  end,
  hasEditBox = true
}
local Flasher = {} ;
function Aspect_CreateFlasher(color)
    local frameImage = "None";
    if(color == "Blue") then
        frameImage = "Interface\\FullScreenTextures\\OutofControl";
    elseif(color == "Red") then
        frameImage = "Interface\\FullScreenTextures\\LowHealth";
    else
        frameImage = nil;
    end

    local frameName = "Aspect"..color.."WarningFrame";
    if not ((Flasher[color]) and (frameImage)) then
        local flasher = CreateFrame("Frame", frameName)
        flasher:SetToplevel(true)
        flasher:SetFrameStrata("FULLSCREEN_DIALOG")
        flasher:SetAllPoints(UIParent)
        flasher:EnableMouse(false)
        flasher.texture = flasher:CreateTexture(nil, "BACKGROUND")
        flasher.texture:SetTexture(frameImage)
        flasher.texture:SetAllPoints(UIParent)
        flasher.texture:SetBlendMode("ADD")
        flasher:Hide()
        flasher:SetScript("OnShow", function(self)
            self.elapsed = 0
            self:SetAlpha(0.25)
        end)
        flasher:SetScript("OnUpdate", function(self, elapsed)
            elapsed = self.elapsed + elapsed
            local alpha = elapsed % 0.4
            if elapsed > 0.2 then
                alpha = 0.4 - alpha
            end
            self:SetAlpha(alpha * 5)
            self.elapsed = elapsed
        end)
        Flasher[color] = flasher;
    end
 end

--
-- various sound efects available in-game:
-- http://www.wowwiki.com/PlaySoundFile_macros_-_other_sounds
--
--[[
local _leaveQ_dlg = nil ;
function oq.leave_queue_dlg(data)
  if (_leaveQ_dlg == nil) then
    local cx = 300 ;
    local cy = 200 ;
    local x  = (UIParent:GetWidth()-cx)/2 ;
    local y  = 300 ;
    local f = oq.CreateFrame("FRAME", "OQLeaveQ", UIParent ) ;
    oq.setpos( f, x, y, cx, cy ) ;
    f:SetBackdropColor(0.2,0.2,0.2,1.0);
    f:SetPoint( "TOPLEFT", x, -1 * y) ;
    f:Show()

    f:SetBackdrop({bgFile="Interface/FrameGeneral/UI-Background-Rock", 
                   edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                   tile=true, tileSize = 16, edgeSize = 16,
                   insets = { left = 4, right = 3, top = 4, bottom = 3 }
                  })
    f:SetBackdropColor(0.2,0.2,0.2,1.0);
    f:SetFrameStrata("DIALOG") ;
    f:SetFrameLevel(99) ;
    f:SetAlpha( 1.0 ) ;
    f.ok = oq.button2( f, 20, 20, cx-2*20, cy-2*20, OQ.LEAVE_QUEUE, 15, function(self) self:GetParent():Hide() ; end ) ;
    
    f:SetScript( "OnShow", function(self)
                             self.init(self) ;
                           end 
               ) ;
    f:SetScript( "OnHide", function(self)
                             self.leaveQ(self) ;
                           end
               ) ;
    f.adjust = function(self)
                 self.ok.string:SetFont( OQ.FONT, self.ok.font_sz ) ;
                 oq.setpos( self.ok, 20, 20, self:GetWidth() - 2*20, self:GetHeight() - 2*20 ) ;
               end
    f.center = function(self)
                 oq.moveto( self, 
                            (GetScreenWidth ()-self:GetWidth ())/2,
                            (GetScreenHeight()-self:GetHeight())/2 - 100
                          ) ;
                 self.adjust(self) ;
               end
    f.drums = function(self)
                local snd = "Interface\\PVPFlagCapturedHordeMono" ;
                local snd2 = "Effects\\DeathImpacts\\mDeathImpactColossalStoneA" ;
                local snd3 = "Character\\PlayerRoars\\CharacterRoarsDwarfMale" ;
                if (self.ticker >= 2) then 
                  PlaySoundFile( "Sound\\".. snd2 ..".wav" ) ;
                  PlaySoundFile( "Sound\\".. snd ..".wav" ) ;
                  PlaySoundFile( "Sound\\".. snd2 ..".wav" ) ;
                  if (self.ticker >= 9) then
                    PlaySoundFile( "Sound\\".. snd3 ..".wav" ) ;
                  end
                end  
              end
    f.flasher = function(self)
                  if (self.ticker > 2) and (self.ticker < 5) then
                    Aspect_CreateFlasher("Blue") ;
                    Flasher["Blue"]:Show() ;    
                  elseif (self.ticker >= 5) and (self.ticker < 8) then
                    Aspect_CreateFlasher("Red") ;
                    Flasher["Blue"]:Hide() ;
                    Flasher["Red"]:Show() ;
                  end
                end
    f.grow = function(self)
               self.ticker = self.ticker + 1 ;
               if (self.ticker < 6) then
                 local cx = self:GetWidth() + 100 ;
                 local cy = self:GetHeight() + 100 ;
                 self:SetWidth ( cx ) ;
                 self:SetHeight( cy ) ;
                 self.ok:SetWidth ( cx-2*20 ) ;
                 self.ok:SetHeight( cy-2*20 ) ;
                 self.ok.font_sz = self.ok.font_sz + 8 ;
                 if (self.ticker == 4) then
                   self.ok:SetText( OQ.LEAVE_QUEUE_BIG ) ;
                 end
                 self.center(self) ;
               end
               self.drums(self) ;
               self.flasher(self) ;
               if (self.ticker > 8) then
                 self.ok:SetText( OQ.DAS_BOOT ) ;  
               end
               if (self.ticker > 10) then
                 Flasher["Red"]:Hide() ;
                 self:Hide() ;
                 self.hammer_down(self) ;
               end
             end
    f.hammer_down = function(self)
                      if (oq.GetNumPartyMembers() > 0) and (my_slot > 1) then
                        oq.timer_oneshot( 1.5, PlaySoundFile, "Sound\\Creature\\Kologarn\\UR_Kologarn_Slay02.wav" ) ; -- you lose!
                        LeaveParty() ;
                        oq.quit_raid_now() ;
                      end
                    end
    f.init = function(self)
               local cx = 300 ;
               local cy = 200 ;
               local x  = (UIParent:GetWidth()-cx)/2 ;
               local y  = 200 ;
               oq.setpos( self, 10, 10, 300, 200 ) ;
               self.center( self ) ;
               oq.timer( "leaveQ", 2.5, self.grow, true, self ) ;
               self.ticker  = 0 ;
               self.ok:SetText( OQ.LEAVE_QUEUE ) ;               
               self.ok.font_sz = 15 ;
               self.ok.string:SetFont( OQ.FONT, self.ok.font_sz ) ;               
             end ;
    f.leaveQ = function(self)
                 oq.battleground_leave_now( self.data ) ;
                 oq.timer( "leaveQ", 2.5, nil ) ;
                 if (Flasher["Blue"]) then
                   Flasher["Blue"]:Hide() ;
                 end
                 if (Flasher["Red"]) then
                   Flasher["Red"]:Hide() ;
                 end
                 oq.tremove_value( UISpecialFrames, self:GetName() ) ;
                 tinsert( UISpecialFrames, oq.ui:GetName() ) ;
               end ;
    _leaveQ_dlg = f ;
  end

  tinsert( UISpecialFrames, _leaveQ_dlg:GetName() ) ;
  oq.tremove_value( UISpecialFrames, oq.ui:GetName() ) ;

  _leaveQ_dlg.init( _leaveQ_dlg ) ;
  _leaveQ_dlg.data = data ;
  _leaveQ_dlg:Show() ;
  return _leaveQ_dlg ;
end
]]--
 
function oq.angry_lil_button(button)
  if (oq.angry_button == nil) then
    local cx = 300 ;
    local cy = 200 ;
    local x  = (UIParent:GetWidth()-cx)/2 ;
    local y  = 300 ;
    local f = {} ;
    
    f.adjust = function(self)
--[[
                 self.ok.string:SetFont( OQ.FONT, self.ok.font_sz ) ;
                 oq.setpos( self.ok, 20, 20, self:GetWidth() - 2*20, self:GetHeight() - 2*20 ) ;
]]--
               end
    f.center = function(self)
                 local but = self._button ;
                 local x = ceil( ((GetScreenWidth ()-but:GetWidth ())/2) - 0.5) ;
                 local y = ceil( ((GetScreenHeight()-but:GetHeight())/2) - 0.5) ;
                 but:SetPoint("TOPLEFT",UIParent,"TOPLEFT", x, -1 * y)
                 self.adjust(self) ;
               end
    f.drums = function(self)
                local snd = "Interface\\PVPFlagCapturedHordeMono" ;
                local snd2 = "Effects\\DeathImpacts\\mDeathImpactColossalStoneA" ;
                local snd3 = "Character\\PlayerRoars\\CharacterRoarsDwarfMale" ;
                if (self.ticker >= 2) then 
                  PlaySoundFile( "Sound\\".. snd2 ..".wav" ) ;
                  PlaySoundFile( "Sound\\".. snd ..".wav" ) ;
                  PlaySoundFile( "Sound\\".. snd2 ..".wav" ) ;
                  if (self.ticker >= 9) then
                    PlaySoundFile( "Sound\\".. snd3 ..".wav" ) ;
                  end
                end  
              end
    f.flasher = function(self)
                  if (self.ticker > 2) and (self.ticker < 5) then
                    Aspect_CreateFlasher("Blue") ;
                    Flasher["Blue"]:Show() ;    
                  elseif (self.ticker >= 5) and (self.ticker < 8) then
                    Aspect_CreateFlasher("Red") ;
                    Flasher["Blue"]:Hide() ;
                    Flasher["Red"]:Show() ;
                  end
                end
    f.grow = function(self)
               if (_inside_bg) or (oq.angry_button._button == nil) or (not oq.angry_button._button:IsVisible()) then
                 oq.angry_lil_button_done( self._button )
               end
               self.ticker = self.ticker + 1 ;
               if (self.ticker < 6) then
                 local cx = self._button:GetWidth() + 100 ;
                 local cy = self._button:GetHeight() + 100 ;
                 self._button:SetWidth ( cx ) ;
                 self._button:SetHeight( cy ) ;
--                 self.ok:SetWidth ( cx-2*20 ) ;
--                 self.ok:SetHeight( cy-2*20 ) ;
--                 self.ok.font_sz = self.ok.font_sz + 8 ;
--                 if (self.ticker == 4) then
--                   self.ok:SetText( OQ.LEAVE_QUEUE_BIG ) ;
--                 end
                 self.center(self) ;
               end
               self.drums(self) ;
               self.flasher(self) ;
               if (self.ticker > 8) then
--                 self.ok:SetText( OQ.DAS_BOOT ) ;  
               end
               if (self.ticker > 10) then
                 Flasher["Red"]:Hide() ;
                 self._button:Hide() ;
                 self.hammer_down(self) ;
               end
             end
    f.hammer_down = function(self)
               if (oq.GetNumPartyMembers() > 0) and (my_slot > 1) then
                 oq.timer_oneshot( 1.5, PlaySoundFile, "Sound\\Creature\\Kologarn\\UR_Kologarn_Slay02.wav" ) ; -- you lose!
                 LeaveParty() ;
                 oq.quit_raid_now() ;
                 self.leaveQ(self) ;
               end
             end
    f.init = function(self)
               local cx = 300 ;
               local cy = 200 ;
               local x  = (UIParent:GetWidth()-cx)/2 ;
               local y  = 200 ;
               oq.setpos( self._button, 10, 10, 300, 200 ) ;
               self.center( self ) ;
               oq.timer( "leaveQ", 2.5, self.grow, true, self ) ;
               self.ticker  = 0 ;
--[[               
               self.ok:SetText( OQ.LEAVE_QUEUE ) ;
               self.ok.font_sz = 15 ;
               self.ok.string:SetFont( OQ.FONT, self.ok.font_sz ) ;
]]--
             end ;
    f.leaveQ = function(self)
                 oq.timer( "leaveQ", 2.5, nil ) ;
                 if (Flasher["Blue"]) then
                   Flasher["Blue"]:Hide() ;
                 end
                 if (Flasher["Red"]) then
                   Flasher["Red"]:Hide() ;
                 end
                 self._button:Hide() ;
                 self._button = nil ;
               end ;
    oq.angry_button = f ;
  end
  oq.angry_button._button = button ;
  oq.angry_button.init( oq.angry_button ) ;
  oq.angry_button.data = data ;
  return oq.angry_button ;
end

function oq.angry_lil_button_done( button )
  oq.reset_button( button ) ;
  if (oq.angry_button ~= nil) then
    oq.angry_button.leaveQ( oq.angry_button ) ;
  end
end
 
StaticPopupDialogs["OQ_NewVersionAvailable"] = {
  text = OQ.DLG_07,
  button1 = OQ.DLG_OK,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
    self.editBox:SetWidth( 275 ) ;
    self.editBox:SetText("http://curse.com/addons/wow/oqueue") ;
    self.editBox:SetFocus() ;
    -- fanfare for new version
    oq.excited_cheer() ;
  end,
  OnAccept = function (self, data, data2)
    self:Hide() ;
  end,
  EditBoxOnEnterPressed = function(self)
    self:GetParent():Hide() ;
  end,
  EditBoxOnEscapePressed = function(self)
    self:GetParent():Hide() ;
  end,
  hasEditBox = true
}

StaticPopupDialogs["OQ_NotPartyLead"] = {
  text = OQ.DLG_08,
  button1 = OQ.DLG_OK,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
  end,
  OnAccept = function (self, data, data2)
    self:Hide() ;
  end,
  OnCancel = function (self, data, data2)
    self:Hide() ;
  end,
  hasEditBox = false
}

StaticPopupDialogs["OQ_CannotCreatePremade"] = {
  text = OQ.DLG_09,
  button1 = OQ.DLG_OK,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
  end,
  OnAccept = function (self, data, data2)
    self:Hide() ;
  end,
  OnCancel = function (self, data, data2)
    self:Hide() ;
  end,
  hasEditBox = false
}

StaticPopupDialogs["OQ_DoNotQualifyPremade"] = {
  text = OQ.DLG_19,
  button1 = OQ.DLG_OK,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
  end,
  OnAccept = function (self, data, data2)
    self:Hide() ;
  end,
  OnCancel = function (self, data, data2)
    self:Hide() ;
  end,
  hasEditBox = false
}

StaticPopupDialogs["OQ_QueuePoppedLeader"] = {
  text = OQ.DLG_10,
  button1 = OQ.DLG_ENTER,
  button2 = OQ.DLG_LEAVE,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
  end,
  OnAccept = function (self, data, data2)
    oq.raid_announce( "enter_bg,".. data ) ;
    self:Hide() ;
  end,
  OnCancel = function (self, data, data2)
    oq.raid_announce( "leave_queue,".. data ) ;
    oq.battleground_leave_now( data ) ;
    self:Hide() ;
    oq.ui:Show() ; -- force it, in case the user hit esc
  end,
  hasEditBox = false
}

StaticPopupDialogs["OQ_QueuePoppedMember"] = {
  text = OQ.DLG_11,
  button1 = nil,
  button2 = nil,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
  end,
  OnAccept = function (self, data, data2)
    self:Hide() ;
  end,
  OnCancel = function (self, data, data2)
    self:Hide() ;
  end,
  hasEditBox = false
}

StaticPopupDialogs["OQ_QuitRaidConfirm"] = {
  text = OQ.DLG_12,
  button1 = OQ.DLG_YES,
  button2 = OQ.DLG_NO,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
  end,
  OnAccept = function (self, data, data2)
    if (not oq.iam_raid_leader()) and (not oq.iam_party_leader()) then
      LeaveParty() ;
    end
    oq.quit_raid_now() ;
    self:Hide() ;
  end,
  OnCancel = function (self, data, data2)
    self:Hide() ;
  end,
  hasEditBox = false
}

StaticPopupDialogs["OQ_ReadyCheck"] = {
  text = OQ.DLG_13,
  button1 = OQ.DLG_READY,
  button2 = OQ.DLG_NOTREADY,
  timeout = 30,
  whileDead = true,
  hideOnEscape = false,
  OnShow = function (self, data)
    oq.ready_check( my_group, my_slot, OQ_FLAG_WAITING ) ;
    PlaySound( "ReadyCheck" ) ;
  end,
  OnAccept = function (self, data, data2)
    oq.ready_check( my_group, my_slot, OQ_FLAG_READY ) ;
    self:Hide() ;
  end,
  OnCancel = function (self, data, reason)
    if (reason == "timeout") then
      oq.ready_check( my_group, my_slot, OQ_FLAG_CLEAR ) ;
    else
      oq.ready_check( my_group, my_slot, OQ_FLAG_NOTREADY ) ;
    end
    self:Hide() ;
  end,
  hasEditBox = false
}

StaticPopupDialogs["OQ_ReloadUI"] = {
  text = OQ.DLG_14,
  button1 = OQ.DLG_OK,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  OnShow = function (self, data)
  end,
  OnAccept = function (self, data, data2)
    oq.on_reload_now() ;
    self:Hide() ;
  end,
  OnCancel = function (self, data, data2)
    oq.on_reload_now() ;
    self:Hide() ;
  end,
  hasEditBox = false
}

--------------------------------------------------------------------------
--
--------------------------------------------------------------------------
function oq.on_enter_bg( ndx )
  StaticPopup1Button1:Enable() ;
  StaticPopup1Button2:Disable() ;
  StaticPopup_Hide("OQ_QueuePoppedMember") ;
  oq.reset_button( StaticPopup1Button1 ) ;
  oq.make_big( StaticPopup1Button1 ) ;
end

function oq.getpos( f ) 
  local p = {} ;
  p.left   = ceil( f:GetLeft  () - 0.5 ) ;
  p.top    = ceil( f:GetTop   () - 0.5 ) ;
  p.width  = ceil( f:GetWidth () - 0.5 ) ;
  p.height = ceil( f:GetHeight() - 0.5 ) ;
  if (f:GetParent() ~= UIParent) then
    p.left = ceil( p.left - f:GetParent():GetLeft() - 0.5 ) ;
    p.top  = ceil( p.top  - f:GetParent():GetTop()  - 0.5 ) ;
  end
  p.top = abs( p.top ) ;
  return p ;
end

function oq.center( f ) 
  local x = ceil( ((GetScreenWidth ()-f:GetWidth ())/2) - 0.5) ;
  local y = ceil( ((GetScreenHeight()-f:GetHeight())/2) - 0.5) ;
  f:SetPoint("TOPLEFT",UIParent,"TOPLEFT", x, -1 * y)
  return f ;
end

function oq.make_big( f )
  if (_inside_bg) then
    return ;
  end
  f._was_vis = f:IsVisible() ;
  if (not f:IsVisible()) then
    f:Show() ;
  end
  if (f._is_big) then
    return ;
  end
  f._is_big          = true ;
  f._original_pos    = oq.getpos( f ) ;
  f._original_level  = f:GetFrameLevel() ;
  f:SetFrameLevel( 99 ) ;
  f:ClearAllPoints() ;
  if (f:IsEnabled()) then
    f._original_enable = 1 ;
  else
    f._original_enable = 0 ;
  end
  f:Enable() ;
  oq.center( oq.setpos( f, 100, 100, 300, 300 ) ) ;
  
  oq.angry_lil_button( f ) ;
  f:SetScript("PostClick", function(self) oq.angry_lil_button_done( self ) ; end ) ;
end

function oq.reset_button( f )
  if (not f._is_big) then
    return ;
  end
  if (f._original_pos ~= nil) then
    local o = f._original_pos ;
    oq.setpos( f, o.left, o.top, o.width, o.height ) ;
  end
  if (f._original_level) then
    f:SetFrameLevel( f._original_level ) ;
  end
  if (f._was_vis) then
    f:Show() ;
  else
    f:Hide() ;
  end
  if (f._original_enable == 0) then
    f:Disable() ;
  else
    f:Enable() ;
  end
  f:SetScript("PostClick", function(self) end ) ;
  f._is_big = nil ;
end

function oq.on_leave_queue( ndx )
  StaticPopup_Hide("OQ_QueuePoppedMember") ;

  -- this may require hardware event
  oq.battleground_leave( tonumber(ndx) ) ; 
end

function oq.quit_raid() 
  local dialog = StaticPopup_Show("OQ_QuitRaidConfirm") ;
end

function oq.raid_cleanup_slot( i, j )
  if (j == 1) then
    oq.raid.group[i]._last_ping     = nil ;
    oq.raid.group[i]._names         = nil ;
    oq.raid.group[i]._stats         = nil ;
    oq.raid.group[i].member[1].lag  = nil ;
    oq.tab1_group[i].status[1]:SetText( "-" ) ;
    oq.tab1_group[i].status[2]:SetText( "-" ) ;
    oq.tab1_group[i].lag:SetText( "" ) ;
    oq.set_group_member( i, j, "-", "-", "XX", "", OQ.NONE, "0", OQ.NONE, "0" ) ;
    oq.set_deserter( i, j, nil ) ;
    oq.set_role( i, j, OQ.ROLES["NONE"] ) ;
  else
    oq.set_group_member( i, j, "-", "-", "XX", "", OQ.NONE, "0", OQ.NONE, "0" ) ;
    oq.set_deserter( i, j, nil ) ;
    oq.set_role( i, j, OQ.ROLES["NONE"] ) ;
  end
end

function oq.ui_raidleader()
  if (oq.raid.type == OQ.TYPE_BG) then
    oq.tab1_bg[1].queue_button:Show() ;
    oq.tab1_bg[2].queue_button:Show() ;
  else
    oq.tab1_bg[1].queue_button:Hide() ;
    oq.tab1_bg[2].queue_button:Hide() ;
  end
  oq.tab1_quit_button:SetText( OQ.DISBAND_PREMADE ) ;
  oq.tab1_readycheck_button:Show() ;
  oq.tab1_brb_button:Show() ;
  oq.tab1_lucky_charms:Show() ;
  OQMainFrameTab7:Show() ;
end

function oq.ui_player()
  if (oq.raid.raid_token) and (oq.iam_raid_leader()) then
    oq.ui_raidleader() ;
    return ;
  end

  oq.tab1_bg[1].queue_button:Hide() ;
  oq.tab1_bg[2].queue_button:Hide() ;
  oq.tab1_quit_button:SetText( OQ.LEAVE_PREMADE ) ;
  oq.tab1_readycheck_button:Hide() ;
  OQMainFrameTab7:Hide() ;
  if (my_slot == 0) then
    oq.tab1_brb_button:Hide() ;
  else
    oq.tab1_brb_button:Show() ;
  end
  oq.tab1_lucky_charms:Hide() ;
end

function oq.raid_cleanup()
  -- leave party
  if (oq.iam_in_a_party()) then
    _error_ignore_tm  = GetTime() + 5 ;
    -- not leaving party... allowing the user to control leaving group
--    LeaveParty() ;
  end

  oq.set_premade_type( OQ.TYPE_BG ) ;
  for i=1,8 do
    oq.tab1_group[i].lag:SetText( "" ) ;
    for k=1,2 do
      oq.tab1_group[i].status[k]:SetText( "-" ) ;
    end
    for j=1,5 do
      oq.raid_cleanup_slot( i, j ) ;
    end
  end
  oq.tab3_create_but:SetText( OQ.CREATE_BUTTON ) ;
  oq.tab1_name :SetText( "" ) ;
  oq.tab1_notes:SetText( "" ) ;
  oq.tab1_raid_stats:SetText( "" ) ;

  -- clear settings
  oq.raid       = {} ;
  oq.raid.group = {} ;
  for i=1,8 do
    oq.raid.group[i] = {} ;
    oq.raid.group[i].member = {} ;
    for j=1,5 do
      oq.raid.group[i].member[j] = {} ;
      oq.raid.group[i].member[j].flags = 0 ;
      oq.raid.group[i].member[j].charm = 0 ;
      oq.raid.group[i].member[j].check = OQ_FLAG_CLEAR ;
      oq.raid.group[i].member[j].bg = {} ;
      for k=1,2 do
        oq.raid.group[i].member[j].bg[k] = {} ;
      end
    end
  end
  oq.waitlist   = {} ;
  my_group      = 0 ;
  my_slot       = 0 ;

  -- remove raid-only procs
  oq.set_premade_type( OQ.TYPE_BG ) ;
  oq.procs_no_raid() ;
  
  oq.ui_player() ;
end

function oq.quit_raid_now() 
  -- 
  -- clear out raid settings
  --
  oq.raid_announce( "leave_slot,".. my_group ..",".. my_slot ) ;
  oq.raid_disband() ;  -- only triggers if i am raid leader

  -- make sure we left any queues we might've been in
  if (not _inside_bg) then
    oq.battleground_leave( 1 ) ;
    oq.battleground_leave( 2 ) ;
  end

  -- update status 
  local raid = oq.premades[ oq.raid.raid_token ] ;
  if (raid ~= nil) then
    local s = raid.stats ;
    local line = oq.find_premade_entry( raid.raid_token ) ;
    if (line ~= nil) then
      if (s.status == 2) then
        -- if inside, disable the waitlist button
        line.req_but:Disable() ;
      else
        line.req_but:Enable() ;
      end
    end  
  end

  -- clean up raid tab
  oq.raid_cleanup() ;
  oq.remove_all_waitlist() ;
end

function oq.accept_group_leader( req_token, group_id )
  local r = oq.waitlist[ req_token ] ;
  if (r == nil) then
    print( "unable to locate req_token ".. req_token ..".  invite failed" ) ;
    return ;
  end

  oq.set_group_member( group_id, 1, r.name, r.realm, r.class, r.realid ) ;
end

function oq.InviteUnit( name, realm )
  if (realm == nil) or (realm == player_realm) then
    InviteUnit( name ) ;
  else
    InviteUnit( name .."-".. realm ) ;
  end
end

local _ninvites = 0 ;
function oq.invite_group_leader( req_token, group_id )
  local r = oq.waitlist[ req_token ] ;  
  if (r == nil) then
    -- wasn't my request
    return ;
  end

  -- the 'W' stands for 'whisper' and should not be echo'd far and wide
  local msg_tok = "W".. oq.token_gen() ;
  oq.token_push( msg_tok ) ;
  local enc_data = oq.encode_data( "abc123", oq.raid.leader, oq.raid.leader_realm, oq.raid.leader_rid ) ;
  local msg = "invite_group_lead,"..  
              req_token ..",".. 
              group_id ..",".. 
              oq.encode_name( oq.raid.name ) ..",".. 
              oq.raid.leader_class  ..",".. 
              enc_data ..",".. 
              oq.raid.raid_token ..","..
              oq.encode_note( oq.raid.notes ) ;

  -- if i'm already b-net friends or the player is on my realm, just send msg
  local pid = oq.bnpresence( r.name .."-".. r.realm ) ;
  if (pid ~= 0) or (player_realm == r.realm) then
    oq.realid_msg( r.name, r.realm, r.realid, msg ) ;
    oq.remove_waitlist( req_token ) ;
    return ;
  end
  
  -- if reaches here, player is not b-net friend or not on realm... must b-net friend then invite
  if (oq.iam_raid_leader() and (player_realm ~= r.realm)) then
    oq.bn_realfriend_invite( r.name, r.realm, r.realid, "#tok:".. req_token ..",#lead" ) ;
  end

  _ninvites = _ninvites + 1 ;
  oq.timer( "invite_to_group".. _ninvites, 2, oq.timer_invite_group, true, req_token, msg, true ) ;
end

function oq.timer_invite_group( req_token, msg, is_lead )
  local r = oq.waitlist[ req_token ] ;
  if (r == nil) then
    return true ; -- this will remove the timer
  end
  next_bn_check = 0 ; -- force the refresh
  local pid = oq.bnpresence( r.name .."-".. r.realm ) ;
  if (pid == 0) then
    -- not friended yet
    if (r.attempts == nil) then
      r.attempts = 1 ;
    else
      r.attempts = r.attempts + 1 ;
    end
    if (r.attempts > 8) then
      print( "B.net has not friended ".. r.name .."-".. r.realm .." (".. tostring(r.realid) ..").  Giving up." ) ;
      return true ; -- this will remove the timer
    end
    return ;
  end

  oq.realid_msg( r.name, r.realm, r.realid, msg ) ;
  if (not is_lead) then
    oq.InviteUnit( r.name, r.realm ) ;
  end
  oq.remove_waitlist( req_token ) ;
  return true ; -- this will remove the timer
end

function oq.is_in_group( name, realm )
  local n = name ;
  if (realm ~= player_realm) then
    n = n .."-".. realm ;
  end
  return UnitInParty( n ) ;
end

function oq.timer_invite_group_member( name, realm, rid_, msg, group_id, slot_, req_token_ )
  if (oq.is_in_group( name, realm )) then
    oq.pending_invites[ name .."-".. realm ] = nil ;
    return ;
  end
  next_bn_check = 0 ; -- force the refresh
  local pid = oq.bnpresence( name .."-".. realm ) ;
  if (pid == 0) then
    -- not friended yet
    local r = oq.pending_invites[ name .."-".. realm ] ;
    if (r == nil) then
      oq.pending_invites[ name .."-".. realm ] = { raid_tok = oq.raid.raid_token, gid = group_id, slot = slot_, rid = rid_, req_token = req_token_ } ;
      r = oq.pending_invites[ name .."-".. realm ] ;
    end
    if (r.attempts == nil) then
      r.attempts = 1 ;
    else
      r.attempts = r.attempts + 1 ;
    end
    if (r.attempts == 5) then
      oq.bn_realfriend_invite( name, realm, rid_, "#tok:".. req_token_ ..",#grp:".. group_id ..",#nam:".. player_name .."-".. tostring(oq.realm_cooked(player_realm)) ) ; 
    elseif (r.attempts > 8) then
      print( "B.net has not friended ".. name .."-".. realm .." (".. tostring(rid_) ..").  Giving up." ) ;
      oq.pending_invites[ name .."-".. realm ] = nil ;
      return true ; -- this will remove the timer
    end
    return ;
  end
  
  oq.realid_msg( name, realm, rid_, msg ) ;
  oq.timer_oneshot( 1.5, oq.InviteUnit, name, realm ) ;
  oq.timer_oneshot( 3.5, oq.brief_group_members ) ;  
  oq.pending_invites[ name .."-".. realm ] = nil ;
  return true ; -- this will remove the timer
end

function oq.find_first_available_slot( p ) 
  if (p ~= nil) then
    -- check to see if player already assigned a slot
    for i=1,8 do
      for j=1,5 do
        if ((oq.raid.group[i].member[j].name == p.name) and (oq.raid.group[i].member[j].realm == p.realm)) then
          oq.raid.group[i].member[j].charm = 0 ; 
          oq.raid.group[i].member[j].check = OQ_FLAG_CLEAR ;
          return i, j ;
        end
      end
    end
  end
  for i=1,8 do
    for j=1,5 do
      if ((oq.raid.group[i].member[j].name == nil) or (oq.raid.group[i].member[j].name == "-")) then
        oq.raid.group[i].member[j].name  = p.name  ; -- reserve spot so we don't get overlap due to slow messaging
        oq.raid.group[i].member[j].realm = p.realm ; 
        oq.raid.group[i].member[j].class = "XX" ; 
        oq.raid.group[i].member[j].charm = 0 ; 
        oq.raid.group[i].member[j].check = OQ_FLAG_CLEAR ;
        return i, j ;
      end
    end
  end
  return 0, 0 ;
end

function oq.find_first_available_group( p ) 
  if (p ~= nil) then
    -- check to see if player already assigned a slot
    for i=1,8 do
      if ((oq.raid.group[i].member[1].name == p.name) and (oq.raid.group[i].member[1].realm == p.realm)) then
        oq.group_charm_clear( i )
        return i ;
      end
    end
  end
  for i=1,8 do
    if ((oq.raid.group[i].member[1].name == nil) or (oq.raid.group[i].member[1].name == "-")) then
        oq.group_charm_clear( i )
      return i ;
    end
  end
  return 0, 0 ;
end

function oq.group_invite_slot( req_token, group_id, slot ) 
  if (not oq.iam_raid_leader()) then
    -- not possible
    return ;
  end
  --
  -- slot will NOT be 1
  --
  local r = oq.waitlist[ req_token ] ;
  
  if (r == nil) then
    oq.remove_waitlist( req_token ) ;
    return ;    
  end
  if (r.realid == nil) then
    oq.remove_waitlist( req_token ) ;
    return ;    
  end
  
  group_id = tonumber( group_id ) ;
  slot     = tonumber( slot ) ;
  
  if ((oq.raid.type ~= OQ.TYPE_RBG) and (oq.raid.type ~= OQ.TYPE_RAID) and (group_id ~= my_group)) then
    -- proxy_invite needed
    oq.proxy_invite( group_id, slot, r.name, r.realm, r.realid, req_token ) ;
    oq.timer( "brief_leader", 1.5, oq.brief_group_lead, nil, group_id ) ;
    oq.remove_waitlist( req_token ) ;
    return ;
  end
  
  -- the 'W' stands for 'whisper' and should not be echo'd far and wide
  local msg_tok = "W".. oq.token_gen() ;
  local g_leader_rid = oq.raid.group[ group_id ].member[1].realid ;
  if (g_leader_rid == nil) then
    g_leader_rid = OQ_NOEMAIL ;
  end

  oq.token_push( msg_tok ) ;
  local enc_data = oq.encode_data( "abc123", oq.raid.leader, oq.raid.leader_realm, oq.raid.leader_rid ) ;
  local msg = "invite_group,"..  
              req_token ..",".. 
              group_id ..",".. 
              slot ..",".. 
              oq.encode_name( oq.raid.name ) ..",".. 
              oq.raid.leader_class  ..",".. 
              enc_data ..",".. 
              oq.raid.raid_token ..","..
              oq.encode_note( oq.raid.notes ) ;

  -- if i'm already b-net friends or the player is on my realm, just send msg
  local pid = oq.bnpresence( r.name .."-".. r.realm ) ;
  if (pid ~= 0) or (player_realm == r.realm) then
    oq.realid_msg( r.name, r.realm, r.realid, msg ) ;
    oq.InviteUnit( r.name, r.realm ) ;
    oq.remove_waitlist( req_token ) ;
    return ;
  end
  
  -- if reaches here, player is not b-net friend or not on realm... must b-net friend then invite
  oq.bn_realfriend_invite( r.name, r.realm, r.realid, "#tok:".. req_token ..",#grp:".. my_group ..",#nam:".. player_name .."-".. tostring(oq.realm_cooked(player_realm)) ) ; 

  _ninvites = _ninvites + 1 ;
  oq.timer( "invite_to_group".. _ninvites, 2, oq.timer_invite_group, true, req_token, msg ) ;
end

function oq.group_invite_first_slot_in( req_token, group_id ) 
  if (not oq.iam_raid_leader()) then
    -- not possible
    return ;
  end
  local r = oq.waitlist[ req_token ] ;
  
  group_id = tonumber( group_id ) ;
  local slot = oq.first_slot_in_group( group_id ) ;
  if (slot == 0) then
    print( "[oq.group_invite_first_slot_in]  no slots available" ) ;
    return ;
  end
  if (slot == 1) then
    oq.invite_group_leader( req_token, group_id ) ;
  else
    oq.group_invite_slot( req_token, group_id, slot ) ;
  end
end

function oq.group_invite_first_available( req_token ) 
  if (not oq.iam_raid_leader()) then
    -- not possible
    return ;
  end
  local r = oq.waitlist[ req_token ] ;
  
  local group_id, slot = oq.find_first_available_slot( r ) ;
  if (group_id == 0) then
    print( "[oq.group_invite_first_available]  no slots available" ) ;
    return ;
  end
  if (slot == 1) then
    oq.invite_group_leader( req_token, group_id ) ;
  else
    oq.group_invite_slot( req_token, group_id, slot ) ;
  end
end

function oq.group_invite_party( req_token ) 
  local r = oq.waitlist[ req_token ] ;

  local group_id = oq.find_first_available_group( r ) ;
  if (group_id == 0) then
    print( "[oq.group_invite_party]  no empty groups available" ) ;
    return ;
  end

  -- if i'm raid leader, all group leaders must be real-id friends if not on the same realm
  if (oq.iam_raid_leader() and (player_realm ~= r.realm)) then
    oq.realid_msg( r.name, r.realm, r.realid, "#tok:".. req_token ..",#lead" ) ;
  end

  -- the 'W' stands for 'whisper' and should not be echo'd far and wide
  local msg_tok = "W".. oq.token_gen() ;
  oq.token_push( msg_tok ) ;
  local enc_data = oq.encode_data( "abc123", oq.raid.leader, oq.raid.leader_realm, oq.raid.leader_rid ) ;
  local msg = "invite_group_lead,"..  
              req_token ..",".. 
              group_id ..",".. 
              oq.encode_name( oq.raid.name ) ..",".. 
              oq.raid.leader_class  ..",".. 
              enc_data ..",".. 
              oq.raid.raid_token ..","..
              oq.encode_note( oq.raid.notes ) ;

  local m = "OQ,".. OQ_VER ..",".. msg_tok ..",0,".. msg ;
  -- do not call direct, as the bnfriend invite may not be completed yet
  oq.timer_oneshot( 3.5, oq.realid_msg, r.name, r.realm, r.realid, m ) ;
  oq.timer_oneshot( 4.0, oq.brief_group_lead, group_id ) ;

  oq.remove_waitlist( req_token ) ;
end

function oq.make_dropdown_03(req_token)
  local f = {} ;
  local options = {} ;

  for i=1,8 do
    if ((oq.raid.group[i].member[1] == nil) or (oq.raid.group[i].member[1].name == nil) or (oq.raid.group[i].member[1].name == "-")) then
      local o = { val = tostring(i), msg = "group ".. i } ;
      table.insert( options, o ) ;
    end
  end

  for i,v in pairs(options) do
    local d = {} ;
    d.text = v.msg ;
    d.arg1 = v.val ;
    d.arg2 = req_token ;
    d.func = function(self,arg1,arg2) oq.invite_group_leader( arg2, arg1 ) ; return true ; end ;
    table.insert( f, d ) ;
  end
  return f ;
end

function oq.first_slot_in_group( g_id )
  if (g_id < 1) or (g_id > 8) then
    return ;
  end
  for i=1,5 do
    local mem = oq.raid.group[g_id].member[i] ;
    if ((mem == nil) or (mem.name == nil) or (mem.name == "-")) then
      mem.charm = 0 ;
      mem.check = OQ_FLAG_CLEAR ;
      return i ;
    end
  end
end

function oq.make_dropdown_04(req_token)
  local f = {} ;
  local options = {} ;

  for i=1,8 do
    local slot = oq.first_slot_in_group( i ) ;
    if (slot) then
      local o = { val = tostring(i), msg = "group ".. i } ;
      table.insert( options, o ) ;
    end
  end

  for i,v in pairs(options) do
    local d = {} ;
    d.text = v.msg ;
    d.arg1 = v.val ;
    d.arg2 = req_token ;
    d.func = function(self,arg1,arg2) oq.group_invite_first_slot_in( arg2, arg1 ) ; return true ; end ;
    table.insert( f, d ) ;
  end
  return f ;
end

function oq.on_bg_selected( qnumber, ndx )
  oq.raid.group[ my_group ].member[ my_slot ].bg[ qnumber ].type = ndx ;
  oq.raid.group[ my_group ]._stats = nil ;
  oq.timer_trip( "check_stats" ) ;  
end

function oq.make_dropdown_02(qnumber)
  local f = {} ;
  for i=0,OQ_TOTAL_BGS do
    local d = {} ;
    d.text = oq.bg_name( i ) ;
    d.arg1 = qnumber ;
    d.arg2 = i ;
    d.func = function(self,arg1,arg2) oq.on_bg_selected( arg1, arg2 ) ; return true ; end ;
    table.insert( f, d ) ;
  end
  return f ;
end

--
-- name to whisper.  could be real-id, could be on leader's realm
--
function oq.on_remove( g_id, slot )
  -- remove from cell
  g_id = tonumber( g_id ) ;
  slot = tonumber( slot ) ;
  if ((my_group == g_id) and (my_slot == slot)) then
    -- remove myself
    oq.quit_raid_now() ;
    if (slot ~= 1) then
      LeaveParty() ;
    end
  elseif ((my_group == g_id) and (my_slot == 1)) then
    -- OQ leader asking me, the group lead, to kick someone
    local mem = oq.raid.group[g_id].member[slot] ;
    local n = mem.name ;
    if (player_realm ~= mem.realm) then
      n = n .."-".. mem.realm ;
    end
    -- requires a hardware event since 3.3.5... won't work and would produce a lua violation error
--      UninviteUnit( n ) ;
  elseif (slot == 1) then
    -- removing group lead, which removes entire group
    oq.on_remove_group( g_id ) ;
  end
end

function oq.on_remove_group( g_id )
  -- msg ok, remove group
  g_id = tonumber(g_id) ;
  if (my_group == g_id) then
    -- leave raid
    oq.quit_raid_now() ;
  else
    -- clear out group
    for i=1,5 do
      oq.raid_cleanup_slot( g_id, i ) ;
    end
  end  
end

function oq.on_new_lead( raid_token, name, realm, rid ) 
  if (raid_token == nil) or (raid_token ~= oq.raid.raid_token) then
    return ;
  end
  if (name == player_name) then
    -- i am the new oq leader
  elseif (my_slot == 1) then
    -- send real-id request if needed
  end
  -- update oq leader info
  oq.raid.leader       = name ;
  oq.raid.leader_realm = realm ;
  oq.raid.leader_rid   = rid ;
end

function oq.new_oq_leader( name, realm, rid ) 
  oq.raid_announce( "new_lead,"..
                    oq.raid.raid_token ..","..
                    name ..","..  
                    realm ..","..  
                    tostring(rid or "")
                  ) ;
end

function oq.remove_member( g_id, slot ) 
  if (not oq.iam_raid_leader()) then
    return ;
  end
  oq.raid_announce( "remove,"..
                    g_id ..","..
                    slot 
                  ) ;
  if (oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID) then
    local m = oq.raid.group[ g_id ].member[ slot ] ;
    local n = m.name ;
    if (m.realm ~= player_realm) then
      n = n .."-".. m.realm ;
    end
    UninviteUnit( n ) ;
  end
  -- incase the slot if a group lead that is offline
  oq.on_remove( g_id, slot ) ;
end

function oq.member_left( g_id, slot ) 
  oq.raid_cleanup_slot( g_id, slot ) ;
end

function oq.group_left( g_id )
  oq.on_remove_group( g_id ) ;
end

function oq.remove_group( g_id ) 
  if (not oq.iam_raid_leader()) then
    return ;
  end
  -- cannot remove main group; disband raid to remove the main group
  if (g_id == 1) then
    return ;
  end
  oq.raid_announce( "remove_group,".. g_id ) ;
  oq.on_remove_group( g_id ) ;
end

function oq.on_classdot_enter( self )
  local gid = self.gid ;
  local slot = self.slot ;
  --
  -- generate tooltip 
  -- 
  if ((oq.raid.group[gid].member[slot].name == nil) or (oq.raid.group[gid].member[slot].name == "-")) then
    return ;
  end
  local m = oq.raid.group[gid].member[slot] ;
  oq.tooltip_set( self, m.name, m.realm, m.bgroup, m.class, m.resil, m.ilevel, m.hp, m.wins, m.losses, m.hks, m.oq_ver, m.tears, m.level, m.pvppower, m.mmr ) ;
end

function oq.on_classdot_exit( self )
  oq.tooltip_hide() ;
end

function oq.on_btag( name, realm, rid )
  _ok2relay = 1 ;
  realm = oq.realm_uncooked(realm) ;
  for i=1,8 do
    for j=1,5 do
      local p = oq.raid.group[i].member[j] ;
      if (p.name ~= nil) and (p.name == name) and (p.realm ~= nil) and (p.realm == realm) then
        p.realid = rid ;
        return ;
      end
    end
  end
end

function oq.on_need_btag( name, realm )
  _ok2relay = 1 ;
  if (name == player_name) and (realm == player_realm) and (player_realid ~= nil) then
    oq.raid_announce( "btag,"..
                      player_name ..","..
                      oq.realm_cooked(player_realm) ..","..
                      player_realid
                    ) ;
  end
end

function oq.on_classdot_promote( g_id, slot )
  -- promote to group lead
  local m1 = oq.raid.group[g_id].member[1] ;
  local m2 = oq.raid.group[g_id].member[slot] ;
  local req_token = "Q".. oq.token_gen() ;
  oq.token_push( req_token ) ;  -- hang onto it for return
  if (m2.realid == nil) or (m2.realid == "") then
    print( OQ_REDX_ICON .."".. OQ.NOBTAG_01 ) ;
    print( OQ_REDX_ICON .."".. OQ.NOBTAG_02 ) ;
    return ;
  end

  if (g_id == 1) then
    -- push as new oq-leader
    oq.new_oq_leader( m2.name, m2.realm, m2.realid ) ;
    -- need to manually push the promote
    oq.raid_announce( "promote,"..
                      g_id ..","..  
                      m2.name ..","..
                      m2.realm ..","..
                      tostring(m2.realid) ..","..
                      tostring(m2.realm) ..","..
                      req_token
                    ) ;
    oq.on_promote( g_id, m2.name, m2.realm, m2.realid, m2.realm, req_token ) ;
    oq.ui_player() ;
  else
    oq.raid_announce( "promote,"..
                      g_id ..","..  
                      m2.name ..","..
                      m2.realm ..","..
                      player_realid ..","..
                      player_realm ..","..
                      req_token
                    ) ;
  end
  -- update info
  oq.set_group_lead( g_id, m2.name, m2.realm, m2.class, m2.realid ) ;
  oq.set_name      ( g_id, slot, m1.name, m1.realm, m1.class, m1.realid ) ;
end

function oq.is_my_toon( name, realm )
  if (realm ~= player_realm) then
    return nil ;
  end
  name = strlower(name) ;
  for i,v in pairs(OQ_toon.my_toons) do
    if (name == strlower(v.name)) then
      return true ;
    end
  end
  return nil ;
end

function oq.on_classdot_menu_select( g_id, slot, action ) 
  if (action == "promote") then
    local p = oq.raid.group[g_id].member[slot] ;
    if (oq.is_my_toon( p.name, p.realm )) then
      p.realid = player_realid ;
    end
    if (p.realid == nil) or (p.realid == "") then
      -- delay to allow btag to be delivered
      oq.timer_oneshot( 2, oq.on_classdot_promote, g_id, slot ) ;
    else
      oq.on_classdot_promote( g_id, slot ) ;
    end
  elseif (action == "ban") then
    local m = oq.raid.group[ tonumber(g_id) ].member[ tonumber(slot) ] ;
    local dialog = StaticPopup_Show("OQ_BanUser", m.realid) ;
    if (dialog ~= nil) then
      dialog.data2 = { flag = 1, gid = g_id, slot_ = slot } ;
    end
  elseif (action == "kick") then
    oq.remove_member( g_id, slot ) ;
  elseif (type(action) == "number") then
    oq.leader_set_charm( g_id, slot, action ) ;
  else
    print( "[oq.on_classdot_menu_select] unhandled event (".. g_id ..".".. slot .." ".. action ..")" ) ;
  end
end

function oq.make_classdot_dropdown(cell)
  local f = {} ;
  local options = { { val = "promote", f = 2, msg = OQ.DD_PROMOTE }, 
--                    { val = "status" , msg = "status check" }, 
                    { val = "spacer" , f = 2, msg = "---------------", notClickable = 1 },
                    { val = 1        , f = 1, msg = OQ_STAR_ICON       .."  ".. OQ.DD_STAR },
                    { val = 2        , f = 1, msg = OQ_CIRCLE_ICON     .."  ".. OQ.DD_CIRCLE },
                    { val = 3        , f = 1, msg = OQ_BIGDIAMOND_ICON .."  ".. OQ.DD_DIAMOND },
                    { val = 4        , f = 1, msg = OQ_TRIANGLE_ICON   .."  ".. OQ.DD_TRIANGLE },
                    { val = 5        , f = 1, msg = OQ_MOON_ICON       .."  ".. OQ.DD_MOON },
                    { val = 6        , f = 1, msg = OQ_SQUARE_ICON     .."  ".. OQ.DD_SQUARE },
                    { val = 7        , f = 1, msg = OQ_REDX_ICON       .."  ".. OQ.DD_REDX },
                    { val = 8        , f = 1, msg = OQ_SKULL_ICON      .."  ".. OQ.DD_SKULL },
                    { val = 0        , f = 1, msg = OQ.DD_NONE },
                    { val = "spacer2", f = 3, msg = "---------------", notClickable = 1 },
                    { val = "kick"   , f = 3, msg = OQ.DD_KICK }, 
                    { val = "ban"    , f = 3, msg = OQ.DD_BAN }, 
                  } ;

  for i,v in pairs(options) do
    if ((cell.slot ~= 1) and ((v.f == 1) or (v.f == 2) or (v.f == 3))) or 
       ((cell.slot == 1) and (cell.gid ~= 1) and ((v.f == 1) or (v.f == 3))) or
       ((cell.slot == 1) and (cell.gid == 1) and (v.f == 1)) then       
      local d = {} ;
      d.text = v.msg ;
      d.arg1 = v.val ;
      d.notClickable = v.notClickable ;
      d.arg2 = cell ;
      d.func = function(self,arg1,arg2) oq.on_classdot_menu_select( arg2.gid, arg2.slot, arg1 ) ; return true ; end ;
      table.insert( f, d ) ;
    end
  end
  
  local p = oq.raid.group[cell.gid].member[cell.slot] ;
  
  if (p.realid == nil) or (p.realid == "") then
    _sender = nil ;
    oq.raid_announce( "need_btag,"..
                      p.name ..","..
                      p.realm 
                    ) ;
  end
  return f ;
end

function oq.make_member_classdot_dropdown(cell)
  local f = {} ;
  local options = { 
                    { val = "ban", f = 3, msg = OQ.DD_BAN }, 
                  } ;

  for i,v in pairs(options) do
    local d = {} ;
    d.text = v.msg ;
    d.arg1 = v.val ;
    d.notClickable = v.notClickable ;
    d.arg2 = cell ;
    d.func = function(self,arg1,arg2) oq.on_classdot_menu_select( arg2.gid, arg2.slot, arg1 ) ; return true ; end ;
    table.insert( f, d ) ;
  end
  return f ;
end

function oq.cell_occupied( g_id, slot )
  local m = oq.raid.group[ g_id ].member[ slot ] ;
  if ((m.name == nil) or (m.name == "") or (m.name == "-")) then
    return nil ;
  end
  return true ;
end

function oq.my_cell( gid, slot )
  return ((my_group == gid) and (my_slot == slot)) ;
end

function oq.on_classdot_click( cell, frame ) 
  if (oq.iam_raid_leader() and oq.cell_occupied( cell.gid, cell.slot )) then
    cell:SetPoint("Center", UIParent, "Center") ;
    EasyMenu( oq.make_classdot_dropdown(cell), cell, cell, 0, 0, nil, 3 ) ; 
    cell:SetHeight(cell.cy) ; -- forcing hieght; EasyMenu seems to resize the cell for some reason
  elseif oq.cell_occupied( cell.gid, cell.slot ) and not oq.my_cell(cell.gid, cell.slot) then
    cell:SetPoint("Center", UIParent, "Center") ;
    EasyMenu( oq.make_member_classdot_dropdown(cell), cell, cell, 0, 0, nil, 3 ) ; 
    cell:SetHeight(cell.cy) ; -- forcing hieght; EasyMenu seems to resize the cell for some reason
  end
end

function oq.create_class_dot( parent, x, y, cx, cy ) 
  oq.nthings = (oq.nthings or 0) + 1 ;
  local n = "DotRegion".. oq.nthings ;
  local f = oq.panel( parent, n, x, y, cx, cy ) ;
  local val = 5 ;

  f.cy = cy ;

  f.gid  = 0 ;
  f.slot = 0 ;
  n = "DotTexture".. oq.nthings ;
  f.texture:SetAllPoints(f) ;
  f.texture:SetTexture( 0.2, 0.2, 0.0, 1 ) ;

  -- deserter 
  f.status = f:CreateTexture(n .. "Deserter", "OVERLAY" ) ;
  f.status:SetPoint("TOPLEFT", f,"TOPLEFT", 2, -3) ;
  f.status:SetPoint("BOTTOMRIGHT", f,"BOTTOMRIGHT", -2, 3) ;
  f.status:SetTexture( nil ) ;

  -- class
  f.class = f:CreateTexture(n .. "Class", "OVERLAY" ) ;
  f.class:SetPoint("TOPLEFT", f,"CENTER", -8, -8) ;
  f.class:SetPoint("BOTTOMRIGHT", f,"CENTER", 8, 8) ;
  f.class:SetTexture( nil ) ;

  -- role
  f.role = f:CreateTexture(n .. "Role", "OVERLAY" ) ;
  f.role:SetPoint("TOPLEFT", f,"BOTTOMRIGHT", -14, 14) ;
  f.role:SetPoint("BOTTOMRIGHT", f,"BOTTOMRIGHT", 4, -4) ;
  f.role:SetTexture( nil ) ;
  
  -- lucky charm
  f.charm = f:CreateTexture(n .. "Charm", "OVERLAY" ) ;
  f.charm:SetPoint("TOPLEFT", f,"TOPLEFT", -3, 3 ) ;
  f.charm:SetPoint("BOTTOMRIGHT", f,"BOTTOMRIGHT", -15, 15) ;
  f.charm:SetTexture( nil ) ;

  -- add tooltip event handler 
  --
  f:SetScript("OnEnter", function(self, ...) oq.on_classdot_enter(self) ; end ) ;
  f:SetScript("OnLeave", function(self, ...) oq.on_classdot_exit (self) ; end ) ;

  f:SetScript( "OnMouseDown", function(self, frame)  
                                oq.on_classdot_click( self, frame ) ;
                              end  
             ) ;

  oq.moveto( f, x, y ) ;
  f:SetSize( cx, cy ) ;
  f:Show() ;
  return f ;
end

function oq.create_dungeon_dot( parent, x, y, cx, cy ) 
  oq.nthings = (oq.nthings or 0) + 1 ;
  local n = "DotRegion".. oq.nthings ;
  local f = oq.panel( parent, n, x, y, cx, cy ) ;
  local val = 5 ;

  f.cy = cy ;

  f.gid  = 0 ;
  f.slot = 0 ;
  n = "DotTexture".. oq.nthings ;
  f.texture:SetAllPoints(f) ;
  f.texture:SetTexture( 0.2, 0.2, 0.0, 1 ) ;

  -- status
  f.status = f:CreateTexture(n .. "Deserter", "OVERLAY" ) ;
  f.status:SetPoint("TOPLEFT", f,"BOTTOMRIGHT", -25, 16) ;
  f.status:SetPoint("BOTTOMRIGHT", f,"BOTTOMRIGHT", -1, -8) ;

  f.status:SetTexture( nil ) ;

  -- class
  f.class = f:CreateTexture(n .. "Class", "OVERLAY" ) ;
  f.class:SetPoint("TOPLEFT", f,"TOPLEFT", -17, -12) ;
  f.class:SetPoint("BOTTOMRIGHT", f,"TOPLEFT", -1, -28) ;
  f.class:SetTexture( nil ) ;

  -- role
  f.role = f:CreateTexture(n .. "Role", "OVERLAY" ) ;
  f.role:SetPoint("TOPLEFT", f,"BOTTOMLEFT", 1, 14) ;
  f.role:SetPoint("BOTTOMRIGHT", f,"BOTTOMLEFT", 17, -4) ;
  f.role:SetTexture( nil ) ;
  
  -- lucky charm
  f.charm = f:CreateTexture(n .. "Charm", "OVERLAY" ) ;
  f.charm:SetPoint("TOPLEFT", f,"BOTTOMLEFT", 19, 14) ;
  f.charm:SetPoint("BOTTOMRIGHT", f,"BOTTOMLEFT", 35, -2) ;
  f.charm:SetTexture( nil ) ;

  -- add tooltip event handler 
  --
  f:SetScript("OnEnter", function(self, ...) oq.on_classdot_enter(self) ; end ) ;
  f:SetScript("OnLeave", function(self, ...) oq.on_classdot_exit (self) ; end ) ;

  f:SetScript( "OnMouseDown", function(self, frame)  
                                oq.on_classdot_click( self, frame ) ;
                              end  
             ) ;

  oq.moveto( f, x, y ) ;
  f:SetSize( cx, cy ) ;
  f:Show() ;
  return f ;
end

function oq.create_group( parent, x, y, cx, cy, label_cx, title, group_id ) 
  oq.nthings = (oq.nthings or 0) + 1 ;
  local n = "GroupRegion".. oq.nthings ;
  local f = oq.panel( parent, n, x, y, cx, cy ) ;
  local i = 1 ;

  f.texture:SetTexture( 0.0, 0.0, 0.0, 1 ) ;

  f.gid       = oq.label( f,   2, 2,  16, cy-8, title ) ;
  f.bgroup    = oq.texture(f ,16, (cy - 25)/2,  25, 25, nil ) ;
-- f.bgroup.texture:SetTexture( OQ_BGROUP_ICON["Vengeance"] ) ;

  f.realm     = oq.label( f,  50, 2,  75, cy-8, "-" ) ;
  f.realm:SetTextColor( 0.6, 0.6, 0.6 ) ;
  f.leader    = oq.label( f, 135, 2, 125, cy-8, "-" ) ;
  f.leader:SetFont(OQ.FONT, 12, "") ;
  f.lag       = oq.label( f, 135, 2, 120, cy-8, "-" ) ;
  f.lag:SetTextColor( 0.7, 0.7, 0.7, 1 ) ;
  f.lag:SetFont(OQ.FONT, 8, "") ;
  f.lag:SetJustifyV( "BOTTOM" ) ;
  f.lag:SetJustifyH( "RIGHT" ) ;
  
  f.status = {} ;
  f.status[1] = oq.label( f, 450, 2, 100, cy-8, "-" ) ;
  f.status[2] = oq.label( f, 625, 2, 100, cy-8, "-" ) ;

  f.dtime = {} ;
  f.dtime[1] = oq.label( f, 450, 2, 100, cy, "" ) ;
  f.dtime[1]:SetTextColor( 0.7, 0.7, 0.7, 1 ) ;
  f.dtime[1]:SetFont(OQ.FONT, 8, "") ;
  f.dtime[1]:SetJustifyV( "BOTTOM" ) ;
  f.dtime[1]:SetJustifyH( "CENTER" ) ;
  
  f.dtime[2] = oq.label( f, 625, 2, 100, cy, "" ) ;
  f.dtime[2]:SetTextColor( 0.7, 0.7, 0.7, 1 ) ;
  f.dtime[2]:SetFont(OQ.FONT, 8, "") ;
  f.dtime[2]:SetJustifyV( "BOTTOM" ) ;
  f.dtime[2]:SetJustifyH( "CENTER" ) ;

  f.slots = {} ;
  local cx = cy-2*2 ; -- to make them square
  for i=1,5 do
    f.slots[i] = oq.create_class_dot( f, 255 + 5 + (cx+4)*(i-1), 2, cx, cy-2*2 ) ;
    f.slots[i].gid  = group_id ;
    f.slots[i].slot = i ;
  end
  f:Show() ;
  return f ;
end

function oq.create_dungeon_group( parent, x_, y_, ix, iy, label_cx, title, group_id ) 
  oq.nthings = (oq.nthings or 0) + 1 ;
  local n = "GroupRegion".. oq.nthings ;
  local f = oq.panel( parent, n, x_, y_, ix, iy ) ;
  local i = 1 ;

  f.texture:SetTexture( 0.0, 0.0, 0.0, 1 ) ;
  f.texture:SetAllPoints( f ) ;

  local cy = iy - 2*5 ;
  local cx = floor( (ix - 4*10 - 2*10) / 5 ) ;
  
  f.gid = oq.label( f,   2, 2,  16, cy-8, title ) ;

  f.slots = {} ;
  local x = 10 ;
  for i=1,5 do
    f.slots[i] = oq.create_dungeon_dot( f, x, 5, cx, cy ) ;
    f.slots[i].gid  = group_id ;
    f.slots[i].slot = i ;
    x = x + cx + 10 ;
  end

  f:Show() ;
  return f ;
end

function oq.create_scenario_group( parent, x, y, ix, iy, label_cx, title, group_id ) 
  oq.nthings = (oq.nthings or 0) + 1 ;
  local n = "GroupRegion".. oq.nthings ;
  local f = oq.panel( parent, n, x, y, ix, iy ) ;
  local i = 1 ;

  f.texture:SetTexture( 0.0, 0.0, 0.0, 1 ) ;
  f.texture:SetAllPoints( f ) ;

  local cy = iy - 2*5 ;
  local cx = floor( (ix - 4*10 - 2*10) / 5 ) ;
  
  f.gid       = oq.label( f,   2, 2,  16, cy-8, title ) ;
  f.slots = {} ;
  local x = 10 ;
  x = x + cx + 10 ; -- bump ahead one panel to center it
  for i=1,3 do
    f.slots[i] = oq.create_dungeon_dot( f, x, 5, cx, cy ) ;
    f.slots[i].gid  = group_id ;
    f.slots[i].slot = i ;
    x = x + cx + 10 ;
  end
  f:Show() ;
  return f ;
end

function oq.create_arena_group( parent, x_, y_, ix, iy, label_cx, title, group_id ) 
  oq.nthings = (oq.nthings or 0) + 1 ;
  local n = "ArenaRegion".. oq.nthings ;
  local f = oq.panel( parent, n, x_, y_, ix, iy ) ;
  local i = 1 ;

  f.texture:SetTexture( 0.0, 0.0, 0.0, 1 ) ;
  f.texture:SetAllPoints( f ) ;

  local cy = iy - 2*5 ;
  local cx = floor( (ix - 4*10 - 2*10) / 5 ) ;
  
  f.gid = oq.label( f,   2, 2,  16, cy-8, title ) ;

  f.slots = {} ;
  local x = 10 ;
  for i=1,5 do
    f.slots[i] = oq.create_dungeon_dot( f, x, 5, cx, cy ) ;
    f.slots[i].gid  = group_id ;
    f.slots[i].slot = i ;
    x = x + cx + 10 ;
  end

  f:Show() ;
  return f ;
end

function oq.on_premade_item_enter( self )
  oq.pm_tooltip_set( self, self.token ) ;
end

function oq.on_premade_item_exit( self )
  oq.pm_tooltip_hide() ;
end

function oq.create_raid_listing( parent, x, y, cx, cy, token, nwins ) 
  oq.nlistings = oq.nlistings + 1 ;
  local i = 1 ;
  local n = "ListingRegion".. oq.nlistings ;
  local f = oq.panel( parent, n, x, y, cx, cy, true ) ;
  f:SetFrameLevel( parent:GetFrameLevel() + 10 ) ;

  f.cy = cy ;
  f.token = token ;
--  f.texture:SetTexture( 0.0, 0.0, 0.0, 1 ) ;
--  f:SetFrameStrata( "LOW" ) ;

  local x2 = 0 ;
  f.raid_name = oq.label  ( f, x2, 2, 175, cy, ""  ) ;  x2 = x2 + 185 ;
  f.raid_name:SetFont(OQ.FONT, 11, "") ;

  -- 
  -- dragon
  --
  local d = oq.CreateFrame("FRAME", "OQListing".. oq.nlistings .."Dragon", f ) ;
  d:SetBackdropColor(0.8,0.8,0.8,1.0) ;
  oq.setpos( d, x2-16, 0, 32, 32 ) ;
  local t = d:CreateTexture( nil, "OVERLAY" ) ;
  t:SetTexture( nil ) ;
  t:SetAllPoints(d) ;
  t:SetAlpha( 1.0 ) ;
  d.texture = t ;
  d:Show() ;
  f.dragon = d ;
  oq.set_dragon( f, nwins ) ;

  f.leader    = oq.label  ( f, x2, 2,  90, cy, ""  ) ;  x2 = x2 +  90 ;
  f.leader:SetTextColor( 0.9, 0.9, 0.9 ) ;
  f.levels    = oq.label  ( f, x2, 2,  45, cy, ""  ) ;  x2 = x2 +  45 + 2 ; -- keep these 2 lines balanced to line up
  f.min_ilvl  = oq.label  ( f, x2, 2,  40, cy, "-" ) ;  x2 = x2 +  40 - 2 ; -- keep these 2 lines balanced to line up
  f.min_resil = oq.label  ( f, x2, 2,2*48, cy, "-" ) ;  x2 = x2 +  45 ; -- extra wide for dungeon icons
  f.min_mmr   = oq.label  ( f, x2, 2,  45, cy, "-" ) ;  x2 = x2 +  45 ;
  f.zones     = oq.label  ( f, x2, 2, 140, cy, ""  ) ;  x2 = x2 + 140 ;
  f.zones:SetTextColor( 0.9, 0.9, 0.9 ) ;
  f.has_pword = oq.texture( f, x2, 2,  24, 38, nil ) ;  x2 = x2 + 22 ;
  f.req_but   = oq.button ( f, x2, 2,  75, cy-2, OQ.BUT_WAITLIST, 
                                              function(self) 
                                                oq.get_battle_tag() ;
                                                if ((player_realid == nil) or (player_realid == "")) then
                                                  local dialog = StaticPopup_Show("OQ_EnterRealID") ;
                                                  if (dialog) then
                                                    data = self:GetParent().token ;
                                                    data2 = oq.check_and_send_request ;
                                                  end
                                                else
                                                  oq.check_and_send_request( self:GetParent().token ) ;
                                                end
                                              end ) ;
  x2 = x2 +  80 ;
  f.unlist_but = oq.button( f, x2, 2,  24, cy-2, "x", 
                                              function(self,button,down) 
                                                local tok = self:GetParent().token ;
                                                if (button == "LeftButton") then
                                                  oq.send_leave_waitlist( tok ) ; 
                                                elseif (button == "RightButton") then  
                                                  local premade = oq.premades[ tok ] ;
                                                  if (premade ~= nil) then
                                                    local dialog = StaticPopup_Show("OQ_BanUser", premade.leader_rid) ;
                                                    if (dialog ~= nil) then
                                                      dialog.data2 = { flag = 4, btag = premade.leader_rid, raid_tok = tok } ;
                                                    end                                                            
                                                  end
                                                end 
                                              end ) ;
                                              
  f.unlist_but:RegisterForClicks("LeftButtonUp", "RightButtonUp") ;
  f.unlist_but.tt = OQ.TT_LEAVEPREMADE ;
  -- add tooltip event handler 
  --
  f:SetScript("OnEnter", function(self, ...) oq.on_premade_item_enter(self) ; end ) ;
  f:SetScript("OnLeave", function(self, ...) oq.on_premade_item_exit (self) ; end ) ;
                                              
  f:Show() ;
  return f ;
end

function oq.create_waitlist_item( parent, x, y, cx, cy, token, n_members ) 
  oq.nthings = (oq.nthings or 0) + 1 ;
  local i = 1 ;
  local n = "WaitRegion".. oq.nthings ;
  local f = oq.panel( parent, n, x, y, cx, cy, true ) ;
  f:SetFrameLevel( parent:GetFrameLevel() + 10 ) ;

  f.cy = cy ;
  f.token = token ;
--  f.texture:SetTexture( 0.0, 0.0, 0.0, 1 ) ;

  local x2 = 0 ;
  f.remove_but = oq.button( f, x2, 2,  20, cy-2, "x", function(self,button,down)  
                                                        local tok = self:GetParent().req_token ;
                                                        if (button == "LeftButton") then
                                                          oq.remove_waitlist( tok ) ; 
                                                        elseif (button == "RightButton") then  
                                                          local req = oq.waitlist[ tok ] ;
                                                          if (req ~= nil) then
                                                            local dialog = StaticPopup_Show("OQ_BanUser", req.realid) ;
                                                            if (dialog ~= nil) then
                                                              dialog.data2 = { flag = 2, btag = req.realid, req_token = tok } ;
                                                            end                                                            
                                                          end
                                                        end 
                                                      end
                           ) ;
  f.remove_but:RegisterForClicks("LeftButtonUp", "RightButtonUp") ;
  x2 = x2 + 20+4 ;                                               
  f.bgroup     = oq.texture(f , x2, (cy - 25)/2,  25, 25, nil ) ;  x2 = x2 + 30 ;
  f.role       = oq.label  ( f, x2, 5,  16, cy, ""            ) ;  x2 = x2 + 16 ;
  f.toon_name  = oq.label  ( f, x2, 2, 108, cy, ""            ) ;  x2 = x2 + 108 ;
  f.toon_name:SetFont(OQ.FONT, 12, "") ;
  f.realm      = oq.label  ( f, x2, 2, 100, cy, ""            ) ;  x2 = x2 + 100 ;
  f.level      = oq.label  ( f, x2, 2,  40, cy, "85"          ) ;  x2 = x2 +  40 ;
  f.ilevel     = oq.label  ( f, x2, 2,  40, cy, "395"         ) ;  x2 = x2 +  40 ;
  f.resil      = oq.label  ( f, x2, 2,  40, cy, "4100"        ) ;  x2 = x2 +  40 ;
  f.pvppower   = oq.label  ( f, x2, 2,  40, cy, "99999"       ) ;  x2 = x2 +  40 ;
  f.mmr        = oq.label  ( f, x2, 2,  40, cy, "1500"        ) ;  x2 = x2 +  40 ;
  x2 = x2 + 20 ; -- nudge for time
  f.nMembers   = n_members ;

  if (n_members == 1) then
    f.invite_but = oq.button( f, x2, 2,  75, cy-2, OQ.BUT_INVITE, 
                                               function(self, button, down) 
                                                oq.get_battle_tag() ;
                                                if (player_realid == nil) then
                                                  local dialog = StaticPopup_Show("OQ_EnterRealID") ;
                                                  if (dialog) then
                                                    data  = self:GetParent().req_token ;
                                                    data2 = oq.group_invite_first_available ;
                                                  end
                                                else
                                                   local now = utc_time() ;
                                                   if (now < next_invite_tm) then
                                                     return ;
                                                   end
                                                   next_invite_tm = now + 4 ;
                                                   if (oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID) then
                                                     if (button == "LeftButton") then
                                                       -- right button should not work, as you cannot invite directly into a group
                                                       local tok = self:GetParent().req_token ;
                                                       local g, s = oq.first_raid_slot() ;
                                                       oq.group_invite_slot( tok, g, s ) ; -- always 1,5 ... will be reassigned later
                                                     end
                                                   elseif (button == "LeftButton") then
                                                     oq.group_invite_first_available( self:GetParent().req_token ) ;
                                                   elseif (button == "RightButton") then
                                                     EasyMenu( oq.make_dropdown_04(self:GetParent().req_token), self, self, 0, 0, nil, 3 ) ; 
                                                   end
                                                end
                                               end ) ;
    f.invite_but:RegisterForClicks("LeftButtonUp", "RightButtonUp") ;
    x2 = x2 +  75 + 5 ;
    f.ginvite_but = oq.button( f, x2, 2,  75, cy-2, OQ.BUT_GROUPLEAD, 
                                               function(self) 
                                                oq.get_battle_tag() ;
                                                if (player_realid == nil) then
                                                  StaticPopup_Show("OQ_EnterRealID") ;
                                                else
                                                  local now = utc_time() ;
                                                  if (now < next_invite_tm) then
                                                    return ;
                                                  end
                                                  next_invite_tm = now + 4 ;
                                                  if (oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID) then
                                                    message( OQ.NOLEADS_IN_RAID ) ;
                                                  else
                                                    EasyMenu( oq.make_dropdown_03(self:GetParent().req_token), self, self, 0, 0, nil, 3 ) ; 
                                                  end
                                                end
                                               end ) ;
    x2 = x2 +  75 ;
  else
    --
    -- group invite button
    --
    f.invite_but = oq.button( f, x2, 2, 75*2+2, cy-2, string.format( OQ.BUT_INVITEGROUP, n_members ), 
                                               function(self) 
                                                oq.get_battle_tag() ;
                                                if (player_realid == nil) then
                                                  StaticPopup_Show("OQ_EnterRealID") ;
                                                else
                                                  local now = utc_time() ;
                                                  if (now < next_invite_tm) then
                                                    return ;
                                                  end
                                                  next_invite_tm = now + 5 ;
                                                  if (oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID) then
                                                    message( OQ.NOGROUPS_IN_RAID ) ;
                                                  else
                                                    oq.group_invite_party( self:GetParent().req_token ) ;
                                                  end
                                                end
                                               end ) ;
    x2 = x2 + 75*2 + 5 ;
  end
  f.wait_tm = oq.label ( f, x2+10, 2,  70, cy, "00:00" ) ;  x2 = x2 +  50 ;
  f:Show() ;
  return f ;
end

function oq.set_class( g_id, slot, class )
  g_id = tonumber(g_id) ;
  slot = tonumber(slot) ;
  local color = OQ.CLASS_COLORS[class] ;
  oq.raid.group[g_id].member[slot].class = class ;
  
  if (color == nil) then
    color = OQ.CLASS_COLORS[ OQ.SHORT_CLASS[class] ] ;
    if (color == nil) then
      return ;
    end
  end
  if (slot == 1) then
    if (class ~= nil) and (OQ.CLASS_COLORS[class] ~= nil) then
      oq.tab1_group[g_id].leader:SetTextColor( OQ.CLASS_COLORS[class].r, OQ.CLASS_COLORS[class].g, OQ.CLASS_COLORS[class].b ) ;
    end
  end  
  oq.tab1_group[g_id].slots[slot].texture:SetTexture( color.r, color.g, color.b, 1 ) ;
end

function oq.set_group_member( group_id, slot, name_, realm_, class_, rid, bg1, s1, bg2, s2 )
  group_id = tonumber( group_id ) ;
  slot     = tonumber( slot ) ;
--  realm_   = oq.realm_uncooked(realm_) ;

  local realm_id = realm_ ;
  if(tonumber(realm_) ~= nil) then
    realm_ = oq.realm_uncooked(realm_) ;
  else
    realm_id = oq.realm_cooked(realm_) ;
  end
  if (class_ == nil) then
    class_ = "XX" ;
  end
  local old_rid = nil ;
  if (rid ~= nil) then
    old_rid = rid ;
  elseif ((oq.raid.group[group_id] ~= nil) and (oq.raid.group[group_id].member[slot] ~= nil)) then 
    old_rid = oq.raid.group[group_id].member[slot].realid ;
  end
  if (class_ == nil) or (class_:len() > 2) then
    class_ = OQ.SHORT_CLASS[ class_ ] or "ZZ" ;
  end
  local bgroup_ = oq.find_bgroup( realm_ ) ;
  local m = oq.raid.group[group_id].member[slot] ;
  m.name         = name_ ;
  m.class        = class_ ;
  m.realm        = realm_ ;
  m.realm_id     = realm_id ;
  m.bgroup       = bgroup_ ;
  m.realid       = old_rid ;

  if (s1 ~= nil) and (s2 ~= nil) then
    m.bg[1].type   = (bg1 or OQ.NONE) ;
    m.bg[1].status = (s1 or "3") ;
    m.bg[2].type   = (bg2 or OQ.NONE) ;
    m.bg[2].status = (s2 or "4") ;
  end

  if (class_ ~= nil) then
    oq.set_class( group_id, slot, class_ ) ;
  end

  if (slot == 1) then
    oq.tab1_group[group_id].realm :SetText( realm_ ) ;
    oq.tab1_group[group_id].leader:SetText( m.name ) ;
    if (class_ ~= nil) and (OQ.CLASS_COLORS[class_] ~= nil) then
      oq.tab1_group[group_id].leader:SetTextColor( OQ.CLASS_COLORS[class_].r, OQ.CLASS_COLORS[class_].g, OQ.CLASS_COLORS[class_].b ) ;
    end
    oq.tab1_group[group_id].bgroup.texture:SetTexture( OQ.BGROUP_ICON[ oq.find_bgroup(realm_) ] ) ;
  end
end

function oq.set_group_lead( g_id, name, realm, class, rid )
  oq.set_group_member( g_id, 1, name, realm, class, rid ) ;
end

function oq.on_queue_up() 
end

function oq.on_queue_leave() 
--print( "clicking button" ) ;
--QueueStatusMinimapButton:Click("LeftButton") ;
--oq.timer_oneshot( 1, oq.leaveQ_in_a_sec ) ;
end

function oq.queue_button_action(self, button, ndx) 
  if (self:GetText() == OQ.LEAVE_QUEUE) or (button == "RightButton") then
    if (oq.iam_raid_leader()) then
      oq.raid_announce( "leave_queue,".. ndx ) ;
    end
    oq.battleground_leave( ndx ) ; 
    self:SetText( OQ.LEAVE_QUEUE ) ;
    oq.on_queue_leave() ;
  end
end

function  oq.on_reload_now() 
  ReloadUI() ;
end

-- remove trailing and leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(8programming)
function oq.trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- remove leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(8programming)
function oq.ltrim(s)
  return (s:gsub("^%s*", ""))
end

-- remove trailing whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(8programming)
function oq.rtrim(s)
  local n = #s
  while n > 0 and s:find("^%s", n) do n = n - 1 end
  return s:sub(1, n)
end

function oq.tab3_create_activate()
  local in_party = (oq.GetNumPartyMembers() > 0) ;
  if (in_party and not UnitIsGroupLeader("player")) then
    StaticPopup_Show("OQ_CannotCreatePremade", nil, nil, ndx ) ;
    return ;
  end
  oq.get_battle_tag() ;
  local name = oq.rtrim( oq.tab3_raid_name:GetText() ) ;
  if ((name == nil) or (name == "")) then
    message( OQ.MSG_MISSINGNAME ) ;
    return ;
  end
  local low_name = strlower( name ) ;
  if (low_name:find( "lfg" )) then
    message( OQ.MSG_NOTLFG ) ;
    return ;
  end

  if ((player_realid == nil) or (player_realid == "")) then
    local dialog = StaticPopup_Show("OQ_EnterRealID") ;
    if (dialog) then
      data  = 1 ;
      data2 = oq.raid_create ; 
    end
    return ;
  elseif (not oq.valid_rid( player_realid )) then
    message( OQ.BAD_REALID .." ".. tostring(player_realid) ) ;
    return ;
  end
  oq.set_premade_type( oq.tab3_radio_selected ) ;
  
  local rc = nil ;
  if (oq.tab3_create_but:GetText() == OQ.CREATE_BUTTON) then
    rc = oq.raid_create() ; 
    if (rc) then
      rc = oq.update_premade_note() ;
      oq.tab3_create_but:SetText( OQ.UPDATE_BUTTON ) ;
    end
  elseif (oq.tab3_create_but:GetText() == OQ.UPDATE_BUTTON) then
    rc = oq.update_premade_note() ;
  end
  if (rc) then
    -- do not let the user create, update, or disband the premade for 15 seconds
    oq.tab3_create_but:Disable() ;
    oq.timer_oneshot( OQ_CREATEPREMADE_CD, oq.enable_button, oq.tab3_create_but ) ;
    oq.tab1_quit_button:Disable() ;
    oq.timer_oneshot( OQ_CREATEPREMADE_CD, oq.enable_button, oq.tab1_quit_button ) ;
  end
end

function oq.enable_button( but ) 
  if (but ~= nil) then
    but:Enable() ;
  end
end

function oq.find_mesh() 
  oq.tab2_findmesh_but:Disable() ;
  oq.timer_oneshot( OQ_FINDMESH_CD, oq.enable_button, oq.tab2_findmesh_but ) ;
  
  local nOQlocals, nOQfriends = oq.get_nConnections() ;
  local connection = nOQlocals + nOQfriends ;
  if ((connection > OQ_MIN_CONNECTION) and (nOQfriends > 3)) then
    -- at least 3 friends off realm
    print( OQ_TRIANGLE_ICON .." ".. OQ.FINDMESH_OK ) ;
    return ;
  end
  local tok = "B" .. oq.token_gen() ;
  local msg = OQSK_HEADER ..",".. 
              OQSK_VER ..","..
              "W1,"..
              "req_btags,"..
              tostring(player_name) ..",".. 
              tostring(oq.realm_cooked(player_realm)) ..",".. 
              tostring(player_faction) ..",".. 
              tostring(player_realid) ..",".. 
              tok ;
  oq.token_push( tok ) ;
  oq.send_to_scorekeeper( msg ) ;
end

function oq.pull_btag() 
  oq.tab5_pullbtag_but:Disable() ;
  oq.timer_oneshot( OQ_FINDMESH_CD, oq.enable_button, oq.tab5_pullbtag_but ) ;
  local msg = OQSK_HEADER ..",".. 
              OQSK_VER ..","..
              "W1,"..
              "pull_btag,"..
              tostring(player_faction) ..",".. 
              tostring(player_realid) ;
  oq.send_to_scorekeeper( msg ) ;
  oq.tab5_pullbtag_but:Disable() ;
  
  oq.tab2_submit_but:Enable() ;
  OQ_data.btag_submitted = nil ;
end

function oq.submit_still_kickin() 
  if (player_realid == nil) then
    oq.get_battle_tag() ;
  end
  if (player_realm == nil) then
    player_realm = oq.GetRealmName() ;
  end
  if ((player_realid == nil) or (player_realm == nil)) then
    return ;
  end
  local msg = OQSK_HEADER ..",".. 
              OQSK_VER ..","..
              "W1,"..
              "still_kickin,"..
              tostring(player_faction) ..",".. 
              tostring(player_realid) ;
  oq.send_to_scorekeeper( msg ) ;
  return 1 ;
end

function oq.submit_btag( faction_, tag_ )
  local faction = player_faction ;
  local tag     = player_realid ;
  local now     = utc_time() ;
  local my_tag  = true ;

  if (faction_ ~= nil) and (tag_ ~= nil) then
    faction = faction_ ;
    tag     = tag_ ;
    my_tag  = nil ;
  elseif (OQ_data.btag_submitted ~= nil) and (OQ_data.btag_submitted > now) then
    -- no more then once per day
    return ;
  end
  local msg = OQSK_HEADER ..",".. 
              OQSK_VER ..","..
              "W1,"..
              "btag,"..
              tostring(faction) ..",".. 
              tostring(tag) ;
  oq.send_to_scorekeeper( msg ) ;
  if (my_tag) then
    oq.tab2_submit_but:Disable() ;
    OQ_data.ok2submit_tag = 1 ;
    oq.tab5_ok2submit_btag:SetChecked( true ) ;
    OQ_data.btag_submitted = now + 6*3600 ; -- no more then once every 6 hrs
  end
  return 1 ;
end

function oq.cache_btag( tag, note_ )
  if (tag == nil) or (tag == "") then
    return ;
  end
  if (OQ_data.btag_cache == nil) then
    OQ_data.btag_cache = {} ;
  end
  OQ_data.btag_cache[ tag ] = { tm = utc_time() + OQ_BTAG_SUBMIT_INTERVAL, note = note_ } ;
end

function oq.clear_btag_cache()
  OQ_data.btag_cache = {} ;
end

function oq.on_btags( token, t1, t2, t3, t4, t5, t6 )
  _ok2relay  = nil ;
  if (not oq.token_was_seen( token )) then
    -- not my token, bogus msg
    return ;
  end
  local msg = OQ_HEADER ..",".. 
              OQ_VER ..","..
              "W1,0,mesh_tag,0" ;

  if (not oq.is_banned( t1 )) then
    oq.BNSendFriendInvite( t1, msg ) ;
  end
  if (not oq.is_banned( t2 )) then
    oq.BNSendFriendInvite( t2, msg ) ;
  end
  if (not oq.is_banned( t3 )) then
    oq.BNSendFriendInvite( t3, msg ) ;
  end
  if (not oq.is_banned( t4 )) then
    oq.BNSendFriendInvite( t4, msg ) ;
  end
  if (not oq.is_banned( t5 )) then
    oq.BNSendFriendInvite( t5, msg ) ;
  end
  if (not oq.is_banned( t6 )) then
    oq.BNSendFriendInvite( t6, msg ) ;
  end
end

function oq.on_mesh_tag( faction_, rid_ ) 
  if (OQ_data.autoaccept_mesh_request ~= 1) then
    return ;
  end
  local n_bnfriends = select( 1, BNGetNumFriends() )  ;
  if (n_bnfriends < OQ_MAX_BNFRIENDS) then
    _ok2decline = nil ;
    _oq_note    = "OQ,mesh node" ;
  end
end

--------------------------------------------------------------------------
-- main ui creation
--------------------------------------------------------------------------
function oq.create_tab1_bgs( parent )
  local x, y, cx, cy, label_cx ;

  oq.tab1_group = {} ;
  x = 20 ;
  y = 65 ;
  cx = parent:GetWidth() - 2 * x ;
  cy = (parent:GetHeight() - 2*y) / 10 ;
  label_cx = 150 ;

  -- group menus
  for i=1,8 do
    local f = oq.create_group( parent, x, y, cx, cy, label_cx, tostring(i), i ) ;
    f.slot = i ;
    f:Show() ;
    y = y + cy + 2 ;
    oq.tab1_group[i] = f ;
  end
  
  -- battleground selector
  oq.tab1_bg = {} ;
  oq.tab1_bg[1] = {} ;
  oq.tab1_bg[1].queue_button = oq.button( parent, 450, y, 100, 28, "queue", function(self, button) oq.queue_button_action(self, button, 1) ; end ) ;
  oq.tab1_bg[1].queue_button:RegisterForClicks( "AnyUp" ) ;
  oq.tab1_bg[1].queue_button:SetText( OQ.LEAVE_QUEUE ) ;
  oq.tab1_bg[1].queue_button:Show() ;
  oq.tab1_bg[1].status = "0" ;

  oq.tab1_bg[2] = {} ;
  oq.tab1_bg[2].queue_button = oq.button( parent, 625, y, 100, 28, "queue", function(self, button) oq.queue_button_action(self, button, 2) ; end ) ;
  oq.tab1_bg[2].queue_button:RegisterForClicks( "AnyUp" ) ;
  oq.tab1_bg[2].queue_button:SetText( OQ.LEAVE_QUEUE ) ;
  oq.tab1_bg[2].queue_button:Show() ;
  oq.tab1_bg[2].status = "0" ;
  
  parent:SetScript( "OnShow", function() 
                                if (oq.iam_raid_leader()) then 
                                  oq.ui_raidleader() ; 
                                else 
                                  oq.ui_player() ;
                                end
                              end ) ;
end

function oq.create_tab1_dungeon( parent )
  local x, y, cx, cy, label_cx ;
  local group_id = 1 ; -- only one group
  
  x  = 20 ;
  y  = 65 ;
  cx = 50 ;
  cy = 50 ;
  label_cx = 150 ;
  
  oq.dungeon_group = oq.create_dungeon_group( parent, x, y, parent:GetWidth()-x*2, 250, label_cx, title, group_id ) ;
end

function oq.create_tab1_ratedbgs( parent )
  local x, y, cx, cy, label_cx ;

  oq.rbgs_group = {} ;
  x = 20 ;
  y = 65 ;
  cx = parent:GetWidth() - 2 * x ;
  cy = (parent:GetHeight() - 2*y) / 10 ;
  label_cx = 150 ;

  -- group menus
  for i=1,2 do
    local f = oq.create_group( parent, x, y, cx, cy, label_cx, tostring(i), i ) ;
    f.slot = i ;
    f:Show() ;
    y = y + cy + 2 ;
    oq.rbgs_group[i] = f ;
  end
end

function oq.create_tab1_raid( parent )
  local x, y, cx, cy, label_cx ;

  oq.raid_group = {} ;
  x = 20 ;
  y = 65 ;
  cx = parent:GetWidth() - 2 * x ;
  cy = (parent:GetHeight() - 2*y) / 10 ;
  label_cx = 150 ;

  -- group menus
  for i=1,8 do
    local f = oq.create_group( parent, x, y, cx, cy, label_cx, tostring(i), i ) ;
    f.slot = i ;
    f:Show() ;
    y = y + cy + 2 ;
    oq.raid_group[i] = f ;
  end
end

function oq.create_tab1_scenario( parent )
  local x, y, cx, cy, label_cx ;
  local group_id = 1 ; -- only one group
  
  x  = 20 ;
  y  = 65 ;
  cx = 50 ;
  cy = 50 ;
  label_cx = 150 ;
  
  oq.scenario_group = oq.create_scenario_group( parent, x, y, parent:GetWidth()-x*2, 250, label_cx, title, group_id ) ;
end

function oq.create_tab1_arena( parent )
  local x, y, cx, cy, label_cx ;
  local group_id = 1 ; -- only one group
  
  x  = 20 ;
  y  = 65 ;
  cx = 50 ;
  cy = 50 ;
  label_cx = 150 ;
  
  oq.arena_group = oq.create_arena_group( parent, x, y, parent:GetWidth()-x*2, 250, label_cx, title, group_id ) ;
end

function oq.create_tab1_common( parent )
  local x, y, cx, cy, label_cx ;
  x = 20 ;
  y = 65 ;
  cx = parent:GetWidth() - 2 * x ;
  cy = (parent:GetHeight() - 2*y) / 10 ;
  label_cx = 150 ;
  
  -- raid title
  oq.tab1_name = oq.label( parent, x, 30, 300, 30, "" ) ;
  oq.tab1_name:SetFont(OQ.FONT, 14, "") ;

  -- raid notes
  y = parent:GetHeight() - cy*2 - 45 ;
  oq.tab1_notes_label = oq.label( parent, x, y     , 100, 20, "notes:" ) ;
  oq.tab1_notes       = oq.label( parent, x, y + 12, 285, cy*2 - 10, "" ) ;
  oq.tab1_notes:SetNonSpaceWrap(true) ;
  oq.tab1_notes_label:SetTextColor( 0.7, 0.7, 0.7, 1 ) ;
  oq.tab1_notes:SetTextColor( 0.9, 0.9, 0.9, 1 ) ;

  --[[ tag and version ]]--
  oq.tab1_tag = oq.place_tag( parent ) ;
  OQFrameHeaderLogo:SetText( OQ.TITLE_LEFT .."".. OQUEUE_VERSION .."".. OQ.TITLE_RIGHT ) ;

  -- brb button
  oq.tab1_brb_button = oq.button( parent, 300, y, 100, 28, OQ.ILL_BRB, 
                                  function(self) oq.brb() ; end ) ;

  -- lucky charms  
  y = y + 30 ;
  oq.tab1_lucky_charms = oq.button( parent, 250, parent:GetHeight()-40, 100, 25, OQ.LUCKY_CHARMS, 
                                    function(self) oq.assign_lucky_charms() ; end ) ;
  oq.tab1_lucky_charms:Hide() ;
  -- ready check
  oq.tab1_readycheck_button = oq.button( parent, 350, parent:GetHeight()-40, 100, 25, OQ.READY_CHK, 
                                         function(self) oq.start_ready_check() ; end ) ;

  -- quit premade
  oq.tab1_quit_button = oq.button( parent, parent:GetWidth()-155, parent:GetHeight()-40, 145, 25, OQ.LEAVE_PREMADE, 
                                   function(self) oq.quit_raid() ; end ) ;

  -- raid stats (ie: "5 / 4000 / 455" )
  x = parent:GetWidth()-155 - 110 ;
  y = parent:GetHeight() -  35 ;
  oq.tab1_raid_stats = oq.label( parent, x, y, 100, 15, "" ) ;  
  oq.tab1_raid_stats:SetJustifyH("RIGHT") ;
  oq.tab1_raid_stats:SetTextColor( 0.8, 0.8, 0.8, 1 ) ;
end

function oq.set_premade_type( t )
  oq.raid.type = t ;
  if (oq.iam_raid_leader()) then
    if (t == OQ.TYPE_RBG) or (t == OQ.TYPE_RAID) then
      ConvertToRaid() ;
    else
      ConvertToParty() ;
    end
  end
  
  -- hide all
  oq.ui.bg_frame       :Hide() ;  
  oq.ui.dungeon_frame  :Hide() ;
  oq.ui.ratedbgs_frame :Hide() ;
  oq.ui.arena_frame    :Hide() ;
  oq.ui.raid_frame     :Hide() ;  
  oq.ui.scenario_frame :Hide() ;  
  if (OQTabPage1:IsVisible()) then
    -- force the showing of the frame, incase the type changed 
    oq.onShow_tab1() ;
    oq.refresh_textures() ;
  end
end

function oq.onShow_tab1()
  if (oq.raid.type == OQ.TYPE_BG) then
    oq.ui.bg_frame:Show() ;  
  elseif (oq.raid.type == OQ.TYPE_DUNGEON) then
    oq.ui.dungeon_frame:Show() ;
  elseif (oq.raid.type == OQ.TYPE_RBG) then
    oq.ui.ratedbgs_frame:Show() ;
  elseif (oq.raid.type == OQ.TYPE_RAID) then
    oq.ui.raid_frame:Show() ;
  elseif (oq.raid.type == OQ.TYPE_SCENARIO) then
    oq.ui.scenario_frame:Show() ;
  elseif (oq.raid.type == OQ.TYPE_ARENA) then
    oq.ui.arena_frame:Show() ;
  end
end

function oq.create_tab1()
  local cx = OQTabPage1:GetWidth() ;
  local cy = OQTabPage1:GetHeight() ;
  local level = OQTabPage1:GetFrameLevel() + 2 ;

  OQTabPage1:SetScript( "OnShow", function() oq.onShow_tab1() ; oq.refresh_textures() ; end ) ;

  -- create common elements
  oq.create_tab1_common( OQTabPage1 ) ;
  
  -- create specific component: battlegrounds
  oq.ui.bg_frame = oq.panel( OQTabPage1, "OQPage1BGs", 0, 0, cx, cy, true ) ;
  oq.ui.bg_frame:SetFrameLevel( level ) ;
  oq.create_tab1_bgs( oq.ui.bg_frame ) ;
  
  -- create specific component: dungeons
  oq.ui.dungeon_frame = oq.panel( OQTabPage1, "OQPage1Dungeon", 0, 0, cx, cy, true ) ;
  oq.ui.dungeon_frame:SetFrameLevel( level ) ;
  oq.create_tab1_dungeon( oq.ui.dungeon_frame ) ;
  
  -- create specific component: rated-bgs
  oq.ui.ratedbgs_frame = oq.panel( OQTabPage1, "OQPage1RatedBGs", 0, 0, cx, cy, true ) ;
  oq.ui.ratedbgs_frame:SetFrameLevel( level ) ;
  oq.create_tab1_ratedbgs( oq.ui.ratedbgs_frame ) ;
  
  -- create specific component: raid
  oq.ui.raid_frame = oq.panel( OQTabPage1, "OQPage1Raid", 0, 0, cx, cy, true ) ;
  oq.ui.raid_frame:SetFrameLevel( level ) ;
  oq.create_tab1_raid( oq.ui.raid_frame ) ;
  
  -- create specific component: scenario
  oq.ui.scenario_frame = oq.panel( OQTabPage1, "OQPage1Scenario", 0, 0, cx, cy, true ) ;
  oq.ui.scenario_frame:SetFrameLevel( level ) ;
  oq.create_tab1_scenario( oq.ui.scenario_frame ) ;
  
  -- create specific component: arena
  oq.ui.arena_frame = oq.panel( OQTabPage1, "OQPage1Arena", 0, 0, cx, cy, true ) ;
  oq.ui.arena_frame:SetFrameLevel( level ) ;
  oq.create_tab1_arena( oq.ui.arena_frame ) ;
  
  -- show appropriate frame
  if (oq.raid == nil) or (oq.raid.type == nil) then
    oq.set_premade_type( OQ.TYPE_BG ) ;
  else
    oq.set_premade_type( oq.raid.type ) ;
  end
  
  -- enable proper controls
  oq.ui_player() ;
end

function oq.create_scrolling_list( parent, type_ )
  local scroll = oq.CreateFrame( "ScrollFrame", parent:GetName() .."ListScrollBar", parent, "FauxScrollFrameTemplate" ) ;
  scroll:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, 16, OQ_ModScrollBar_Update); end ) ;
  scroll:SetScript("OnShow", function(self) OQ_ModScrollBar_Update(self) ; end ) ;
  scroll._type = type_ ;

  local list = oq.CreateFrame( "Frame", parent:GetName() .."List", scroll ) ;
  list:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                 edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                 tile=true, tileSize = 16, edgeSize = 16,
                 insets = { left = 1, right = 1, top = 1, bottom = 1 }
                 })
  list:SetBackdropColor(0.0,0.0,0.0,1.0);
  oq.setpos( list, 0, 0, parent:GetWidth() - 2*30, 1000 ) ;

  scroll:SetScrollChild( list ) ;
  scroll:Show() ;
  
  return scroll, list ;
end

function oq.sort_premades( col )
  local order = oq.premade_sort_ascending ;
  if (oq.premade_sort ~= col) then
    order = true ;
  else
    if (order) then
      order = nil ;
    else
      order = true ;
    end
  end
  oq.premade_sort = col ;
  oq.premade_sort_ascending = order ;
  oq.reshuffle_premades() ;
end

function oq.on_premade_filter( arg1, arg2 )
  oq.premade_filter_type = arg1 ;
  oq.reshuffle_premades() ;
end

--
-- good page for docs:
-- http://www.wowpedia.org/API_UIDropDownMenu_AddButton
-- 
function oq.make_dropdown_premade_filter()
  local types = { { text = OQ.LABEL_ALL      , arg1 = OQ.TYPE_NONE },
                  { text = OQ.LABEL_ARENAS   , arg1 = OQ.TYPE_ARENA },
                  { text = OQ.LABEL_BGS      , arg1 = OQ.TYPE_BG },
                  { text = OQ.LABEL_DUNGEONS , arg1 = OQ.TYPE_DUNGEON },
                  { text = OQ.LABEL_RBGS     , arg1 = OQ.TYPE_RBG },
                  { text = OQ.LABEL_RAIDS    , arg1 = OQ.TYPE_RAID },
                  { text = OQ.LABEL_SCENARIOS, arg1 = OQ.TYPE_SCENARIO },
                } ;
  for i=1,7 do
    local d = UIDropDownMenu_CreateInfo() ;
    d.text = types[i].text ;
    d.value = types[i].arg1 ;
    d.arg1  = types[i].arg1 ;
    d.arg2  = types[i].text ;
    d.cb    = self ;
    d.func = function(self,arg1,arg2) 
               oq.on_premade_filter( arg1, arg2 ) ; 
               UIDropDownMenu_SetSelectedValue( oq.tab2_filter, arg1 ) ;
               return true ; 
             end ;
    UIDropDownMenu_AddButton(d) ;
  end
end

function oq.update_premade_count() 
  local nShown, nPremades = oq.n_premades() ;

  local str = string.format( "%s  (|cFFE0E0E0%d|r - |cFF808080%d|r)", OQ.HDR_PREMADE_NAME, nShown, nPremades ) ;
  oq.premade_hdr.label:SetText( str ) ;
end

function oq.create_tab2()
  local parent = OQTabPage2 ;
  local x, y, cx, cy ;

  -- sorting and filtering presets
  oq.premade_sort = "name" ;
  oq.premade_sort_ascending = true ;
  oq.premade_filter_qualified = 0 ;
  oq.premade_filter_type = OQ.TYPE_NONE ; -- show all premade types
  
  parent:SetScript( "OnShow", function() oq.populate_tab2() ; end ) ;

  oq.tab2_scroller, oq.tab2_list = oq.create_scrolling_list( parent, "premades" ) ;
  
  local f = oq.tab2_scroller ;
  oq.setpos( f, -40, 50, f:GetParent():GetWidth() - 2*30, f:GetParent():GetHeight() - (50+38) ) ;

  -- list header
  cy = 20 ;
  x  = 20 + 20 ;
  y  = 27 ;
  f = oq.click_label( parent, x, y, 185, cy, OQ.HDR_PREMADE_NAME  ) ;  x = x + 185 ;
  f:SetScript("OnClick", function(self) oq.sort_premades( "name" ) ; end ) ;
  oq.premade_hdr = f ;
  
  f = oq.click_label( parent, x, y,  90, cy, OQ.HDR_LEADER        ) ;  x = x +  90 ;
  f:SetScript("OnClick", function(self) oq.sort_premades( "lead" ) ; end ) ;
  f = oq.click_label( parent, x, y,  45, cy, OQ.HDR_LEVEL_RANGE   ) ;  x = x +  47 ;
  f:SetScript("OnClick", function(self) oq.sort_premades( "level" ) ; end ) ;
  f = oq.click_label( parent, x, y,  40, cy, OQ.HDR_ILEVEL        ) ;  x = x +  40 ;
  f:SetScript("OnClick", function(self) oq.sort_premades( "ilevel" ) ; end ) ;
  f = oq.click_label( parent, x, y,  45, cy, OQ.HDR_RESIL         ) ;  x = x +  45 ;
  f:SetScript("OnClick", function(self) oq.sort_premades( "resil" ) ; end ) ;
  f = oq.click_label( parent, x, y,  45, cy, OQ.HDR_MMR           ) ;  x = x +  45 ;
  f:SetScript("OnClick", function(self) oq.sort_premades( "mmr" ) ; end ) ;
--  oq.label( parent, x, y, 150, cy, OQ_HDR_BATTLEGROUNDS ) ; x = x + 125 ;

  x = parent:GetWidth() - 200 ;
  oq.tab2_nfriends = oq.label( parent, x, y, 150, cy, string.format( OQ.BNET_FRIENDS, 0 ) ) ; 
  oq.tab2_nfriends:SetJustifyH("right") ;

  x = parent:GetWidth() - (110 + 50) ;
  y = parent:GetHeight() - 32 ;
  oq.tab2_connection = oq.label( parent, x, y, 110, 15, "connection  0 : 0" ) ;
  oq.tab2_connection:SetJustifyH("right") ;

  x = x - 110 ;
  oq.tab2_findmesh_but = oq.button2( parent, x, y-5, 90, 24, OQ.BUT_FINDMESH, 14,
                                     function(self) oq.find_mesh() ; end 
                                    ) ;
  oq.tab2_findmesh_but.string:SetFont(OQ.FONT, 10, "") ;
  
  x = x - 95 ;
  oq.tab2_submit_but = oq.button2( parent, x, y-5, 90, 24, OQ.BUT_SUBMIT2MESH, 14,
                                   function(self) oq.submit_btag() ; end 
                                 ) ;
  oq.tab2_submit_but.string:SetFont(OQ.FONT, 10, "") ;
  if (OQ_data.btag_submitted ~= nil) and (OQ_data.btag_submitted > utc_time()) then
    oq.tab2_submit_but:Disable() ;
  else
    oq.tab2_submit_but:Enable() ;
  end

  x = x - 195 ;
  oq.tab2_filter = CreateFrame("Frame", "OQCombo1", parent, "UIDropDownMenuTemplate") ;
  oq.setpos( oq.tab2_filter, x, y-5, 195, 24 ) ;
  UIDropDownMenu_Initialize( oq.tab2_filter, oq.make_dropdown_premade_filter ) ;
  UIDropDownMenu_SetSelectedID( oq.tab2_filter, 1 ) ;
  UIDropDownMenu_JustifyText( oq.tab2_filter, "LEFT" ) ;
  UIDropDownMenu_SetWidth( oq.tab2_filter, 150, 0 ) ;

  x = x - 85 ;
  oq.tab3_enforce = oq.checkbox( parent, x, y,  23, cy, 90, OQ.QUALIFIED, (oq.premade_filter_qualified == 1), 
                     function(self) oq.toggle_premade_qualified( self ) ; end ) ;  

  -- tooltips
  oq.tab2_findmesh_but.tt = OQ.TT_FINDMESH ;
  oq.tab2_submit_but.tt   = OQ.TT_SUBMIT2MESH ;

  -- add sample raids
  oq.tab2_raids = {} ;

  -- tag
  oq.tab2_tag = oq.place_tag( parent ) ;

  oq.reshuffle_premades() ;
end

function oq.tab3_radio_buttons( but )
  local nmembers = oq.nMembers() ;
  if (but.value == OQ.TYPE_SCENARIO) and (nmembers > 3) then
    message( string.format( OQ.DLG_16, 3 ) ) ;
    oq.tab3_radio_scenario:SetChecked( nil ) ;
    return ;
  end
  if (but.value == OQ.TYPE_DUNGEON ) and (nmembers > 5) then
    message( string.format( OQ.DLG_16, 5 ) ) ;
    oq.tab3_radio_dungeon:SetChecked( nil ) ;
    return ;
  end
  if (but.value == OQ.TYPE_ARENA) and (nmembers > 5) then
    message( string.format( OQ.DLG_16, 5 ) ) ;
    oq.tab3_radio_arena:SetChecked( nil ) ;
    return ;
  end
  if (but.value == OQ.TYPE_RBG     ) and (nmembers > 10) then
    message( string.format( OQ.DLG_16, 10 ) ) ;
    oq.tab3_radio_rbgs:SetChecked( nil ) ;
    return ;
  end

  oq.tab3_radio_bgs     :SetChecked( nil ) ;
  oq.tab3_radio_dungeon :SetChecked( nil ) ;
  oq.tab3_radio_rbgs    :SetChecked( nil ) ;
  oq.tab3_radio_arena   :SetChecked( nil ) ;
  oq.tab3_radio_raid    :SetChecked( nil ) ;
  oq.tab3_radio_scenario:SetChecked( nil ) ;

  but:SetChecked( true ) ;
  oq.tab3_radio_selected = but.value ;
end

function oq.tab3_set_radiobutton( value )
  if (oq.tab3_radio_bgs.value == value) then
    oq.tab3_radio_buttons( oq.tab3_radio_bgs ) ;
  elseif (oq.tab3_radio_dungeon.value == value) then
    oq.tab3_radio_buttons( oq.tab3_radio_dungeon ) ;
  elseif (oq.tab3_radio_rbgs.value == value) then
    oq.tab3_radio_buttons( oq.tab3_radio_rbgs ) ;
  elseif (oq.tab3_radio_raid.value == value) then
    oq.tab3_radio_buttons( oq.tab3_radio_raid ) ;
  elseif (oq.tab3_radio_scenario.value == value) then
    oq.tab3_radio_buttons( oq.tab3_radio_scenario ) ;
  end
  oq.tab3_radio_selected = value ;
  oq.set_premade_type( value ) ;
end

function oq.create_tab3()
  local x, y, cx, cy ;

  OQTabPage3:SetScript( "OnShow", function() oq.populate_tab3() ; end ) ;
  x  = 20 ;
  y  = 30 ;
  cy = 25 ;
  local t = oq.label( OQTabPage3, x, y, 400, 30, OQ.CREATEURPREMADE ) ;
  t:SetFont(OQ.FONT, 14, "") ;

  y = 65 ;
  x = 40 ;
  oq.label( OQTabPage3, x, y, 100, cy, OQ.PREMADE_NAME    ) ;   y = y + cy + 4 ;
  oq.label( OQTabPage3, x, y, 100, cy, OQ.LEADERS_NAME    ) ;   y = y + cy + 4 ;
  oq.label( OQTabPage3, x, y, 100, cy, OQ.REALID_MOP      ) ;   y = y + cy + 4 ;
  oq.label( OQTabPage3, x, y, 100, cy, OQ.MIN_ILEVEL      ) ;   y = y + cy + 4 ;
  oq.label( OQTabPage3, x, y, 100, cy, OQ.MIN_RESIL       ) ;   y = y + cy + 4 ;
  oq.label( OQTabPage3, x, y, 125, cy, OQ.MIN_MMR         ) ;   y = y + cy + 4 ;
  oq.label( OQTabPage3, x, y, 100, cy, OQ.BATTLEGROUNDS   ) ;   y = y + cy + 4 ;
  oq.label( OQTabPage3, x, y, 100, cy, OQ.NOTES           ) ;   y = y + 3*cy + 4 ;
  oq.label( OQTabPage3, x, y, 100, cy, OQ.PASSWORD        ) ;   

  -- set faciton emblem
  local txt ;
  if (player_faction == "A") then
    txt = "Interface\\FriendsFrame\\PlusManz-Alliance" ;
  else
    txt = "Interface\\FriendsFrame\\PlusManz-Horde" ;
  end
  oq.tab3_faction_emblem = oq.texture( OQTabPage3, 450, 65, 100, 100, txt ) ;

  -- set level range 
  if (player_level == 90) then
    t = oq.label( OQTabPage3, 540, 65, 100, 50, OQ.LABEL_LEVEL ) ;
  else
    t = oq.label( OQTabPage3, 540, 65, 100, 50, OQ.LABEL_LEVELS ) ;
  end
  t:SetFont(OQ.FONT, 22, "") ;
  t:SetJustifyH("center") ;

  local minlevel, maxlevel = oq.get_player_level_range() ;
  if (minlevel == 0) then
    txt = "unavailable" ;
  elseif (minlevel == 90) then
    txt = "90" ;
  else
    txt = minlevel .." - ".. maxlevel ;
  end
  oq.tab3_level_range = txt ;
  t = oq.label( OQTabPage3, 540, 100, 100, 50, txt ) ;
  t:SetFont(OQ.FONT, 22, "") ;
  t:SetJustifyH("center") ;

  y  = 65 ;
  x  = 175 ;
  cx = 200 ;
  cy = 25 ;
  oq.tab3_raid_name      = oq.editline( OQTabPage3, "RaidName"     , x, y,   cx,   cy,  25 ) ; y = y + cy + 4 ;
  oq.tab3_lead_name      = oq.editline( OQTabPage3, "LeadName"     , x, y,   cx,   cy,  30 ) ; y = y + cy + 4 ;
  oq.tab3_rid            = oq.editline( OQTabPage3, "RealID"       , x, y,   cx,   cy,  60 ) ; y = y + cy + 4 ;
  oq.tab3_min_ilevel     = oq.editline( OQTabPage3, "MinIlevel"    , x, y,   cx,   cy,  10 ) ; y = y + cy + 4 ;
  oq.tab3_min_resil      = oq.editline( OQTabPage3, "MinResil"     , x, y,   cx,   cy,  10 ) ; y = y + cy + 4 ;
  oq.tab3_min_mmr        = oq.editline( OQTabPage3, "MinMMR"       , x, y,   cx,   cy,  10 ) ; y = y + cy + 4 ;

  oq.tab3_enforce = oq.checkbox( OQTabPage3, x+cx+10, y,  23, cy, 200, OQ.ENFORCE_LEVELS, (oq.raid.enforce_levels == 1), 
                     function(self) oq.toggle_enforce_levels( self ) ; end ) ;  
  
  oq.tab3_bgs            = oq.editline( OQTabPage3, "Battlegrounds", x, y,   cx,   cy,  60 ) ; y = y + cy + 4 ;
  oq.tab3_notes          = oq.editbox ( OQTabPage3, "Notes"        , x, y,  350, 3*cy, 150 ) ; y = y + 3*cy + 4 ;
  oq.tab3_notes:SetMaxLetters( 125 ) ;
  oq.tab3_notes:SetFont(OQ.FONT, 10, "") ;
  oq.tab3_notes:SetTextColor( 0.9, 0.9, 0.9, 1 ) ;
  oq.tab3_notes:SetText( OQ.DEFAULT_PREMADE_TEXT ) ;
  
  oq.tab3_pword          = oq.editline( OQTabPage3, "password", x, y,   cx,   cy,  10 ) ; y = y + cy + 6 ;

  -- disable real-id to force user to setup tab
  -- in MoP, tab3_rid can only be the battle-tag
  oq.tab3_lead_name:Disable() ; 
  oq.tab3_rid      :Disable() ; 

  oq.tab3_faction        = player_faction ;
  oq.tab3_channel_pword  = "p".. oq.token_gen() ;  -- no reason for the leader to set password.  just auto generate
  oq.tab3_lead_name:SetText( player_name ) ; -- auto-populate the leader name
  if (player_realid ~= nil) then
    oq.tab3_rid:SetText( player_realid ) ; -- auto-populate the leader real-id, if we have it
  end

  -- premade type selector
  y  = 180 ;
  x  = OQTabPage3:GetWidth() - 250 ;
  cy = 22 ;
  oq.label( OQTabPage3, x, y, 100, cy, "Premade type:" ) ;   y = y + cy + 3 ;
  x = x + 25 ;
  oq.tab3_radio_bgs      = oq.radiobutton( OQTabPage3, x, y, 24, 22, 100, OQ.LABEL_BG      , OQ.TYPE_BG      , oq.tab3_radio_buttons ) ;   y = y + cy ;
  oq.tab3_radio_dungeon  = oq.radiobutton( OQTabPage3, x, y, 24, 22, 100, OQ.LABEL_DUNGEON , OQ.TYPE_DUNGEON , oq.tab3_radio_buttons ) ;   y = y + cy ;
  oq.tab3_radio_rbgs     = oq.radiobutton( OQTabPage3, x, y, 24, 22, 100, OQ.LABEL_RBG     , OQ.TYPE_RBG     , oq.tab3_radio_buttons ) ;   y = y + cy ;
  oq.tab3_radio_arena    = oq.radiobutton( OQTabPage3, x, y, 24, 22, 100, OQ.LABEL_ARENA   , OQ.TYPE_ARENA   , oq.tab3_radio_buttons ) ;   y = y + cy ;
  oq.tab3_radio_raid     = oq.radiobutton( OQTabPage3, x, y, 24, 22, 100, OQ.LABEL_RAID    , OQ.TYPE_RAID    , oq.tab3_radio_buttons ) ;   y = y + cy ;
  oq.tab3_radio_scenario = oq.radiobutton( OQTabPage3, x, y, 24, 22, 100, OQ.LABEL_SCENARIO, OQ.TYPE_SCENARIO, oq.tab3_radio_buttons ) ;   y = y + cy ;

  -- not ready yet
--  oq.tab3_radio_rbgs:Disable() ;
--  oq.tab3_radio_raid:Disable() ;

  if (oq.raid.type == nil) or (oq.raid.raid_token == nil) then
    oq.tab3_radio_buttons( oq.tab3_radio_bgs ) ;
  else
    oq.tab3_set_radiobutton( oq.raid.type ) ;
  end
  
  -- create/update button
  oq.tab3_create_but     = oq.button2( OQTabPage3, OQTabPage3:GetWidth() - 250, OQTabPage3:GetHeight() - 80, 150, 45, OQ.CREATE_BUTTON, 14,
                                      function(self) oq.tab3_create_activate() ; end 
                                    ) ;
  oq.tab3_create_but.string:SetFont(OQ.FONT, 14, "") ;

  -- tabbing order
  oq.set_tab_order( oq.tab3_raid_name    , oq.tab3_min_ilevel ) ;
  oq.set_tab_order( oq.tab3_min_ilevel   , oq.tab3_min_resil ) ;
  oq.set_tab_order( oq.tab3_min_resil    , oq.tab3_min_mmr ) ;
  oq.set_tab_order( oq.tab3_min_mmr      , oq.tab3_bgs ) ;
  oq.set_tab_order( oq.tab3_bgs          , oq.tab3_notes ) ;
  oq.set_tab_order( oq.tab3_notes        , oq.tab3_pword ) ;
  oq.set_tab_order( oq.tab3_pword        , oq.tab3_raid_name ) ;

  -- tag
  oq.tab3_tag = oq.place_tag( OQTabPage3 ) ;
end

function oq.sort_waitlist( col )
  local order = oq.waitlist_sort_ascending ;
  if (oq.waitlist_sort ~= col) then
    order = true ;
  else
    if (order) then
      order = nil ;
    else
      order = true ;
    end
  end
  oq.waitlist_sort = col ;
  oq.waitlist_sort_ascending = order ;
  oq.reshuffle_waitlist() ;
end

function oq.create_tab_waitlist()
  local x, y, cx, cy ;
  local parent = OQTabPage7 ;
  oq.tab7_scroller, oq.tab7_list = oq.create_scrolling_list( parent, "waitlist" ) ;
  local f = oq.tab7_scroller ;
  oq.setpos( f, -40, 50, f:GetParent():GetWidth() - 2*30, f:GetParent():GetHeight() - (50+38) ) ;

  -- list header
  cy = 20 ;
  x  = 58 ; 
  y  = 27 ;

  f = oq.click_label( parent, x, y,  50, cy, OQ.HDR_BGROUP    ) ;  x = x +  55 ;  -- leave space for role icon
  f:SetScript("OnClick", function(self) oq.sort_waitlist( "bgrp" ) ; end ) ;
  f = oq.click_label( parent, x, y, 120, cy, OQ.HDR_TOONNAME  ) ;  x = x + 105 ;  
  f:SetScript("OnClick", function(self) oq.sort_waitlist( "name" ) ; end ) ;
  f = oq.click_label( parent, x, y, 100, cy, OQ.HDR_REALM     ) ;  x = x + 100 ;
  f:SetScript("OnClick", function(self) oq.sort_waitlist( "rlm" ) ; end ) ;
  f = oq.click_label( parent, x, y,  40, cy, OQ.HDR_LEVEL     ) ;  x = x +  40 ;
  f:SetScript("OnClick", function(self) oq.sort_waitlist( "level" ) ; end ) ;
  f = oq.click_label( parent, x, y,  40, cy, OQ.HDR_ILEVEL    ) ;  x = x +  40 ;
  f:SetScript("OnClick", function(self) oq.sort_waitlist( "ilevel" ) ; end ) ;
  f = oq.click_label( parent, x, y,  50, cy, OQ.HDR_RESIL     ) ;  x = x +  41 ;
  f:SetScript("OnClick", function(self) oq.sort_waitlist( "resil" ) ; end ) ;
  f = oq.click_label( parent, x, y,  40, cy, OQ.HDR_PVPPOWER  ) ;  x = x +  40 ;
  f:SetScript("OnClick", function(self) oq.sort_waitlist( "power" ) ; end ) ;
  f = oq.click_label( parent, x, y,  40, cy, OQ.HDR_MMR       ) ;  x = x +  40 ;
  f:SetScript("OnClick", function(self) oq.sort_waitlist( "mmr" ) ; end ) ;
  f = oq.click_label( parent, x+185, y,  40, cy, OQ.HDR_TIME ) ;  
  f:SetScript("OnClick", function(self) oq.sort_waitlist( "time" ) ; end ) ;

  -- add samples
  oq.tab7_waitlist = {} ;

  -- tag
  oq.tab7_tag = oq.place_tag( parent ) ;
  oq.waitlist_sort = "time" ;
  oq.waitlist_sort_ascending = true ;
  oq.reshuffle_waitlist() ;
end

function oq.create_tab_banlist()
  local x, y, cx, cy ;
  local parent = OQTabPage6 ;
  oq.tab6_scroller, oq.tab6_list = oq.create_scrolling_list( parent, "banlist" ) ;
  local f = oq.tab6_scroller ;
  oq.setpos( f, -40, 50, f:GetParent():GetWidth() - 2*30, f:GetParent():GetHeight() - (50+38) ) ;

  -- list header
  cy = 20 ;
  x  = 80 ;
  y  = 27 ;

  oq.label( parent, x, y, 125, cy, OQ.HDR_BTAG    ) ;  x = x + 125 ;  
  oq.label( parent, x, y, 450, cy, OQ.HDR_REASON  ) ;  

  x = parent:GetWidth() - 135 ;
  y = parent:GetHeight() - 30 ;
  oq.tab6_ban_but = oq.button2( parent, x, y-4, 90, 24, OQ.BUT_BAN_BTAG, 14,
                                     function(self) StaticPopup_Show("OQ_BanBTag") ; end 
                                    ) ;
  oq.tab6_ban_but.string:SetFont(OQ.FONT, 10, "") ;

  -- add samples
  oq.tab6_banlist = {} ;

  -- tag
  oq.tab6_tag = oq.place_tag( parent ) ;

  oq.populate_ban_list() ; 
end

function oq.create_begbox( parent ) 
  local pcx = parent:GetWidth() ;
  local pcy = parent:GetHeight() ;
  local cx = floor(pcx/2) ;
  local cy = floor(4*pcy/5) ;
  local f = oq.panel( parent, "BegBox", floor((pcx - cx)/2), floor((pcy - cy)/2), cx, cy) ;
  f:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                 edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                 tile=true, tileSize = 16, edgeSize = 16,
                 insets = { left = 1, right = 1, top = 1, bottom = 1 }
                 })
  f:SetBackdropColor( 0.2, 0.2, 0.2, 1.0 ) ;
  f:SetAlpha( 1.0 ) ;
  oq.closebox( f, function(self) self:GetParent():GetParent():Hide() ; end ) ;

  local x = 15 ;
  local y = 20 ;
  for i,v in pairs(OQ.CONTRIBUTION_DLG) do
    if (v ~= "beg.oq") and (v ~= "beg.vent") then
      local t = oq.label( f, x, y, cx-2*15, 20, v, "CENTER", "LEFT" ) ;
      t:SetFont(OQ.FONT, 16, "") ;
    elseif (v == "beg.oq") then
      f.beg_oq   = oq.editline( f, "oQueueBeg", x+10, y, cx-2*20, 24, 60 ) ;  
      f.beg_oq:SetText( "https://solidice.com/oqueue/contribute.html" ) ;
    elseif (v == "beg.vent") then
      f.beg_vent = oq.editline( f, "VentBeg", x+10, y, cx-2*20, 24, 60 ) ;  
      f.beg_vent:SetText( "http://contribute.publicvent.org/" ) ;
    end
    y = y + 24 ;
  end

  return f ;
end

function oq.onShadeHide(f)
  oq.tremove_value( getglobal("UISpecialFrames"), f:GetName() ) ;
  tinsert( getglobal("UISpecialFrames"), oq.ui:GetName() ) ;
end

function oq.onShadeShow(f)
  tinsert( getglobal("UISpecialFrames"), f:GetName() ) ;
  oq.tremove_value( getglobal("UISpecialFrames"), oq.ui:GetName() ) ;
end

function oq.create_ui_shade()
  if (oq.ui_shade ~= nil) then
    return oq.ui_shade ;
  end
  local parent = oq.ui ;
  local cx = floor(parent:GetWidth()) ;
  local cy = floor(parent:GetHeight()) + 30 + 10 ;
  local f = oq.panel( parent, "Shade", 0, -10, cx, cy ) ;
  f:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                 edgeFile=nil, 
                 tile=true, tileSize = 16, edgeSize = 16,
                 insets = { left = 1, right = 1, top = 1, bottom = 1 }
                 })
  f:SetBackdropColor( 0.2, 0.2, 0.2, 0.75 ) ;
  f:SetFrameLevel( 125 ) ;
  f:EnableMouse(true) ;
  f:SetScript( "OnShow", function(self) oq.onShadeShow(self) ; end ) ;
  f:SetScript( "OnHide", function(self) oq.onShadeHide(self) ; end ) ;
  oq.onShadeShow(f) ; -- first time
  oq.ui_shade = f ;

-- HELP PLATE?
-- http://wowprogramming.com/utils/xmlbrowser/live/AddOns/Blizzard_TalentUI/Blizzard_TalentUI.lua
-- HelpPlate_Show
-- HelpPlate_Hide

  -- place contribution dialog  
  oq.create_begbox( oq.ui_shade ) ;
  
  return oq.ui_shade ;
end

function oq.contribute_dialog()
  -- cover entire oq ui with alpha screen to darken
  -- display dialog with request for contributions for oqueue dev and public vent servers
  -- should have dialogs to copy/paste from
  -- will have links to contribution pages
  -- solidice:   https://solidice.com/oqueue/contribute.html
  -- public vent:  http://donate.publicvent.org/
  local f = oq.create_ui_shade() ;
  f:Show() ;
end

function oq.place_tag( parent )
  local txt = "|cFF000000".. OQ.CONTRIBUTE .. "|r" ;
  local tag = oq.click_label( parent, 20, parent:GetHeight() - 32, 75, 18, txt, "CENTER", "CENTER" ) ;
  local t = tag:CreateTexture(nil,"BACKGROUND") ;
  t:SetAllPoints(tag) ;
  t:SetDrawLayer("BACKGROUND") ;
  tag.texture = t ;
  tag.texture:SetTexture( "Interface\\Addons\\oqueue\\art\\but_gold_blank.tga" ) ;
  tag:SetScript("OnClick", function(self) oq.contribute_dialog() ; end ) ;
  tag.label:SetFont(OQ.FONT, 12, "") ;
  return tag ;
end

function oq.create_score_tab_label( x, y, cx, cy, txt )
  local f = {} ;
  local parent = OQTabPage4 ;
  f.label = oq.label( parent, x, y, cx, cy, txt ) ;
  f.label:SetJustifyH("left") ;
  f.score = oq.label( parent, x + cx + 5, y, 25, cy, "50" ) ;
  f.score:SetJustifyH("left") ;
  
  f.bar = oq.texture( parent, x + cx, y, 170, cy, "Interface\\WorldStateFrame\\WorldState-CaptureBar" ) ;
  f.bar.texture:SetTexCoord( 0, 0.67578125, 0, 0.40625 ) ;
  f.bar.texture:SetDrawLayer( "BORDER" ) ;

  cy = 9 ;
  y  = y + 7 ;
  
  -- alliance blue
  f.bar_left = oq.texture( parent, x + cx+24, y, (170*0.20), cy, "Interface\\WorldStateFrame\\WorldState-CaptureBar" ) ;
  f.bar_left.texture:SetTexCoord( 0.8203125, 1.0, 0, 0.140625 ) ;

  -- horde red
  f.bar_right = oq.texture( parent, x + cx+170-52, y, (170*0.10), cy, "Interface\\WorldStateFrame\\WorldState-CaptureBar" ) ;
  f.bar_right.texture:SetTexCoord( 0.8203125, 1.0, 0.171875, 0.3125 ) ;
  
  -- indicator for middle
  f.indicator = oq.texture( parent, x + cx+(170/2)-5, y-1, 6, cy+8, "Interface\\WorldStateFrame\\WorldState-CaptureBar" ) ;
  f.indicator.texture:SetTexCoord( 0.77734375, 0.796875, 0, 0.28125 ) ;
  f.indicator.texture:SetDrawLayer( "ARTWORK" ) ;
  
  f.min_x = x + cx + 24 ;
  f.max_x = x + cx + 170 - 24 ;
  f.bar_y = y ;
  f.bar_cy = cy ;

  return f ;
end

function oq.set_bg_percent( f, v ) 
  local width = (f.max_x - f.min_x) ;
  cx = width / 2 ;
  oq.setpos( f.bar_left , f.min_x, f.bar_y, cx, f.bar_cy ) ;
  oq.setpos( f.bar_right, f.max_x-cx, f.bar_y, cx, f.bar_cy ) ;
  
  cx = width * ((100-v) / 100) ;
  oq.moveto( f.indicator, f.min_x+cx, f.bar_y-2 ) ;
end

function oq.get_gametime()
  local t = oq.scores.timeleft or 0 ;
  if (t < 0) then
    t = 0 ;
  elseif (t ~= 0) then
    t = oq.scores.end_round_tm - utc_time() + oq.scores.time_lag ;
    if (t < 0) then
      t = 0 ;
    end
  end
  
  local hrs = floor( t / (60*60)) ;
  local min = floor( t / 60 ) % 60 ;
  local sec = t % 60 ;
  local tm_str = string.format( "%d:%02d:%02d", hrs, min, sec ) ;
  if (hrs == 0) then
    tm_str = string.format( "%02d:%02d", min, sec ) ;
  end
  return tm_str ;
end

function oq.update_gametime()
  local tm_str = oq.get_gametime() ;
  if (oq.tab4_timeleft:IsVisible()) then
    oq.tab4_timeleft:SetText( tm_str ) ;
  end
end

function oq.update_marquee_gametime()
  local tm_str = oq.get_gametime() ;
  if (oq.marquee.timeleft:IsVisible()) then
    oq.marquee.timeleft:SetText( tm_str ) ;
  end
end

function oq.create_tab_score() 
  local x, y, cx, cy, spacer ;
  local parent = OQTabPage4 ;
  
  parent:SetScript( "OnShow", function() oq.update_gametime() ; oq.timer( "scoreboard_ticker", 0.5, oq.update_gametime, true ) ; end ) ;
  parent:SetScript( "OnHide", function() oq.timer( "scoreboard_ticker", 0.5, nil ) ; end ) ;
  
  x = 390 ;
  y = 75 ;
  oq.tab4_horde_emblem    = oq.texture( parent, x,  y+10, 80, 80, "Interface\\FriendsFrame\\PlusManz-Horde" ) ;

  x = x + 100 ;
  oq.tab4_horde_label     = oq.label( parent, x, y, 100, 100, "Horde" ) ;
  oq.tab4_horde_label:SetFont(OQ.FONT, 22, "") ;
  oq.tab4_horde_label:SetJustifyH("left") ;
  oq.tab4_horde_label:SetJustifyV("center") ;
  
  x = x + 100 ;
  oq.tab4_horde_score     = oq.label( parent, x, y, 100, 100, "99,999" ) ;
  oq.tab4_horde_score:SetFont(OQ.FONT, 22, "") ;
  oq.tab4_horde_score:SetJustifyH("right") ;
  oq.tab4_horde_score:SetJustifyV("center") ;

  x = 390 ;
  y = y + 105 ;
  oq.tab4_alliance_emblem = oq.texture( parent, x, y+10, 80, 80, "Interface\\FriendsFrame\\PlusManz-Alliance" ) ;
  
  x = x + 100 ;
  oq.tab4_alliance_label  = oq.label( parent, x, y, 100, 100, "Alliance" ) ;
  oq.tab4_alliance_label:SetFont(OQ.FONT, 22, "") ;
  oq.tab4_alliance_label:SetJustifyH("left") ;
  oq.tab4_alliance_label:SetJustifyV("center") ;
  
  x = x + 100 ;
  oq.tab4_alliance_score     = oq.label( parent, x, y, 100, 100, "0" ) ;
  oq.tab4_alliance_score:SetFont(OQ.FONT, 22, "") ;
  oq.tab4_alliance_score:SetJustifyH("right") ;
  oq.tab4_alliance_score:SetJustifyV("center") ;

  x = 390 + 100 ;
  y = y + 50 ;
  oq.tab4_timeleft_label  = oq.label( parent, x, y, 100, 100, "Time left:" ) ;
  oq.tab4_timeleft_label:SetFont(OQ.FONT, 14, "") ;
  oq.tab4_timeleft_label:SetJustifyH("left") ;
  oq.tab4_timeleft_label:SetJustifyV("center") ;
  oq.tab4_timeleft_label:SetTextColor( 0.8, 0.8, 0.8, 1 ) ;


  x = x + 100 ;  
  oq.tab4_timeleft  = oq.label( parent, x, y, 100, 100, "168:17" ) ;
  oq.tab4_timeleft:SetFont(OQ.FONT, 14, "") ;
  oq.tab4_timeleft:SetJustifyH("right") ;
  oq.tab4_timeleft:SetJustifyV("center") ;
  
  x = 40 ;
  y = 60 ;
  cx = 155 ;
  cy = 24 ;
  spacer = 4 ;
  oq.tab4_bg = {} ;
  oq.tab4_bg[ "AB"   ] = oq.create_score_tab_label( x, y, cx, cy, oq.bg_name( OQ.AB   ) ) ;
  y = y + cy + spacer ;
  oq.tab4_bg[ "AV"   ] = oq.create_score_tab_label( x, y, cx, cy, oq.bg_name( OQ.AV   ) ) ;
  y = y + cy + spacer ;
  oq.tab4_bg[ "BFG"  ] = oq.create_score_tab_label( x, y, cx, cy, oq.bg_name( OQ.BFG  ) ) ;
  y = y + cy + spacer ;
  oq.tab4_bg[ "EotS" ] = oq.create_score_tab_label( x, y, cx, cy, oq.bg_name( OQ.EOTS ) ) ;
  y = y + cy + spacer ;
  oq.tab4_bg[ "IoC"  ] = oq.create_score_tab_label( x, y, cx, cy, oq.bg_name( OQ.IOC  ) ) ;
  y = y + cy + spacer ;
  oq.tab4_bg[ "SotA" ] = oq.create_score_tab_label( x, y, cx, cy, oq.bg_name( OQ.SOTA ) ) ;
  y = y + cy + spacer ;
  oq.tab4_bg[ "TP"   ] = oq.create_score_tab_label( x, y, cx, cy, oq.bg_name( OQ.TP   ) ) ;
  y = y + cy + spacer ;
  oq.tab4_bg[ "WSG"  ] = oq.create_score_tab_label( x, y, cx, cy, oq.bg_name( OQ.WSG  ) ) ;
  y = y + cy + spacer ;
  oq.tab4_bg[ "SSM"  ] = oq.create_score_tab_label( x, y, cx, cy, oq.bg_name( OQ.SSM  ) ) ;
  y = y + cy + spacer ;
  oq.tab4_bg[ "ToK"  ] = oq.create_score_tab_label( x, y, cx, cy, oq.bg_name( OQ.TOK  ) ) ;
  
  oq.tab4_tag = oq.place_tag( parent ) ;
end

--
-- https://sea.battle.net/support/en/article/color-blind-mode-improvements-in-patch-4-3
--
function oq.make_colorblind_dropdown()
  local types = { { text = OQ.COLORBLINDSHADER[0], arg1 = 0 },
                  { text = OQ.COLORBLINDSHADER[1], arg1 = 1 },
                  { text = OQ.COLORBLINDSHADER[2], arg1 = 2 },
                  { text = OQ.COLORBLINDSHADER[3], arg1 = 3 },
                  { text = OQ.COLORBLINDSHADER[4], arg1 = 4 },
                  { text = OQ.COLORBLINDSHADER[5], arg1 = 5 },
                  { text = OQ.COLORBLINDSHADER[6], arg1 = 6 },
                  { text = OQ.COLORBLINDSHADER[7], arg1 = 7 },
                  { text = OQ.COLORBLINDSHADER[8], arg1 = 8 },
                } ;
  for i=1,9 do
    local d = UIDropDownMenu_CreateInfo() ;
    d.text  = types[i].text ;
    d.value = types[i].arg1 ;
    d.arg1  = types[i].arg1 ;
    d.arg2  = types[i].text ;
    d.cb    = self ;
    d.func = function(self,arg1,arg2) 
               if (OQColorBlindShader:IsVisible()) then
                 if (oq.color_blind_mode( arg1 )) then
                   UIDropDownMenu_SetSelectedValue( oq.tab5_colorblindshader, arg1 ) ;
                 end
               end
               return true ; 
             end ;
    UIDropDownMenu_AddButton(d) ;
  end
end

function oq.create_tab_setup() 
  local x, y, cx, cy ;
  local parent = OQTabPage5 ;
  
  parent:SetScript( "OnShow", function() oq.populate_tab_setup() ; end ) ;
  parent:SetScript( "OnHide", function() oq.onhide_tab_setup() ; end ) ;
  x  = 20 ;
  y  = 30 ;
  cy = 25 ;
  local t = oq.label( parent, x, y, 400, 30, OQ.SETUP_HEADING ) ;
  t:SetFont(OQ.FONT, 14, "") ;

  y = 65 ;
  x = 40 ;
  oq.label( parent, x, y, 200, cy, OQ.REALID_MOP ) ;  
  y = y + cy + 6 ;

  t:SetTextColor( 0.75, 0.75, 0.75, 1 ) ;

  oq.label( parent, x, y, 200, cy, OQ.SETUP_GODARK_LBL ) ; 
  y = y + cy ;
  oq.label( parent, x, y, 200, cy, OQ.SETUP_REMOQADDED ) ; 
  y = y + cy ;
  oq.label( parent, x, y, 200, cy, OQ.SETUP_REMOVEBTAG ) ; 
  y = y + cy ;
  oq.label( parent, x, y, 200, cy, OQ.SETUP_COLORBLIND ) ;

  x  = parent:GetWidth() - 225 ;
  y  = 30 ;  
  oq.tab5_ar = oq.checkbox( parent, x, y,  23, cy, 200, OQ.SETUP_AUTOROLE, (OQ_toon.auto_role == 1), 
               function(self) oq.toggle_auto_role( self ) ; end ) ;
  y = y + cy ;
  oq.tab5_cp = oq.checkbox( parent, x, y,  23, cy, 200, OQ.SETUP_CLASSPORTRAIT, (OQ_toon.class_portrait == 1), 
               function(self) oq.toggle_class_portraits( self ) ; end ) ;
  y = y + cy ;
  oq.tab5_gc = oq.checkbox( parent, x, y,  23, cy, 200, OQ.SETUP_GARBAGE, (OQ_toon.ok2gc == 1), 
               function(self) oq.toggle_gc( self ) ; end ) ;
  y = y + cy ;
  oq.tab5_ss = oq.checkbox( parent, x, y,  23, cy, 200, OQ.SETUP_SAYSAPPED, (OQ_toon.say_sapped == 1), 
               function(self) oq.toggle_say_sapped( self ) ; end ) ;
  y = y + cy ;
  oq.tab5_wp = oq.checkbox( parent, x, y,  23, cy, 200, OQ.SETUP_WHOPOPPED, (OQ_toon.who_popped_lust == 1), 
               function(self) oq.toggle_who_popped_lust( self ) end ) ;
  y  = y + cy ;
  oq.tab5_shoutkbs = oq.checkbox( parent, x, y,  23, cy, 200, OQ.SETUP_SHOUTKBS, (OQ_toon.shout_kbs == 1), 
               function(self) oq.toggle_shout_kbs( self ) ; end ) ;
  y  = y + cy ;
  oq.tab5_shoutcaps = oq.checkbox( parent, x, y,  23, cy, 200, OQ.SETUP_SHOUTCAPS, (OQ_toon.shout_caps == 1), 
               function(self) oq.toggle_shout_caps( self ) ; end ) ;
  y  = y + cy ;
  oq.tab5_shoutads = oq.checkbox( parent, x, y,  23, cy, 200, OQ.SETUP_SHOUTADS, (OQ_data.show_premade_ads == 1), 
               function(self) oq.toggle_premade_ads( self ) ; end ) ;
  y  = y + cy ;
  oq.tab5_ok2submit_btag = oq.checkbox( parent, x, y,  23, cy, 200, OQ.SETUP_OK2SUBMIT_BTAG, (OQ_data.ok2submit_tag == 1), 
               function(self) oq.toggle_btag_submit( self ) ; end ) ;
  y  = y + cy ;
  oq.tab5_autoaccept_mesh_request = oq.checkbox( parent, x, y,  23, cy, 200, OQ.SETUP_AUTOACCEPT_MESH_REQ, (OQ_data.autoaccept_mesh_request == 1), 
               function(self) oq.toggle_autoaccept_mesh_request( self ) ; end ) ;
  y  = y + cy ;
  oq.tab5_ragequits = oq.checkbox( parent, x, y,  23, cy, 200, OQ.SETUP_ANNOUNCE_RAGEQUIT, (OQ_toon.shout_ragequits == 1), 
               function(self) oq.toggle_ragequits( self ) ; end ) ;
 
  x = 40 ;
  y  = parent:GetHeight() - 185 ;
  cx = 200 ;
  cy = 25 ;
  oq.label( parent, x, y, 225, cy*2, OQ.SETUP_ALTLIST ) ; 

  x  = 250 ;

  local f = oq.CreateFrame( "Frame", "OQTabPage5List", parent ) ;
  f:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                 edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                 tile=true, tileSize = 16, edgeSize = 16,
                 insets = { left = 1, right = 1, top = 1, bottom = 1 }
                 })
  f:SetBackdropColor(0.0,0.0,0.0,1.0);
  oq.setpos( f, 0, 0, 175, 150 ) ;
  oq.tab5_list = f ;

  f = oq.CreateFrame( "ScrollFrame", "OQTabPage5ListScrollBar", OQTabPage5, "FauxScrollFrameTemplate" ) ;
  f:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, 16, OQ_ModScrollBar_Update); end ) ;
  f:SetScript("OnShow", function(self) OQ_ModScrollBar_Update(self) ; end ) ;
  f:SetScrollChild( oq.tab5_list ) ;
  f:Show() ;
  oq.setpos( f, x, y, 175, f:GetParent():GetHeight() - (y+30) ) ;
  oq.tab5_scroller = f ;
  
  oq.tab5_add_alt = oq.button( parent, x+200, y, 75, cy, OQ.SETUP_ADD, function() StaticPopup_Show("OQ_AddToonName") ; end ) ;
  y = y + cy + 2 ;
  oq.tab5_add_mycrew = oq.button( parent, x+200, y, 75, cy, OQ.SETUP_MYCREW, function() oq.mycrew() ; end ) ;
  y = y + cy + 2 ;
  oq.tab5_clear = oq.button( parent, x+200, y, 75, cy, OQ.SETUP_CLEAR, function() oq.mycrew("clear") ; end ) ;
  if (oq.tab5_alts == nil) then
    oq.tab5_alts = {} ;
  end

  --
  -- edits and buttons
  --
  y  = 65 ; -- skip comment
  x  = 250 ;
  cy = 25 ;
  cx = 125 ;
  oq.tab5_bnet        = oq.editline( parent, "BnetAddress", x, y,   cx,   cy,  60 ) ; 
  y = y + cy + 6 ;
  oq.tab5_go_dark     = oq.button( parent, x-5, y, 145, cy, OQ.SETUP_GODARK, 
                                     function() oq.godark() ; end )
  y = y + cy ;
  oq.tab5_prune_bnet  = oq.button( parent, x-5, y, 145, cy, OQ.SETUP_REMOVENOW, 
                                     function() oq.remove_OQadded_bn_friends() ; end )
  oq.tab5_bnet:Disable() ;
  y = y + cy ;
  oq.tab5_pullbtag_but = oq.button2( parent, x-5, y, 145, cy, OQ.BUT_PULL_BTAG, 14,
                                   function(self) oq.pull_btag() ; end ) ;
  oq.tab5_pullbtag_but.string:SetFont(OQ.FONT, 10, "") ;

  y = y + cy ;
  oq.tab5_colorblindshader = CreateFrame("Frame", "OQColorBlindShader", parent, "UIDropDownMenuTemplate") ;
  oq.setpos( oq.tab5_colorblindshader, x-22, y, 127, cy ) ;
  UIDropDownMenu_Initialize( oq.tab5_colorblindshader, oq.make_colorblind_dropdown ) ;
  UIDropDownMenu_SetSelectedID( oq.tab5_colorblindshader, ((OQ_data.colorblindshader or 0) + 1) ) ;
  UIDropDownMenu_JustifyText( oq.tab5_colorblindshader, "LEFT" ) ;
  UIDropDownMenu_SetWidth( oq.tab5_colorblindshader, 127, 0 ) ;

  oq.button( parent, x+140, y+1, 22, cy, "+", function() oq.color_blind_mode( "next" ) ; end )
  
  --
  --  geek corner
  --
  x  = parent:GetWidth() - 200 ;
  x2 = parent:GetWidth() -  90 ;
  y  = parent:GetHeight() - 42 ;
  cy = 22 ;
  oq.label( parent, x, y, 150, cy, OQ.PPS_SENT ) ;
  oq.tab5_oq_pktsent = oq.label( parent, x2, y, 60, cy, "0", "CENTER", "RIGHT" ) ; 
  y = y - cy ; -- moving up
 
  oq.label( parent, x, y, 150, cy, OQ.PPS_PROCESSED ) ;
  oq.tab5_oq_pktprocessed = oq.label( parent, x2, y, 60, cy, "0", "CENTER", "RIGHT" ) ; 
  y = y - cy ; -- moving up
  
  oq.label( parent, x, y, 150, cy, OQ.PPS_RECVD ) ;
  oq.tab5_oq_pktrecv = oq.label( parent, x2, y, 60, cy, "0", "CENTER", "RIGHT" ) ; 
  y = y - cy ; -- moving up
  
  oq.tab5_oq_sk_dtime_err = oq.label( parent, x-26, y+4, 24, cy, OQ_REDX_ICON, "CENTER", "RIGHT" ) ; 
  oq.label( parent, x, y, 150, cy, OQ.OQSK_DTIME ) ;
  oq.tab5_oq_sk_dtime = oq.label( parent, x2-40, y, 100, cy, "0", "CENTER", "RIGHT" ) ; 
  y = y - cy ; -- moving up
  
  -- tag
  oq.tab5_tag = oq.place_tag( parent ) ;
  
  -- populate alt list
  oq.populate_alt_list() ; 
end

function oq.update_alltab_text() 
  OQMainFrameTab1:SetText( OQ.TAB_PREMADE       ) ; 
  OQMainFrameTab2:SetText( OQ.TAB_FINDPREMADE   ) ; 
  OQMainFrameTab3:SetText( OQ.TAB_CREATEPREMADE ) ; 
  OQMainFrameTab4:SetText( OQ.TAB_THESCORE      ) ; 
  OQMainFrameTab5:SetText( OQ.TAB_SETUP         ) ; 
  OQMainFrameTab6:SetText( OQ.TAB_BANLIST       ) ; 

  local nWaiting = oq.n_waiting() ;
  if (nWaiting > 0) then
    OQMainFrameTab7:SetText( string.format( OQ.TAB_WAITLISTN, nWaiting ) ) ;
  else
    OQMainFrameTab7:SetText( OQ.TAB_WAITLIST ) ;
  end
end

function oq.attach_pvp_queue()
  --
  -- hook pvp frame join-as-group button
  -- note: the bg-index and bg-type are now irrelevant since selection must be manual by the leaders
  --
  if (PVPUIFrame == nil) then
    return ;
  end
  local but = PVPFrameLeftButton or HonorFrameSoloQueueButton ; -- 5.2 update
  but:SetScript("PostClick", function(self) 
                               if (oq.iam_raid_leader()) then 
                                 oq.raid_join( 1, OQ.AB ) ; 
                               end 
                               oq.reset_button( self ) ;
                               self:Show() ;
                             end ) ;  
  but = PVPFrameRightButton or HonorFrameGroupQueueButton ; -- 5.2 update
  but:SetScript("PostClick", function(self) 
                               if (oq.iam_raid_leader()) then 
                                 oq.raid_join( 1, OQ.AB ) ; 
                               end 
                               oq.reset_button( self ) ;
                               self:Show() ;
                             end ) ;  
  return 1 ; -- done
end

function oq.create_main_ui() 
  ------------------------------------------------------------------------
  --  tab 1: current premade
  ------------------------------------------------------------------------
  oq.create_tab1() ;
  
  ------------------------------------------------------------------------
  --  tab 2: find premade
  ------------------------------------------------------------------------
  oq.create_tab2() ;
  
  ------------------------------------------------------------------------
  --  tab 3: create premade
  ------------------------------------------------------------------------
  oq.create_tab3() ;
    
  ------------------------------------------------------------------------
  --  tab 4: scores
  ------------------------------------------------------------------------
  oq.create_tab_score() ;
  
  ------------------------------------------------------------------------
  --  tab 5: setup
  ------------------------------------------------------------------------
  oq.create_tab_setup() ;
  
  ------------------------------------------------------------------------
  --  tab 6: ban list
  ------------------------------------------------------------------------
  oq.create_tab_banlist() ;
  
  ------------------------------------------------------------------------
  --  tab 7: waiting list
  ------------------------------------------------------------------------
  oq.create_tab_waitlist() ;
  
  oq.update_alltab_text() ;
  
  oq.timer( "attach_pvpui", 2, oq.attach_pvp_queue, true ) ;
    
  --
  -- leave queue macro button
  --
  oq.leaveQ = oq.CreateFrame("Button","OQLeaveQBut",UIParent,"SecureActionButtonTemplate UIPanelButtonTemplate") 
  oq.leaveQ:SetAttribute("type","macro") 

  oq.leaveQ:SetAttribute("macrotext", "/click QueueStatusMinimapButton \n/click DropDownList1Button3\n/click DropDownList1Button2");
  
  local t = oq.leaveQ:CreateTexture()
  t:SetParent(oq.leaveQ)
  t:SetTexture("Interface\\Addons\\Buttons\\UI-Panel-Button-Up.blp") ;
  oq.leaveQ:SetText( OQ.DLG_LEAVE ) ;
  oq.setpos( oq.leaveQ, 5,  65, 75, 25 ) ;
  oq.leaveQ:Hide() ;
  SecureHandlerWrapScript(oq.leaveQ,"OnClick",oq.leaveQ,[[ self:Hide() ; return nil,"done"]], [[ ]]) ;
  oq.leaveQ:SetScript( "OnHide", function(self) oq.angry_lil_button_done( self ) ; end ) ;
end

function oq.get_battle_tag()
  player_realid = select( 2, BNGetInfo() ) ;
  if (player_realid == nil) then
    print( OQ_REDX_ICON .." Please set your battle-tag before using oQueue." ) ;
    print( OQ_REDX_ICON .." Your battle-tag can only be set via your WoW account page." ) ;
    return nil ;
  end
  return true ;
end

function oq.populate_tab2() 
  oq.get_battle_tag() ;
  oq.n_connections() ;
  oq.update_premade_count() ;
end

function oq.create_tab3_notice( parent )
  local pcx = parent:GetWidth() ;
  local pcy = parent:GetHeight() ;
  local cx = floor(pcx/2) ;
  local cy = floor(4*pcy/5) ;
  local f = oq.panel( parent, "Notice", floor((pcx - cx)/2), floor((pcy - cy)/2), cx, cy) ;
  f:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                 edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                 tile=true, tileSize = 16, edgeSize = 16,
                 insets = { left = 1, right = 1, top = 1, bottom = 1 }
                 })
  f:SetBackdropColor( 0.2, 0.2, 0.2, 1.0 ) ;
  f:SetAlpha( 1.0 ) ;
  oq.closebox( f, function(self) self:GetParent():GetParent():Hide() ; end ) ;

  local x = 15 ;
  local y = 20 ;
  for i,v in pairs(OQ.LFGNOTICE_DLG) do
    local s = v ;
    if (i ~= 2) then
      s = "|cFFE0E0E0".. v .."|r" ;
    end    
    local t = oq.label( f, x, y, cx-2*15, 20, string.format( s, dtstr ), "CENTER", "LEFT" ) ;
    t:SetFont(OQ.FONT, 16, "") ;
    y = y + 24 ;
  end
  
  f.ok_but = oq.button( f, floor((cx - 80)/2), cy - 50,  80, 32, "Okay", 
                        function(self) 
                          self:GetParent():GetParent():Hide() ; 
                        end ) ;
  return f ;
end

function oq.create_tab3_warning( parent )
  local pcx = parent:GetWidth() ;
  local pcy = parent:GetHeight() ;
  local cx = floor(pcx/2) ;
  local cy = floor(4*pcy/5) ;
  local f = oq.panel( parent, "TimeVariance", floor((pcx - cx)/2), floor((pcy - cy)/2), cx, cy) ;
  f:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                 edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                 tile=true, tileSize = 16, edgeSize = 16,
                 insets = { left = 1, right = 1, top = 1, bottom = 1 }
                 })
  f:SetBackdropColor( 0.2, 0.2, 0.2, 1.0 ) ;
  f:SetAlpha( 1.0 ) ;
  oq.closebox( f, function(self) self:GetParent():GetParent():Hide() ; end ) ;

  local x = 15 ;
  local y = 20 ;
  local dtstr = oq.render_tm( oq._sktime_last_dt ) ;
  for i,v in pairs(OQ.TIMEVARIANCE_DLG) do
    local s = v ;
    if (i ~= 2) then
      s = "|cFFE0E0E0".. v .."|r" ;
    end    
    local t = oq.label( f, x, y, cx-2*15, 20, string.format( s, dtstr ), "CENTER", "LEFT" ) ;
    t:SetFont(OQ.FONT, 16, "") ;
    if (v:find("%%s") ~= nil) then
      f.variance = t ;
      f.variance_str = s ;
    end
    y = y + 24 ;
  end

  return f ;
end

function oq.create_tab3_shade( parent )
  local cx = floor(parent:GetWidth()) ;
  local cy = floor(parent:GetHeight()) ;
  local f = oq.panel( parent, "Shade", 0, 0, cx, cy ) ;
  f:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                 edgeFile=nil, 
                 tile=true, tileSize = 16, edgeSize = 16,
                 insets = { left = 1, right = 1, top = 1, bottom = 1 }
               })
  f:SetBackdropColor( 0.2, 0.2, 0.2, 0.75 ) ;
  f:SetFrameLevel( 125 ) ;
  f:EnableMouse(true) ;
  return f ;
end

function oq.populate_tab3() 
  oq.get_battle_tag() ;
  
  oq.tab3_lead_name:SetText( player_name or "" ) ;
  oq.tab3_rid      :SetText( player_realid or "" ) ;
  
  local now = utc_time() ;
  local dt = oq._sktime_last_dt ;
  if (dt > 5*60) and (oq._sktime_last_tm > 0) then
    -- warning
    if (oq.ui_tab3_shade == nil) then
      oq.ui_tab3_shade = oq.create_tab3_shade( OQTabPage3 ) ;
    end
    if (oq.ui_tab3_warning == nil) then
      oq.ui_tab3_warning = oq.create_tab3_warning( oq.ui_tab3_shade ) ;
    end
    oq.ui_tab3_shade:Show() ;
    oq.ui_tab3_warning:Show() ;
    if (oq.ui_tab3_notice) then oq.ui_tab3_notice:Hide() ; end 
    
    local dtstr = oq.render_tm( oq._sktime_last_dt ) ;
    oq.ui_tab3_warning.variance:SetText( string.format( oq.ui_tab3_warning.variance_str, dtstr )) ;
  elseif (OQ_toon.tab3_notice == nil) or (OQ_toon.tab3_notice < now) then
    -- notice
    OQ_toon.tab3_notice = now + 7*24*60*60 ; -- once per week
    if (oq.ui_tab3_shade == nil) then
      oq.ui_tab3_shade = oq.create_tab3_shade( OQTabPage3 ) ;
    end
    if (oq.ui_tab3_notice == nil) then
      oq.ui_tab3_notice = oq.create_tab3_notice( oq.ui_tab3_shade ) ;
      oq.ui_tab3_shade:SetScript( "OnShow", function(self) oq.onShadeShow(self) ; end ) ;
      oq.ui_tab3_shade:SetScript( "OnHide", function(self) oq.onShadeHide(self) ; end ) ;
      oq.onShadeShow(oq.ui_tab3_shade) ; -- first time
    end
    oq.ui_tab3_shade:Show() ;
    if (oq.ui_tab3_warning) then oq.ui_tab3_warning:Hide() ; end
    oq.ui_tab3_notice:Show() ;    
  elseif (oq.ui_tab3_shade ~= nil) and (oq.ui_tab3_shade:IsVisible()) then
    oq.ui_tab3_shade:Hide() ;
    if (oq.ui_tab3_notice) then oq.ui_tab3_notice:Hide() ; end
    if (oq.ui_tab3_warning) then oq.ui_tab3_warning:Hide() ; end
  end
end

function oq.populate_dtime()
  if (not oq.tab5_oq_sk_dtime:IsVisible()) then
    return ;
  end
  local dtime_str = "--:--" ;
  if (oq._sktime_last_dt ~= nil) then
    dtime_str = oq.render_tm( oq._sktime_last_dt ) ;
    if (oq._sktime_last_dt > (15*60)) then
      oq.tab5_oq_sk_dtime_err:Show() ;
    else
      oq.tab5_oq_sk_dtime_err:Hide() ;
    end
  end
  oq.tab5_oq_sk_dtime:SetText( dtime_str ) ;
end

function oq.populate_tab_setup() 
  oq.get_battle_tag() ;

  oq.tab5_bnet:SetText( player_realid or "" ) ;
  if (_oqgeneral_id) then
    SetSelectedDisplayChannel( _oqgeneral_id ) ;
  end
  
  oq.populate_dtime() ;
end

function oq.onhide_tab_setup()
  OQ_data.realid = player_realid ;
end

--------------------------------------------------------------------------
--  event handlers
--------------------------------------------------------------------------
function oq.on_addon_event( prefix, msg, channel, sender )
  if ((prefix ~= "OQ") or (sender == player_name)) or ((msg == nil) or (msg == "")) then
    return ;
  end
  if ((channel == "WHISPER") and oq.iam_party_leader() and (sender == oq.raid.leader) and (not OQ_toon.disabled)) then
    -- from the leader and i'm party leader, send only to my party
    oq.SendAddonMessage( "OQ", msg, "PARTY" ) ;
  end

  -- just process, do not send it on
  _local_msg = true ;
  _source    = "addon" ;
  if (channel == "PARTY") then
    _source = "party" ;
  end
  _ok2relay  = nil ;
  _sender    = sender ;
  
  oq.process_msg( sender, msg ) ;  
  oq.post_process() ;
end

function oq.on_party_event( msg, sender, lang, line_id )
  oq.echo_party_msg( sender, msg ) ;
end

function oq.is_my_req_token( req_tok )
  return oq.token_was_seen( req_tok ) ;
end

function oq.bnfriend_note( presenceId )
  if (presenceId == nil) or (presenceId == 0) then
    return nil ;
  end
  local noteText = select( 12, BNGetFriendInfoByID(presenceId)) ;
--  pid, givenName, surname, toonName, toonID, client, isOnline, lastOnline, 
--  isAFK, isDND, messageText, noteText, isFriend, unknown = BNGetFriendInfoByID(presenceID) ;
  return noteText ;
end

function oq.on_bnet_friend_invite() 
  local nInvites = BNGetNumFriendInvites() ; 
  if (nInvites == 0) then 
    return ;
  end
  -- 
  -- do the list backwards incase there are multiple
  --
  local valid_req = nil ;
  local is_lead = nil ;
  for i=nInvites,1,-1 do
    local presenceId, name, surname, message, timeSent, days = BNGetFriendInviteInfo( i ) ; 
    if ((message ~= nil) and (message ~= "")) then
      local msg_type = message:sub(1,#OQ_MSGHEADER) ;
      if (msg_type == OQ_MSGHEADER) then
        -- OQ message.  check note to see if i initiated it
        local msg = message:sub( message:find(OQ_MSGHEADER)+1, -1 ) ;
        local req_tok = nil ;
        local p = msg:find("#tok:") ;
        if (p) then
          req_tok = msg:sub( p+5, msg:find(",", p+5 )-1 ) ;
        end
        if (req_tok ~= nil) and (oq.is_my_req_token( req_tok )) then
          -- bn_realfriend_invite( r.realid, "#tok:".. req_token ..",#lead" ) ;
          if (msg:find("#lead")) then
            -- inviting to be group lead, bnfriend must stay
            BNAcceptFriendInvite(presenceId) ;
            oq.set_bn_enabled( presenceId ) ;
            oq.timer_oneshot( 1.5, oq.bn_check_online ) ;
            if (oq.bnfriend_note( presenceId ) == nil) then
              oq.timer_oneshot( 2, BNSetFriendNote, presenceId, "OQ,leader" ) ;    
            end                  
          elseif (msg:find("#grp:")) then
            -- inviting to be group member, bnfriend is temporary until grouped
            -- "#tok:".. req_token_ ..",#grp:".. my_group ..",#nam:".. player_name .."-".. player_realm 
            p = msg:find("#grp:") ;
            local group_id = msg:sub( p+5, p+5 ) ;
            if (group_id ~= nil) then
              my_group = tonumber(group_id) ;
              oq.ui_player() ;
              oq.update_my_premade_line() ;
              local lead = oq.raid.group[ my_group ].member[1] ;
              p = msg:find("#nam:") ;
              local n = msg:sub( p+5, -1 ) ;
              lead.name  = n:sub( 1, n:find("-")-1 ) ;
              lead.realm = n:sub( n:find("-")+1, -1 ) ;
              lead.realm = oq.realm_uncooked(lead.realm) ;
              BNAcceptFriendInvite(presenceId) ;
              oq.set_bn_enabled( presenceId ) ;
              oq.timer_oneshot( 1.5, oq.bn_check_online ) ;
              -- giving it some time to set the removal note
              local note = oq.bnfriend_note( presenceId ) ;
              if (note == nil) or (note:sub(1,7) == "REMOVE ") then
                oq.timer_oneshot( 1, BNSetFriendNote, presenceId, "" ) ; -- clear any previous note
                oq.timer_oneshot(15, BNSetFriendNote, presenceId, "REMOVE OQ" ) ;
              end
            end
          end
        else  -- not my token, inc OQ msg
          -- msg thru invite note, decline invite and process msg
           -- now process
           
           -- the b-tag is not sent along with the invite request (lame)
--          if (oq.is_banned( rid_ )) then
--            return ;
--          end
          _sender     = name .." ".. tostring(surname) ;
          _source     = "bnfinvite" ;
          _oq_note    = "OQ,leader" ;
          _oq_msg     = nil ;
          _ok2relay   = nil ; 
          _ok2decline = true ;
          oq.process_msg( _sender, message ) ;
          oq.post_process() ;

          -- valid OQ msg, remove from friend-req-list 
          if (_ok2decline) then
            oq.timer_oneshot( 1, BNDeclineFriendInvite, presenceId ) ; -- allow other accts to process the message before removing
          else
            BNAcceptFriendInvite(presenceId) ;
            oq.set_bn_enabled( presenceId ) ;
            oq.timer_oneshot( 1.5, oq.bn_check_online ) ;
            oq.timer_oneshot( 2, BNSetFriendNote, presenceId, _oq_note ) ;
          end
        end
      end
    end
  end
end

function oq.on_disband( raid_tok, token, local_override )
  _error_ignore_tm  = GetTime() + 5 ;
  if (oq.token_was_seen( token ) and (local_override == nil)) then
    _ok2relay = nil ; 
    return ;
  end
  oq.token_push( token ) ;
  oq.remove_premade( raid_tok ) ;
  if (oq.raid.raid_token ~= raid_tok) then
    -- not my raid
    return ;
  end
  oq.raid_cleanup() ;
end

local oq_find_request = {} ;
--
-- this is called in response to a "find" message
--
function oq.queue_find_request( reply_token_, faction_, level_range_, realm_ )
  if (oq.token_was_seen( reply_token_ )) then
    _ok2relay = nil ;
    return ;
  end
  oq.token_push( reply_token_ ) ;
  realm_ = oq.realm_uncooked(realm_) ;

  -- to be processed within the next 10 seconds
  local now  = utc_time() ;
  local when = now + random( 3, 10 ) ;
  local tok  = reply_token_ ..".".. (utc_time() % 1000) ;
  oq_find_request[ tok ] = { reply_token = reply_token_, 
                             faction = faction_,
                             level_range = level_range_,
                             realm = realm_,
                             tm = when 
                           } ;
  oq.send_my_premade_info() ;
end

function oq.process_find_requests()
  local now = utc_time() ;
  for i,v in pairs(oq_find_request) do
    if (v.tm < now) then
      oq.announce_premade_info( v.reply_token, v.faction, v.level_range, v.realm ) ;
      oq_find_request[i] = nil ;
    end
  end  
end

function oq.announce_premades()
  local now = utc_time() ;
  for i,v in pairs(oq.premades) do
    if ((player_faction == v.faction) and (v.next_advert < now)) then
      -- if realm or battlegroup restricted, check requestors realm
      -- ####

      -- premade qualifies, send out
      --
      local enc_data = oq.encode_data( "abc123", v.leader, v.leader_realm, v.leader_rid ) ;
      local s = v.stats ;
      local stat = s.status or 0 ;
      if (v.raid_token == oq.raid.raid_token) and _inside_bg then
        stat = 2 ;
      end
      
      local is_realm_specific = nil ;
      local is_source = 0 ;
      oq.announce( "premade,".. 
                   v.raid_token ..",".. 
                   oq.encode_name( v.name ) ..",".. 
                   oq.encode_premade_info( v.raid_token, s.avg_ilevel or 0, s.avg_resil or 0, stat, v.tm, v.has_pword, is_realm_specific, is_source ) ..","..
                   enc_data ..","..
                   oq.encode_bg( v.bgs ) ..","..
                   v.type ..","..
                   v.pdata
                 ) ;
      v.next_advert = now + OQ_SEC_BETWEEN_ADS + random(1,10) ;
    end
  end
end

function oq.on_timer_send_premade( raid_token )
  if (not oq.atok_ok2process( raid_token )) then
    -- this raid_token has been seen recently, don't resend
    return ;
  end
  local v = oq.premades[ raid_token ] ;
  local now = utc_time() ;
  if (v == nil) or (v.next_advert > now) then
    return ;
  end
  local enc_data = oq.encode_data( "abc123", v.leader, v.leader_realm, v.leader_rid ) ;
  local s = v.stats ;

  local stat = s.status or 0 ;
  if (v.raid_token == oq.raid.raid_token) and _inside_bg then
    stat = 2 ;
  end
  local is_realm_specific = nil ;
  local is_source = 0 ;
  oq.announce( "premade,".. 
               v.raid_token ..",".. 
               oq.encode_name( v.name ) ..",".. 
               oq.encode_premade_info( v.raid_token, s.avg_ilevel or 0, s.avg_resil or 0, stat, v.tm, v.has_pword, is_realm_specific, is_source ) ..","..
               enc_data ..","..
               oq.encode_bg( v.bgs ) ..","..
               v.type ..","..
               v.pdata
             ) ;
  v.next_advert = now + OQ_SEC_BETWEEN_ADS + random(1,10) ;
end

function oq.announce_premade_info( reply_token, faction, level_range, realm )
  local now = utc_time() ;
  if (oq.token_was_seen( reply_token )) then
    _ok2relay = nil ; 
    return ;
  end
  oq.token_push( reply_token ) ; -- incase we see this token again

  _sender = nil ;  -- responding directly will need this nil
  local dt = random(8) ; -- will start sending within 8 seconds
  for i,v in pairs(oq.premades) do
    if (faction == v.faction) and (v.next_advert < now) then
      -- if realm or battlegroup restricted, check requestors realm
      -- ####

      -- premade qualifies, send out
      --
      oq.timer_oneshot( dt, oq.on_timer_send_premade, v.raid_token ) ;
      dt = dt + 0.5 ;
    end
  end
end

--
-- each group slot is 2 characters in group_hp representing the max_hp of the unit
-- max_hp of 0 for the slot means that slot is empty
-- this is reported by every group leader and echoe'd by the raid leader
-- ####
function oq.on_group_hp( raid_token, group_id, group_hp )
  if (oq.raid.raid_token ~= raid_token) then
    return ;
  end

  local a, b, hp ;
  group_id = tonumber(group_id) ;
  for i=1,5 do
    a  = oq_mime64[ group_hp:sub((i-1)*2+1,(i-1)*2+1) ] ;
    b  = oq_mime64[ group_hp:sub((i-1)*2+2,(i-1)*2+2) ] ;
    hp = (a * 36) + b ;
    if (hp == 0) then
      -- deadspot
      oq.raid_cleanup_slot( group_id, i ) ;
    else
      oq.raid.group[ group_id ].member[ i ].hp = hp ;
    end
  end
end

-- 
-- called by party_leader (my_group == group_id)
-- dead slots have hp of 0
--
function oq.get_group_hp()
  if ((my_group < 1) or (my_slot < 1)) then
    return ;
  end
  local spots = "" ;
  local hp, n, a, b ;
  for i = 1,5 do
    n  = oq.raid.group[ my_group ].member[ i ].name ;
    hp = 0 ;
    if ((n ~= nil) and (n ~= "held") and (n ~= "n/a") and (oq.raid.group[ my_group ].member[ i ].realm ~= nil)) then
      if (oq.raid.group[ my_group ].member[ i ].realm ~= player_realm) then
        n = n .."-".. oq.raid.group[ my_group ].member[ i ].realm ;
      end
      hp = UnitHealthMax( n ) ;
    end
    a = floor((hp / 1000) / 36) ;
    b = floor((hp / 1000) % 36) ;
    oq.raid.group[ my_group ].member[ i ].hp = (a * 36) + b ;
    spots = spots .."".. oq_mime64[ a ] .."".. oq_mime64[ b ] ;

    oq.set_status_online( my_group, i, (hp > 0) ) ;

    if (hp == 0) then
      -- deadspot
--      oq.raid_cleanup_slot( my_group, i ) ;
    end
  end
  return spots ;
end

function oq.send_group_hp()
  if (oq.raid.raid_token == nil) then
    return ; 
  end
  if (not oq.iam_party_leader() and not oq.iam_raid_leader()) then
    return ;
  end
  local spots = oq.get_group_hp() ;
  if (spots) then
    oq.raid_announce( "group_hp,".. 
                       oq.raid.raid_token ..","..
                       my_group ..","..
                       spots
                    ) ;
  end
end

function oq.on_join( ndx, bg_type )
  oq.battleground_join( tonumber(ndx), tonumber(bg_type) ) ;
end

function oq.on_leave( ndx )
  oq.battleground_leave( tonumber(ndx) ) ;
end

function oq.on_leave_group( name, realm )
  -- clean up the raid ui
  for i=1,8 do
    for j=1,5 do
      local mem = oq.raid.group[i].member[j] ;
      if ((mem ~= nil) and (mem.name == name) and (mem.realm == realm)) then
        -- clean out the locker
        mem.name   = nil ;
        mem.class  = "XX" ;
        mem.realm  = nil ;
        mem.realid = nil ;
        oq.set_group_member( i, j, nil, nil, "XX", nil, OQ.NONE, "0", OQ.NONE, "0" ) ;
        oq.set_deserter( i, j, nil ) ;
        oq.set_role( i, j, OQ.ROLES["NONE"] ) ;
        if (j == 1) then
        
          oq.group_left( i ) ;
          oq.raid_announce( "remove_group,".. i ) ;          
        else
          oq.member_left( i, j ) ;
        end
        return ;
      end
    end
  end
end

function oq.on_leave_slot( g_id, slot )
  g_id = tonumber(g_id) ;
  slot = tonumber(slot) ;
  if (g_id == 0) or (slot == 0) then
    return ;
  end
  local mem = oq.raid.group[g_id].member[slot] ;
  if (mem == nil) then
    return ;
  end
  mem.name   = nil ;
  mem.class  = "XX" ;
  mem.realm  = nil ;
  mem.realid = nil ;
  oq.set_group_member( g_id, slot, nil, nil, "XX", nil ) ;
  oq.set_deserter( g_id, slot, nil ) ;
  oq.set_role( g_id, slot, OQ.ROLES["NONE"] ) ;
  if (slot == 1) then
    oq.group_left( g_id ) ;
    oq.raid_announce( "remove_group,".. g_id ) ;
  else
    oq.member_left( g_id, slot ) ;
  end
end

--
-- intended for group leader 
--
function oq.on_proxy_invite( group_id, slot_, enc_data_, req_token_ ) 
  group_id = tonumber( group_id ) ;
  slot     = tonumber( slot ) ;

  if ((not oq.iam_party_leader()) or (group_id == nil) or (group_id ~= my_group)) then
    return ;
  end
  if (oq.raid.raid_token == nil) then
    return ;
  end

  local enc_data = oq.encode_data( "abc123", 
                                   player_name, 
                                   player_realm, 
                                   player_realid ) ;
  local msg = "OQ,".. 
              OQ_VER ..",".. 
              "W1,"..
              "1,"..
              "proxy_target,".. 
              group_id ..","..
              slot_ ..","..
              enc_data ..","..
              oq.raid.raid_token ..","..
              req_token_ ;
              
  -- this is the target name, realm, and real-id
  local  name, realm, rid_ = oq.decode_data( "abc123", enc_data_ ) ;
  if (realm == player_realm) then
    -- on my realm, let player know he's in my group then invite him
    oq.realid_msg( name, realm, rid_, msg ) ;
    oq.timer_oneshot( 1.5, oq.InviteUnit, name, realm ) ;
    oq.timer_oneshot( 2.5, oq.brief_group_members ) ;  
    return ;
  end
  
  local n = name .."-".. realm ;
  if (oq.pending_invites == nil) then
    oq.pending_invites = {} ;
  end
  oq.pending_invites[ n ] = { raid_tok = oq.raid.raid_token, gid = my_group, slot = slot_, rid = rid_, req_token = req_token_ } ;
  
  local pid = oq.bnpresence( name .."-".. realm ) ;
  if (pid ~= 0) then
    oq.realid_msg( name, realm, rid_, msg ) ;
    oq.timer_oneshot( 1.5, oq.InviteUnit, name, realm ) ;
    oq.timer_oneshot( 2.5, oq.brief_group_members ) ;  
    return ;
  end
  
  -- if reaches here, player is not b-net friend or not on realm... must b-net friend then invite
  oq.bn_realfriend_invite( name, realm, rid_, "#tok:".. req_token_ ..",#grp:".. my_group ..",#nam:".. player_name .."-".. tostring(oq.realm_cooked(player_realm)) ) ; 

  _ninvites = _ninvites + 1 ;
  oq.timer( "invite_to_group".. _ninvites, 2, oq.timer_invite_group_member, true, name, realm, rid_, msg, my_group, slot_, req_token_ ) ;  
end

--
-- intended for recruit  
--
function oq.on_proxy_target( group_id, slot, enc_data, raid_token ) 
  group_id = tonumber( group_id ) ;
  slot     = tonumber( slot ) ;

  local  gl_name, gl_realm, gl_rid = oq.decode_data( "abc123", enc_data ) ;
  my_group = group_id ;
  my_slot  = slot ;
  oq.ui_player() ;
  oq.update_my_premade_line() ;
  
  -- set group leader to prepare for invite
  oq.raid.group[ group_id ].member[ 1 ].name   = gl_name ;
  oq.raid.group[ group_id ].member[ 1 ].realm  = gl_realm ;
  oq.raid.group[ group_id ].member[ 1 ].realid = gl_rid ;
  oq.raid.raid_token = raid_token ;

  if (gl_realm ~= player_realm) then
    oq.bn_realfriend_invite( gl_name, gl_realm, gl_rid ) ; -- will need to be b-net friends to invite cross-realm (!!!!)
  end
end

--
-- fired by raid leader
--
function oq.proxy_invite( group_id, slot, name, realm, rid, req_token ) 
  if ((oq.raid.group[ group_id ].member[1].name == nil) or (oq.raid.group[ group_id ].member[1].name == "-")) then
    return ;
  end

  --
  -- creating new msgs... ok to turn off sender info
  --
  _sender = nil ;

  --[[ if group to be invited to isn't my group, send message out for that group-leader to do the invite ]]--
  if (my_group == group_id) then
    local enc_data = oq.encode_data( "abc123", name, realm, rid ) ;
    oq.on_proxy_invite( group_id, slot, enc_data, req_token ) ;
  else
    -- not my group, ask the other group leader to invite
    msg_tok = "W".. oq.token_gen() ;
    oq.token_push( msg_tok ) ;

    enc_data = oq.encode_data( "abc123", name, realm, rid ) ;
    local m = "OQ,".. 
              OQ_VER ..",".. 
              msg_tok ..","..
              OQ_TTL ..","..
              "proxy_invite,".. 
              group_id ..","..
              slot ..","..
              enc_data ..","..
              req_token ;

    local lead = oq.raid.group[ group_id ].member[1] ;
    oq.realid_msg( lead.name, lead.realm, lead.realid, m ) ;
  end
end

function oq.valid_rid( rid )
   if (rid == nil) or (rid == OQ_NOEMAIL) then
      return nil ;
   end
   -- good battle-tag has a '#' in the middle
   if (rid:find("#") ~= nil) then
      -- battle-tag
      return true ;
   end
   if (rid:find("+") or rid:find("&")) then
      return nil ;
   end
   -- good email has a '@' and a '.'
   local f1 = rid:find("@") ;
   if (f1 ~= nil) then
      local f2 = rid:find(".", f1) ;
      if (f2 ~= nil) then
         -- possible email 
         return true ;
      end
   end
   return nil ;
end

-- will need to real-id friend the person in order to invite  (!!!!)
function oq.bn_realfriend_invite( name, realm, rid, extra_note ) 
  if ((rid == nil) or (rid == OQ_NOEMAIL)) then
    return ;
  end
  if (not oq.valid_rid( rid )) then
    message( OQ.BAD_REALID .." ".. tostring(rid) ) ;
    return ;
  end
  
  oq.bntoons() ;
  local friend = OQ_data.bn_friends[ name .."-".. realm ] ;
  if (friend ~= nil) and friend.isOnline and friend.oq_enabled then
    -- won't try to add if friended at all.  oq enabled or not
    return ;
  end
  if (friend ~= nil) and (friend.presenceId == 0) then
    return ;
  end
  
  -- if already friended, ok to re-try.  will fail silently (well, red text top center)
  local msg = "OQ,".. oq.raid.raid_token ;
  if (extra_note) then
    msg = msg ..",".. extra_note ;
  end
  oq.BNSendFriendInvite( rid, msg ) ;
  
  oq.timer_oneshot( 15, oq.set_note_if_null, name, realm, "OQ,".. oq.raid.raid_token ) ;
end

function oq.set_note_if_null( name, realm, note )
  oq.bntoons() ;
  local friend = OQ_data.bn_friends[ name .."-".. realm ] ;
  if (friend == nil) or (not friend.isOnline) then
    return ;
  end
  local pid = friend.presenceID or 0 ;
  if (oq.bnfriend_note( pid ) == nil) then
    BNSetFriendNote( pid, note ) ;
  end
end

function oq.raid_identify_self()
  oq.raid_announce( "identify,0" ) ;
end

function oq.brief_group_lead( group_id ) 
  local name  = oq.raid.group[group_id].member[1].name ;
  local realm = oq.raid.group[group_id].member[1].realm ;
  if (name == nil) or (realm == nil) then
    return ;
  end
  _sender = nil ;
  for i=1,8 do
    if (i ~= group_id) then
      local grp = oq.raid.group[i] ;
      if (grp._names ~= nil) then
        oq.whisper_msg( name, realm, grp._names ) ;
      end
      if (grp._stats ~= nil) then
        oq.whisper_msg( name, realm, grp._stats ) ;
      end
    end
  end
end

function oq.assign_lucky_charms()
  if (oq.raid.raid_token == nil) then
    return ;
  end
  -- assigning lucky charms, first come first served
  local charm = 1 ;
  for i=1,8 do
    for j=1,5 do
      local m = oq.raid.group[i].member[j] ;
      if (m.name ~= nil) and (m.name ~= "-") and (m.name ~= "") then
        if (m.role == OQ.ROLES["HEALER"]) and (charm < 8) then
          if (m.charm ~= charm) then
            oq.leader_set_charm( i, j, charm ) ;
          end
          charm = charm + 1 ;
        elseif (m.charm ~= 0) then
          oq.leader_set_charm( i, j, 0 ) ;
        end
        
        -- set the charm if currently in the bg
        if (_inside and oq.IsRaidLeader()) then
          if (m.name == player_name) then
            SetRaidTarget( "player", m.charm or 0 ) ;
          else
            local n = m.name ;
            if (m.realm ~= player_realm) then
              n = n .."-".. m.realm ;
            end
            SetRaidTarget( n, m.charm or 0 ) ;
          end
        end
      end
    end
  end
  _lucky_charms = (_inside_bg and oq.IsRaidLeader()) ;
end

function oq.handout_lucky_charms()
  if (not oq.IsRaidLeader()) or (oq.raid.raid_token == nil) then
    return ;
  end
  -- i am the bg leader and we are inside, hand out lucky charms
  for i=1,8 do
    for j=1,5 do
      local m = oq.raid.group[i].member[j] ;
      if (m.name ~= nil) and (m.name ~= "-") and (m.name ~= "") then
        if (m.name == player_name) then
          SetRaidTarget( "player", m.charm or 0 ) ;
        else
          local n = m.name ;
          if (m.realm ~= player_realm) then
            n = n .."-".. m.realm ;
          end
          SetRaidTarget( n, m.charm or 0 ) ;
        end
      end
    end
  end
  _lucky_charms = true ;
end

function oq.IsRaidLeader()
  return UnitIsGroupLeader("player") ;  -- pandaria update
end

local last_group_brief = 0 ;
function oq.group_lead_bookkeeping()
  if (oq.iam_raid_leader() and _inside_bg and (not _lucky_charms) and oq.IsRaidLeader()) then
    oq.timer_oneshot( 30, oq.handout_lucky_charms ) ;    
  end

  if (my_slot ~= 1) or (_inside_bg) then
    return ;
  end
  local now = utc_time() ;
  if (now < (last_group_brief + OQ_BOOKKEEPING_INTERVAL)) then
    return ;
  end
  last_group_brief = now ;
  
  -- update online status
  for slot=2,5 do
    local m = oq.raid.group[my_group].member[slot] ;
    if (m.name ~= nil) and (m.name ~= "-") then
      local n = m.name ;
      if (m.realm ~= player_realm) then
        n = n .."-".. m.realm ;
      end
      
      -- online status check
      oq.set_status_online( my_group, slot, UnitIsConnected( n ) ) ;
    end
  end
end
  
function oq.ready_check( g_id, slot, stat )
  g_id = tonumber( g_id ) ;
  slot = tonumber( slot ) ;
  if (stat == nil) then
    stat = 0 ;
  end
  stat = tonumber( stat ) ;
  local m = oq.raid.group[ g_id ].member[ slot ] ;
  m.check = stat ;
  oq.set_textures( g_id, slot ) ;
end

function oq.on_ready_check_complete()
  for grp=1,8 do
    for s=1,5 do
      oq.raid.group[grp].member[s].check = OQ_FLAG_CLEAR ;
      oq.set_textures( grp, s ) ;
    end
  end
end

local last_brief_tm = 0 ;
function oq.brief_group_members() 
  local now = utc_time() ;
  if (my_slot ~= 1) or (now < (last_brief_tm + OQ_BRIEF_INTERVAL) or (_inside_bg)) then
    return ;
  end
  last_brief_tm = now ;
  
  local mygrp = oq.raid.group[my_group] ;
  
  -- send party info
  local enc_data = oq.encode_data( "abc123", oq.raid.leader, oq.raid.leader_realm, oq.raid.leader_rid ) ;
  oq.party_announce( "party_join,".. 
                      my_group ..","..
                      oq.encode_name( oq.raid.name ) ..",".. 
                      oq.raid.leader_class ..",".. 
                      enc_data ..",".. 
                      oq.raid.raid_token  ..",".. 
                      oq.encode_note( oq.raid.notes )
                   ) ;

  -- send party slots
  local msg = "party_slots,"..
               my_group ;
  for i=1,5 do
    local name = mygrp.member[i].name ;
    if (name == nil) or (name == "") or (name == "-") then
      name = "-" ;
    end
    msg = msg ..",".. name ;
  end 
  oq.party_announce( msg ) ;
  
  -- send group info from other known groups
  _sender = nil ;
  for i=1,8 do
    local grp = oq.raid.group[i] ;
    if (grp._names ~= nil) then
      oq.party_announce( grp._names ) ;
    end
    if (grp._stats ~= nil) then
      oq.party_announce( grp._stats ) ;
    end
  end
end

--
--  received by the raid-leader
--
function oq.on_invite_accepted( raid_token, group_id, slot, class, enc_data, req_token )
  if (oq.raid.raid_token ~= raid_token) then
    return ;
  end
  if (not oq.iam_raid_leader()) then
    return ;
  end

  group_id = tonumber( group_id ) ;
  slot     = tonumber( slot ) ;

  local  name, realm, rid = oq.decode_data( "abc123", enc_data ) ;
  oq.set_group_member( group_id, slot, name, realm, class, rid ) ;

  if (slot == 1) then
    -- unit is new group leader, brief him
    oq.timer( "brief_leader", 1.5, oq.brief_group_lead, nil, group_id ) ;
    return ;
  end 

  -- invite (by proxy if needed)
  if ((realm == player_realm) and (group_id == my_group)) then
    -- direct invite ok
    local enc = oq.encode_data( "abc123", name, realm, rid ) ;  -- rid not needed, as the invite goes to this realm
    oq.on_proxy_invite( group_id, slot, enc, req_token ) ;
  else
    oq.proxy_invite( group_id, slot, name, realm, rid, req_token ) 
  end
  
  -- not the best, as we don't have resil and ilevel, but that will be updated when we queue.
-- this is on a 60 sec timer
--  oq.send_my_premade_info() ;  
end

function oq.update_my_premade_line()
  if (oq.raid.raid_token == nil) then
    return ;
  end
  
  -- update status 
  local raid = oq.premades[ oq.raid.raid_token ] ;
  if (raid ~= nil) then
    local s = raid.stats ;
    local line = oq.find_premade_entry( raid.raid_token ) ;
    if (line ~= nil) then
      line.req_but:Disable() ;
      if (raid.has_pword) then
        line.has_pword.texture:Show() ;
        line.has_pword.texture:SetTexture( OQ_KEY ) ;
      else
        line.has_pword.texture:Hide() ;
        line.has_pword.texture:SetTexture( nil ) ;
      end
    end  
  end
end

function oq.on_invite_group_lead( req_token, group_id, raid_name, raid_leader_class, enc_data, raid_token, raid_notes )
  if (not oq.token_was_seen( req_token )) then
    return ;
  end
  local  raid_leader, raid_leader_realm, raid_leader_rid = oq.decode_data( "abc123", enc_data ) ;
  _received = true ;
  group_id = tonumber(group_id) ;
  raid_name  = oq.decode_name( raid_name ) ;
  raid_notes = oq.decode_note( raid_notes ) ;
  if (not raid_notes) then
    raid_notes = "" ;
  end
  
  if (oq.iam_raid_leader() and (oq.raid.raid_token ~= raid_token)) then
    -- tried to start my own premade, but join another instead.  
    -- my original premade must be disbanded
    oq.raid_disband() ;
  end

  -- activate in-raid only procs
  oq.procs_join_raid() ;
  
  -- make sure i'm not queue'd
  oq.battleground_leave( 1 ) ;
  oq.battleground_leave( 2 ) ;  

  my_group             = group_id ;
  my_slot              = 1 ;
  oq.raid.name         = raid_name ;
  oq.raid.leader       = raid_leader ;
  oq.raid.leader_class = raid_leader_class ;
  oq.raid.leader_realm = raid_leader_realm ;
  oq.raid.leader_rid   = raid_leader_rid ;
  oq.raid.notes        = (raid_notes or "") ;
  oq.raid.raid_token   = raid_token ;

  oq.tab1_name :SetText( raid_name ) ;
  oq.tab1_notes:SetText( raid_notes ) ;

  oq.set_group_lead( group_id, player_name, player_realm, player_class, player_realid ) ;
  local me = oq.raid.group[group_id].member[1] ;
  me.name   = player_name ;
  me.realm  = player_realm ;
  me.level  = player_level ;
  me.class  = player_class ;
  me.resil  = player_resil ;
  me.ilevel = player_ilevel ;
  me.realid = player_realid ;
  me.check  = OQ_FLAG_CLEAR ;

  oq.send_invite_accept( raid_token, group_id, my_slot, player_name, player_class, player_realm, player_realid, req_token ) ;
  
  -- assign slots to the party members
  oq.party_assign_slots( group_id, enc_data ) ;
  
  -- remove myself from other waitlists
  oq.clear_pending() ;
  oq.ui_player() ;
  oq.update_my_premade_line() ;
  
  -- null out the group stats will force stats send
  last_stats = nil ;
  oq.raid.group[ my_group ]._stats = nil ;
  oq.raid.group[ my_group ]._names = nil ; 
  
  -- make sure we don't decline the friend request
  _ok2decline = nil ;
end

function oq.party_assign_slots( group_id, enc_data )
  local  n_members = oq.GetNumPartyMembers() ;
  if (n_members == 0) then
    return ;
  end
  
  -- send party members raid info and slot assignment
  oq.party_announce( "party_join,".. 
                      group_id ..","..
                      oq.encode_name( oq.raid.name ) ..",".. 
                      oq.raid.leader_class ..",".. 
                      enc_data ..",".. 
                      oq.raid.raid_token  ..",".. 
                      oq.encode_note( oq.raid.notes )
                   ) ;
  local msg = "party_slots,"..                   
               group_id ..","..
               player_name ;
  for i=1,4 do
    local name = GetUnitName( "party".. i, true )
    if (name ~= nil) then
      if (name:find(" - ") ~= nil) then
        name  = name:sub(1,name:find(" - ")-1) ;
      end
    else
      name = "-" ;
    end
    msg = msg ..",".. name ;
  end 
  
  oq.party_announce( msg ) ;
end

function oq.on_raid_join( raid_name, premade_type, raid_leader_class, enc_data, raid_token, raid_notes )
  if (_msg_type ~= 'R') then
    return ;
  end
  
  local  raid_leader, raid_leader_realm, raid_leader_rid = oq.decode_data( "abc123", enc_data ) ;
  _received = true ;

  raid_name  = oq.decode_name( raid_name ) ;
  raid_notes = oq.decode_note( raid_notes ) ;

  oq.raid.name         = raid_name ;
  oq.raid.leader       = raid_leader ;
  oq.raid.leader_class = raid_leader_class ;
  oq.raid.leader_realm = raid_leader_realm ;
  oq.raid.leader_rid   = raid_leader_rid ;
  oq.raid.notes        = raid_notes or "" ;
  oq.raid.raid_token   = raid_token ;

  oq.tab1_name :SetText( raid_name ) ;
  oq.tab1_notes:SetText( raid_notes ) ;
  
  -- activate in-raid only procs
  oq.procs_join_raid() ;  
  oq.set_premade_type( premade_type ) ;
  oq.ui_player() ;
  oq.update_my_premade_line() ;
end

function oq.on_party_join( group_id, raid_name, raid_leader_class, enc_data, raid_token, raid_notes )
  if (_msg_type ~= 'P') then
    return ;
  end
  
  local  raid_leader, raid_leader_realm, raid_leader_rid = oq.decode_data( "abc123", enc_data ) ;
  _received = true ;

  raid_name  = oq.decode_name( raid_name ) ;
  raid_notes = oq.decode_note( raid_notes ) ;

  my_group             = tonumber(group_id) ;
  oq.raid.name         = raid_name ;
  oq.raid.leader       = raid_leader ;
  oq.raid.leader_class = raid_leader_class ;
  oq.raid.leader_realm = raid_leader_realm ;
  oq.raid.leader_rid   = raid_leader_rid ;
  oq.raid.notes        = raid_notes or "" ;
  oq.raid.raid_token   = raid_token ;

  oq.tab1_name :SetText( raid_name ) ;
  oq.tab1_notes:SetText( raid_notes ) ;
  
  -- activate in-raid only procs
  oq.procs_join_raid() ;  
  oq.ui_player() ;
  oq.update_my_premade_line() ;
end

function oq.on_party_slots( group_id, n1, n2, n3, n4, n5 )
  if (_msg_type ~= 'P') then
    return ;
  end
  oq.on_party_slot( n1, group_id, 1 ) ;
  oq.on_party_slot( n2, group_id, 2 ) ;
  oq.on_party_slot( n3, group_id, 3 ) ;
  oq.on_party_slot( n4, group_id, 4 ) ;
  oq.on_party_slot( n5, group_id, 5 ) ;
end

function oq.player_demographic()
  local _, raceId = UnitRace( "player" ) ;
  local gender = UnitSex( "player" ) ; 
  if (gender == 2) then
    gender = 0 ; -- represented in a bit flag, 0 and 1 are better
  end
  return gender, OQ.RACE[raceId] ; -- 1 == female, 0 == male
end

function oq.on_party_slot( name, group_id, slot )
  if (name ~= player_name) or ((_msg_type ~= 'P') and (_msg_type ~= 'A') and (_msg_type ~= 'R')) then
    return ;
  end
  my_group  = tonumber( group_id ) ;
  my_slot   = tonumber( slot ) ;

  -- populate the slot for myself
  oq.gather_my_stats() ; -- will populate 'me'
  local me = oq.raid.group[ my_group ].member[ my_slot ] ;

-- use to be:
-- OQ_NONE, 0, OQ_NONE, 0, 
  local stats = oq.encode_stats( my_group, my_slot, player_level, player_faction, player_class, me.race, me.gender,
                                 me.bg[1].type, me.bg[1].status, me.bg[2].type, me.bg[2].status,
                                 player_resil, player_ilevel, me.flags, me.hp, player_role,
                                 me.charm, me.check, me.wins, me.losses, me.hks, me.oq_ver, me.tears, me.pvppower, me.mmr ) ;
  oq._override = true ;
  oq.on_stats( player_name, oq.realm_cooked(player_realm), stats ) ;
  oq.ui_player() ;
  oq.update_my_premade_line() ;

  -- push stats for everyone else in the raid
  last_stats = nil ;
end

function oq.update_premade_note()
  if (not oq.iam_raid_leader()) then
    return ;
  end
  local name = oq.tab3_raid_name:GetText() ;
  local note = oq.tab3_notes:GetText() ;
  
  oq.raid.name  = name ;  
  oq.raid.notes = note ;
  
  if (oq.get_resil()  < oq.numeric_sanity( oq.tab3_min_resil:GetText() )) or 
     (oq.get_ilevel() < oq.numeric_sanity( oq.tab3_min_ilevel:GetText() )) or 
     (oq.get_mmr()    < oq.numeric_sanity( oq.tab3_min_mmr:GetText() )) then
    StaticPopup_Show("OQ_DoNotQualifyPremade") ;
    return ;
  end

  
  oq.tab1_name :SetText( oq.raid.name ) ;
  oq.tab1_notes:SetText( oq.raid.notes ) ; 
  oq.raid.level_range      = oq.tab3_level_range ;
  oq.raid.min_ilevel       = oq.numeric_sanity( oq.tab3_min_ilevel:GetText() ) ;
  oq.raid.min_resil        = oq.numeric_sanity( oq.tab3_min_resil:GetText() ) ;
  oq.raid.min_mmr          = oq.numeric_sanity( oq.tab3_min_mmr:GetText() ) ;
  oq.raid.bgs              = string.gsub( oq.tab3_bgs:GetText() or ".", ",", ";" ) ;
  oq.raid.pword            = oq.tab3_pword:GetText() or "" ;
  if (oq.raid.pword == nil) or (oq.raid.pword == "") then
    oq.raid.has_pword = nil ;
  else
    oq.raid.has_pword = true ;
  end

  oq.raid_announce( "premade_note,"..
                    oq.raid.raid_token ..","..
                    oq.encode_name( name ) ..","..
                    oq.encode_note( note ) 
                  ) ;
  local premade = oq.premades[ oq.raid.raid_token ] ;                  
  if (premade ~= nil) then      
    premade.tm          = 0 ;            
    premade.last_seen   = utc_time() ;
    premade.next_advert = 0 ;    
    premade.min_ilevel  = oq.raid.min_ilevel ;
    premade.min_resil   = oq.raid.min_resil ;
    premade.min_mmr     = oq.raid.min_mmr ;
    premade.pdata       = oq.get_pdata() ;
  end
  oq.send_my_premade_info() ;
  return 1 ;
end

function oq.on_premade_note( raid_token, name, note )
  if (oq.raid.raid_token == nil) or (oq.raid.raid_token ~= raid_token) then
    return ;
  end
  name = oq.decode_name( name ) ;
  note = oq.decode_note( note ) ;

  oq.raid.name = name ;  
  oq.tab1_name :SetText( oq.raid.name ) ;
  
  oq.raid.notes = note ;
  oq.tab1_notes:SetText( oq.raid.notes ) ; 
end

function oq.find_player_slot( g_id, name, realm )
  for i=1,5 do
    local p = oq.raid.group[g_id].member[i] ;
    if (p.name ~= nil) and (p.name == name) and (p.realm == realm) then
      return i ;
    end
  end
  return 0 ;
end

function oq.on_promote( g_id, name, realm, lead_rid, leader_realm, req_token )
  g_id = tonumber(g_id) ;
  slot = tonumber(slot) ;
  if (my_group ~= g_id) and (g_id ~= 1) then
    return ;
  end
  oq.token_push( req_token ) ; -- push it to the list so auto-realid-invites can happen

  if (g_id == 1) and (my_group ~= 1) and (my_slot == 1) then
    -- connect with oq-leader
    if (realm ~= player_realm) then
      local pid = oq.bnpresence( name .."-".. realm ) ;
      if (pid == 0) then
        -- real-id the oq-leader
        oq.realid_msg( name, realm, lead_rid, "#tok:".. req_token ..",#lead" ) ;
      end
    end
    -- push info
    lead_ticker = 0 ;
    oq.timer_oneshot( 1, oq.force_stats ) ;
    return ;
  end
  if (my_slot == 1) or oq.iam_party_leader() then
    -- take the slot of the target
    local p_slot = oq.find_player_slot( g_id, name, realm ) ;
    if (p_slot == 0) then
      return ;
    end
    -- send to party BEFORE processing
    oq.channel_party( _msg ) ;
    _ok2relay = nil ;
    
    -- promote
    my_slot = p_slot ;
    if (realm ~= player_realm) then
      PromoteToLeader( name .."-".. realm ) ;
    else
      PromoteToLeader( name ) ;
    end
    -- update info
    oq.set_group_lead( g_id, name, realm, oq.raid.group[g_id].member[p_slot].class, nil ) ;
    oq.set_name      ( g_id, my_slot, player_name, player_realm, player_class ) ;
    
    -- push info
    lead_ticker = 0 ;
    oq.timer_oneshot( 1, oq.force_stats ) ;
  elseif (player_name == name) then
    -- change my_slot
    local p_slot = my_slot ;
    my_slot = 1 ;
    -- update info
    local p = oq.raid.group[g_id].member[1] ;
    oq.set_name      ( g_id, p_slot, p.name, p.realm, p.class ) ;
    oq.set_group_lead( g_id, name, realm, player_class, player_realid ) ;
    -- push info
    lead_ticker = 0 ;
    oq.timer_oneshot( 3, oq.force_stats ) ;
    if (g_id == 1) then
      oq.ui_raidleader() ;
    end

    -- connect with oq-leader
    if (player_realm ~= leader_realm) and (g_id ~= 1) then
      local r = oq.raid.group[1].member[1] ;
      local pid = oq.bnpresence( r.name .."-".. r.realm ) ;
      if (pid == 0) then
        -- real-id the oq-leader
        oq.realid_msg( r.name, r.realm, lead_rid, "#tok:".. req_token ..",#lead" ) ;
      end
    end
    -- push info
    lead_ticker = 0 ;
    oq.timer_oneshot( 1, oq.force_stats ) ;
  end
end

function oq.on_invite_group( req_token, group_id, slot, raid_name, raid_leader_class, enc_data, raid_token, raid_notes )
  if (not oq.token_was_seen( req_token )) then
    return ;
  end
  local  raid_leader, raid_leader_realm, raid_leader_rid = oq.decode_data( "abc123", enc_data ) ;
  _received = true ;
  _ok2relay = nil ;

  if (oq.iam_raid_leader() and (oq.raid.raid_token ~= raid_token)) then
    -- tried to start my own premade, but join another instead.  
    -- my original premade must be disbanded
    oq.raid_disband() ;
  end

  -- activate in-raid only procs
  oq.procs_join_raid() ;

  -- make sure i'm not queue'd
  oq.battleground_leave( 1 ) ;
  oq.battleground_leave( 2 ) ;  
  
  raid_name  = oq.decode_name( raid_name ) ;
  raid_notes = oq.decode_note( raid_notes ) ;
  
  my_group             = tonumber(group_id) ;
  my_slot              = tonumber(slot) ;
  oq.raid.name         = raid_name ;
  oq.raid.leader       = raid_leader ;
  oq.raid.leader_class = raid_leader_class ;
  oq.raid.leader_realm = raid_leader_realm ;
  oq.raid.leader_rid   = raid_leader_rid ;
  oq.raid.notes        = raid_notes ;
  oq.raid.raid_token   = raid_token ;
  
  local me = oq.raid.group[my_group].member[my_slot] ;
  me.name   = player_name ;
  me.realm  = player_realm ;
  me.level  = player_level ;
  me.class  = player_class ;
  me.resil  = player_resil ;
  me.ilevel = player_ilevel ;
  me.realid = player_realid ;
  me.check  = OQ_FLAG_CLEAR ;
  me.charm  = 0 ;

  oq.tab1_name :SetText( raid_name ) ;
  oq.tab1_notes:SetText( raid_notes ) ;

  oq.set_group_lead( 1, raid_leader, raid_leader_realm, raid_leader_class, raid_leader_rid ) ;
  oq.set_group_member( group_id, slot, player_name, player_realm, player_class, player_realid, OQ.NONE, "0", OQ.NONE, "0" ) ;

  -- send out invite acceptance
  oq.send_invite_accept( raid_token, group_id, slot, player_name, player_class, player_realm, player_realid, req_token ) ;

  -- send out my status (give it time for the group invites to settle)
--  oq.timer( "mystatus", 2, oq.send_my_status ) ; 

  -- remove myself from other waitlists
  oq.clear_pending() ;
  oq.ui_player() ;
  oq.update_my_premade_line() ;

  -- null out the group stats will force stats send
  last_stats = nil ;
  oq.raid.group[ my_group ]._stats = nil ;
  oq.raid.group[ my_group ]._names = nil ; 
  
end

function oq.on_member( group_id, slot, class, name, realm )
  realm = oq.realm_uncooked(realm) ;
  oq.set_group_member( group_id, slot, name, realm, class, nil ) ;
end

function oq.on_pass_lead( raid_token, nuleader, nuleader_realm, nuleader_rid )
  oq.raid.leader        = nuleader ;
  oq.raid.leader_realm  = nuleader_realm ;
  oq.raid.leader_realid = nuleader_rid ;
end

function oq.on_party_update( raid_token )
  oq.raid.raid_token = raid_token ;
end

function oq.on_ping( token, ts )
  if (_to_name == _player_name) then
    _ok2relay = nil ;
  end
  if (not oq.iam_party_leader()) then
    return ;
  end
  oq.raid_ping_ack( token, ts ) ;
end

function oq.on_ping_ack( token, ts, g_id )
  local now = GetTime() * 1000 ;
  if (token ~= oq.my_tok) then
    return ;
  end
  local lag = floor((now - tonumber(ts))/2) ;
  g_id = tonumber(g_id) ;
  if (g_id ~= nil) and (g_id > 0) and (g_id <= 8) then
    local grp = oq.raid.group[ g_id ] ;
    local m = grp.member[1] ;
    grp._last_ping = utc_time() ;
    m.lag = lag ;
    oq.tab1_group[g_id].lag:SetText( string.format( "%5.2f", m.lag/1000 )) ;
    oq.timer( "push_lagtimes", 1, oq.send_lag_times ) ;
    return ;
  end
  
  -- update lag on group leaders
  for i,grp in pairs(oq.raid.group) do
    if ((grp.member[1].name ~= nil) and (grp.member[1].name ~= "") and (grp.member[1].name ~= "-")) then
      local m = grp.member[1] ;
      local n = m.name ;
      if (m.realm ~= player_realm) then
        n = n .."-".. m.realm ;
      end
      if (m.name == _sender) then
        grp._last_ping = utc_time() ;
        m.lag = lag ;
        oq.tab1_group[i].lag:SetText( string.format( "%5.2f", m.lag/1000 )) ;
        oq.timer( "push_lagtimes", 1, oq.send_lag_times ) ;
        break ;
      end
    end
  end
end

function oq.premade_remove( lead_name, lead_realm, lead_rid, tm ) 
  local found = nil ;
  for i,v in pairs(oq.premades) do
    if ((v.leader == lead_name) and (v.leader_realm == lead_realm) and (v.leader_rid == lead_rid)) then
      if ((tm == nil) or (v.tm == nil) or (v.tm < tm)) then
        oq.remove_premade( v.raid_token ) ;
        found = true ;
      end
    end
  end
  return found ;
end

function oq.get_role_icon( n )
  if (n == "T") then
    -- OQ_TANK_ICON     
    return "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:%d:64:64:0:19:22:41|t";
  elseif (n == "H") then
    -- OQ_HEALER_ICON   
    return "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:%d:64:64:20:39:1:20|t";
  elseif (n == "D") then
    -- OQ_DAMAGE_ICON    
    return "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:%d:64:64:20:39:22:41|t" ;
  end
  -- OQ_EMPTY_ICON 
  return "|TInterface\\TARGETINGFRAME\\UI-PhasingIcon.blp:16:16:0:%d:64:64:0:64:0:64|t";
--  return "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:%d:64:64:0:0:0:0|t";
end

function oq.nMaxGroups()
  if (oq.raid.type == OQ.TYPE_RBG) then
    return 2 ;
  elseif (oq.raid.type == OQ.TYPE_ARENA) then
    return 1 ;
  elseif (oq.raid.type == OQ.TYPE_SCENARIO) then
    return 1 ;
  elseif (oq.raid.type == OQ.TYPE_DUNGEON) then
    return 1 ;
  end
  return 8 ;
end

function oq.get_n_roles() 
  local ntanks = 0 ;
  local nheals = 0 ;
  local ndps   = 0 ;
  local ngroups = oq.nMaxGroups() ;

  for i=1,ngroups do
    for j=1,5 do
      local m = oq.raid.group[i].member[j] ;
      if (m.name ~= nil) and (m.name ~= "-") then
        if (OQ.ROLES[ m.role ] == "TANK") then
          ntanks = ntanks + 1 ;
        elseif (OQ.ROLES[ m.role ] == "HEALER") then
          nheals = nheals + 1 ;
        else
          ndps   = ndps + 1 ;
        end
      end
    end
  end
  return ntanks, nheals, ndps ;
end

function oq.update_raid_listitem( raid_tok, raid_name, ilevel, resil, mmr, battlegrounds, tm_, status, has_pword, lead_name, pdata, type )
  if (oq.tab2_raids == nil) then 
    return ;
  end
  status = tonumber(status) ;
  for i,f in pairs( oq.tab2_raids ) do
    if (f.raid_token == raid_tok) then
      f.leader   :SetText( lead_name ) ;
      f.raid_name:SetText( raid_name ) ;
      f.min_ilvl :SetText( ilevel ) ;
      if (type == OQ.TYPE_DUNGEON) then
        oq.moveto( f.min_resil, 360, 6 ) ; -- move down slightly 
        local s = "" ;
        for j=1,5 do
          local ch = pdata:sub(j,j) ;
          if (ch ~= "") and (ch ~= "-") then
            s = s .."".. oq.get_role_icon( ch ) ;
          elseif (j <= 3) or (type == OQ.TYPE_DUNGEON) then
            s = s .."".. oq.get_role_icon( "X" ) ; -- empty slot
          end
        end
        f.min_resil:SetText( s ) ;
        f.min_mmr  :SetText( "" ) ;
      elseif (type == OQ.TYPE_SCENARIO) then
        oq.moveto( f.min_resil, 360, 6 ) ; -- move down slightly 
        local s = "" ;
        for j=1,3 do
          local ch = pdata:sub(j,j) ;
          if (ch ~= "") and (ch ~= "-") then
            s = s .."".. oq.get_role_icon( ch ) ;
          else
            s = s .."".. oq.get_role_icon( "X" ) ; -- empty slot
          end
        end
        f.min_resil:SetText( s ) ;
        f.min_mmr  :SetText( "" ) ;
      elseif (type == OQ.TYPE_RAID) then
--        oq.moveto( f.min_resil, 360, 6 ) ; -- move down slightly 
        if (pdata:sub(1,3) == "---") then
          pdata = "AAA" ; -- equivalent to 000 in mime64
        end
        local ntanks = oq.decode_mime64_digits(pdata:sub(1,1)) ;
        local nheals = oq.decode_mime64_digits(pdata:sub(2,2)) ;
        local ndps   = oq.decode_mime64_digits(pdata:sub(3,3)) ;
        local s = string.format( "%01d", ntanks ) .."".. oq.get_role_icon( "T" ) ;
        s = s .." ".. string.format( "%01d", nheals ) .."".. oq.get_role_icon( "H" ) ;
        s = s .." ".. string.format( "%02d", ndps   ) .."".. oq.get_role_icon( "D" ) ;
        f.min_resil:SetText( s ) ;
        f.min_mmr  :SetText( "" ) ;
      else
        oq.moveto( f.min_resil, 360, 2 ) ; -- back to normal position
        f.min_resil:SetText( resil ) ;
        f.min_mmr  :SetText( mmr ) ;
      end
      f.zones  :SetText( battlegrounds ) ;
      -- update status 
      if (status == 2) or (raid_tok == oq.raid.raid_token) then
        -- inside, disable button
        f.req_but:Disable() ;
      else
        f.req_but:Enable() ;
        f.has_pword.texture:Show() ;
        if (has_pword) then
          f.has_pword.texture:SetTexture( OQ_KEY ) ;
        else
          f.has_pword.texture:SetTexture( nil ) ;
        end
      end
      
      local r = oq.premades[ raid_tok ] ;
      if (r ~= nil) then
        r.leader       = lead_name ;
        r.name         = raid_name ;
        r.min_ilevel   = ilevel ; 
        r.min_resil    = resil ;
        r.min_mmr      = mmr ;
        r.bgs          = battlegrounds ;
        r.tm           = tm_ ;
      end
      return ;
    end
  end
end

local npremades = 0 ;
function oq.on_premade( raid_tok, raid_name, premade_info, enc_data, bgs_, type_, pdata_ )
  if (enc_data == nil) then
    return ;
  end
  if (type_ == nil) then
    type_ = OQ.TYPE_BG ; -- default type, regular battlegrounds
  end
  if (pdata_ == nil) or (pdata_:find( "#rlm" )) then
    pdata_ = "-----" ;
  end
  local faction, has_pword, is_realm_specific, is_source, level_range, 
        min_ilevel, min_resil, nmembers, nwaiting, avg_ilevel, avg_resil,
        wins, losses, avgHonor, avgHks, avgDeaths, dnTime, 
        bg_len, status, tm_, min_mmr  = oq.decode_premade_info( premade_info ) ;
        
  local raid_tm_token = raid_tok ..".".. tm_ ;
  if (oq.token_was_seen( raid_tm_token ) or (faction ~= player_faction)) then
    _ok2relay = nil ;
    return ;
  end
  oq.token_push( raid_tm_token ) ;
  
  oq.process_premade_info( raid_tok, raid_name, faction, level_range, min_ilevel, min_resil, min_mmr,
                           enc_data, bgs_, nmembers, avg_resil, avg_ilevel, wins, losses, 
                           avgHonor, avgHks, avgDeaths, dnTime, bg_len, is_source, tm_, status, 
                           nwaiting, has_pword, is_realm_specific, type_, pdata_ ) ;
end
  
function oq.process_premade_info( raid_tok, raid_name, faction, level_range, ilevel, resil, mmr, enc_data, 
                                  bgs_, nMem, avgResil, avgIlevel, wins, losses, avgHonor, avgHks, 
                                  avgDeaths, dnTime, bg_len, is_source, tm_, status, nWait, has_pword, 
                                  is_realm_specific, type_, pdata_ )
  if (OQ_toon.disabled) then
    return ;
  end
  local  now = utc_time() ;
  local battlegrounds = oq.decode_bg( bgs_ ) ;
  raid_name = oq.ltrim( oq.decode_name( raid_name ) ) ;
  -- decode data
  lead_name, lead_realm, lead_rid = oq.decode_data( "abc123", enc_data ) ;
  if (oq.is_banned( lead_rid )) then
    -- do not record or relay premade info for banned people
    _ok2relay = nil ;
    return ;
  end
  if (raid_tok == oq.raid.raid_token) then
    if (type_ ~= oq.raid.type) then
      oq.set_premade_type( type_ ) ;
    end
    oq.update_my_premade_line() ;
  end
  if (oq.premades[ raid_tok ] ~= nil) then
    -- already seen
    local premade = oq.premades[ raid_tok ] ;
    if (tm_ < premade.tm) then
      -- drop old data
      _ok2relay = nil ;
      return ;
    end
    if ((tm_ - premade.tm) > 120) then
--      print( "oQ: forged ts? (".. (tm_ - premade.tm) ..")  [".. tostring(premade.name) .."] sender: ".. tostring(_sender) .."  src: ".. tostring(_source) ) ;
    end
    -- data is newer then what i have.. replace
    premade.leader        = lead_name ;
    premade.leader_realm  = lead_realm ;
    premade.leader_rid    = lead_rid ;
    premade.last_seen     = now ;
    premade.type          = type_ ; 
    premade.pdata         = pdata_ ;
    if (is_source == 0) then
      premade.next_advert = now + OQ_SEC_BETWEEN_ADS + random(1,10) ;
    end
    local is_update = (premade.name ~= raid_name) and (raid_name ~= nil) ;
    premade.has_pword         = has_pword ;
    premade.is_realm_specific = is_realm_specific ;
    oq.on_premade_stats( raid_tok, nMem, avgResil, avgIlevel, wins, losses, avgHonor, avgHks, avgDeaths, dnTime, bg_len, is_source, tm_, status, nWait ) ;
    oq.update_raid_listitem( raid_tok, raid_name, ilevel, resil, mmr, battlegrounds, tm_, status, has_pword, lead_name, pdata_, type_ ) ;
    if (is_update) then
      -- announce premade name change
      oq.announce_new_premade( raid_name, true, raid_tok ) ;
    end
    return ;
  end

  oq.premade_remove( lead_name, lead_realm, lead_rid, tm_ ) ;

  oq.premades[ raid_tok ] = { raid_token   = raid_tok, 
                              name         = raid_name, 
                              leader       = lead_name, 
                              leader_realm = lead_realm,
                              leader_rid   = lead_rid, 
                              level_range  = level_range, 
                              faction      = faction, 
                              min_ilevel   = ilevel, 
                              min_resil    = resil, 
                              min_mmr      = mmr,
                              bgs          = battlegrounds,
                              type         = type_,
                              pdata        = pdata_,
                              tm           = tm_,  -- owner's time
                              last_seen    = now,  -- my time
                              next_advert  = now + OQ_SEC_BETWEEN_ADS + random(1,10),
                              stats = { nMembers    = tonumber(nMem), 
                                        avg_resil   = avgResil, 
                                        avg_ilevel  = avgIlevel,
                                        nWins       = wins,
                                        nLosses     = losses,
                                        avg_honor   = avgHonor,
                                        avg_hks     = avgHks,
                                        avg_deaths  = avgDeaths,
                                        avg_down_tm = dnTime,
                                        avg_bg_len  = bg_len,
                                        nWaiting    = tonumber(nWait),
                                      }
                            } ;
  
  oq.premades[ raid_tok ].has_pword         = has_pword ;
  oq.premades[ raid_tok ].is_realm_specific = is_realm_specific ;
  local ok2add = true ;
  if (abs(now - tm_) >= 10*60) then
    -- premade leader's time is off.  don't add
--      print( "time variance (".. abs(now-tm_) .." sec) [".. tostring(lead_name) .."-".. tostring(lead_realm) .."][".. tostring(lead_rid) .."]" ) ;
    ok2add = nil ;
  end
  
  if (ok2add) then  
    local x, y, cy ;
    cy = 25 ;
    x  = 20 ;
    y  =  npremades * (cy + 2) + 10 ; 
    npremades = npremades + 1 ;
    
    local f   = oq.create_raid_listing( oq.tab2_list, x, y, oq.tab2_list:GetWidth() - 2*x, cy, raid_tok, wins ) ;
    f.leader   :SetText( lead_name ) ;
    f.levels   :SetText( level_range ) ;
    f.raid_token = raid_tok ;
    table.insert( oq.tab2_raids, f ) ;
    oq.reshuffle_premades() ;
    oq.on_premade_stats( raid_tok, nMem, avgResil, avgIlevel, wins, losses, avgHonor, avgHks, avgDeaths, dnTime, bg_len, is_source, tm_, status, nWait ) ;
    oq.update_raid_listitem( raid_tok, raid_name, ilevel, resil, mmr, battlegrounds, tm_, status, has_pword, lead_name, pdata_, type_ ) ;
    if (raid_tok == oq.raid.raid_token) then
      oq.update_my_premade_line() ;
    end
    oq.announce_new_premade( raid_name, nil, raid_tok ) ;
  end
end

function oq.on_premade_stats( raid_token, nMem, avgResil, avgIlevel, wins, losses, avgHonor, avgHks, avgDeaths, dnTime, bg_len, is_source, tm, status, nWait )
  _ok2relay = "bnet" ; -- should only bounce to bn-friends and oqgeneral, if raid-leader not on realm and msg never seen
  local raid = oq.premades[ raid_token ] ;
  if (raid == nil) then
    -- never seen, nothing to do
    return ;
  end
  local s = raid.stats ;
  tm = tonumber(tm) ;
  if ((raid.tm == nil) or (raid.tm < tm)) then
    s.nMembers     = tonumber(nMem) ;
    s.avg_resil    = tonumber(avgResil) ;
    s.avg_ilevel   = tonumber(avgIlevel) ;
    s.nWins        = tonumber(wins) ;
    s.nLosses      = tonumber(losses) ;
    s.avg_honor    = tonumber(avgHonor) ;
    s.avg_hks      = tonumber(avgHks) ;
    s.avg_deaths   = tonumber(avgDeaths) ;
    s.avg_down_tm  = tonumber(dnTime) ;
    s.avg_bg_len   = tonumber(bg_len) ;
    s.status       = tonumber(status) ;
    s.nWaiting     = tonumber(nWait) ;
    if (is_source) then
      raid.tm = tm ; -- so only the latest data is kept
    end
    -- update status 
    local line = oq.find_premade_entry( raid_token ) ;
    if (line ~= nil) then
      if (s.status == 2) or (raid_token == oq.raid.raid_token) then
        -- if inside, disable the waitlist button
        line.req_but:Disable() ;
      else
        line.req_but:Enable() ;
      end
      oq.set_dragon( line, wins ) ;
    end  
  end
end

function oq.set_dragon( line, nwins )
  local tag = nil ;
  local cx = 32 ;
  local cy = 32 ;
  local x  = 169 ;
-- should work, but pushes the panel to the right with each call.  no idea.  might be scaling
--  local x  = floor(line.dragon:GetLeft()) ;
  local y  = 0 ;
  if (nwins >= 5000) then
    tag = "Interface\\Addons\\oqueue\\art\\gold_talpha.tga" ;  -- golden dragon
  elseif (nwins >= 1000) then
    tag = "Interface\\Addons\\oqueue\\art\\silver_talpha.tga" ;  -- silver dragon
  elseif (nwins >= 500) then
    tag = "Interface\\PvPRankBadges\\PvPRank12" ; -- general
    cx = 16 ;
    cy = 16 ;
    y = 4 ;
  elseif (nwins >= 100) then
    tag = "Interface\\PvPRankBadges\\PvPRank06" ; -- knight
    cx = 16 ;
    cy = 16 ;
    y = 4 ;
  end
  line.dragon.texture:SetTexture( tag ) ;
  oq.setpos( line.dragon, x, y, cx, cy ) ;
end

function oq.on_invite_req_response( raid_token, req_token, answer, reason )
  if (not oq.token_was_seen( req_token )) then
    -- multi-boxer can receive same msg if via real-id msg
    _ok2decline = nil ;
    return ;
  end
  if (answer == "N") then
    PlaySound( "RaidWarning" ) ;
    message( string.format( OQ.MSG_REJECT, reason )) ;
  elseif (answer == "Y") then
    PlaySound( "AuctionWindowOpen" ) ;
    local f = oq.find_premade_entry( raid_token ) ;
    if (f ~= nil) then
      f.req_but:SetText( OQ.BUT_PENDING ) ;
      f.req_but:SetBackdropColor( 0.5, 0.5, 0.5, 1 ) ;
      f.pending = true ;
    end
  end
end

function oq.send_invite_response( name, realm, realid, raid_token, req_token, answer, reason )
  oq.timer_oneshot( 2, oq.realid_msg, name, realm, realid, 
                    OQ_MSGHEADER .."".. 
                    OQ_VER ..","..
                    "W1,"..
                    "0,"..
                    "invite_req_response,"..                 
                    raid_token ..","..
                    req_token ..","..
                    answer ..","..
                    (reason or ".")
                  ) ;
end

function oq.on_report_recvd( report, token )
  if (token == nil) or (report == nil) or (OQ_toon.reports == nil) then
    return ;
  end
  local r = OQ_toon.reports[token] ;
  if (r == nil) then
    -- why am i getting this response?
    return ;
  end
  
  r.report_recvd = true ;
  if (r.report_recvd and r.top_dps_recvd and r.top_heals_recvd) then
    OQ_toon.reports[token] = nil ;
  end
end

function oq.on_top_dps_recvd( token )
  if (token == nil) or (OQ_toon.reports == nil) then
    return ;
  end
  local r = OQ_toon.reports[token] ;
  if (r == nil) then
    -- why am i getting this response?
    return ;
  end
  
  r.top_dps_recvd = true ;
  if (r.report_recvd and r.top_dps_recvd and r.top_heals_recvd) then
    OQ_toon.reports[token] = nil ;
  end
end

function oq.on_top_heals_recvd( token )
  if (token == nil) or (OQ_toon.reports == nil) then
    return ;
  end
  local r = OQ_toon.reports[token] ;
  if (r == nil) then
    -- why am i getting this response?
    return ;
  end
  
  r.top_heals_recvd = true ;
  if (r.report_recvd and r.top_dps_recvd and r.top_heals_recvd) then
    OQ_toon.reports[token] = nil ;
  end
end

function oq.is_banned( rid )
  if (rid == nil) or (rid == "") or (rid == "nil") then
--    print( OQ_REDX_ICON .." invalid battle-tag (".. tostring(rid) ..")" ) ;
    return true ;
  end
  if (OQ_data.banned == nil) then
    OQ_data.banned = {} ;
  end
  if (OQ_data.banned[rid] ~= nil) then
    return true ;
  end
  if (OQ.gbl[rid] ~= nil) then
    return true ;
  end
  return nil ;
end

function oq.ban_add( rid, reason_ )
  if (rid == nil) or (rid == "") then
    print( OQ_REDX_ICON .." invalid battle-tag (".. tostring(rid) ..")" ) ;
    return ;
  end
  if (OQ_data.banned == nil) then
    OQ_data.banned = {} ;
  end
  OQ_data.banned[ rid ] = { ts = utc_time(), reason = reason_ } ;  
  
  -- now add to the list
  local f = oq.create_ban_listitem( oq.tab6_list, 1, 1, 200, 22, rid, reason_ ) ;
  table.insert( oq.tab6_banlist, f ) ;
  oq.reshuffle_banlist() ;  
end

function oq.ban_remove( rid )
  if (rid == nil) or (rid == "") then
    print( OQ_REDX_ICON .." invalid battle-tag (".. tostring(rid) ..")" ) ;
    return ;
  end
  if (OQ_data.banned == nil) then
    OQ_data.banned = {} ;
  end
  OQ_data.banned[ rid ] = nil ;
end

function oq.ban_clearall()
  OQ_data.banned = {} ;
end

function oq.is_qualified( level_, faction, resil_, ilevel_, role_, mmr_ )
  local level_min, level_max = oq.get_player_level_range() ;
  if (level_ < level_min) or (level_ > level_max) then
    return (oq.raid.enforce_levels == 0) ;
  end
  if (oq.raid.min_ilevel ~= 0) and (oq.raid.min_ilevel > ilevel_) then
    return nil ;
  end
  if (oq.raid.min_resil ~= 0) and (oq.raid.min_resil > resil_) then
    return nil ;
  end
  if (oq.raid.min_mmr ~= 0) and (oq.raid.min_mmr > mmr_) then
    return nil ;
  end
  return true ;
end

function oq.on_req_invite( raid_token, n_members_, req_token, enc_data, stats, pword )
  if (not oq.iam_raid_leader()) then
    return ;
  end
  -- not my raid
  --
  if (raid_token ~= oq.raid.raid_token) then
    return ;
  end

  local  name_, realm_, realid_ = oq.decode_data( "abc123", enc_data ) ;
  pword      = oq.decode_pword( pword ) ;
  n_members_ = tonumber( n_members_ ) ;
  
  local level_, faction, class_, resil_, ilevel_, role_, mmr_, pvppower_ = oq.decode_short_stats( stats ) ;
  local flags_ = 0 ;
  local hp_ = 0 ;

  if (oq.n_waiting() > OQ_MAX_WAITLIST) then  
    oq.send_invite_response( name_, realm_, realid_, raid_token, req_token, "N", "wait list full" ) ;
    return ;
  elseif (not class_) then
    oq.send_invite_response( name_, realm_, realid_, raid_token, req_token, "N", "invalid class" ) ;
    return ;
  elseif (oq.is_banned( realid_ )) then
    oq.send_invite_response( name_, realm_, realid_, raid_token, req_token, "N", "banned" ) ;
    return ;
  elseif (n_members_ == 1) and (not oq.is_qualified( level_, faction, resil_, ilevel_, role_, mmr_ )) then
    oq.send_invite_response( name_, realm_, realid_, raid_token, req_token, "N", "not qualified" ) ;
    return ;
  elseif (oq.raid.has_pword and (oq.raid.pword ~= pword)) then
    oq.send_invite_response( name_, realm_, realid_, raid_token, req_token, "N", "invalid password" ) ;
    return ;
  end

  if (oq.waitlist == nil) then
    oq.waitlist = {} ;
  end

  -- check to see if the toon is already queue'd
  if (not oq.ok_for_waitlist( name_, realm_ )) then
    return ;
  end

  oq.waitlist[ req_token ] = { name      = name_,
                               class     = class_,
                               realm     = realm_,
                               realid    = realid_,
                               level     = level_,
                               ilevel    = ilevel_,
                               resil     = resil_,
                               flags     = flags_,
                               hp        = hp_,
                               role      = role_,
                               n_members = n_members_,
                               mmr       = mmr_,
                               pvppower  = pvppower_,
                             } ;
  local x, y, cy ;
  x  = 2 ;
  cy = 25 ;
  y  = oq.nwaitlist * (cy + 2) + 10 ;
  oq.nwaitlist = oq.nwaitlist + 1 ;
  
  local f = oq.insert_waitlist_item( x, y, req_token, n_members_, name_, realm_, role_, level_, ilevel_, resil_, class_, mmr_, pvppower_ ) ;
  table.insert( oq.tab7_waitlist, f ) ;
  oq.reshuffle_waitlist() ;
  oq.send_invite_response( name_, realm_, realid_, raid_token, req_token, "Y" ) ;  
  -- play sound to alert raid leader
  PlaySound( "AuctionWindowOpen" ) ;
end

function oq.insert_waitlist_item( x, y, req_token, n_members_, name_, realm_, role_, level_, ilevel_, resil_, class_, mmr_, pvppower_ )
  local f = oq.create_waitlist_item( oq.tab7_list, x, y, oq.tab7_list:GetWidth() - 2*x, 25, req_token, n_members_ ) ;
  f.bgroup.texture:SetTexture( OQ.BGROUP_ICON[oq.find_bgroup(realm_)] ) ;
  if (role_ == 2) then
    f.role:SetText( INLINE_HEALER_ICON ) ;
  elseif (role_ == 4) then
    f.role:SetText( INLINE_TANK_ICON ) ;
  end
  f.create_tm = utc_time() ;
  f.toon_name :SetText( name_ ) ;
  f.realm     :SetText( realm_ ) ;
  f.level     :SetText( level_ ) ;
  f.ilevel    :SetText( ilevel_ ) ;
  f.resil     :SetText( resil_ ) ;
  f.mmr       :SetText( mmr_ ) ;
  f.pvppower  :SetText( pvppower_ ) ;
  f.toon_name :SetTextColor( OQ.CLASS_COLORS[class_].r, OQ.CLASS_COLORS[class_].g, OQ.CLASS_COLORS[class_].b, 1 ) ;
-- 
-- set texture for role (might not work as ppl can't set role without a party/raid)
--
  f.req_token = req_token ;
  return f ;
end

function oq.update_wait_times()
  local now = utc_time() ;
  for i,v in pairs(oq.tab7_waitlist) do
    v.wait_tm:SetText( date("!%H:%M:%S", (now - v.create_tm) )) ;
  end
end

function oq.on_req_waitlist( raid_token, stats, req_token, enc_data )
  oq.on_req_waitlist_party( raid_token, stats, 1, req_token, enc_data ) ;
end

function oq.ok_for_waitlist( name, realm )
  -- check to see if the toon is already queue'd
  for i,v in pairs(oq.waitlist) do
    if ((name == v.name) and (realm == v.realm)) then
      return nil ;
    end
  end
  -- or already in the group
  
  for i=1,8 do
    for j=1,5 do
      local mem = oq.raid.group[i].member[j] ;
      if (mem.name == name) and (mem.realm == realm) and (mem.class ~= "XX") then
        return nil ;
      end
    end
  end
  return true ;
end

function oq.on_req_waitlist_party( raid_token, stats, n_members_, req_token, enc_data )
  -- only raid leader can respond
  --
  if (not oq.iam_raid_leader()) then
    return ;
  end
  -- not my raid
  --
  if (raid_token ~= oq.raid.raid_token) then
    return ;
  end

  local  name_, realm_, realid_ = oq.decode_data( "abc123", enc_data ) ;
  
  local g_id, slot, level_, faction, class_, race_, gender_, bg1, s1, bg2, s2, resil_, ilevel_, flags_, hp_, 
        role_, charm_, xflags_, wins_, losses_, hks_, oq_ver_, tears_, pvppower_, mmr_ = oq.decode_stats( stats ) ;
  if (not class_) then
    return ;
  end

  if (oq.waitlist == nil) then
    oq.waitlist = {} ;
  end

  -- check to see if the toon is already queue'd
  if (not oq.ok_for_waitlist( name_, realm_ )) then
    return ;
  end

  oq.waitlist[ req_token ] = { name      = name_,
                               class     = class_,
                               race      = race_,
                               gender    = gender_,
                               realm     = realm_,
                               realid    = realid_,
                               level     = level_,
                               ilevel    = ilevel_,
                               resil     = resil_,
                               flags     = flags_,
                               hp        = hp_,
                               role      = role_,
                               n_members = n_members_,
                               charm     = charm_,
                               xflags    = xflags_,
                               wins      = wins_,
                               losses    = losses_,
                               hks       = hks_,
                               oq_ver    = oq_ver_,
                               tears     = tears_,
                               pvppower  = pvppower_,
                               mmr       = mmr_,
                             } ;
  local x, y, cy ;
  x  = 2 ;
  cy = 25 ;
  y  = oq.nwaitlist * (cy + 2) + 10 ;
  oq.nwaitlist = oq.nwaitlist + 1 ;

  local f = oq.create_waitlist_item( oq.tab7_list, x, y, oq.tab7_list:GetWidth() - 2*x, cy, req_token, n_members_ ) ;
  f.bgroup.texture:SetTexture( OQ.BGROUP_ICON[oq.find_bgroup(realm_)] ) ;
  f.toon_name     :SetText( name_ ) ;
  f.realm         :SetText( realm_ ) ;
  f.level         :SetText( level_ ) ;
  f.ilevel        :SetText( ilevel_ ) ;
  f.resil         :SetText( resil_ ) ;
  f.mmr           :SetText( "" ) ; -- doesn't make sense for a party
  f.pvppower      :SetText( "" ) ; -- doesn't make sense for a party
  f.toon_name     :SetTextColor( OQ.CLASS_COLORS[class_].r, OQ.CLASS_COLORS[class_].g, OQ.CLASS_COLORS[class_].b, 1 ) ;
-- 
-- set texture for role (might not work as ppl can't set role without a party/raid)
--
  f.req_token = req_token ;
  table.insert( oq.tab7_waitlist, f ) ;

  oq.reshuffle_waitlist() ;
end

function oq.start_role_check()
  oq.boss_announce( "role_check" ) ;
  InitiateRolePoll() ;
end

function oq.start_ready_check()
  oq.raid_announce( "ready_check" ) ;
  oq.on_ready_check() ;
end

function oq.brb()
  if (oq.raid.raid_token == nil) or (my_group == 0) or (my_slot == 0) then
    return ;
  end
  oq.raid_announce( "brb,".. oq.raid.raid_token ..",".. my_group ..",".. my_slot ) ;
  player_away = true ;
  oq.on_brb( oq.raid.raid_token, my_group, my_slot ) ;
  
  oq.brb_dlg() ;
  if ((oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID)) then
    SendChatMessage( "brb", "RAID", nil ) ;  
  else
    SendChatMessage( "brb", "PARTY", nil ) ;  
  end
end

function oq.iam_back()
  player_away = nil ;
  oq.raid_announce( "iam_back,".. oq.raid.raid_token ..",".. my_group ..",".. my_slot ) ;
  oq.on_iam_back( oq.raid.raid_token, my_group, my_slot ) ;
  if ((oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID)) then
    SendChatMessage( "back", "RAID", nil ) ;  
  else
    SendChatMessage( "back", "PARTY", nil ) ;  
  end
end

function oq.on_brb( raid_token, g_id, slot )
  if (raid_token ~= oq.raid.raid_token) then
    return ;
  end
  g_id = tonumber( g_id ) ;
  slot = tonumber( slot ) ;

  if (g_id <= 0) or (slot <= 0) then
    return ;
  end
  local m = oq.raid.group[g_id].member[slot] ;
  m.flags = oq.bset( m.flags, OQ_FLAG_BRB, true ) ;
  oq.set_textures( g_id, slot ) ;
end

function oq.on_iam_back( raid_token, g_id, slot )
  if (raid_token ~= oq.raid.raid_token) then
    return ;
  end
  g_id = tonumber( g_id ) ;
  slot = tonumber( slot ) ;

  if (g_id <= 0) or (slot <= 0) then
    return ;
  end
  local m = oq.raid.group[g_id].member[slot] ;
  m.flags = oq.bset( m.flags, OQ_FLAG_BRB, nil ) ;
  oq.set_textures( g_id, slot ) ;
end

function oq.ready_check_complete()
  oq.on_ready_check_complete() ;
end

function oq.on_ready_check()
  local ngroups = oq.nMaxGroups() ;
  for grp=1,ngroups do
    for s=1,5 do
      oq.raid.group[grp].member[s].check = OQ_FLAG_WAITING ;
      oq.set_textures( grp, s ) ;
    end
  end

  if (oq.iam_raid_leader()) then
    oq.ready_check( my_group, my_slot, OQ_FLAG_READY ) ;
    oq.timer( "rdycheck_end", 30, oq.ready_check_complete ) ;
    return ;
  end
  local dialog = StaticPopup_Show("OQ_ReadyCheck", nil, nil, ndx ) ;
  last_group_brief = 0 ; -- force the update for ready-check status
  oq.timer( "rdycheck_end", 30, oq.ready_check_complete ) ;
end

function oq.on_role_check()
  if (not oq.iam_party_leader()) then
    return ;
  end
  InitiateRolePoll() ;
end

function oq.nMembers() 
  if (oq.raid.type ~= OQ.TYPE_BG) then
    return max( 1, GetNumGroupMembers() ) ;
  end
  local i, j, nMembers ;
  nMembers = 0 ;
  for i=1,8 do
    for j=1,5 do
      local m = oq.raid.group[i].member[j] ;
      if ((m.name ~= nil) and (m.name ~= "-")) then
        nMembers = nMembers + 1 ;
      end
    end
  end
  return nMembers ;
end

function oq.strrep(value, insert, place)
  if (value == nil) then
    return insert ;
  end
  if place == nil or (place > #value) then
    place = string.len(value)+1
  elseif (place <= 0) then
    place = 1 ;
  end
  return string.sub( value, 1, place-1) .. insert .. string.sub( value, place+1, -1 ) ;
end


-- premade data 
-- this is data specific to the premade type
-- 
function oq.get_pdata()
  local pdata = "-----" ;
  if (oq.raid.type == OQ.TYPE_DUNGEON) then
    local n = 0 ;
    for i=1,5 do
      local m = oq.raid.group[1].member[i] ;
      if (m.name ~= nil) and (m.name ~= "-") then 
        if (OQ.ROLES[ m.role ] == "TANK") then
          pdata = oq.strrep( pdata, "T", 1 ) ;
        elseif (OQ.ROLES[ m.role ] == "HEALER") then
          pdata = oq.strrep( pdata, "H", 2 ) ;
        else
          pdata = oq.strrep( pdata, "D", 3 + n ) ;
          n = n + 1 ;
        end
      end
    end
  elseif (oq.raid.type == OQ.TYPE_SCENARIO) then
    local n = 0 ;
    pdata = "---" ;
    for i=1,3 do
      local m = oq.raid.group[1].member[i] ;
      if (m.name ~= nil) and (m.name ~= "-") then 
        if (OQ.ROLES[ m.role ] == "TANK") then
          pdata = oq.strrep( pdata, "T", i ) ;
        elseif (OQ.ROLES[ m.role ] == "HEALER") then
          pdata = oq.strrep( pdata, "H", i ) ;
        else
          pdata = oq.strrep( pdata, "D", i ) ;
          n = n + 1 ;
        end
      end
    end
  else
    local ntanks, nheals, ndps = oq.get_n_roles() ;
    pdata = oq.encode_mime64_1digit(ntanks) .."".. oq.encode_mime64_1digit(nheals) .."".. oq.encode_mime64_1digit(ndps) ;
  end
  return pdata ;
end

function oq.calc_raid_stats()
  local nMembers = oq.nMembers() ;
  local resil    = 0 ;
  local ilevel   = 0 ;
  local nWaiting = oq.n_waiting() ;
  
  for i=1,8 do
    for j=1,5 do
      local mem = oq.raid.group[i].member[j] ;
      if ((mem ~= nil) and (mem.name ~= nil) and (mem.name ~= "-")) then
        if ((mem.ilevel == 0) and (mem.name == player_name)) then
          mem.ilevel = player_ilevel ;
          mem.resil  = player_resil ;
        end
        resil    = resil  + (mem.resil  or 0) ;
        ilevel   = ilevel + (mem.ilevel or 0) ;
      end
    end
  end
  if (nMembers == 0) then
    return 0, 0, 0, 0 ;
  end
  return  nMembers, floor(resil / nMembers), floor(ilevel / nMembers), nWaiting ;
end

function oq.update_tab1_stats()
  local nMembers, avg_resil, avg_ilevel = oq.calc_raid_stats() ;

  if (nMembers == 0) then
    oq.tab1_raid_stats:SetText( "0 / - / -" ) ;
  else
    oq.tab1_raid_stats:SetText( nMembers .." / ".. avg_resil .." / ".. avg_ilevel ) ;
  end
end

function oq.update_tab3_info()
  if ((oq.raid.raid_token == nil) or (not oq.iam_raid_leader())) then
    return ;
  end
  oq.tab3_raid_name :SetText( oq.raid.name ) ;
  oq.tab3_lead_name :SetText( player_name ) ;
  oq.tab3_rid       :SetText( player_realid or "" ) ;
  oq.tab3_min_ilevel:SetText( oq.raid.min_ilevel or 0 ) ;
  oq.tab3_min_resil :SetText( oq.raid.min_resil or 0 ) ;
  oq.tab3_min_mmr   :SetText( oq.raid.min_mmr or 0 ) ;
  oq.tab3_bgs       :SetText( oq.raid.bgs or "" ) ;
  oq.tab3_notes     :SetText( oq.raid.notes or "" ) ;
  oq.tab3_pword     :SetText( oq.raid.pword or "" ) ;
  
  oq.tab3_set_radiobutton( oq.raid.type ) ;
end

function oq.bset( flags, mask, set )
  flags = bit.bor( flags, mask ) ;
  if ((set == nil) or (set == 0) or (set == false)) then
    flags = bit.bxor( flags, mask ) ;
  end
  return flags ;
end

function oq.is_set( flags, mask )
  if (bit.band( flags, mask ) ~= 0) then
    return true ;
  end
  return nil ;
end

function oq.refresh_textures() 
  local ngroups = oq.nMaxGroups() ;
  for i=1,ngroups do
    for j=1,5 do
      oq.set_textures( i, j ) ;
    end
  end
end

function oq.set_textures( g_id, slot )
  if (oq.raid.type == nil) then
    return ;
  end
  g_id = tonumber( g_id ) ;
  slot = tonumber( slot ) ;
  if (g_id == nil) or (slot == nil) then
    return ;
  end
  local m     = oq.raid.group[g_id].member[slot] ;
  if (m == nil) then
    return ;
  end
  if (oq.raid.type == OQ.TYPE_BG) then
    oq.set_textures_cell( m, oq.tab1_group[g_id].slots[slot] ) ; -- bgs
  end
  if (oq.raid.type == OQ.TYPE_RAID) then
    oq.set_textures_cell( m, oq.raid_group[g_id].slots[slot] ) ; -- raid
  end
  if (oq.raid.type == OQ.TYPE_RBG) then
    oq.set_textures_cell( m, oq.rbgs_group[g_id].slots[slot] ) ; -- rbgs
  end
  if (oq.raid.type == OQ.TYPE_ARENA) then
    oq.set_textures_cell( m, oq.arena_group.slots[slot]   ) ; -- scenario
  end
  if (oq.raid.type == OQ.TYPE_DUNGEON) then
    oq.set_textures_cell( m, oq.dungeon_group.slots[slot] ) ; -- dungeon
  end
  if (oq.raid.type == OQ.TYPE_SCENARIO) then
    oq.set_textures_cell( m, oq.scenario_group.slots[slot]   ) ; -- scenario
  end
end

function oq.get_model_standin( gender, race )
  local fname = "Models/Character/" ;
  for i,v in pairs(OQ.RACE) do
    if (v == race) then
      fname = fname .."".. i ;
      break ;
    end
  end
  if (gender == 0) then
    fname = fname .."".. "Male" ;
  else
    fname = fname .."".. "Female" ;
  end
  return fname .."".. ".m2" ;  
end

function oq.set_player_model( panel, name, gender, race )
  if (panel.model_frame == nil) then
    oq.nmodels = (oq.nmodels or 0) + 1 ;
    panel.model_frame = oq.CreateFrame("Button", "OQModelFrame".. oq.nmodels, panel ) ;
    panel.model_frame:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                                  edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                                  tile=true, tileSize = 16, edgeSize = 16,
                                  insets = { left = 1, right = 1, top = 1, bottom = 1 }
                                 })
    panel.model_frame:SetBackdropColor(0.0,0.0,0.0,1.0);
    panel.model_frame:SetAlpha( 0.8 ) ;
    panel.model_frame:Show() ;
    oq.setpos( panel.model_frame, 0,  0, panel:GetWidth(),  panel:GetHeight()-17 ) ;
    if (panel.model == nil) then
      panel.model = oq.CreateFrame("DressUpModel", "OQModel".. oq.nmodels, panel.model_frame ) ;
      panel.model:SetAllPoints( panel.model_frame ) ;
      panel.model:SetModelScale(1) ;
      panel.model:SetPosition(0,0,0) ;
      panel.model:Show() ;
    end
  end
  if (panel._model == name) and (name ~= nil) then
    local fname = panel.model:GetModel() ;
    if (fname == "") then
      -- out of range
      panel.model:ClearModel() ;
      panel._model = nil ;
    end
  end
  if (panel._model == nil) or (panel._model ~= name) then
    panel.model:ClearModel() ;
    if (name) then
      panel.model:SetUnit( name ) ;
      panel.model:Show() ;
      panel._model = name ;
      local fname = panel.model:GetModel() ;
      if (fname == "") and ((gender ~= nil) and (race ~= nil)) then
        fname = oq.get_model_standin( gender, race ) ;
        panel._model = nil ;
        panel.model:ClearModel() ;
        panel.model:SetModel( fname ) ;
        panel.model:SetAlpha(0.75) ;    
      end
      panel.model_frame:Show() ;
    else
      panel.model_frame:Hide() ;
      panel.model:Hide() ;
    end 
  else
    panel.model_frame:Show() ;
    panel.model:Show() ;
  end
end

function oq.set_textures_cell( m, cell )
  if (m == nil) or (cell == nil) then
    if (cell ~= nil) and (cell.texture ~= nil) and ((oq.raid.type == OQ.TYPE_DUNGEON) or (oq.raid.type == OQ.TYPE_SCENARIO) or (oq.raid.type == OQ.TYPE_ARENA)) then
      cell.texture:SetPoint("TOPLEFT", cell.model_frame,"TOPLEFT", 2, -3) ;
      cell.texture:SetPoint("BOTTOMRIGHT", cell.model_frame,"BOTTOMRIGHT", -2, 3) ;
    end
    return ;
  end
  local color = OQ.CLASS_COLORS["XX"] ;

  -- set color of cell
  if ((m.class ~= nil) and oq.is_set( m.flags, OQ_FLAG_ONLINE ) and (OQ.CLASS_COLORS[m.class] ~= nil)) then
    color = OQ.CLASS_COLORS[m.class] ;
  end
  if (color ~= nil) then
    cell.texture:SetTexture( color.r, color.g, color.b, 1 ) ;
  else
    -- should not get here
  end

  if ((m.name == nil) or (m.name == "") or (m.name == "-")) then
    -- unused slot
    cell.status:SetTexture( nil ) ;
    cell.class :SetTexture( nil ) ;
    cell.role  :SetTexture( nil ) ;
    cell.charm :SetTexture( nil ) ;
    oq.set_player_model( cell, nil, nil, nil ) ;
    if (cell.texture ~= nil) and ((oq.raid.type == OQ.TYPE_DUNGEON) or (oq.raid.type == OQ.TYPE_SCENARIO) or (oq.raid.type == OQ.TYPE_ARENA)) then
      cell.texture:SetPoint("TOPLEFT", cell.model_frame,"TOPLEFT", 2, -3) ;
      cell.texture:SetPoint("BOTTOMRIGHT", cell.model_frame,"BOTTOMRIGHT", -2, 3) ;
    end
    return ;
  end

  -- set overlap state
  if (m.check == nil) then
    m.check = OQ_FLAG_CLEAR ;
  end
  if (m.check == OQ_FLAG_WAITING) then
    cell.status:SetTexCoord( 0, 1.0, 0.0, 1.0 ) ; 
    cell.status:SetTexture( "Interface\\RAIDFRAME\\ReadyCheck-Waiting" ) ;
  elseif (m.check == OQ_FLAG_READY) then
    cell.status:SetTexCoord( 0, 1.0, 0.0, 1.0 ) ; 
    cell.status:SetTexture( "Interface\\RAIDFRAME\\ReadyCheck-Ready" ) ;
  elseif (m.check == OQ_FLAG_NOTREADY) then
    cell.status:SetTexCoord( 0, 1.0, 0.0, 1.0 ) ; 
    cell.status:SetTexture( "Interface\\RAIDFRAME\\ReadyCheck-NotReady" ) ;
  elseif (not oq.is_set( m.flags, OQ_FLAG_ONLINE )) then
    cell.status:SetTexCoord( 0, 1.0, 0.0, 1.0 ) ; 
    cell.status:SetTexture( "Interface\\CHARACTERFRAME\\Disconnect-Icon" ) ; -- "Interface\\GuildFrame\\GuildLogo-NoLogoSm" ) ;
  elseif (oq.is_set( m.flags, OQ_FLAG_BRB )) then
    cell.status:SetTexCoord( 0, 0.50, 0.0, 0.50 ) ; 
    cell.status:SetTexture( "Interface\\CHARACTERFRAME\\UI-StateIcon" ) ; -- Interface\\RAIDFRAME\\ReadyCheck-Waiting" ) ;
  elseif (oq.is_set( m.flags, OQ_FLAG_DESERTER )) then
    cell.status:SetTexCoord( 0, 1.0, 0.0, 1.0 ) ; 
    cell.status:SetTexture( "Interface\\Icons\\Ability_Druid_Cower" ) ;
  elseif (oq.is_set( m.flags, OQ_FLAG_QUEUED )) then
    cell.status:SetTexCoord( 0, 1.0, 0.0, 1.0 ) ; 
    if (player_faction == "A") then
      cell.status:SetTexture( "Interface\\BattlefieldFrame\\Battleground-Alliance" ) ;
    else
      cell.status:SetTexture( "Interface\\BattlefieldFrame\\Battleground-Horde" ) ;
    end
  else
    cell.status:SetTexture( nil ) ;
  end

  -- set role
  if (oq.is_set( m.flags, OQ_FLAG_TANK )) then
    cell.role:SetTexture( "Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES" ) ;
    cell.role:SetTexCoord( 0, 19/64, 22/64, 41/64 ) ;
  elseif (oq.is_set( m.flags, OQ_FLAG_HEALER )) then
    cell.role:SetTexture( "Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES" ) ;
    cell.role:SetTexCoord( 20/64, 39/64, 1/64, 20/64 ) ;
  elseif ((oq.raid.type == OQ.TYPE_DUNGEON) or (oq.raid.type == OQ.TYPE_SCENARIO) or (oq.raid.type == OQ.TYPE_ARENA)) then
    cell.role:SetTexture( "Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES" ) ;
    cell.role:SetTexCoord( 20/64, 39/64, 22/64, 41/64 ) ;
  else
    cell.role:SetTexture( nil ) ; 
  end
  
  -- set model (dungeons & scenarios)
  if (m.realm_id == nil) then
    m.realm_id = 0 ;
  end
  m.realm_id = tonumber(m.realm_id) ;

  if (cell.class ~= nil) and (m.realm_id > 0) and ((oq.raid.type == OQ.TYPE_DUNGEON) or (oq.raid.type == OQ.TYPE_SCENARIO) or (oq.raid.type == OQ.TYPE_ARENA)) then
    local name = m.name ;
    if (m.realm_id ~= player_realm_id) then
      name = name .."-".. oq.realm_uncooked(m.realm_id) ;
    end
    if (name ~= nil) then
      oq.set_player_model( cell, name, m.gender, m.race ) ;
    end
    if (cell.texture ~= nil) then
      cell.texture:SetPoint("TOPLEFT", cell.model_frame,"TOPLEFT", 2, -3) ;
      cell.texture:SetPoint("BOTTOMRIGHT", cell.model_frame,"BOTTOMRIGHT", -2, 3) ;
    end
  end

  -- set lucky charm
  if (cell.charm ~= nil) then
--    cell.charm:SetTexCoord( 0,0.25,0,0.5 );
    cell.charm:SetTexture( "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcons" ) ;
    cell.charm:SetTexCoord( unpack(OQ.ICON_COORDS[ m.charm or 0 ]) ); 
--    cell.charm:SetTexCoord( 0,0.25,0,0.25 );
  end
end

function oq.set_status( g_id, slot, deserter, queued, online )
  g_id = tonumber( g_id ) ;
  slot = tonumber( slot ) ;
  if ((g_id <= 0) or (slot <= 0)) then
    return ;
  end

  local m = oq.raid.group[g_id].member[slot] ;
  local old_stat = m.flags ;

  m.flags = oq.bset( m.flags, OQ_FLAG_DESERTER, deserter ) ;
  m.flags = oq.bset( m.flags, OQ_FLAG_QUEUED  , queued ) ;
  m.flags = oq.bset( m.flags, OQ_FLAG_ONLINE  , online ) ;

  oq.set_textures( g_id, slot ) ;
end

function oq.gather_my_stats() 
  oq.check_for_deserter() ;
  player_ilevel   = oq.get_ilevel() ;
  player_resil    = oq.get_resil() ;
  if (player_realm_id == nil) or (player_realm_id == 0) then
    player_realm_id = oq.realm_cooked( player_realm ) ;
  end

--  local v = { UnitAura("player", "Deserter", nil, "PLAYER|HARMFUL") } ;
--  player_deserter = (v[1] ~= nil) ;

  local s1 = OQ.QUEUE_STATUS[ select(1, GetBattlefieldStatus(1)) ] ;
  local s2 = OQ.QUEUE_STATUS[ select(1, GetBattlefieldStatus(2)) ] ;
  local old_q = player_queued ;
  player_queued = ((s1 ~= "0") or (s2 ~= "0")) ;
  player_online = true ;

  -- send out update if queue status changed
  if (player_queued and (old_q ~= player_queued) and (not _inside_bg)) then
    PlaySound("PVPENTERQUEUE") ;
-- this is on a 60 sec timer
--    oq.send_my_premade_info() ;
  end

  if ((my_group <= 0) or (my_slot <= 0)) then
    return ;
  end
  local me = oq.raid.group[ my_group ].member[ my_slot ] ;
  me.bg[1].status = OQ.QUEUE_STATUS[ select(1, GetBattlefieldStatus(1)) ] ;
  me.bg[2].status = OQ.QUEUE_STATUS[ select(1, GetBattlefieldStatus(2)) ] ;
  me.gender, me.race = oq.player_demographic() ;  

  me.flags = 0 ; -- reset to 0
  me.flags = oq.bset( me.flags, OQ_FLAG_DESERTER, player_deserter ) ;
  me.flags = oq.bset( me.flags, OQ_FLAG_QUEUED  , player_queued ) ;
  me.flags = oq.bset( me.flags, OQ_FLAG_ONLINE  , player_online ) ;
  me.flags = oq.bset( me.flags, OQ_FLAG_BRB     , player_away ) ;
  if (player_role == OQ.ROLES["TANK"]) then
    me.flags = oq.bset( me.flags, OQ_FLAG_TANK  , true ) ;
  elseif (player_role == OQ.ROLES["HEALER"]) then
    me.flags = oq.bset( me.flags, OQ_FLAG_HEALER, true ) ;
  end
  
  if (me.check == nil) then
    me.check = OQ_FLAG_CLEAR ;
  end

  oq.set_role( my_group, my_slot, player_role ) ;

  me.resil    = player_resil ;
  me.ilevel   = player_ilevel ;
  me.hp       = floor(UnitHealthMax("player")/1000) ;
  me.wins     = OQ_toon.wins or 0 ;
  me.losses   = OQ_toon.losses or 0 ;
  local hks = GetStatistic(588) ;
  if (hks == "--") then
    hks = 0 ;
  end
  me.hks      = floor(hks / 1000) ;  
  me.oq_ver   = oq.get_version_id() ;
  me.tears    = OQ_data.stats.tears or 0 ;
  me.pvppower = oq.get_pvppower() ;
  me.mmr      = oq.get_mmr() ;
  --
  -- note: statistic id list
  --       http://www.wowwiki.com/Complete_list_of_Achievement_ID%27s
  --       588   Total Honorable Kills 
end

function oq.set_deserter( g_id, slot, deserter ) 
  if ((g_id <= 0) or (slot <= 0)) then
    return ;
  end
  local m = oq.raid.group[g_id].member[slot] ;

  m.flags = oq.bset( m.flags, OQ_FLAG_DESERTER, deserter ) ;

  oq.set_textures( g_id, slot ) ;
end

function oq.set_status_queued( g_id, slot, queued ) 
  if ((g_id <= 0) or (slot <= 0)) then
    return ;
  end
  local m = oq.raid.group[g_id].member[slot] ;

  m.flags = oq.bset( m.flags, OQ_FLAG_QUEUED, queued ) ;

  oq.set_textures( g_id, slot ) ;
end

function oq.set_status_online( g_id, slot, online ) 
  if ((g_id <= 0) or (slot <= 0)) then
    return ;
  end
  local m = oq.raid.group[g_id].member[slot] ;

  m.flags = oq.bset( m.flags, OQ_FLAG_ONLINE, online ) ;

  oq.set_textures( g_id, slot ) ;
end

function oq.set_role( g_id, slot, role ) 
  if ((g_id <= 0) or (slot <= 0)) then
    return ;
  end
  local m = oq.raid.group[g_id].member[slot] ;
  m.role = role ;

  if (role == OQ.ROLES["TANK"]) then
    m.flags = oq.bset( m.flags, OQ_FLAG_HEALER, false ) ;
    m.flags = oq.bset( m.flags, OQ_FLAG_TANK  , true  ) ;
  elseif (role == OQ.ROLES["HEALER"]) then
    m.flags = oq.bset( m.flags, OQ_FLAG_HEALER, true  ) ;
    m.flags = oq.bset( m.flags, OQ_FLAG_TANK  , false ) ;
  else
    m.flags = oq.bset( m.flags, OQ_FLAG_HEALER, false ) ;
    m.flags = oq.bset( m.flags, OQ_FLAG_TANK  , false ) ;
  end
  oq.set_textures( g_id, slot ) ;
end

function oq.scores_init_bgs()
  oq.scores.bg = {} ;
  oq.scores.bg[ "AB"   ] = 50 ;
  oq.scores.bg[ "AV"   ] = 50 ;
  oq.scores.bg[ "BFG"  ] = 50 ;
  oq.scores.bg[ "EotS" ] = 50 ;
  oq.scores.bg[ "IoC"  ] = 50 ;
  oq.scores.bg[ "SotA" ] = 50 ;
  oq.scores.bg[ "TP"   ] = 50 ;
  oq.scores.bg[ "WSG"  ] = 50 ;
end

function oq.scores_init()
  -- no acct level data, initialize
  OQ_data.scores = {} ;
  oq.scores = OQ_data.scores ;
  oq.scores = { ngames = 0, horde = 0, alliance = 0 } ;
  oq.scores_init_bgs() ;
  oq.scores.timeleft       = 1 * 60*60 ;
  oq.scores.end_round_tm   = utc_time() + oq.scores.timeleft ;
  oq.scores.start_round_tm = oq.scores.end_round_tm - (7 * 24 * 60 * 60) ;
  oq.scores.time_lag       = 0 ;
  oq.update_scores() ;
end

function oq.on_scores( enc_data, sk_time, curr_oq_version )
  local args = { enc_data:match( "([0-9A-F]*).([0-9A-F]*).([0-9A-F]*).([0-9A-F]*).([0-9A-F]*).([0-9A-F]*).([0-9A-F]*).([0-9A-F]*).([0-9A-F]*).([0-9A-F]*).([0-9A-F]*).([0-9A-F]*).([0-9A-F]*).([0-9A-F]*).([0-9A-F]*)" ) } ;
  for i,v in pairs(args) do
    args[i] = tonumber( v, 16 ) ;
  end
  sk_time = tonumber( sk_time or 0, 16 ) ;
  
  if (oq._sktime_notice_tm == nil) then
    oq._sktime_notice_tm = 0 ;
  end ;
  if (oq._sktime_last_tm == nil) then
    oq._sktime_last_tm = 0 ;
  end
    
  if (oq._sktime_last_tm > 0) and (sk_time > 0) and (sk_time < oq._sktime_last_tm) then
    -- old score info, drop
    _ok2relay = nil ;  -- do not relay 
    return ;
  end
  local now = utc_time() ;
  -- to do: compare sk_time with now to see if there is a significant difference.  if so, alert user
  -- to do: insure user notification does not happen more then once per hour or so
  local dt = abs(now - sk_time) ;
  if (sk_time > 0) and (dt > 5*60) and (now > oq._sktime_notice_tm) then
    -- spit out notice only once per 5 minute interval
    print( OQ_LILREDX_ICON .." ".. string.format( OQ.TIMEERROR_1, oq.render_tm( dt ) ) ) ;
    print( OQ_LILREDX_ICON .." ".. OQ.TIMEERROR_2 ) ;
    oq._sktime_notice_tm = now + 5*60 ; -- notify every 5 minutes
  end
  oq._sktime_last_tm = sk_time ; -- holding onto the last sk time
  oq._sktime_last_dt = dt ; -- holding onto the last dtime

  -- update score info
  if (oq.scores == nil) then
    oq.scores = {} ;
  end
  if (oq.scores.bg == nil) then
    oq.scores.bg = {} ;
  end
  oq.scores.bg[ "AB"   ] = args[ 1] ;
  oq.scores.bg[ "AV"   ] = args[ 2] ;
  oq.scores.bg[ "BFG"  ] = args[ 3] ;
  oq.scores.bg[ "EotS" ] = args[ 4] ;
  oq.scores.bg[ "IoC"  ] = args[ 5] ;
  oq.scores.bg[ "SotA" ] = args[ 6] ;
  oq.scores.bg[ "TP"   ] = args[ 7] ;
  oq.scores.bg[ "WSG"  ] = args[ 8] ;
  oq.scores.bg[ "SSM"  ] = args[ 9] ;
  oq.scores.bg[ "ToK"  ] = args[10] ;
  oq.scores.horde        = args[11] ;
  oq.scores.alliance     = args[12] ;
  oq.scores.ngames       = args[13] ;
  oq.scores.timeleft     = args[14] ;
  oq.scores.end_round_tm = args[15] ;  
  
  local local_tmleft = oq.scores.end_round_tm - now ;
  oq.scores.time_lag = (oq.scores.timeleft - local_tmleft) ;
  oq.scores.start_round_tm = oq.scores.end_round_tm - (7 * 24 * 60 * 60) ;
  
  oq.update_scores() ;
  
  -- check current version against sk version
  oq.verify_version( OQ_VER, curr_oq_version ) ;
end

function oq.verify_version( proto_version, oq_version ) 
  if (proto_version == nil) or (oq_version == nil) then
    return ;
  end
  if (proto_version == OQ_VER) and (oq_version == OQ_VERSION) then
    if (oq.version_marquee ~= nil) then
      oq.version_marquee:Hide() ;
    end
    return ;
  end
  -- older or newer?
  local major = tonumber(oq_version:sub(1,1)) ;
  local minor = tonumber(oq_version:sub(2,2)) ;
  local rev   = tonumber(oq_version:sub(3,3)) ;
  if (major == nil) or (minor == nil) or (rev == nil) then
    -- all digits, no alpha allowed
    if (oq.version_marquee ~= nil) then
      oq.version_marquee:Hide() ;
    end
    return ;
  end
  local ver = major * 100 + minor * 10 + rev ; -- ie: 107
  local my_ver = OQ_MAJOR * 100 + OQ_MINOR * 10 + OQ_REVISION  ;
  if (ver <= my_ver) then
    if (oq.version_marquee ~= nil) then
      oq.version_marquee:Hide() ;
    end
    return ;
  end
  local is_required = (proto_version ~= OQ_VER) ;
  -- update ui component to reflect new version
  oq.version_marquee = oq.create_version_marquee() ;
  oq.version_marquee.line_1:SetText( string.format( OQ.DLG_18a, major, minor, rev )) ;
  if (is_required) then
    oq.version_marquee.line_2:SetText( OQ.DLG_18b ) ;
    oq.version_marquee:SetHeight(65) ;
    oq.version_marquee.line_2:Show() ;
  else
    oq.version_marquee:SetHeight(35) ;
    oq.version_marquee.line_2:Hide() ;
  end
  oq.version_marquee:Show() ;
  if (oq._fanfare_queued == nil) then
    oq._fanfare_queued = 1 ;
    -- will check every second to see if the marquee is up, and when it is 
    -- it'll play the fanfare and stop the timer
    oq.timer( "fanfare", 1, oq.new_version_fanfare, true ) ;
  end
end

function oq.new_version_fanfare()
  if (not oq.version_marquee:IsVisible()) then
    return nil ;
  end
  oq.excited_cheer() ;
  return 1 ;
end

function oq.create_version_marquee()
  if (oq.version_marquee ~= nil) then
    return oq.version_marquee ;
  end
  
  local cx = 300 ;
  local cy = 65 ;
  local parent = OQMainFrame ;
  local x = floor(parent:GetWidth() - cx)/2 ;
  local y = parent:GetHeight() - 2*cy ;

  local f = oq.panel( parent, "OQVerMarquee", x, y, cx, cy ) ;
  f:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                          edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                          tile=true, tileSize = 16, edgeSize = 16,
                          insets = { left = 4, right = 3, top = 4, bottom = 3 }
                         })
  f:SetBackdropColor(0.2,0.2,0.2,1.0);
  f:SetFrameLevel( f:GetFrameLevel() + 100 ) ; -- top
  
  f.line_1 = oq.label( f, 10, 10, cx-2*10, 22, "new version available", "TOP", "CENTER", font ) ;
  f.line_1:SetFont(OQ.FONT, 14, "") ;
  f.line_2 = oq.label( f, 10, 35, cx-2*10, 22, "required", "TOP", "CENTER", font ) ;
  f.line_2:SetFont(OQ.FONT, 14, "") ;
  return f ;
end

function oq.fmt_time( t )
  if (t == nil) then
    t = 0 ;
  end
  local hrs = floor( t / (60*60)) ;
  local min = floor( t / 60 ) % 60 ;
  return string.format( "%d:%02d", hrs, min ) ;
end

function oq.update_scores()
  if (oq.scores.start_round_tm == nil) or (oq.scores.end_round_tm == nil) then
    if (oq.scores.timeleft == nil) then
      oq.scores.timeleft     = 1 * 60*60 ;
    end
    oq.scores.end_round_tm   = utc_time() + oq.scores.timeleft ;
    oq.scores.start_round_tm = oq.scores.end_round_tm - (7 * 24 * 60 * 60) ;
  end
  
  -- update UI elements
  oq.tab4_horde_score   :SetText( oq.scores.horde    ) ;
  oq.tab4_alliance_score:SetText( oq.scores.alliance ) ;
  
  oq.marquee.horde_score   :SetText( oq.scores.horde    ) ;
  oq.marquee.alliance_score:SetText( oq.scores.alliance ) ;
  
  -- won't call the function in-line for some reason.....
--  oq.tab4_timeleft:SetText( oq.fmt_time( oq.scores.timeleft ) ) ;
--[[ 
  local t = oq.scores.timeleft or 0 ;
  local hrs = floor( t / (60*60)) ;
  local min = floor( t / 60 ) % 60 ;
  local sec = t % 60 ;
  local tm_str = string.format( "%d:%02d:%02d", hrs, min, sec ) ;
  if (hrs == 0) then
    tm_str = string.format( "%02d:%02d", min, sec ) ;
  end
  oq.tab4_timeleft:SetText( tm_str ) ;
]]
  for i,v in pairs(oq.scores.bg) do
    oq.set_bg_percent( oq.tab4_bg[ i ], v ) ;
  end
end

function oq.on_stats( name, realm, stats )
  local g_id, slot, lvl, faction, class, race, gender, bg1, s1, bg2, s2, resil, ilevel, flags, 
        hp, role, charm, xflags, wins, losses, hks, oq_ver, tears, pvppower, mmr = oq.decode_stats( stats ) ;
  if (faction == nil) then
    -- null status, no player represented
    return ;
  end
  if (my_group == g_id) and (my_slot == slot) and (oq._override == nil) then
    -- don't tell me my own status
    return ;
  end
  oq._override = nil ;
  
  if (lvl == 0) then
    oq.raid_cleanup_slot( g_id, slot ) ;
    return ;
  end
  if ((name == nil) or (name == "-")) then
    name = "n/a" ;
  end
  local realm_id = 0 ;
  if (realm == nil) or (realm == "-") then
    realm = "n/a" ;
  else
    realm_id = tonumber(realm) ;
    realm = oq.realm_uncooked(realm) ;
  end
  oq.set_group_member( g_id, slot, name, realm, class, nil, bg1, s1, bg2, s2 ) ;
  oq.set_role( g_id, slot, role ) ;
  oq.set_charm( g_id, slot, charm ) ;

  local m = oq.raid.group[g_id].member[slot] ;
  m.realm    = realm ;
  m.realm_id = realm_id ;
  m.race     = race ;
  m.gender   = gender ;
  m.level    = lvl ;
  m.resil    = resil ;
  m.ilevel   = ilevel ;
  m.flags    = flags ;
  m.hp       = hp ;
  m.check    = xflags ;
  m.wins     = wins ;
  m.losses   = losses ;
  m.hks      = hks ;
  m.oq_ver   = oq_ver ;
  m.tears    = tears or 0 ;
  m.pvppower = pvppower ;
  m.mmr      = mmr ;
  -- set overlays
  oq.set_textures( g_id, slot ) ;
  oq.update_tab1_stats() ;
  
  _ok2relay = nil ;  -- do not relay the stats message
end

function oq.init_table()
   for i=0,255 do
      local c = string.format("%c", i ) ;
      local n = i ;
      oq_ascii[n] = c ;
      oq_ascii[c] = n ;
   end
   
   local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" ;
   local n = strlen(charset) ;
   for i=1,n do
      local c = charset:sub(i,i) ;
      oq_mime64[i-1] = c ;
      oq_mime64[c] = i-1 ;
   end
end

function oq.base64( a, b, c )
   local w, x, y, z ;
   a = oq_ascii[ a ] ;
   b = oq_ascii[ b ] ;
   c = oq_ascii[ c ] ;
   
   --   w = (a & 0xFC) >> 2 ;
   w = bit.rshift( bit.band( a, 0xFC ), 2 ) ;
   
   --   x = ((a & 0x03) << 4) + ((b & 0xF0) >> 4) ;
   x =  bit.lshift( bit.band( a, 0x03 ), 4 ) + bit.rshift( bit.band( b, 0xF0 ), 4 ) ;
   
   --   y = ((b & 0x0F) << 2) + ((c & 0xC0) >> 6) ;
   y = bit.lshift( bit.band( b, 0x0F ), 2 ) + bit.rshift( bit.band( c, 0xC0 ), 6 ) ;
   
   --   z = (c & 0x3F) ;
   z = bit.band( c, 0x3F ) ;
   
   w = oq_mime64[ w ] ;
   x = oq_mime64[ x ] ;
   y = oq_mime64[ y ] ;
   z = oq_mime64[ z ] ;
   return  w, x, y, z ;
end

function oq.base256( w, x, y, z )
   local a, b, c ;
   w = oq_mime64[ w ] or 0 ;
   x = oq_mime64[ x ] or 0 ;
   y = oq_mime64[ y ] or 0 ;
   z = oq_mime64[ z ] or 0 ;
   
   --   a = (w << 2) + ((x & 0x30) >> 4) ;
   a = bit.lshift( w, 2 ) + bit.rshift( bit.band( x, 0x30 ), 4 ) ;
   
   --   b = ((x & 0x0F) << 4) + ((y & 0x3C) >> 2) ;
   b = bit.lshift( bit.band( x, 0x0F ), 4 ) + bit.rshift( bit.band( y, 0x3C ), 2 ) ;
   
   --   c = ((y & 0x03) << 6) + z ;
   c = bit.lshift( bit.band( y, 0x03 ), 6 ) + z ;
   
   a = oq_ascii[ a ] ;
   b = oq_ascii[ b ] ;
   c = oq_ascii[ c ] ;
   return a, b, c ;
end

function oq.decode256( enc ) 
   local str = "" ;
   local n = strlen(enc) ;
   local w, x, y, z, a, b, c ;
   for i=1,n,4 do
      w = enc:sub(i,i) ;
      x = enc:sub(i+1,i+1) ;
      y = enc:sub(i+2,i+2) ;
      z = enc:sub(i+3,i+3) ;
      a, b, c = oq.base256( w, x, y, z ) ;
      str = str .."".. a .."".. b .."".. c ;
   end
   return str ;
end

function oq.encode64( str ) 
   local enc = "" ;
   local n = strlen(str) ;
   local w, x, y, z, a, b, c ;
   for i=1,n,3 do
      a = str:sub(i,i) ;
      b = str:sub(i+1,i+1) ;
      c = str:sub(i+2,i+2) ;
      w, x, y, z = oq.base64( a, b, c ) ;
      enc = enc .."".. w .."".. x .."".. y .."".. z ;
   end
   return enc ;
end

function oq.encrypt( pword, str )
   local enc = "" ;
   local plen = strlen(pword) ;
   local len = strlen(str) ;
   local n = 1 ;
   local i ;
   for i=1,len do
      local a = oq_ascii[ str:sub(i,i) ] ;
      local b = oq_ascii[ pword:sub(n,n) ] ;
      enc = enc .. oq_ascii[ bit.bxor( a, b ) ] ;
      n = n + 1 ;
      if (n > plen) then
         n = 1 ;
      end
   end
   return enc ;
end

function oq.decrypt( pword, enc )
   local str = "" ;
   local plen = strlen(pword) ;
   local len = strlen(enc) ;
   local n = 1 ;
   local i ;
   for i=1,len do
      local a = oq_ascii[ enc:sub(i,i) ] ;
      local b = oq_ascii[ pword:sub(n,n) ] ;
      str = str .. oq_ascii[ bit.bxor( a, b ) ] ;
      n = n + 1 ;
      if (n > plen) then
         n = 1 ;
      end
   end
   return str ;
end

function oq.encode_data( pword, name, realm, rid )
  local s = tostring(name) ..",".. tostring(oq.realm_cooked(realm)) ..",".. tostring(rid) ;

  -- sub then reverse
  s = string.gsub( s, ",", ";" ) ;
  s = s:reverse() ;

  -- encrypt
-- current bug with encrypt / decrypt
--  s = oq.encrypt( pword, s ) ;

  -- put in cocoon
  return oq.encode64( s ) ;
end

function oq.decode_data( pword, data )
  -- pull from the cocoon
  local s = oq.decode256( data ) ;

  -- decrypt
-- current bug with encrypt / decrypt
--  s = oq.decrypt( pword, s ) ;
   
  -- reverse then sub
  s = s:reverse() ;
  s = string.gsub( s, ";", "," ) ;
   
  -- pull vars out of it
  local vars = {};
  local v ;
  for v in string.gmatch( s, "([^,]+)") do
    table.insert(vars, v);
  end
   
  return vars[1], OQ.SHORT_BGROUPS[tonumber(vars[2])], vars[3] ;
end

function oq.encode_pword( pword )
  local s = pword or "." ;
  if (s:len() > 10) then
    s = s:sub( 1, 10 ) ;
  elseif (s == "") then
    s = "." ;
  end

  -- sub then reverse
  s = string.gsub( s, ",", ";" ) ;
  s = s:reverse() ;
   
  -- put in cocoon
  return oq.encode64( s ) ;
end

function oq.decode_pword( data )
  -- pull from the cocoon
  local s = oq.decode256( data ) ;
   
  -- reverse then sub
  s = s:reverse() ;
  s = string.gsub( s, ";", "," ) ;
  
  if (s == ".") then
    s = "" ;
  end
   
  return s ;
end

function oq.encode_name( name )
  local s = name or "." ;
  if (s:len() > 25) then
    s = s:sub( 1, 25 ) ;
  elseif (s == "") then
    s = "." ;
  end

  -- sub then reverse
  s = string.gsub( s, ",", ";" ) ;
  s = s:reverse() ;
   
  -- put in cocoon
  return oq.encode64( s ) ;
end

function oq.decode_name( data )
  -- pull from the cocoon
  local s = oq.decode256( data ) ;
   
  -- reverse then sub
  s = s:reverse() ;
  s = string.gsub( s, ";", "," ) ;
  
  if (s == ".") then
    s = "" ;
  end
   
  return s ;
end

function oq.encode_note( note )
  local s = note or "." ;
  if (s:len() > 150) then
    s = s:sub( 1, 150 ) ;
  elseif (s == "") then
    s = "." ;
  end

  -- sub then reverse
  s = string.gsub( s, ",", ";" ) ;
  s = s:reverse() ;
   
  -- put in cocoon
  return oq.encode64( s ) ;
end

function oq.decode_note( data )
  -- pull from the cocoon
  local s = oq.decode256( data ) ;
   
  -- reverse then sub
  s = s:reverse() ;
  s = string.gsub( s, ";", "," ) ;
  
  if (s == ".") then
    s = "" ;
  end
   
  return s ;
end

function oq.encode_bg( note )
  local s = note or "." ;
  if (s:len() > 35) then
    s = s:sub( 1, 35 ) ;
  elseif (s == "") then
    s = "." ;
  end

  -- sub then reverse
  s = string.gsub( s, ",", ";" ) ;
  s = s:reverse() ;
   
  -- put in cocoon
  return oq.encode64( s ) ;
end

function oq.decode_bg( data )
  if (data == nil) then
    return "" ;
  end
  -- pull from the cocoon
  local s = oq.decode256( data ) ;
   
  -- reverse then sub
  s = s:reverse() ;
  s = string.gsub( s, ";", "," ) ;
  
  if (s == ".") then
    s = "" ;
  end
   
  return s ;
end

function oq.decode_stats( s )
  local gid      = tonumber( s:sub( 1,1 )) ;
  local slot     = tonumber( s:sub( 2,2 )) ;
  local lvl      = tonumber( s:sub( 3,4 )) ;
  local demos    = oq_mime64[ s:sub( 5,5 ) ] ;
  if (demos == "0") then
    return gid, slot, lvl, demos ;
  end
  local gender   = bit.rshift( bit.band( 0x02, demos ), 1 ) ;
  local race     = bit.rshift( bit.band( 0x3C, demos ), 2 ) ;
  local faction  = 'H' ;
  if (bit.band( 0x01, demos ) ~= 0) then
    faction = 'A' ;
  end

  local class    = s:sub( 6, 7 ) ;
  local bg1      = oq_mime64[s:sub(8, 8)] ;
  local stat1    = s:sub(9, 9) ;
  local bg2      = oq_mime64[s:sub(10, 10)] ;
  local stat2    = s:sub(11, 11) ;
  local resil    = oq.decode_mime64_digits( s:sub(12,14) ) ;
  local ilevel   = oq.decode_mime64_digits( s:sub(15,16) ) ;

  local f1       = oq_mime64[ s:sub(17, 17)] ;
  local f2       = oq_mime64[ s:sub(18, 18)] ;
  local flags    = bit.lshift( f1, 4 ) + f2 ;
  local hp       = oq.decode_mime64_digits( s:sub(19,20) ) ;
  local role     = tonumber(s:sub(21,21) or 3) ;
  local charm    = tonumber(s:sub(22,22) or 0) ;
  local f3       = oq_mime64[ s:sub(23, 23)] ;
  local f4       = oq_mime64[ s:sub(24, 24)] ;
  local xflags   = bit.lshift( f3, 4 ) + f4 ;
  
  local wins     = oq.decode_mime64_digits( s:sub(25,27) ) ;
  local losses   = oq.decode_mime64_digits( s:sub(28,30) ) ;
  local hks      = oq.decode_mime64_digits( s:sub(31,32) ) ;
  local oq_ver   = oq.decode_mime64_digits( s:sub(33,33) ) ;
  local tears    = oq.decode_mime64_digits( s:sub(34,36) ) ;
  local pvppower = oq.decode_mime64_digits( s:sub(37,39) ) ;
  local mmr      = oq.decode_mime64_digits( s:sub(40,41) ) ;

  return gid, slot, lvl, faction, class, race, gender, 
         bg1, stat1, bg2, stat2, resil, ilevel, flags, 
         hp, role, charm, xflags, wins, losses, hks, oq_ver, tears, pvppower, mmr ;  
end

function oq.encode_hp( hp )
  if (hp == nil) then
    hp = 0 ;
  end
  local  a = floor(hp / 36) ;
  local  b = floor(hp % 36) ;
  return oq_mime64[ a ] .."".. oq_mime64[ b ] ;
end

function oq.decode_hp( code )
  local a = tonumber(oq_mime64[ code:sub( 1,1 ) ]) ;
  local b = tonumber(oq_mime64[ code:sub( 2,2 ) ]) ;
  return (a * 36) + b ;
end

function oq.encode_stats( g_id, slot, level, faction, class, race, gender, b1, s1, b2, s2, resil, ilevel, flags, hp, role, charm, xflags, wins, losses, hks, oq_ver, tears, pvppower, mmr )
  local lvl = level or 0 ;
  if (lvl < 10) then
    lvl = "0" .. tostring(lvl) ;
  end
  if (flags == nil) then
    flags = 0 ;
  end
  if (xflags == nil) then
    xflags = 0 ;
  end
  local faction_ = 0 ; -- 0 == horde, 1 == alliance
  if (faction ~= "H") then
    faction_ = 1 ;
  end
  local f1 = oq_mime64[ bit.rshift( flags ,    4 )] ;
  local f2 = oq_mime64[ bit.band  ( flags , 0x0F )] ;
  local f3 = oq_mime64[ bit.rshift( xflags,    4 )] ;
  local f4 = oq_mime64[ bit.band  ( xflags, 0x0F )] ;
  local demos = oq_mime64[ bit.lshift( race, 2 ) + bit.lshift( gender, 1 ) + faction_ ] ;
  if (not b1) then
    b1 = oq_mime64[ OQ.NONE ] ;
  else
    b1 = oq_mime64[ b1 ] ;
  end
  if (not b2) then
    b2 = oq_mime64[ OQ.NONE ] ;
  else
    b2 = oq_mime64[ b2 ] ;
  end
  local cls = class ;
  if (cls == nil) or (cls:len() > 2) then
    cls = (OQ.SHORT_CLASS[ class ] or "ZZ") ;
  end
  
  local stats = g_id .."".. 
                slot .."".. 
                lvl .."".. 
                demos .."".. 
                cls .."".. 
                (b1 or "x") .."".. 
                (s1 or "A") ..""..
                (b2 or "x") .."".. 
                (s2 or "A") ..""..
                oq.encode_mime64_3digit( resil ) ..""..
                oq.encode_mime64_2digit( ilevel ) ..""..
                f1 .."".. f2 ..""..
                oq.encode_mime64_2digit( hp ) ..""..
                tostring( role or 3 ) ..""..
                tostring( charm or 0 ) ..""..
                f3 .."".. f4 ..""..
                oq.encode_mime64_3digit( wins ) ..""..
                oq.encode_mime64_3digit( losses ) ..""..
                oq.encode_mime64_2digit( hks ) ..""..
                oq.encode_mime64_1digit( oq_ver ) ..""..
                oq.encode_mime64_3digit( tears ) ..""..
                oq.encode_mime64_3digit( pvppower or 0 ) ..""..
                oq.encode_mime64_2digit( mmr or 0 ) 
                ;
  return stats ;
end

function oq.decode_short_stats( s )
  local lvl      = tonumber( s:sub( 1,2 )) ;
  local faction  = s:sub( 3, 3 ) ;
  if (faction == "0") then
    return lvl, faction ;
  end
  local class    = s:sub( 4, 5 ) ;
  local resil    = oq.decode_mime64_digits( s:sub(6, 8)) ;
  local ilevel   = oq.decode_mime64_digits( s:sub(9, 10)) ;
  local role     = tonumber( s:sub(11,11) or 3 ) ;
  local mmr      = oq.decode_mime64_digits( s:sub(12,13) ) ;
  local pvppower = oq.decode_mime64_digits( s:sub(14,16) ) ;

  return lvl, faction, class, resil, ilevel, role, mmr, pvppower ;
end

function oq.encode_short_stats( level, faction, class, resil, ilevel, role, mmr, pvppower )
  local lvl = level ;
  if (lvl < 10) then
    lvl = "0" .. tostring(lvl) ;
  end
  local cls = class ;
  if (cls == nil) or (cls:len() > 2) then
    cls = OQ.SHORT_CLASS[ class ] or "ZZ" ;
  end
  
  local stats = lvl .."".. 
                faction .."".. 
                cls .."".. 
                oq.encode_mime64_3digit( resil  ) ..""..
                oq.encode_mime64_2digit( ilevel ) ..""..
                tostring( role or 3 ) ..""..
                oq.encode_mime64_2digit( mmr ) ..""..
                oq.encode_mime64_3digit( pvppower ) 
                ;
  return stats ;
end

function oq.encode_mime64_6digit( n_ )
  local n = oq.numeric_sanity(n_) ;
  local f = floor( n % 64 ) ;
  n = floor( n / 64 ) ;
  local e = floor( n % 64 ) ;
  n = floor( n / 64 ) ;
  local d = floor( n % 64 ) ;
  n = floor( n / 64 ) ;
  local c = floor( n % 64 ) ;
  n = floor( n / 64 ) ;
  local b = floor( n % 64 ) ;
  n = floor( n / 64 ) ;
  local a = floor( n % 64 ) ;  
  return oq_mime64[ a ] .."".. oq_mime64[ b ] .."".. oq_mime64[ c ] .."".. oq_mime64[ d ] .."".. oq_mime64[ e ] .."".. oq_mime64[ f ] ;
end

function oq.encode_mime64_5digit( n_ )
  local n = oq.numeric_sanity(n_) ;
  local e = floor( n % 64 ) ;
  n = floor( n / 64 ) ;
  local d = floor( n % 64 ) ;
  n = floor( n / 64 ) ;
  local c = floor( n % 64 ) ;
  n = floor( n / 64 ) ;
  local b = floor( n % 64 ) ;
  n = floor( n / 64 ) ;
  local a = floor( n % 64 ) ;  
  return oq_mime64[ a ] .."".. oq_mime64[ b ] .."".. oq_mime64[ c ] .."".. oq_mime64[ d ] .."".. oq_mime64[ e ] ;
end

function oq.encode_mime64_3digit( n_ )
  local n = oq.numeric_sanity(n_) ;
  local c = floor( n % 64 ) ;
  n = floor( n / 64 ) ;
  local b = floor( n % 64 ) ;
  n = floor( n / 64 ) ;
  local a = floor( n % 64 ) ;  
  return oq_mime64[ a ] .."".. oq_mime64[ b ] .."".. oq_mime64[ c ] ;
end

function oq.encode_mime64_2digit( n_ )
  local n = oq.numeric_sanity(n_) ;
  local b = floor( n % 64 ) ;
  n = floor( n / 64 ) ;
  local a = floor( n % 64 ) ;  
  return oq_mime64[ a ] .."".. oq_mime64[ b ] ;
end

function oq.encode_mime64_1digit( n_ )
  local n = oq.numeric_sanity(n_) ;
  local a = floor( n % 64 ) ;  
  return oq_mime64[ a ] ;
end

function oq.encode_mime64_flags( f1, f2, f3, f4, f5, f6 )
  local a = 0 ;
  a = oq.bset( a, 0x01, f1 ) ;
  a = oq.bset( a, 0x02, f2 ) ;
  a = oq.bset( a, 0x04, f3 ) ;
  a = oq.bset( a, 0x08, f4 ) ;
  a = oq.bset( a, 0x10, f5 ) ;
  a = oq.bset( a, 0x20, f6 ) ;
  return oq_mime64[ a ] ;
end

function oq.decode_mime64_digits( s )
  if (s == nil) then
    return 0 ;
  end
  local n = 0 ;
  for i=1,#s do
    local x = s:sub( i,i ) ;
    n = n * 64 + oq_mime64[ x ] ;
  end
  return n ;
end

function oq.decode_mime64_flags( data )
  local n = oq_mime64[ data ] ;
  local f1 = oq.is_set( n, 0x01 ) ;
  local f2 = oq.is_set( n, 0x02 ) ;
  local f3 = oq.is_set( n, 0x04 ) ;
  local f4 = oq.is_set( n, 0x08 ) ;
  local f5 = oq.is_set( n, 0x10 ) ;
  return f1, f2, f3, f4, f5 ;
end

function oq.encode_premade_info( raid_token, avg_ilevel, avg_resil, stat, tm, has_pword, is_realm_specific, is_source )
  local raid = oq.premades[ raid_token ] ;
  if (raid == nil) then
    return ;
  end
  return oq.encode_mime64_flags ( (raid.faction == "H"), has_pword, is_realm_specific, is_source ) ..""..
         oq.encode_mime64_1digit( OQ.SHORT_LEVEL_RANGE[ raid.level_range ] ) ..""..
         oq.encode_mime64_2digit( raid.min_ilevel ) ..""..
         oq.encode_mime64_3digit( raid.min_resil ) ..""..
         oq.encode_mime64_1digit( raid.stats.nMembers ) ..""..
         oq.encode_mime64_1digit( raid.stats.nWaiting ) ..""..
         oq.encode_mime64_2digit( avg_ilevel ) ..""..
         oq.encode_mime64_3digit( avg_resil ) ..""..
         oq.encode_mime64_3digit( raid.stats.nWins ) ..""..
         oq.encode_mime64_3digit( raid.stats.nLosses ) ..""..
         oq.encode_mime64_2digit( raid.stats.avg_honor ) ..""..
         oq.encode_mime64_2digit( raid.stats.avg_hks ) ..""..
         oq.encode_mime64_2digit( raid.stats.avg_deaths ) ..""..
         oq.encode_mime64_2digit( raid.stats.avg_down_tm ) ..""..
         oq.encode_mime64_3digit( raid.stats.avg_bg_len ) ..""..
         oq.encode_mime64_1digit( stat ) ..""..
         oq.encode_mime64_6digit( tm ) .."".. 
         oq.encode_mime64_2digit( raid.min_mmr ) ;
end

function oq.decode_premade_info( data ) 
  local is_horde, has_pword, is_realm_specific, is_source = oq.decode_mime64_flags( data:sub(1,1) ) ;
  local faction = "A" ;
  if (is_horde) then
    faction = "H" ;
  end
  local  range = OQ.SHORT_LEVEL_RANGE[ oq.decode_mime64_digits( data:sub(2,2) ) ] ;
  
  return faction, has_pword, is_realm_specific, is_source, 
         range,
         oq.decode_mime64_digits( data:sub( 3, 4) ), -- min ilevel
         oq.decode_mime64_digits( data:sub( 5, 7) ), -- min resil
         oq.decode_mime64_digits( data:sub( 8, 8) ), -- nmembers
         oq.decode_mime64_digits( data:sub( 9, 9) ), -- nwaiting
         oq.decode_mime64_digits( data:sub(10,11) ), -- avg ilevel
         oq.decode_mime64_digits( data:sub(12,14) ), -- avg resil
         oq.decode_mime64_digits( data:sub(15,17) ), -- nwins
         oq.decode_mime64_digits( data:sub(18,20) ), -- nlosses
         oq.decode_mime64_digits( data:sub(21,22) ), -- avg honor
         oq.decode_mime64_digits( data:sub(23,24) ), -- avg hks
         oq.decode_mime64_digits( data:sub(25,26) ), -- avg deaths
         oq.decode_mime64_digits( data:sub(27,28) ), -- down tm
         oq.decode_mime64_digits( data:sub(29,31) ), -- bg tm
         oq.decode_mime64_digits( data:sub(32,32) ), -- stat
         oq.decode_mime64_digits( data:sub(33,38) ), -- raid.tm
         oq.decode_mime64_digits( data:sub(39,40) )  -- min mmr
         ;         
end

function oq.echo_party_msg( sender, msg ) 
  if (oq.raid.raid_token == nil) or (my_slot ~= 1) or _inside_bg then
    return ;
  end
  if (oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID) then
    return ;
  end
  local name  = sender ;
  local realm = player_realm ;
  if (sender:find("-")) then
    name  = sender:sub( 1, sender:find("-")-1 ) ;
    realm = sender:sub( sender:find("-")+1, -1 ) ;
  end
  if (name == player_name) then
    if (msg:find('[[]') == 1) then
      -- most likely a relayed msg, do not echo 
      -- (this is buggy, as any messages sent by the group leader starting with '[' won't be relayed)
      return ;
    end
  end
  oq.boss_announce( "party_msg,".. oq.raid.raid_token ..",".. name ..",".. realm ..",".. oq.encode_note( msg ) ) ;  
end

function oq.on_party_msg( raid_token, name, realm, enc_note ) 
  _ok2relay = nil ;
  if (oq.raid.raid_token == nil) or (my_slot ~= 1) then
    return ;
  end
  if (oq.iam_raid_leader()) then
    _ok2relay = 1 ;
  end
  local n = name ;
  if (realm ~= player_realm) then
    n = n .."-".. realm ;
  end
  local note = "[".. n .."] ".. oq.decode_note( enc_note ) ;

  if (oq.iam_in_a_party()) then
    SendChatMessage( note, "PARTY" ) ;
  else
    SendChatMessage( note, "WHISPER", nil, player_name ) ;
  end
end

function oq.check_party_members()
  if (my_group == 0) then
    return ;
  end
  local grp = oq.raid.group[ my_group ] ;
  local new_mem = nil ;
  local mem_gone = nil ;
  local n_members = oq.GetNumPartyMembers() ;
  local rost = {} ;
  
  for i=1,4 do
    if (grp.member[i].name ~= nil) and (grp.member[i].name ~= "") and (grp.member[i].name ~= "-") then
      rost[ grp.member[i].name ] = { ndx = i, raidid = 0 } ;
    end
  end

  for i = 1,n_members do
    name = UnitName("party".. i)
    if (rost[name] == nil) then
      new_mem = true ;
    else
      rost[name].raidid = i ;
    end
  end

  for name,v in pairs(rost) do
    if (name ~= nil) and (v.raidid == 0) and (name ~= player_name) then
      mem_gone = true ;
      oq.raid_cleanup_slot( my_group, v.ndx ) ;
    end
  end
  
  if (oq.iam_party_leader() and (new_mem or mem_gone)) then
    local now = utc_time() ;
    if ((last_ident_tm + 5) < now) then
      last_ident_tm = now ;
      oq.party_announce( "identify,".. my_group ) ;
    end
  end
end

function oq.get_party_roles()
  local grp = oq.raid.group[ my_group ] ;
  local m = "" ;
  
  for i=1,5 do
    local p = grp.member[i] ;
    if (p.name == nil) or (p.name == "-") or (p.name == "") then
      m = m .."x" ;
    else
      m = m .."".. UnitGroupRolesAssigned( p.name ):sub(1,1) ;
    end
  end
  return m ;
end

function oq.find_first_empty_slot( gid )
  local grp = oq.raid.group[ my_group ] ;
  for i = 2,5 do
    local p = grp.member[i] ;
    if (p.name == nil) or (p.name == "-") then
      return i ;
    end
  end
  return nil ;
end

-- makes sure slots are filled with party member names to insure someone doesn't 
-- disappear from group
--
function oq.verify_group_members() 
  if (not oq.iam_party_leader() or _inside_bg) then 
    return ;
  end
  if (oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID) then
    -- short circuit for raids
    return ;
  end
  local i, j ;
  local n_members = oq.GetNumPartyMembers() ;
  local grp = oq.raid.group[ my_group ] ;
  
  -- check for members that left
  for i=2,5 do
    grp.member[i].not_here = true ;
  end
  for i=1,4 do
    local n = GetUnitName( "party".. i, true )
    local name  = n ;
    local realm = player_realm ;
    if (name ~= nil) and (name:find(" - ") ~= nil) then
      name  = n:sub(1,n:find(" - ")-1) ;
      realm = n:sub(n:find(" - ")+3, -1) ;
    end
    for j=2,5 do
      if (grp.member[j].name == name) then
        grp.member[j].not_here = nil ;
        break ;
      end
    end
  end
  for i=2,5 do
    if (grp.member[i].not_here) then
      oq.raid_cleanup_slot( my_group, i ) ;
    end
  end

  -- look for new members  
  for i=1,4 do
    local n = GetUnitName( "party".. i, true )
    local name  = n ;
    local realm = player_realm ;
    if (name ~= nil) and (name:find(" - ") ~= nil) then
      name  = n:sub(1,n:find(" - ")-1) ;
      realm = n:sub(n:find(" - ")+3, -1) ;
    end
    if (name ~= nil) then
      local found = nil ;
      for j=2,5 do
        local p = grp.member[j] ;
        if (p.name ~= nil) and (p.name == name) then
          p.realm    = realm ;
          found      = true ;
          p.not_here = nil ;
          break ;
        end
      end
      if (not found) then
        -- new member found; party member not in OQ raid group
        slot = oq.find_first_empty_slot( my_group ) ;
        if (slot) then
          grp.member[slot].name     = name ; -- reserve the spot for this player
          grp.member[slot].realm    = realm ;
          grp.member[slot].class    = OQ.SHORT_CLASS[ select(2, UnitClass("party".. i)) ] or "ZZ" ;
          grp.member[slot].not_here = nil  ; -- reserve the spot for this player
--          oq.brief_player( slot, name ) ;
          oq.timer( "brief_new_member", 1.0, oq.brief_group_members ) ;
        else
          -- error.  all slots full, unknown people in party
        end
      end
    end
  end
end

function oq.get_party_stats( gid )
  -- create message
  gid = gid or my_group ;
  local msg = "gs,".. gid ; -- changed from "grp_stats"
  local grp = oq.raid.group[ gid ] ;
  
  oq.verify_group_members() ;  
  oq.gather_my_stats() ; -- will populate 'me'
  
  for i=1,5 do
    local p = grp.member[i] ;
    local stats ;
    if (p.name == nil) or (p.name == "-") or (p.name == "") then
      stats = gid .."".. i .."000000000000000000000000000000000000000" ;
    else
      local n = p.name ;
      if (p.realm ~= nil) and (p.realm ~= player_realm) then
        n = n .."-".. p.realm ;
      end
      p.hp = floor(UnitHealthMax(n) / 1000) ;
      if (p.check == nil) then
        p.check = OQ_FLAG_CLEAR ;
      end
      stats = oq.encode_stats( gid, i, (p.level or player_level), player_faction, p.class, p.race, p.gender,
                               p.bg[1].type, p.bg[1].status, p.bg[2].type, p.bg[2].status, 
                               p.resil, p.ilevel, p.flags, p.hp, p.role, p.charm, p.check,
                               p.wins, p.losses, p.hks, p.oq_ver, p.tears, p.pvppower, p.mmr ) ;
    end
    msg = msg ..",".. stats ;
  end
  
  -- tack on queue_tm
  local s1 = OQ.QUEUE_STATUS[ select(1, GetBattlefieldStatus(1)) ] ;
  local s2 = OQ.QUEUE_STATUS[ select(1, GetBattlefieldStatus(2)) ] ;
  local m  = oq.raid.group[ gid ].member[ 1 ] ;

  msg = msg ..",".. 
        (s1 or "0") ..","..
        oq.encode_mime64_6digit( m.bg[1].queue_ts ) ..","..
        (s2 or "0") ..","..
        oq.encode_mime64_6digit( m.bg[2].queue_ts ) ..","..
        tostring(oq.raid.type or OQ.TYPE_NONE) 
        ;

  -- add on roles
  return msg ;
end

function oq.first_raid_slot()
  local n = oq.nMaxGroups() ;
  for g=1,n do
    for s=1,5 do
      local p = oq.raid.group[g].member[s] ;
      if (p.name == nil) or (p.name == "-") then
        return g, s ;
      end
    end
  end
  return 0,0 ;
end

function oq.get_party_names( gid )
  oq.verify_group_members() ;
  if (gid == nil) then
    gid = my_group ;
  end
  -- create message
  local msg = "party_names,".. gid ;
  local grp = oq.raid.group[ gid ] ;
  local i ;
  
  for i=1,5 do
    local p = grp.member[i] ;
    local name ;
    if (p.name == nil) or (p.name == "-") or (p.name == "") or (p.realm == nil) or (p.realm == "-") then
      name = "-,0,-" ;
    else
      local cls = p.class ;
      if (cls == nil) or (cls:len() > 2) then
        cls = OQ.SHORT_CLASS[ cls ] or "YY" ;
      end
--      name = p.name ..",".. tostring(oq.realm_cooked(p.realm)) ..",".. cls ;
      name = p.name ..",".. tostring(p.realm_id) ..",".. cls ;
    end
    msg = msg ..",".. name ;
  end
  return msg ;
end

function oq.clear_the_dead()
  if (not oq.iam_raid_leader()) or (oq.raid.type ~= OQ.TYPE_BGS) then
    return ;
  end
  local n = oq.nMaxGroups() ;
  for i=2,n do
    local p = oq.raid.group[i].member[1] ;
    if (p == nil) or (p.name == nil) or (p.name == "") or (p.name == "-") then
      local stats = oq.get_party_stats( i ) ; 
      oq.boss_announce( stats ) ;
      oq.party_announce( stats ) ;
    end
  end
end

function oq.send_party_stats() 
  if ((my_group <= 0) or (my_slot <= 0)) then
    return ;
  end
  -- send message
oq._showme = true ;
  oq.raid.group[ my_group ]._stats = oq.get_party_stats() ; -- used to brief new players  
  oq.boss_announce( oq.raid.group[ my_group ]._stats ) ;
oq._showme = nil ;
end

function oq.send_party_names() 
  if ((my_group <= 0) or (my_slot <= 0)) then
    return ;
  end
  
  local msg = oq.get_party_names() ;
  
  -- send message
  oq.boss_announce( msg ) ;
  oq.raid.group[ my_group ]._names = msg ; -- used to brief new players  
end

function oq.set_name( gid, slot, name, realm, class )
  if ((gid == 0) or (slot == 0)) then
    return ;
  end
  local realm_id = realm ;
  if(tonumber(realm) ~= nil) then
    realm = oq.realm_uncooked(realm) ;
  else
    realm_id = oq.realm_cooked(realm) ;
  end
  local m = oq.raid.group[ gid ].member[ slot ] ;
  if (name == "-") then
    m.name     = nil ;
    m.realm    = nil ;
    m.realm_id = 0 ;
    m.class    = nil ;
  else
    m.name     = name ;
    m.realm    = realm ;
    m.realm_id = realm_id ;
    m.class    = class ;
    if (slot == 1) then
      -- update group leader info
    end
  end
  if (name == player_name) and ((realm == nil) or (realm == "-") or (realm == player_realm)) then
    my_group   = gid ;
    my_slot    = slot ;
    m.realm    = player_realm ;
    m.realm_id = player_realm_id ;
    m.class = player_class ;
    oq.ui_player() ;
    oq.update_my_premade_line() ;
    -- push my stats
    last_stats = nil ;
    oq.check_stats() ;
  end
  oq.set_textures( gid, slot ) ;
end

function oq.on_party_names( gid, n1, r1, c1, n2, r2, c2, n3, r3, c3, n4, r4, c4, n5, r5, c5 )
  gid = tonumber(gid) ;
  if (gid == 0) or ((my_group == gid) and (my_slot == 1) and (not oq.is_raid())) then
    return ;
  end
  oq.set_name( gid, 1, n1, r1, c1 ) ;
  oq.set_group_lead( gid, n1, r1, c1, nil ) ;
  
  oq.set_name( gid, 2, n2, r2, c2 ) ;
  oq.set_name( gid, 3, n3, r3, c3 ) ;
  oq.set_name( gid, 4, n4, r4, c4 ) ;
  oq.set_name( gid, 5, n5, r5, c5 ) ;
  
  if (oq.is_raid()) then
    return ;
  end

  if (oq.iam_raid_leader()) then
    local msg = "party_names,".. gid ..",".. 
                 n1 ..",".. r1 ..",".. (c1 or "QQ") ..",".. 
                 n2 ..",".. r2 ..",".. (c2 or "QQ") ..",".. 
                 n3 ..",".. r3 ..",".. (c3 or "QQ") ..",".. 
                 n4 ..",".. r4 ..",".. (c4 or "QQ") ..",".. 
                 n5 ..",".. r5 ..",".. (c5 or "QQ") ;
    oq.boss_announce( msg )
    oq.raid.group[ gid ]._names = msg ; -- used to brief new players
  end  
  
  if (oq.iam_party_leader()) then
    -- tell party
    local msg = "party_names,".. gid ..",".. 
                 n1 ..",".. r1 ..",".. (c1 or "QQ") ..",".. 
                 n2 ..",".. r2 ..",".. (c2 or "QQ") ..",".. 
                 n3 ..",".. r3 ..",".. (c3 or "QQ") ..",".. 
                 n4 ..",".. r4 ..",".. (c4 or "QQ") ..",".. 
                 n5 ..",".. r5 ..",".. (c5 or "QQ") ;
    oq.party_announce( msg ) ;
    oq.raid.group[ gid ]._names = msg ; -- used to brief new players
  end
end

function oq.on_grp_stats( gid, m1, m2, m3, m4, m5, s1, tm1, s2, tm2, raid_type )
  gid = tonumber(gid) ;
  if (gid == 0) then
    return ;
  end
  if (gid == my_group) and (oq.iam_party_leader()) then
    -- echo?  don't process
    return ;
  end
  local grp = oq.raid.group[ gid ] ;
  tm1 = oq.decode_mime64_digits( tm1 ) ;
  tm2 = oq.decode_mime64_digits( tm2 ) ;

  if (raid_type == OQ.TYPE_NONE) then
    raid_type = OQ.TYPE_BG ;
  end
  
  if (oq.raid.type ~= raid_type) then
    oq.set_premade_type( raid_type ) ;
  end
  
  oq.on_stats( grp.member[1].name, grp.member[1].realm_id, m1 ) ;
  oq.on_stats( grp.member[2].name, grp.member[2].realm_id, m2 ) ;
  oq.on_stats( grp.member[3].name, grp.member[3].realm_id, m3 ) ;
  oq.on_stats( grp.member[4].name, grp.member[4].realm_id, m4 ) ;
  oq.on_stats( grp.member[5].name, grp.member[5].realm_id, m5 ) ;
  
  -- deal with queue tms
  oq.on_queue_tm( gid, s1, tm1, s2, tm2 ) ;
  
  if (my_slot == 1) then
    -- changed from "grp_stats"
    local msg = "gs,".. 
                 gid ..",".. 
                 m1 ..",".. 
                 m2 ..",".. 
                 m3 ..",".. 
                 m4 ..",".. 
                 m5 ..",".. 
                 s1 ..",".. oq.encode_mime64_6digit(tm1) ..",".. 
                 s2 ..",".. oq.encode_mime64_6digit(tm2) ..","..
                 tostring(oq.raid.type or OQ.TYPE_NONE) 
                 ;

    local now = utc_time() ;
    if (grp._stat_tm == nil) then
      grp._stat_tm = 0 ;
    end
    if (grp._stats == msg) and ((now - grp._stat_tm) < 5) then
      _ok2relay = nil ;
    else
      if (my_group == 1) then
        oq.boss_announce( msg ) ;
      end
      oq.party_announce( msg ) ;
      grp._stats = msg ; -- used to brief new players
      grp._stat_tm = now ; -- tm of last update
    end
  end  
end

function oq.on_identify( gid )
  gid = tonumber(gid) ;
  if (gid == 0) then
    gid = nil ;
  end 
  _ok2relay = nil ;
  if (_inside_bg) or ((gid ~= nil) and (gid ~= my_group)) then
    return ;
  end
  local now = utc_time() ;
  if ((last_ident_tm + 5) > now) then
    return ;
  end
  last_ident_tm = now ;
  oq.party_announce( "name,".. my_group ..",".. my_slot ..",".. player_name ..",".. player_realm ) ;
  if (oq.iam_party_leader()) then            
    oq.timer( "party_names", 2, oq.send_party_names ) ;    
  end  
end

function oq.on_name( gid, slot, name, realm )
  gid  = tonumber(gid) ;
  slot = tonumber(slot) ;
  if ((oq.raid.raid_token ~= raid_tok) or _inside_bg or (gid == 0) or (slot == 0)) then
    return ;
  end
  local m = oq.raid.group[ gid ].member[ slot ] ;
  m.name  = name ;
  m.realm = realm ;
end

function oq.get_my_stats()
  oq.gather_my_stats() ;

  -- pack up info and ship
  local m = oq.raid.group[ my_group ].member[ my_slot ] ;
  local stats = oq.encode_stats( my_group, my_slot, player_level, player_faction, player_class, m.race, m.gender,
                                 m.bg[1].type, m.bg[1].status, m.bg[2].type, m.bg[2].status, 
                                 player_resil, player_ilevel, m.flags, floor(UnitHealthMax("player")/1000), 
                                 player_role, m.charm, m.check, m.wins, m.losses, m.hks, m.oq_ver, m.tears, m.pvppower, m.mmr ) ;
  return stats ;
end

function oq.force_stats()
  last_stats = nil ;
  oq.check_stats() ;
end

-- fired on a timer once every 5 seconds.  only send if stats change
--
function oq.check_stats()
  -- if not in an OQ raid, leave
  if ((my_group <= 0) or (my_slot <= 0) or (oq.raid.raid_token == nil) or (_inside_bg)) then
    return ;
  end

  -- gather bg queue status
  local me = oq.raid.group[ my_group ].member[ my_slot ] ;
  me.bg[1].status = OQ.QUEUE_STATUS[ select(1, GetBattlefieldStatus(1)) ] ;
  me.bg[2].status = OQ.QUEUE_STATUS[ select(1, GetBattlefieldStatus(2)) ] ;

  -- if i'm lead, check party stats
  if (my_slot == 1) and (not oq.is_raid()) then      
    oq.check_stats_lead() ;
  end
  -- check my stats, post if changed
  local my_stats = oq.get_my_stats() ;
  skip_stats = skip_stats + 1 ;
  if (last_stats == nil) or (my_stats ~= last_stats) or (skip_stats >= 3) then
    last_stats = my_stats ;
    skip_stats = 0 ;
    oq._override = true ;
    oq.on_stats( player_name, oq.realm_cooked(player_realm), my_stats ) ;
    if (oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID) then
      oq.raid_announce( "stats,".. 
                        player_name ..",".. 
                        tostring(oq.realm_cooked(player_realm)) ..","..
                        my_stats 
                      ) ;
    else
      oq.party_announce( "stats,".. 
                         player_name ..",".. 
                         tostring(oq.realm_cooked(player_realm)) ..","..
                         my_stats 
                       ) ;
    end
  end
end

function oq.lead_send_party_names()
  local grp = oq.raid.group[ my_group ] ;
  local now = utc_time() ;
  --  send_party_names
  local party_names = oq.get_party_names() ;
  if (party_names ~= grp._names) or ((grp._names_tm == nil) or (grp._names_tm < now)) then
    grp._names    = party_names ;
    grp._names_tm = now + random(25,35) ;
    
    local enc_data = oq.encode_data( "abc123", oq.raid.leader, oq.raid.leader_realm, oq.raid.leader_rid ) ;
    oq.party_announce( "party_join,".. 
                       my_group ..","..
                       oq.encode_name( oq.raid.name ) ..",".. 
                       oq.raid.leader_class ..",".. 
                       enc_data ..",".. 
                       oq.raid.raid_token  ..",".. 
                       oq.encode_note( oq.raid.notes )
                     ) ;    
    oq.boss_announce( party_names ) ;
    oq.party_announce( party_names ) ;
  end
end

function oq.lead_send_party_stats()
  local grp = oq.raid.group[ my_group ] ;
  local now = utc_time() ;
  -- send_party_stats() 
  local party_stats = oq.get_party_stats() ;
  if (party_stats ~= grp._stats) or ((grp._stats_tm == nil) or (grp._stats_tm < now)) then
    grp._stats    = party_stats ;
    grp._stats_tm = now + random(25,35) ;
    oq.boss_announce( party_stats ) ;
    oq.party_announce( party_stats ) ;
  end
end

local lead_ticker = 0 ;
function oq.check_stats_lead()
  lead_ticker = lead_ticker + 1 ;

  -- alternating the sending of party_names and party_stats
  -- in an effort to reduce the number of msgs coming from the lead
  -- at any one moment
  --
  if ((lead_ticker % 2) == 1) then
    oq.lead_send_party_names() ;
  else
    oq.lead_send_party_stats() ;
  end
end

function oq.send_lag_times()
  local msg = "lag_times" ;
  for i=1,8 do
    msg = msg ..",".. (oq.raid.group[i].member[1].lag or 0) ;
  end
  oq.raid_announce( msg ) ;  
end

function oq.set_lag( grp, label, tm )
  tm = tonumber(tm) or 0 ;
  grp.member[1].lag = tm ;
  if (grp.member[1].name == nil) or (grp.member[1].name == "-") then
    label:SetText( "" ) ;
  else
    label:SetText( string.format( "%5.2f", tm/1000 )) ;  
  end
end

function oq.on_lag_times( t1, t2, t3, t4, t5, t6, t7, t8 )
  oq.set_lag( oq.raid.group[1], oq.tab1_group[1].lag, t1 ) ;
  oq.set_lag( oq.raid.group[2], oq.tab1_group[2].lag, t2 ) ;
  oq.set_lag( oq.raid.group[3], oq.tab1_group[3].lag, t3 ) ;
  oq.set_lag( oq.raid.group[4], oq.tab1_group[4].lag, t4 ) ;
  oq.set_lag( oq.raid.group[5], oq.tab1_group[5].lag, t5 ) ;
  oq.set_lag( oq.raid.group[6], oq.tab1_group[6].lag, t6 ) ;
  oq.set_lag( oq.raid.group[7], oq.tab1_group[7].lag, t7 ) ;
  oq.set_lag( oq.raid.group[8], oq.tab1_group[8].lag, t8 ) ;
  oq.raid._last_lag = utc_time() ;
end

function oq.procs_init()
  -- all procs
  --
  oq.proc = {} ;
  oq.proc[ "brb"                ] = oq.on_brb ;
  oq.proc[ "btag"               ] = oq.on_btag ;
  oq.proc[ "btags"              ] = oq.on_btags ;
  oq.proc[ "charm"              ] = oq.on_charm ;
  oq.proc[ "disband"            ] = oq.on_disband ;
  oq.proc[ "enter_bg"           ] = oq.on_enter_bg ;
  oq.proc[ "find"               ] = oq.queue_find_request ;
  oq.proc[ "group_hp"           ] = oq.on_group_hp ;
  oq.proc[ "gs"                 ] = oq.on_grp_stats ;  -- changed from "grp_stats"
  oq.proc[ "iam_back"           ] = oq.on_iam_back ;
  oq.proc[ "identify"           ] = oq.on_identify ;
  oq.proc[ "invite_accepted"    ] = oq.on_invite_accepted ;
  oq.proc[ "invite_group_lead"  ] = oq.on_invite_group_lead ;
  oq.proc[ "invite_group"       ] = oq.on_invite_group ;
  oq.proc[ "invite_req_response"] = oq.on_invite_req_response ;
  oq.proc[ "join"               ] = oq.on_join ;
  oq.proc[ "lag_times"          ] = oq.on_lag_times ;
  oq.proc[ "leave"              ] = oq.on_leave ;
  oq.proc[ "leave_slot"         ] = oq.on_leave_slot ;
  oq.proc[ "leave_queue"        ] = oq.on_leave_queue ;
  oq.proc[ "leave_waitlist"     ] = oq.on_leave_waitlist ;  
  oq.proc[ "mbox_bn_enable"     ] = oq.on_mbox_bn_enable ;
  oq.proc[ "member"             ] = oq.on_member ;
  oq.proc[ "mesh_tag"           ] = oq.on_mesh_tag ;
  oq.proc[ "name"               ] = oq.on_name ;
  oq.proc[ "need_btag"          ] = oq.on_need_btag ;
  oq.proc[ "new_lead"           ] = oq.on_new_lead ;
  oq.proc[ "party_join"         ] = oq.on_party_join ;
  oq.proc[ "party_msg"          ] = oq.on_party_msg ;
  oq.proc[ "party_names"        ] = oq.on_party_names ;
  oq.proc[ "party_slot"         ] = oq.on_party_slot ;
  oq.proc[ "party_slots"        ] = oq.on_party_slots ;
  oq.proc[ "party_update"       ] = oq.on_party_update ;
  oq.proc[ "pass_lead"          ] = oq.on_pass_lead ;
  oq.proc[ "ping"               ] = oq.on_ping ;
  oq.proc[ "ping_ack"           ] = oq.on_ping_ack ;
  oq.proc[ "premade"            ] = oq.on_premade ;
  oq.proc[ "premade_note"       ] = oq.on_premade_note ;
  oq.proc[ "promote"            ] = oq.on_promote ;
  oq.proc[ "proxy_invite"       ] = oq.on_proxy_invite ;
  oq.proc[ "proxy_target"       ] = oq.on_proxy_target ;
  oq.proc[ "oq_version"         ] = oq.on_oq_version ;   
  oq.proc[ "queue_tm"           ] = oq.on_queue_tm ;
  oq.proc[ "raid_join"          ] = oq.on_raid_join ;
  oq.proc[ "ready_check"        ] = oq.on_ready_check ;
  oq.proc[ "ready_check_complete"] = oq.on_ready_check_complete ;
  oq.proc[ "remove"             ] = oq.on_remove ;
  oq.proc[ "remove_group"       ] = oq.on_remove_group ;
  oq.proc[ "removed_from_waitlist" ] = oq.on_removed_from_waitlist ;
  oq.proc[ "report_recvd"       ] = oq.on_report_recvd ;
  oq.proc[ "req_invite"         ] = oq.on_req_invite ;
  oq.proc[ "req_waitlist"       ] = oq.on_req_waitlist ;
  oq.proc[ "req_waitlist_party" ] = oq.on_req_waitlist_party ;
  oq.proc[ "role_check"         ] = oq.on_role_check ;
  oq.proc[ "scores"             ] = oq.on_scores ;
  oq.proc[ "stats"              ] = oq.on_stats ;
  oq.proc[ "top_dps_recvd"      ] = oq.on_top_dps_recvd ;
  oq.proc[ "top_heals_recvd"    ] = oq.on_top_heals_recvd ;
  
  -- these msgids will be processed while in a bg
  oq.bg_msgids                = {} ;
  oq.bg_msgids[ "pass_lead"       ] = 1 ;
  oq.bg_msgids[ "premade"         ] = 1 ;
  oq.bg_msgids[ "report_recvd"    ] = 1 ;
  oq.bg_msgids[ "top_dps_recvd"   ] = 1 ;
  oq.bg_msgids[ "top_heals_recvd" ] = 1 ;
  
  -- remove raid-only procs
  oq.procs_no_raid() ;
end

-- in-raid only procs
--
function oq.procs_join_raid()
--[[ no raid required
  oq.proc[ "btags"                 ] = oq.on_btags ;
  oq.proc[ "disband"               ] = oq.on_disband ;
  oq.proc[ "find"                  ] = oq.queue_find_request ;
  oq.proc[ "invite_accepted"       ] = oq.on_invite_accepted ;
  oq.proc[ "invite_group_lead"     ] = oq.on_invite_group_lead ;
  oq.proc[ "invite_group"          ] = oq.on_invite_group ;
  oq.proc[ "invite_req_response"   ] = oq.on_invite_req_response ;
  oq.proc[ "leave_waitlist"        ] = oq.on_leave_waitlist ;  
  oq.proc[ "mbox_bn_enable"        ] = oq.on_mbox_bn_enable ;
  oq.proc[ "mesh_tag"              ] = oq.on_mesh_tag ;
  oq.proc[ "oq_version"            ] = oq.on_oq_version ;   
  oq.proc[ "party_join"            ] = oq.on_party_join ;
  oq.proc[ "party_slot"            ] = oq.on_party_slot ;
  oq.proc[ "party_slots"           ] = oq.on_party_slots ;
  oq.proc[ "premade"               ] = oq.on_premade ;
  oq.proc[ "proxy_invite"          ] = oq.on_proxy_invite ;
  oq.proc[ "proxy_target"          ] = oq.on_proxy_target ;
  oq.proc[ "raid_join"             ] = oq.on_raid_join ;
  oq.proc[ "removed_from_waitlist" ] = oq.on_removed_from_waitlist ;
  oq.proc[ "report_recvd"          ] = oq.on_report_recvd ;
  oq.proc[ "req_invite"            ] = oq.on_req_invite ;
  oq.proc[ "req_waitlist"          ] = oq.on_req_waitlist ;
  oq.proc[ "req_waitlist_party"    ] = oq.on_req_waitlist_party ;
  oq.proc[ "scores"                ] = oq.on_scores ;
  oq.proc[ "tops_recvd"            ] = oq.on_tops_recvd ;
]]
  -- raid required procs
  --
  oq.proc[ "brb"                ] = oq.on_brb ;
  oq.proc[ "btag"               ] = oq.on_btag ;
  oq.proc[ "charm"              ] = oq.on_charm ;
  oq.proc[ "enter_bg"           ] = oq.on_enter_bg ;
  oq.proc[ "group_hp"           ] = oq.on_group_hp ;
  oq.proc[ "gs"                 ] = oq.on_grp_stats ;  -- changed from "grp_stats"
  oq.proc[ "iam_back"           ] = oq.on_iam_back ;
  oq.proc[ "identify"           ] = oq.on_identify ;
  oq.proc[ "join"               ] = oq.on_join ;
  oq.proc[ "lag_times"          ] = oq.on_lag_times ;
  oq.proc[ "leave"              ] = oq.on_leave ;
  oq.proc[ "leave_slot"         ] = oq.on_leave_slot ;
  oq.proc[ "leave_queue"        ] = oq.on_leave_queue ;
  oq.proc[ "member"             ] = oq.on_member ;
  oq.proc[ "name"               ] = oq.on_name ;
  oq.proc[ "need_btag"          ] = oq.on_need_btag ;
  oq.proc[ "new_lead"           ] = oq.on_new_lead ;
  oq.proc[ "party_msg"          ] = oq.on_party_msg ;
  oq.proc[ "party_names"        ] = oq.on_party_names ;
  oq.proc[ "party_update"       ] = oq.on_party_update ;
  oq.proc[ "pass_lead"          ] = oq.on_pass_lead ;
  oq.proc[ "ping"               ] = oq.on_ping ;
  oq.proc[ "ping_ack"           ] = oq.on_ping_ack ;
  oq.proc[ "premade_note"       ] = oq.on_premade_note ;
  oq.proc[ "promote"            ] = oq.on_promote ;
  oq.proc[ "queue_tm"           ] = oq.on_queue_tm ;
  oq.proc[ "ready_check"        ] = oq.on_ready_check ;
  oq.proc[ "ready_check_complete"] = oq.on_ready_check_complete ;
  oq.proc[ "remove"             ] = oq.on_remove ;
  oq.proc[ "remove_group"       ] = oq.on_remove_group ;
  oq.proc[ "role_check"         ] = oq.on_role_check ;
  oq.proc[ "stats"              ] = oq.on_stats ;
end

-- nulls the in-raid only procs
--
function oq.procs_no_raid()
  -- clear the associated function for raid-only procs
  --
  oq.proc[ "brb"                ] = nil ;
  oq.proc[ "btag"               ] = nil ;
  oq.proc[ "charm"              ] = nil ;
  oq.proc[ "enter_bg"           ] = nil ;
  oq.proc[ "group_hp"           ] = nil ;
  oq.proc[ "gs"                 ] = nil ;   -- changed from "grp_stats"
  oq.proc[ "iam_back"           ] = nil ;
  oq.proc[ "identify"           ] = nil ;
  oq.proc[ "join"               ] = nil ;
  oq.proc[ "lag_times"          ] = nil ;
  oq.proc[ "leave"              ] = nil ;
  oq.proc[ "leave_group"        ] = nil ;
  oq.proc[ "leave_queue"        ] = nil ;
  oq.proc[ "member"             ] = nil ;
  oq.proc[ "name"               ] = nil ;
  oq.proc[ "need_btag"          ] = nil ;
  oq.proc[ "new_lead"           ] = nil ;
  oq.proc[ "party_msg"          ] = nil ;
  oq.proc[ "party_names"        ] = nil ;
  oq.proc[ "party_update"       ] = nil ;
  oq.proc[ "pass_lead"          ] = nil ;
  oq.proc[ "ping"               ] = nil ;
  oq.proc[ "ping_ack"           ] = nil ;
  oq.proc[ "premade_note"       ] = nil ;
  oq.proc[ "promote"            ] = nil ;
  oq.proc[ "queue_tm"           ] = nil ;
  oq.proc[ "ready_check"        ] = nil ;
  oq.proc[ "ready_check_complete"] = nil ;
  oq.proc[ "remove"             ] = nil ;
  oq.proc[ "remove_group"       ] = nil ;
  oq.proc[ "role_check"         ] = nil ;
  oq.proc[ "stats"              ] = nil ;
end

function oq.forward_msg( source, sender, msg_type, msg_id, msg ) 
  if (_source == "bnet") and (not oq.iam_party_leader()) and (msg_type == 'B') then
    _ok2relay = 1 ;
  end
  
  -- no relaying while in a BG.  BATTLEGROUND msgs are BG-wide, everything else stops here
  --
  if (_msg_id == "premade") and (_inc_channel ~= "oqgeneral") then
    oq.channel_general( msg ) ;
  end
  if (_inside_bg) then
    return ;
  end
  if (_to_realm ~= nil) and (_to_name ~= nil) then
    if (_to_realm == player_realm) then
      _ok2relay = nil ;  -- on the realm, just send direct
    end
    if (_to_name == player_name) then
      -- msg was for me, do not forward unless it was an announcement ... then strip off the to & realm fields and send
      if (msg_type == 'A') then
        if (_msg_id == nil) or (_msg_id ~= "premade") then
          oq.announce_relay( _core_msg ) ;
        end
      elseif ((msg_type == 'R') and (not oq.iam_raid_leader()) and oq.iam_party_leader()) then
        -- raid msg coming from raid leader, just send to channel
        oq.channel_party( _core_msg ) ;      
      end
      return ;
    end
    -- delivered
    oq.SendAddonMessage( "OQ", msg, "WHISPER", _to_name ) ;
    return ;
  end
  if (_ok2relay == "bnet") then
    oq.bnfriends_relay( msg ) ;
    _ok2relay = nil ; -- it's been sent via bnfriends, stop it there
  end
  if (not _ok2relay) then
    return ;
  end
  if (oq.iam_raid_leader()) and ((msg_type == 'B') or (msg_type == 'R')) then
    -- relay to group leads
    oq.send_to_group_leads( msg ) ;
    oq.channel_party( msg ) ;
    return ;
  end
  if (source == "bnet") and ((msg_type == 'B') or (msg_type == 'P') or (msg_type == 'R')) and (not oq.iam_raid_leader()) then
    -- receiving msg via an alt (happens with multi-boxers); must send to raid leader
    if (sender ~= oq.raid.leader) then  -- prevent back flow
      oq.whisper_raid_leader( msg ) ;
    end
    oq.whisper_party_leader( msg ) ;
  end
  if ((msg_type == 'A') or ((msg_type == 'W') and (not _received))) then
    oq.bn_echo_raid( msg ) ;
    oq.announce_relay( msg ) ;
  elseif (msg_type == 'P') then
    oq.channel_party( msg ) ;
  elseif (msg_type == 'R') then
    if (oq.iam_party_leader() and (_source == "party")) then
      oq.whisper_raid_leader( msg ) ;
    elseif (oq.iam_party_leader() and (_source ~= "party")) then
      oq.channel_party( msg ) ;
    end
  end
end

function oq.on_oq_version( version, build )
  build = tonumber(build) ;
  if (build == nil) or (build == OQ_BUILD) then
    -- match, bail out
    return ;
  end
  -- x.xx
  if (#version > 4) then
    return ;
  end
  local major, minor, revision =  version:match( "(%d+).(%d+)(%w?)" ) ;
  if (major == nil) or (minor == nil) then
    return ;
  end
  local now = utc_time() ;
  if (build < OQ_BUILD) then
    -- my version is the same or newer, nothing to do.  
    return ;
  elseif (OQ_data.next_update_notice == nil) or (OQ_data.next_update_notice < now) then
    -- notify user
    local dialog = StaticPopup_Show("OQ_NewVersionAvailable", version, build ) ;
    dialog:SetWidth( 400 ) ;
    dialog:SetHeight( 175 ) ;
    -- update notification cycle
    OQ_data.next_update_notice = now + OQ_NOTIFICATION_CYCLE ; 
  end
end

function oq.check_version( vars )
  local oq_sig   = vars[1] ;
  local oq_ver   = vars[2] ;
--  local token    = vars[3] ;
  local msg_id   = vars[5] ;
  local version  = vars[6] ;
  local build    = vars[7] ;
  if (msg_id == nil) or (oq_sig ~= "OQ") then
    -- definitely not an OQ msg
    return ;
  end
  -- definitely an OQ msg if it gets this far
  --
  if (msg_id == "oq_version") then
    oq.on_oq_version( version, build ) ;
  elseif (msg_id == "scores") then
    oq.verify_version( oq_ver, vars[8] ) ; -- vars[8] is the 3rd arg for 'scores'
  end
end

function oq.post_process()
  _sender      = nil ;
  _sender_pid  = nil ;
  _source      = nil ;
  _inc_channel = nil ;
  _msg         = nil ;
  _core_msg    = nil ;
end

function stricmp(a,b)
  if (a == nil) and (b == nil) then
    return true ;
  end
  if (a == nil) or (b == nil) then
    return nil ;
  end
  if (strlower(a) == strlower(b)) then
    return true ;
  end
  return nil ;
end

function oq.iam_related_to_boss()
  if (player_realm ~= oq.raid.leader_realm) then
    return nil ;
  end
  for i,v in pairs(OQ_toon.my_toons) do
    if (stricmp(v.name, oq.raid.leader)) then
      return true ;
    end
  end
  return nil ;
end

function oq.route_to_boss( msg )
  if (_sender ~= oq.raid.leader) then  -- prevent back flow
    oq.whisper_raid_leader( msg ) ;
  end
  oq.post_proces_cleanup() ;
end

function oq.process_msg( sender, msg )
  local vars = {};
  local v ;
  for v in string.gmatch(msg, "([^,]+)") do
    table.insert(vars, v);
  end
  _msg = msg ;
  _core_msg, _to_name, _to_realm, _from = oq.crack_bn_msg( msg ) ;

  --
  -- format:  "OQ,".. OQ_VER ..",".. msg_tok ..",".. hop | raid-token ..",".. msg ;
  --
  local oq_sig   = vars[1] ;
  local oq_ver   = vars[2] ;
  local token    = vars[3] ;
  local msg_id   = vars[5] ;
  local atok     = nil ;

  -- every msg recv'd is counted, not just those processed
  _pkt_recv  = _pkt_recv + 1 ;
  
  if (_inside_bg and (oq.bg_msgids[msg_id] == nil)) then
    return ;
  end
  if (oq_sig ~= "OQ") or (oq_ver ~= OQ_VER) or (OQ_toon.disabled) then
    -- not the same protocol, cannot proceed
    oq.check_version( vars ) ;
    return ;
  end
  _msg_type = token:sub(1,1) ;
  _oq_msg   = true ;
  
  if (_msg_type == 'A') then
    atok = vars[6] ; -- announce token
    if (not oq.atok_ok2process( atok )) then
      return ;
    end
  end
  
  --
  -- squash any echo
  --
--  if ((oq.token_was_seen( token )) and (msg_type ~= "Q")) then
  if ((token ~= "W1") and oq.token_was_seen( token )) then
    return ;
  end
  if ((token == "W1") and (_source == "oqgeneral")) then
    -- these messages cannot come from OQgen
    return ;
  elseif (token == "W1") then
    _ok2relay = nil ;
  end
  
  _msg_token     = token ;
  _msg_id        = msg_id ;
  _received      = nil ;
  _pkt_processed = _pkt_processed + 1 ;

  if ((_msg_id ~= "scores") and (_msg_id ~= "premade")) then
    if (_source == "bnet") and (_to_name ~= nil) and (_to_name ~= player_name) and
       (_to_realm ~= nil) and (_to_realm == player_realm) then
      oq.SendAddonMessage( "OQ", _core_msg, "WHISPER", _to_name ) ;
      oq.post_proces_cleanup() ;
      return ;
    end
    if (_source == "bnet") and (not oq.iam_raid_leader()) and oq.iam_related_to_boss() then
      oq.route_to_boss( _core_msg ) ;
      return ;
    end
  end
  -- hang onto token to reduce echo
  -- note: hold token after sending to boss as multi-acct bnets will route the data back 
  --       and dont want to ignore it when it comes back
  oq.token_push( token ) ;

  --
  -- unseen message-token.  ok to process
  --
  local inc_channel = _inc_channel ;
  _inc_channel = nil ;  -- suspend the nonsending for processing.  afterwards, put it back for relaying

  -- raid, party or boss msgs
  if ((_msg_type == 'R') or (_msg_type == 'P') or (_msg_type == 'B')) then
    local raid_token = vars[4] ;
    -- check to see if it's my raid token
    if (((oq.raid.raid_token == nil) or (raid_token == oq.raid.raid_token) or (msg_id == "party_join") or (msg_id == "raid_join")) and (oq.proc[ msg_id ] ~= nil)) then
      oq.proc[ msg_id ]( vars[ 6], vars[ 7], vars[ 8], vars[ 9], vars[10], 
                         vars[11], vars[12], vars[13], vars[14], vars[15], 
                         vars[16], vars[17], vars[18], vars[19], vars[20],
                         vars[21], vars[22], vars[23], vars[24], vars[25],
                         vars[26], vars[27], vars[28], vars[29], vars[30],
                         vars[31], vars[32], vars[33], vars[34], vars[35]
                        ) ;
    end
  elseif ((_msg_type == 'A') or (_msg_type == 'W')) then
    _hop = tonumber(vars[4]) ;
    if (oq.proc[ msg_id ] ~= nil) then
      oq.proc[ msg_id ]( vars[ 6], vars[ 7], vars[ 8], vars[ 9], vars[10], 
                         vars[11], vars[12], vars[13], vars[14], vars[15], 
                         vars[16], vars[17], vars[18], vars[19], vars[20],
                         vars[21], vars[22], vars[23], vars[24], vars[25],
                         vars[26], vars[27], vars[28], vars[29], vars[30],
                         vars[31], vars[32], vars[33], vars[34], vars[35]
                        ) ;
    else
      _ok2relay = nil ;
    end
    -- rebuild msg for transport, incrementing #hops
    if ((_msg_type == 'A') and (_hop > 0) and (_hop <= OQ_TTL)) then
      vars[4] = _hop - 1 ;
      msg = "" ;
      for i=1,#vars do
        if (i == 1) then
          msg = vars[i] ;
        else
          msg = msg ..",".. vars[i] ;
        end
      end
      -- re-crack to get update the core_msg
      _core_msg, _to_name, _to_realm, _from = oq.crack_bn_msg( msg ) ;      
    elseif (_msg_type == 'A') then
      _ok2relay = nil ;
    end
  end

  -- reset the inc channel
  _inc_channel = inc_channel ;

  --
  -- spread message 
  --
  if (token ~= "W1") or ((token == "W1") and (_to_name ~= nil) and (_to_name ~= player_name)) then
    if (_msg_type == 'A') and (not _ok2relay) then
      -- # hops exceeded, do nothing and return 
    else
      oq.forward_msg( _source, sender, _msg_type, msg_id, msg ) ;
    end
  end

  -- clean up
  oq.post_proces_cleanup() ;
end

function oq.post_proces_cleanup()
  _sender     = nil ;
  _sender_pid = nil ;
  _local_msg  = nil ;
  _source     = nil ;
  _ok2relay   = 1 ; 
  _dest_realm = nil ;
  _msg_type   = nil ;
  _msg_id     = nil ;
  _core_msg   = nil ;
  _to_name    = nil ;
  _to_realm   = nil ;  
end

function oq.send_queue_tm( g_id, s1, tm1, s2, tm2 ) 
  if (oq.raid.raid_token == nil) then
    return ; 
  end
  if (not oq.iam_party_leader() or _inside_bg) then
    return ;
  end
  oq.raid_announce( "queue_tm,".. 
                     g_id ..",".. 
                     (s1 or "0") ..","..
                     (tm1 or 0) ..","..
                     (s2 or "0") ..","..
                     (tm2 or 0) 
                  ) ;  
                  
end

-- TODO: subtract off leader timestamp to show time difference
--
function oq.update_status_txt()
  local lead = oq.raid.group[ 1 ].member[1] ;
  
  for i,v in pairs(oq.raid.group) do
    local mem = v.member[1] ;
    if ((mem.name ~= nil) and (mem.name ~= "") and (mem.name ~= "-")) then
      for j=1,2 do
        local txt = OQ.QUEUE_STATUS[ mem.bg[j].status ] ;
        oq.tab1_group[ i ].status[ j ]:SetText( txt or "-" ) ; 
        oq.tab1_group[ i ].status[ j ]:SetTextColor( 0.9, 0.9, 0.1, 1 ) ; 
        
        if (mem.bg[j].status == "2") then
          -- status: confirmed
          local dt = mem.bg[j].queue_ts ;
          -- if raid lead has popped, subtract times to show diff from raid lead
          if ((i ~= 1) and (lead.bg[j].queue_ts ~= nil) and (lead.bg[j].queue_ts > 0) and (dt ~= nil)) then
            dt = math.abs(dt - lead.bg[j].queue_ts) ;
          end
          -- times are all milliseconds.  display in hundredths (ie: ss.hh)
          if (dt ~= nil) and (i == 1) then
            oq.tab1_group[ i ].dtime [ j ]:SetText( string.format( "%5.2f", (dt / 1000) ) ) ; 
            oq.tab1_group[ i ].dtime [ j ]:SetTextColor( 0.9, 0.9, 0.9, 1  ) ;
            oq.tab1_group[ i ].status[ j ]:SetTextColor( 0.1, 0.9, 0.1, 1 ) ; -- first group is always good
          else
            oq.tab1_group[ i ].dtime[ j ]:SetText( string.format( "%5.2f", (dt / 1000) ) ) ; 
            oq.tab1_group[ i ].dtime[ j ]:SetTextColor( 0.9, 0.9, 0.9, 1  ) ;
            if (mem.lag ~= nil) then
              if ((dt < (2 * mem.lag)) or (dt < 0.3)) then -- 2*lag or less then 0.30 seconds; trying to remove the guess work
                oq.tab1_group[ i ].dtime [ j ]:SetTextColor( 0.1, 0.9, 0.1, 1 ) ;  
                oq.tab1_group[ i ].status[ j ]:SetTextColor( 0.1, 0.9, 0.1, 1 ) ;  
              elseif (math.abs(dt) < (3 * mem.lag)) then
                oq.tab1_group[ i ].dtime [ j ]:SetTextColor( 0.9, 0.9, 0.1, 1 ) ;
                oq.tab1_group[ i ].status[ j ]:SetTextColor( 0.9, 0.9, 0.1, 1 ) ;  
              else
                oq.tab1_group[ i ].dtime [ j ]:SetTextColor( 0.9, 0.1, 0.1, 1 ) ;
                oq.tab1_group[ i ].status[ j ]:SetTextColor( 0.9, 0.1, 0.1, 1 ) ;  
              end
            end
          end
        else
          oq.tab1_group[ i ].dtime[ j ]:SetText( "" ) ; 
        end
      end
    end
  end
end

function oq.excited_cheer()
  PlaySoundFile("Sound\\Events\\GuldanCheers.wav") ;
  PlaySound("LevelUp") ;
  PlaySoundFile("Sound\\interface\\levelup2.wav") ;
end

function oq.on_player_target_change()
  local name = GetUnitName("target", true ) ;
  if (name == nil) or (not _inside_bg) then
    return ;
  end
  name = strlower(name) ;
  if ((name == "tinystomper") or (name == "tinystomper-magtheridon")) and (player_faction == "A") then
    local now = utc_time() ;
    if (_hailtiny == nil) or ((now - _hailtiny) > HAILTOTHEKINGBABY) then
      -- hail to the king, baby
      _hailtiny = now ;
      DoEmote("hail") ;
      oq.excited_cheer() ;
    end
  end
end

function oq.on_queue_tm( g_id, s1, tm1, s2, tm2 ) 
  g_id   = tonumber( g_id ) ;

  local bg1    = oq.raid.group[ g_id ].member[1].bg[ 1 ] ;
  bg1.queue_ts = tonumber(tm1) ;

  local bg2    = oq.raid.group[ g_id ].member[1].bg[ 2 ] ;
  bg2.queue_ts = tonumber(tm2) ;
  
  oq.update_status_txt() ;
end

function oq.on_bg_event(event,...)
  if (my_group < 1) or (my_slot < 1) then
    return ;
  end
  local me = oq.raid.group[my_group].member[my_slot] ;
  for i = 1,2 do
    if (oq.tab1_bg[i].status == "1") then
      oq.tab1_bg[i].status = "2" ; -- queue'd
      me.bg[i].start_tm = GetTime() ;
      return ;
    end
  end
end

function oq.bn_enabled( toonName, realm, faction, presenceID, isOnline, enabled )
  local name = toonName .."-".. realm ;
  local friend = OQ_data.bn_friends[name] ;
  
  if (friend == nil) then
    OQ_data.bn_friends[name] = {} ;
  elseif (friend.oq_enabled == enabled) then
    friend.presenceID = presenceID ;
    friend.isOnline   = isOnline ;
    return ;
  end
  friend = OQ_data.bn_friends[name] ;
 
  friend.toonName      = toonName ;
  friend.realm         = realm ;
  friend.faction       = faction ;
  friend.presenceID    = presenceID ;
  friend.isOnline      = isOnline ;
  if (enabled ~= "unk") then
    friend.oq_enabled    = enabled ;
    if (enabled) then
      oq.mbnotify_bn_enable( friend.toonName, friend.realm, 1 ) ;
    else
      oq.mbnotify_bn_enable( friend.toonName, friend.realm, 0 ) ;
    end
  end
  oq.n_connections() ;
end

function oq.isNewPresenceID( pid )
  if (pid ~= nil) then
    for i,v in pairs(OQ_data.bn_friends) do
      if (v.presenceID == pid) then
        return true ;
      end
    end
  end
  return nil ;
end

function oq.check_if_new( pid, toonName, realmName )
  local name = toonName .."-".. realmName ;
  local friend = OQ_data.bn_friends[ name ] ;
  --
  -- only does the check if more then 30 seconds have passed or the name is new
  --
  if (friend ~= nil) then
    local now = utc_time() ;
    if (next_bn_check > now) then
      return ;
    end
  else
    OQ_data.bn_friends[ name ] = {} ;
    friend = OQ_data.bn_friends[ name ] ;
    friend.isOnline      = true ;
    friend.toonName      = toonName ;
    friend.realm         = realmName ;
    friend.presenceID    = pid ;
  end
  
  friend.oq_enabled    = nil ;
  local f = { BNGetFriendInfoByID( pid ) } ;
  local broadcast  = f[12] ;
  if (broadcast ~= nil) and (broadcast:sub(1, #OQ_BNHEADER ) == OQ_BNHEADER) then
    friend.oq_enabled = true ;
  end
  if (broadcast ~= nil) and (broadcast:sub(1, #OQ_SKHEADER ) == OQ_SKHEADER) then
    friend.sk_enabled = true ;
  end
  oq.n_connections() ;
end

function oq.on_bn_event( ... )
  if (OQ_toon.disabled or (not oq.loaded)) then
    return ;
  end

  _arg = { ... } ;
  local msg        = _arg[1] ;
  local presenceID = _arg[13] ;
  if (presenceID == nil) or (presenceID == 0) or ((msg == nil) or (msg == "")) then
    return ;
  end
  
  _vars = { BNGetToonInfo(presenceID) } ;
  local toonName   = _vars[2] ;
  local realmName  = _vars[4] ;
  local faction    = _vars[6] ;
  
  if (toonName == nil) or (realmName == nil) then
    return ;
  end
  local name = toonName .."-".. realmName ;
  
  if (msg == OQUEUE_CHECK) or (msg == OQUEUE_OLD_CHECK) then
    -- being queried, send response
    BNSendWhisper( presenceID, OQ.RESPONSE_NEWVERSION ) ;
    BNSendWhisper( presenceID, OQ.RESPONSE_NEWVERSION2 ) ;
    _pkt_sent = _pkt_sent + 2 ;
    return ;
  end

  _sender     = name ;
  _sender_pid = presenceID ;
  _source     = "bnet" ;
  _oq_msg     = nil ;
  _ok2relay   = 1 ; 
  
  oq.check_if_new( presenceID, toonName, realmName ) ;
  
  oq.process_msg( name, msg ) ;
  oq.post_process() ;
end

function oq.on_channel_msg( ... )
  _arg = { ... } ;
  if (_arg[2] == player_name) or ((_arg[1] == nil) or (_arg[1] == "")) then
    return ;
  end

  local chan_name = strlower(_arg[9]) ;
  if (not oq.channel_isregistered( chan_name )) then
    return ;
  end
  if (chan_name == "oqgeneral") then
    _inc_channel = "oqgeneral" ;
    _local_msg = true ;
    _source = "oqgeneral" ;
    _ok2relay   = 1 ; 
    oq.process_msg( _arg[2], _arg[1] ) ;
    oq.post_process() ;
  end
end

function oq.queue_popped( ndx ) 
  if ((my_group == 0) or (my_slot == 0)) then
    return ;
  end
  -- hide wow standard dialog buttons
  -- if raid leader, show dialog with choice
  -- leader can choose to 'leave queue', abandoning the pop
  -- or choose to 'enter', which will send a msg to the raid 
  -- the message will display the 'enter now' button for raid members
  
--  local which = "CONFIRM_BATTLEFIELD_ENTRY" ;
--  StaticPopup_Hide( which ) ;
  
  -- would be nice to hide the buttons... but Hide() is nil 
  --    local OnCancel = StaticPopupDialogs[which].OnCancel
  
  if (oq.iam_raid_leader()) then
    -- show raid leader dialog
    StaticPopup1Button1:SetScript("PostClick", function(self) oq.raid_announce( "enter_bg,".. ndx ) ; end ) ;
    StaticPopup1Button2:SetScript("PostClick", function(self) oq.raid_announce( "leave_queue,".. ndx ) ; end ) ;
--[[
    local dialog = StaticPopup_Show("OQ_QueuePoppedLeader", nil, nil, ndx ) ;
    if (dialog) then
      dialog.data = ndx ;
    end
]]--
  else
    -- disable buttons so user can't click by accident
    StaticPopup1Button1:Disable() ;
    StaticPopup1Button2:Disable() ;
    
    -- show member dialog
    local dialog = StaticPopup_Show("OQ_QueuePoppedMember", nil, nil, ndx ) ;
    if (dialog) then
      dialog.data = ndx ;
    end
  end
end

function oq.send_my_queue_status()
  if ((my_group == 0) or (my_slot == 0) or not oq.iam_party_leader()) then
    return ;
  end
  local s1 = OQ.QUEUE_STATUS[ select(1, GetBattlefieldStatus(1)) ] ;
  local s2 = OQ.QUEUE_STATUS[ select(1, GetBattlefieldStatus(2)) ] ;
  local m  = oq.raid.group[ my_group ].member[ my_slot ] ;
  oq.send_queue_tm( my_group, s1, m.bg[1].queue_ts, s2, m.bg[2].queue_ts ) ;
end

function oq.get_zone_info()
  if (_bg_zone == nil) then
    _bg_zone = GetZoneText() ;
  end
  if (_bg_shortname == nil) then  
    _bg_shortname = OQ.BG_SHORT_NAME[ _bg_zone ] ;
    if (_bg_shortname == nil) then
      _bg_zone = nil ;
    end
  end
end

function oq.on_bg_score_update() 
  oq.flag_watcher() ;
  oq.get_zone_info() ;
  
  if ((my_group == 0) or (my_slot == 0)) then
    -- not in an OQ group
    if (GetBattlefieldWinner() ~= nil) and (_winner == nil) then
      oq.game_ended() ;
    end
    return ;
  end
  
  if (GetBattlefieldWinner() == nil) then
    oq.game_in_process() ;
  elseif (_winner == nil) then
    -- there is a winner and we haven't calc'd the stats yet
    oq.game_ended() ;
  end
end

function oq.on_bg_status_update() 
  if ((my_group == 0) or (my_slot == 0) or _inside_bg) then
    return ;
  end
  
  local s1 = OQ.QUEUE_STATUS[ select(1, GetBattlefieldStatus(1)) ] ;
  local s2 = OQ.QUEUE_STATUS[ select(1, GetBattlefieldStatus(2)) ] ;
  local m  = oq.raid.group[ my_group ].member[ my_slot ] ;
  local queued = nil ;
  if ((s1 ~= "0") or (s2 ~= "0")) then
    queued = 1 ;
  end
  oq.set_status_queued( my_group, my_slot, queued ) ;

  -- determine 'queue time'.  SS.ss
  --
  if ((s1 == "1") or (s1 == "0")) then
    -- reset the clock
    m.bg[1].queue_ts = 0 ;
  end
  if ((s1 == "1") and (m.bg[1].status == "0")) then
    -- from none to queue'd
    m.bg[1].start_tm = GetTime() ;
  end
  if ((s1 == "2") and (m.bg[1].status ~= s1)) then
    -- queue popped
    m.bg[1].confirm_tm = GetTime() ;
    if (m.bg[1].start_tm == nil) then
      m.bg[1].start_tm = m.bg[1].confirm_tm ;
    end
    m.bg[1].queue_ts = floor((m.bg[1].confirm_tm - m.bg[1].start_tm) * 1000) ; -- rounding to milliseconds
    oq.queue_popped( 1 ) ;
  end
  
  if ((s2 == "1") or (s2 == "0")) then
    -- reset the clock
    m.bg[2].queue_ts = 0 ;
  end
  if ((s2 == "1") and (m.bg[2].status == "0")) then
    -- from none to queue'd
    m.bg[2].start_tm = GetTime() ;
  end
  if ((s2 == "2") and (m.bg[2].status ~= s2)) then
    -- queue popped
    m.bg[2].confirm_tm = GetTime() ;
    if (m.bg[2].start_tm == nil) then
      m.bg[2].start_tm = m.bg[2].confirm_tm ;
    end
    m.bg[2].queue_ts = floor((m.bg[2].confirm_tm - m.bg[2].start_tm) * 1000) ; -- rounding to milliseconds
    oq.queue_popped( 2 ) ;
  end

  local changed = nil ;
  if (my_slot == 1) then
    -- only party leaders should send info
--    oq.timer( "snd_qstat", 2, oq.send_my_queue_status ) ;
  end

  if (m.bg[1].status ~= s1) then
    changed = 1 ;
  end
  if (m.bg[2].status ~= s2) then
    changed = 1 ;
  end

  m.bg[1].status = s1 ;
  m.bg[2].status = s2 ;

  oq.update_status_txt() ;

  -- only insta-trip if not leader, giving the leader a chance to bundle up stats
  if (my_slot == 1) then  
    lead_ticker = 1 ; -- force stats send on alternating ticker
    oq.timer_reset( "check_stats", 1 ) ;
  else
    oq.timer_trip( "check_stats" ) ;
  end
end

function oq.on_addon_loaded( name )
--  if (name == "oqueue") then
--    oq.on_init( GetTime() ) ;
--  end
end

function oq.good_region_info()
  if (string.sub(GetCVar("realmList"),1,2) == "us") then
    return true ;
  end
  if (string.sub(GetCVar("realmList"),1,2) == "eu") then
    return true ;
  end
  return nil ;
end

function oq.on_player_enter_world()
  if (oq.loaded) then
    return ;
  end
  if (oq.good_region_info()) then
    oq.on_init( GetTime() ) ;
  else
    -- no region info.
    print( OQ_REDX_ICON ) ;
    print( OQ_REDX_ICON .." Error : oQueue disabled" ) ;
    print( OQ_REDX_ICON .." Reason: Invalid realmlist information (".. GetCVar("realmList") ..")" ) ;
    print( OQ_REDX_ICON .." Reason: This usually happens due to private server use." ) ;
    print( OQ_REDX_ICON .." Action: Please exit wow, delete your config.wtf, and restart your wow" ) ;
    print( OQ_REDX_ICON ) ;
  end
  oq.loaded = true ;
end

function oq.chat_filter(self, event, msg, author, ...)
  if (msg:sub(1,#OQ_MSGHEADER) == OQ_MSGHEADER) or 
     (msg:sub(1,#OQSK_HEADER) == OQSK_HEADER) then
    -- make sure 'author' is bn.enabled
    return true ;
  end

  local now = GetTime() ;
  if ((msg == "You aren't in a party.") and (now < _error_ignore_tm)) then 
    -- ignore message
    return true ;   
  end

  -- hide error msg if scorekeeper is temporarily offline or being ignored
  if (msg:find( "No player named '".. OQ.SK_NAME .."' is currently playing") ~= nil) or
     ((msg:find( OQ.SK_NAME) ~= nil) and (msg:find( "is no longer being ignored" ) ~= nil)) then 
    -- ignore message
    return true ;   
  end
  
  -- remove duplicate afk msgs
  if (oq._last_afkmsg == nil) then
    oq._last_afkmsg = 0 ;
  end
  if ((msg:find( OQSYS_YOUARE_AFK ) ~= nil) or
     (msg:find( OQSYS_YOUARENOT_AFK ) ~= nil)) then
    if ((now - oq._last_afkmsg) < 15) then
      -- remove msg
      oq._last_afkmsg = now ;
      return true ;
    end
    oq._last_afkmsg = now ;
  end
  
  -- b-net spam 
  if (msg:find( "is not online" ) ~= nil) then
    return true ;
  end
  
  if (msg == OQUEUE_CHECK) or (msg == OQUEUE_OLD_CHECK) or
     (msg == OQUEUE_RESP_OK) or 
     (strlower(msg) == OQUEUE_RESP_GTFO) or 
     (strlower(msg) == OQUEUE_RESP_GTFO2) or 
     (strlower(msg) == OQUEUE_RESP_GTFO3) then
     return true ;
  end
  
  -- remove deadly boss mods messages
  if (msg:find( "<Deadly Boss Mods>" )) or 
     (msg:find( "<DBM>" )) then
     return true ;
  end  
--   return false, msg, author, ...
end

--------------------------------------------------------------------------
-- tooltip functions
--------------------------------------------------------------------------
function oq.tooltip_label( tt, x, y, align )
  local t = tt:CreateFontString() ;
  t:SetFontObject(GameFontNormal)
  t:SetWidth( tt:GetWidth()- (x + 2*15) ) ;
  t:SetHeight( 15 ) ;
  t:SetJustifyV( "CENTER" ) ;
  t:SetJustifyH( align ) ;
  t:SetText( "" ) ;
  t:Show() ;
  t:SetPoint("TOPLEFT", tt,"TOPLEFT", x, -1 * y ) ;
  return t ;
end

function oq.tooltip_create() 
  if (oq.tooltip ~= nil) then
    return oq.tooltip ;
  end
  local tooltip = CreateFrame("FRAME", "OQTooltip", UIParent, nil ) ;
  tooltip:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                       edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                       tile=true, tileSize = 16, edgeSize = 16,
                       insets = { left = 4, right = 3, top = 4, bottom = 3 }
                      })

  tooltip:SetBackdropColor(0.2,0.2,0.2,1.0);

  -- class portrait
  local f = CreateFrame("FRAME", "OQTooltipPortraitFrame", tooltip ) ;
  f:SetWidth(35) ;
  f:SetHeight(35) ;
  f:SetBackdropColor(0.8,0.8,0.8,1.0) ;

  local t = tooltip:CreateTexture( nil, "OVERLAY" ) ;
  t:SetTexture( "Interface\\TargetingFrame\\UI-Classes-Circles" ) ;
  t:SetAllPoints( f ) ;
  t:SetAlpha( 1.0 ) ;
  f.texture = t ;

  f:SetPoint( "TOPRIGHT", -6, -1 * 6 ) ;
  f:Show() ;
  tooltip.portrait = f ;

  local nRows = 12 ;
  tooltip:SetWidth ( 175 ) ;
  tooltip:SetHeight( (nRows+1)*(15+2) ) ;
  tooltip.left  = {} ;
  tooltip.right = {} ;

  local x = 8 ;
  local y = 8 ;
  for i = 1, nRows do
    tooltip.left [i] = oq.tooltip_label( tooltip, x, y, "LEFT"  ) ;
    tooltip.right[i] = oq.tooltip_label( tooltip, x, y, "RIGHT" ) ;
    if (i == 1) then
      x = x + 10 ;
      y = y + 2 ;
      tooltip.left [i]:SetFont(OQ.FONT, 12, "") ;
      tooltip.right[i]:SetFont(OQ.FONT, 12, "") ;
    else
      tooltip.left [i]:SetTextColor( 0.6, 0.6, 0.6 ) ;
      tooltip.left [i]:SetFont(OQ.FONT, 10, "") ;

      tooltip.right[i]:SetTextColor( 0.9, 0.9, 0.25 ) ;
      tooltip.right[i]:SetFont(OQ.FONT, 10, "") ;
    end
    y = y + 15 + 2 ;
  end
  oq.tooltip = tooltip ;
  return tooltip ;
end

function oq.tooltip_clear()
  local tooltip = oq.tooltip ;
  if (tooltip ~= nil) then
    for i = 1,6 do
      tooltip.left [i]:SetText( "" ) ;
      tooltip.right[i]:SetText( "" ) ;
    end
  end
end

function oq.tooltip_set( f, name, realm, bgroup, class, resil, ilevel, hp, nWins, nLosses, HKs, oq_ver, ntears, level, pvppower, mmr )
  local tooltip = oq.tooltip_create() ;
  tooltip:SetParent( f, "ANCHOR_RIGHT" ) ;
  tooltip:SetPoint("TOPLEFT", tooltip:GetParent(), "TOPRIGHT", 10, 0 ) ;
  tooltip:SetFrameLevel( f:GetFrameLevel() + 10 ) ;
  oq.tooltip_clear() ;

  if (OQ.CLASS_COLORS[class] == nil) then
    class = OQ.SHORT_CLASS[ class ] ;
    if (OQ.CLASS_COLORS[class] == nil) then
      return ;
    end
  end

  tooltip.left [ 1]:SetText( name .." (".. tostring(level or 0) ..")" ) ;
  tooltip.left [ 1]:SetTextColor( OQ.CLASS_COLORS[class].r, OQ.CLASS_COLORS[class].g, OQ.CLASS_COLORS[class].b, 1 ) ;
  tooltip.left [ 2]:SetText( realm ) ;
  tooltip.left [ 2]:SetTextColor( 0.0, 0.9, 0.9, 1 ) ;
  tooltip.left [ 3]:SetText( bgroup ) ;
  tooltip.left [ 3]:SetTextColor( 0.8, 0.8, 0.8, 1 ) ;
  tooltip.left [ 4]:SetText( OQ.TT_ILEVEL ) ;
  tooltip.right[ 4]:SetText( ilevel ) ;
  tooltip.left [ 5]:SetText( OQ.TT_RESIL ) ;
  tooltip.right[ 5]:SetText( resil ) ;
  tooltip.left [ 6]:SetText( OQ.TT_PVPPOWER ) ;
  tooltip.right[ 6]:SetText( pvppower ) ;
  tooltip.left [ 7]:SetText( OQ.TT_MMR ) ;
  tooltip.right[ 7]:SetText( mmr ) ;
  tooltip.left [ 8]:SetText( OQ.TT_MAXHP ) ;
  tooltip.right[ 8]:SetText( tostring(hp or 0) .." k" ) ;
  tooltip.left [ 9]:SetText( OQ.TT_WINLOSS ) ;
  tooltip.right[ 9]:SetText( tostring(nWins or 0) .." - ".. tostring(nLosses or 0) ) ;
  tooltip.left [10]:SetText( OQ.TT_HKS ) ;
  tooltip.right[10]:SetText( tostring(HKs or 0) .." k" ) ;
  tooltip.left [11]:SetText( OQ.TT_TEARS ) ;
  tooltip.right[11]:SetText( tostring( ntears or 0 ) ) ;
  tooltip.left [12]:SetText( OQ.TT_OQVERSION ) ;
  tooltip.right[12]:SetText( oq.get_version_str( oq_ver ) ) ;

  -- adjust dimensions of the box
  local w = tooltip.left[1]:GetStringWidth() ;
  tooltip.right[ 4]:SetWidth( tooltip:GetWidth() - 30 ) ;
  tooltip.right[ 5]:SetWidth( tooltip:GetWidth() - 30 ) ;
  tooltip.right[ 6]:SetWidth( tooltip:GetWidth() - 30 ) ;
  tooltip.right[ 7]:SetWidth( tooltip:GetWidth() - 30 ) ;
  tooltip.right[ 8]:SetWidth( tooltip:GetWidth() - 30 ) ;
  tooltip.right[ 9]:SetWidth( tooltip:GetWidth() - 30 ) ;
  tooltip.right[10]:SetWidth( tooltip:GetWidth() - 30 ) ;
  tooltip.right[11]:SetWidth( tooltip:GetWidth() - 30 ) ;
  tooltip.right[12]:SetWidth( tooltip:GetWidth() - 30 ) ;

  local t = CLASS_ICON_TCOORDS[ OQ.LONG_CLASS[class] ] ;
  if t then
    tooltip.portrait.texture:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles") ;
    tooltip.portrait.texture:SetTexCoord(unpack(t)) ;
    tooltip.portrait.texture:SetAlpha( 1.0 ) ;
  end

  tooltip:Show() ;
end

function oq.tooltip_show()
  local tooltip = oq.tooltip ;
  if (tooltip ~= nil) then
    tooltip:Show() ;
  end
end

function oq.tooltip_hide() 
  local tooltip = oq.tooltip ;
  if (tooltip ~= nil) then
    tooltip:Hide() ;
  end
end

--------------------------------------------------------------------------
-- text helper tooltip
--------------------------------------------------------------------------
function oq.gen_tooltip_label( tt, x, y, align )
  local t = tt:CreateFontString() ;
  t:SetFontObject(GameFontNormal)
  t:SetWidth( tt:GetWidth()- (x + 2*15) ) ;
  t:SetHeight( 3*25 ) ;
  t:SetJustifyV( "TOP" ) ;
  t:SetJustifyH( align or "LEFT" ) ;
  t:SetText( "" ) ;
  t:Show() ;
  t:SetPoint("TOPLEFT", tt,"TOPLEFT", x, -1 * y ) ;
  return t ;
end

function oq.gen_tooltip_create() 
  if (oq.gen_tooltip ~= nil) then
    return oq.gen_tooltip ;
  end
  local tooltip ;
  tooltip = CreateFrame("FRAME", "OQGenTooltip", UIParent, nil ) ;
  tooltip:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                       edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                       tile=true, tileSize = 16, edgeSize = 16,
                       insets = { left = 4, right = 3, top = 4, bottom = 3 }
                      })
--  local p = OQMainFrame ;
--  tooltip:SetPoint("TOPLEFT", p, "BOTTOMLEFT", 10, 0 ) ;

  tooltip:SetFrameStrata( "TOOLTIP" ) ;
  tooltip:SetBackdropColor(0.2,0.2,0.2,1.0);
  oq.setpos( tooltip, 100, 100, 100, 100 ) ;
  tooltip:Hide() ;

  tooltip.left  = {} ;
  tooltip.right = {} ;
  tooltip.left[1] = oq.gen_tooltip_label( tooltip, 8, 8 ) ;
  oq.gen_tooltip = tooltip ;
  return tooltip ;
end

function oq.gen_tooltip_clear()
  oq.gen_tooltip.left [1]:SetText( "" ) ;
  oq.gen_tooltip.right[1]:SetText( "" ) ;
end

function oq.gen_tooltip_set( f, txt )
  local tooltip = oq.gen_tooltip_create() ;
  tooltip:SetFrameLevel( 99 ) ;
  oq.tooltip_clear() ;
  tooltip.left [ 1]:SetText( txt ) ;

  -- adjust dimensions of the box
  local w = floor(tooltip.left[1]:GetStringWidth())  + 2*10 ;
  local h = 3*12 + 2*10 ;
  tooltip.left[1]:SetWidth ( w ) ;
  local x = f:GetLeft() + f:GetWidth() + 20 ;
  local y = (GetScreenHeight() - f:GetTop()) + f:GetHeight() + 20 ;
  tooltip:SetPoint("TOPLEFT", f, "BOTTOMRIGHT", 0, 0 ) ;
  oq.setpos( tooltip, x, y, w, h ) ;
  
  tooltip:Show() ;
end

function oq.gen_tooltip_show()
  if (oq.gen_tooltip ~= nil) then
    oq.gen_tooltip:Show() ;
  end
end

function oq.gen_tooltip_hide() 
  if (oq.gen_tooltip ~= nil) then
    oq.gen_tooltip:Hide() ;
  end
end

--------------------------------------------------------------------------
-- premade tooltip functions
--------------------------------------------------------------------------
local pm_tooltip = nil ;

function oq.pm_tooltip_create() 
  if (pm_tooltip ~= nil) then
    return pm_tooltip ;
  end
  pm_tooltip = CreateFrame("FRAME", "OQPMTooltip", UIParent, nil ) ;
  pm_tooltip:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                          edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                          tile=true, tileSize = 16, edgeSize = 16,
                          insets = { left = 4, right = 3, top = 4, bottom = 3 }
                         })

  pm_tooltip:SetBackdropColor(0.2,0.2,0.2,1.0);
  pm_tooltip:SetWidth ( 225 ) ;
  pm_tooltip:SetHeight( (11+1)*(15+2) ) ;
  pm_tooltip:SetMovable(true) ;
  pm_tooltip:SetFrameStrata( "TOOLTIP" ) ;
  pm_tooltip.left  = {} ;
  pm_tooltip.right = {} ;

  local x = 8 ;
  local y = 8 ;
  for i = 1, 11 do
    pm_tooltip.left [i] = oq.tooltip_label( pm_tooltip, x, y, "LEFT"  ) ;
    pm_tooltip.right[i] = oq.tooltip_label( pm_tooltip, x, y, "RIGHT" ) ;
    if (i == 1) then
      x = x + 10 ;
      y = y + 2 ;
      pm_tooltip.left [i]:SetFont(OQ.FONT, 12, "") ;
      pm_tooltip.right[i]:SetFont(OQ.FONT, 12, "") ;
    else
      pm_tooltip.left [i]:SetTextColor( 0.6, 0.6, 0.6 ) ;
      pm_tooltip.left [i]:SetFont(OQ.FONT, 10, "") ;

      pm_tooltip.right[i]:SetPoint("TOPRIGHT", pm_tooltip,"TOPRIGHT", -10, -1 * y ) ;
      pm_tooltip.right[i]:SetTextColor( 0.9, 0.9, 0.25 ) ;
      pm_tooltip.right[i]:SetFont(OQ.FONT, 10, "") ;
    end
    y = y + 15 + 2 ;
  end
  return pm_tooltip ;
end

function oq.pm_tooltip_clear()
  for i = 1,7 do
    pm_tooltip.left [i]:SetText( "" ) ;
    pm_tooltip.right[i]:SetText( "" ) ;
  end
end

function oq.fmt_time( tm )
  local nmin, nsec ;
  if (tm == nil) then
    return "0:00" ;
  end
  nmin = floor( tm / 60) ;
  nsec = floor( tm % 60) ;
  return string.format( "%d:%02d", nmin, nsec ) ;  
end

function oq.pm_tooltip_set( f, raid_token )
  oq.pm_tooltip_create() ;
  local p = f:GetParent():GetParent():GetParent() ;
  pm_tooltip:SetPoint("TOPLEFT", p, "TOPRIGHT", 10, 0 ) ;
  
--  pm_tooltip:SetFrameStrata( "HIGH" ) ;
--  pm_tooltip:SetFrameLevel( 128 ) ;
  pm_tooltip:Raise() ;
  oq.pm_tooltip_clear() ;

  local raid = oq.premades[raid_token] ;
  if (raid == nil) then
    return ;
  end
  local s = raid.stats ;
  local nMembers = s.nMembers ;
  local nWaiting = s.nWaiting ;
  if ((raid_token == oq.raid.raid_token) and oq.iam_raid_leader()) then
    s = OQ_data.stats ;
    nMembers, _avgresil, _avgilevel, nWaiting = oq.calc_raid_stats() ;
  end
  if (s == nil) then
    return ;
  end

  pm_tooltip.left [ 1]:SetText( raid.name ) ;
  
  pm_tooltip.left [ 2]:SetText( OQ.TT_LEADER ) ;
  pm_tooltip.right[ 2]:SetText( raid.leader ) ;
  
  pm_tooltip.left [ 3]:SetText( OQ.TT_REALM ) ;
  pm_tooltip.right[ 3]:SetText( raid.leader_realm ) ;
  
  pm_tooltip.left [ 4]:SetText( OQ.TT_BATTLEGROUP ) ;
  pm_tooltip.right[ 4]:SetText( oq.find_bgroup( raid.leader_realm ) ) ;
  
  pm_tooltip.left [ 5]:SetText( OQ.TT_MEMBERS ) ;
  pm_tooltip.right[ 5]:SetText( nMembers ) ;
  pm_tooltip.left [ 6]:SetText( OQ.TT_WAITLIST ) ;
  pm_tooltip.right[ 6]:SetText( nWaiting ) ;
  pm_tooltip.left [ 7]:SetText( OQ.TT_RECORD ) ;
  pm_tooltip.right[ 7]:SetText( s.nWins .." - ".. s.nLosses ) ;
  pm_tooltip.left [ 8]:SetText( OQ.TT_AVG_HONOR ) ;
  pm_tooltip.right[ 8]:SetText( s.avg_honor ) ;
  pm_tooltip.left [ 9]:SetText( OQ.TT_AVG_HKS ) ;
  pm_tooltip.right[ 9]:SetText( s.avg_hks ) ;
  pm_tooltip.left [10]:SetText( OQ.TT_AVG_GAME_LEN ) ;
  pm_tooltip.right[10]:SetText(oq.fmt_time( s.avg_bg_len or 0 )) ;
  pm_tooltip.left [11]:SetText( OQ.TT_AVG_DOWNTIME ) ;
  pm_tooltip.right[11]:SetText(oq.fmt_time( s.avg_down_tm or 0 )) ;

  pm_tooltip:Show() ;
end

function oq.pm_tooltip_show()
  if (pm_tooltip ~= nil) then
    pm_tooltip:Show() ;
  end
end

function oq.pm_tooltip_hide() 
  if (pm_tooltip ~= nil) then
    pm_tooltip:Hide() ;
  end
end

--------------------------------------------------------------------------
-- initialization functions & event handlers
--------------------------------------------------------------------------
function oq.on_event(self,event,...)
  if (oq.msg_handler[event] ~= nil) then
    oq.msg_handler[event]( ... ) ;
  end  
end

function oq.on_bn_friend_invite_added( ... )
  oq.on_bnet_friend_invite( ... ) ;
  oq.bn_check_online() ;
end

function oq.get_seat( name )
  if (name:find('-')) then
    name = name:sub(1, (name:find('-') or 0)-1 ) ;
  end
  for gid=1,8 do
    for slot=1,5 do
      local m = oq.raid.group[gid].member[slot] ;
      if (m.name == name) then
        return gid, slot ;
      end
    end
  end
  return 0, 0 ;
end

function oq.check_seat( name, group_id, slot )
  if (name:find('-')) then
    name = name:sub(1, (name:find('-') or 0)-1 ) ;
  end
  local m = oq.raid.group[group_id].member[slot] ;
  return (m.name == name) ;
end

function oq.first_open_seat( gid )
  for j=1,5 do
    if ((oq.raid.group[gid].member[j].name == nil) or (oq.raid.group[gid].member[j].name == "-")) then
      return gid, j ;
    end
  end
  return gid, 0 ;
end

function oq.swap_seats( m, x ) 
  local tmp1 = copyTable( m ) ;
  local tmp2 = copyTable( x ) ;
  m = copyTable( tmp2 ) ;
  x = copyTable( tmp1 ) ;
end

function oq.move_member( name, new_gid, new_slot ) 
  local old_gid, old_slot = oq.get_seat( name ) ;
  
  if (old_slot ~= 0) then
    local m = oq.raid.group[new_gid].member[new_slot] ;
    local x = oq.raid.group[old_gid].member[old_slot] ;
    oq.raid_announce( "party_slot,".. 
                       x.name ..","..
                       new_gid ..","..
                       new_slot
                    ) ;
--[[
    if (m.name ~= nil) and (m.name ~= "-") then
      oq.raid_announce( "party_slot,".. 
                         m.name ..","..
                         old_gid ..","..
                         old_slot
                      ) ;
    end
]]--
    oq.swap_seats( m, x ) ;
--    oq.raid_cleanup_slot( old_gid, old_slot ) ;  
  end 
--[[  
  local enc_data = oq.encode_data( "abc123", oq.raid.leader, oq.raid.leader_realm, oq.raid.leader_rid ) ;
  oq.raid_announce( "party_join,".. 
                      new_gid ..","..
                      oq.encode_name( oq.raid.name ) ..",".. 
                      oq.raid.leader_class ..",".. 
                      enc_data ..",".. 
                      oq.raid.raid_token  ..",".. 
                      oq.encode_note( oq.raid.notes )
                   ) ;
]]--
end

function oq.find_member( table, name )
  if (name == nil) or (name == "-") then
    return nil ;
  end
  for i=1,8 do
    for j=1,5 do
      local m = table[i].member[j] ;
      if (m.name ~= nil) and (m.name == name) then
        return m ;
      end
    end
  end
  return nil ;
end

function oq.assign_raid_seats()
  local n = GetNumGroupMembers() ;
  local slot = 0 ;
  local i, j ;
  local cur = copyTable( oq.raid.group ) ;
  local grp = {} ;
  my_group = 1 ;
  my_slot  = 1 ;
  for i=1,8 do
    grp[i] = 0 ;
  end

  for i=1,n do
    local name, _, gid = GetRaidRosterInfo(i) ;
    local realm ;
    name, realm = oq.crack_name( name ) ;

    grp[ gid ] = grp[ gid ] + 1 ;
    slot = grp[ gid ] ;
    if (name ~= nil) then
      local m = oq.find_member( cur, name ) ;
      if (m ~= nil) then
        oq.raid.group[gid].member[ slot ] = copyTable( m ) ;
        oq.raid.group[gid].member[ slot ].realm = realm ;
        oq.raid.group[gid].member[ slot ].realm_id = oq.realm_cooked(realm) ;
        oq.set_textures( gid, slot ) ;
      else
        oq.raid.group[gid].member[ slot ].name  = name ;
        oq.raid.group[gid].member[ slot ].realm = realm ;
        oq.raid.group[gid].member[ slot ].realm_id = oq.realm_cooked(realm) ;
      end
    end
  end
  if (n == 0) then
    -- only one person in the 'raid'
    local m = oq.find_member( cur, player_name ) ;
    gid = 1 ;
    grp[ gid ] = grp[ gid ] + 1 ;
    slot = grp[ gid ] ;
    oq.raid.group[gid].member[ slot ] = copyTable( m ) ;
    oq.set_textures( gid, slot ) ;    
  end
  -- make sure everyone knows we're in the raid
  local enc_data = oq.encode_data( "abc123", oq.raid.leader, oq.raid.leader_realm, oq.raid.leader_rid ) ;
  oq.raid_announce( "raid_join,".. 
                     oq.encode_name( oq.raid.name ) ..",".. 
                     tostring(oq.raid.type) ..","..
                     oq.raid.leader_class ..",".. 
                     enc_data ..",".. 
                     oq.raid.raid_token  ..",".. 
                     oq.encode_note( oq.raid.notes )
                  ) ;

  -- clear the other seats
  local ngroups = oq.nMaxGroups() ;
  for i=1,ngroups do
    if (grp[i] < 5) then
      for j=grp[i]+1,5 do
        oq.raid_cleanup_slot( i, j ) ;
      end
    end
    local names = oq.get_party_names( i ) ;
    
    -- the 'R' stands for 'raid' and should not be echo'd far and wide
    local msg_tok = "R".. oq.token_gen() ;
    oq.token_push( msg_tok ) ;
    local msg = "OQ,".. OQ_VER ..",".. msg_tok ..",".. oq.raid.raid_token ..",".. names ;
    oq.SendAddonMessage( "OQ", msg, "RAID" ) ;
  end
  -- cleanup (how to actually delete/free-up the memory??)
  cur = {} ;
  cur = nil ;
end

function oq.on_party_members_changed()
  oq.closeInvitePopup() ;
  local instance, instanceType = IsInInstance() ;
  if (_inside_bg) then
    return ;
  end
  if (oq.iam_party_leader()) then
    last_brief_tm = 0 ;
    lead_ticker = 1 ; -- force the sending of stats on the next tick
    if (my_group > 0) then
      oq.raid.group[ my_group ]._stats = nil ;
      oq.raid.group[ my_group ]._names = nil ; 
    end
    if ((oq.GetNumPartyMembers() > 0) and 
        (select(1,GetLootMethod()) ~= "freeforall") and 
        (instance == nil) and
        ((oq.raid.type ~= OQ.TYPE_DUNGEON) and (oq.raid.type ~= OQ.TYPE_RAID))) then
      SetLootMethod( "freeforall" ) ;
    end
    if (oq.GetNumPartyMembers() == 2) and (oq.iam_raid_leader()) then
      -- make sure it's a raid if required
      if (oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID) then
        ConvertToRaid() ;
      else
        ConvertToParty() ;
      end
    end
  elseif ((oq.GetNumPartyMembers() == 0) and (not oq.iam_raid_leader())) then
    -- was a party member and left party... need to clean up
    if (my_slot > 1) and (my_group > 0) then
      oq.quit_raid_now() ;
    end
  end
  if (oq.iam_raid_leader() and ((oq.raid.type == OQ.TYPE_RBG) or (oq.raid.type == OQ.TYPE_RAID))) then
    -- re-assign slots
    oq.assign_raid_seats() ;
  end
end

function oq.on_party_member_disable()
  oq.timer( "chk_dead", 2, oq.check_the_dead ) ;
end

-- hook the world map show function so we can know if the UI was forced closed by the map
function oq.WorldMap_show(...)
  local now = GetTime() ;
  if (oq.ui.old_show) then
    oq.ui.old_show(...) ;
  end
  if (now == oq.ui.hide_tm) then
    _ui_open = true ;
  end
end

-- hook for BNSetCustomMessage
function oq.BNSetCustomMessage(...)
  _arg = { ... } ;

  if (oq.old_bncustommsg ~= nil) then
    oq.old_bn_msg = _arg[1] or "" ;
    if (oq.old_bn_msg:sub(1, #OQ_BNHEADER ) == OQ_BNHEADER) or
       (oq.old_bn_msg:sub(1, #OQ_OLDBNHEADER ) == OQ_OLDBNHEADER) then
      -- strip it
      oq.old_bn_msg = oq.old_bn_msg:sub( #OQ_BNHEADER+1, -1 ) ;
    end
    oq.old_bncustommsg( OQ_BNHEADER .."".. oq.old_bn_msg ) ;
  else
  print( "b-net custom msg not available" ) ;
  end
end

function oq.set_bn_msg_clear()
  if (oq.old_bncustommsg ~= nil) and (oq.old_bn_msg ~= nil) then
    oq.old_bncustommsg( oq.old_bn_msg ) ;
  end
end

function oq.init_bn_custom_msg()
  if (BNSetCustomMessage ~= nil) and (oq.old_bncustommsg ~= BNSetCustomMessage) then
    oq.old_bncustommsg = BNSetCustomMessage ;
    BNSetCustomMessage = oq.BNSetCustomMessage ;
  end
  -- grab last msg and tack an [OQ] on the front
  local args = { BNGetInfo() } ;
--  pid, toonID, broadcast, bnetAFK, bnetDND  = BNGetInfo() ;
  local broadcast = args[4] ;
  -- pandaria update
  if (broadcast ~= nil) then
    broadcast = tostring(broadcast) ;
  end
  if (broadcast == nil) then
    oq.BNSetCustomMessage( "" ) ;
  elseif (broadcast:sub(1, #OQ_BNHEADER ) ~= OQ_BNHEADER) then
    oq.BNSetCustomMessage( broadcast ) ;
  end
end

function oq.reset_bn_custom_msg()
  if (oq.old_bncustommsg == nil) then
    return ;
  end
  BNSetCustomMessage = oq.old_bncustommsg ;
  oq.old_bncustommsg = nil ;
  BNSetCustomMessage( oq.old_bn_msg or "" ) ;
  oq.old_bn_msg = nil ;
end

function oq.on_channel_roster_update(id)
  if (_oqgeneral_id ~= nil) and (_oqgeneral_id == id) then
    oq.n_connections() ;
  end
end

function oq.toggle_gc( cb )
  if (cb:GetChecked()) then 
    OQ_toon.ok2gc = 1 ; 
  else 
    OQ_toon.ok2gc = 0 ; 
  end 
end

function oq.toggle_shout_kbs( cb )
  if (cb:GetChecked()) then 
    OQ_toon.shout_kbs = 1 ; 
    oq.ui:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") ;    
  else 
    OQ_toon.shout_kbs = 0 ; 
    if (OQ_toon.who_popped_lust == 0) and (OQ_toon.say_sapped == 0) and (OQ_toon.shout_kbs == 0) then
      oq.ui:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED") ;
    end
  end 
end

function oq.toggle_premade_ads( cb )
  if (cb:GetChecked()) then 
    OQ_data.show_premade_ads = 1 ; 
  else 
    OQ_data.show_premade_ads = 0 ; 
  end 
end

function oq.toggle_say_sapped( cb )
  if (cb:GetChecked()) then 
    OQ_toon.say_sapped = 1 ; 
    oq.ui:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") ;    
  else 
    OQ_toon.say_sapped = 0 ; 
    if (OQ_toon.who_popped_lust == 0) and (OQ_toon.say_sapped == 0) and (OQ_toon.shout_kbs == 0) then
      oq.ui:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED") ;
    end
  end 
end

function oq.toggle_who_popped_lust( cb )
  if (cb:GetChecked()) then 
    OQ_toon.who_popped_lust = 1 ; 
    oq.ui:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") ;    
  else 
    OQ_toon.who_popped_lust = 0 ; 
    if (OQ_toon.who_popped_lust == 0) and (OQ_toon.say_sapped == 0) and (OQ_toon.shout_kbs == 0) then
      oq.ui:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED") ;
    end
  end 
end

function oq.toggle_premade_qualified(cb)
  if (cb:GetChecked()) then
    oq.premade_filter_qualified = 1 ;
  else
    oq.premade_filter_qualified = 0 ;
  end
  oq.reshuffle_premades() ;
end

function oq.toggle_enforce_levels( cb )
  if (cb:GetChecked()) then
    oq.raid.enforce_levels = 1 ;
  else
    oq.raid.enforce_levels = 0 ;
  end
end

function oq.toggle_auto_role( cb )
  if (cb:GetChecked()) then
    OQ_toon.auto_role = 1 ;
  else
    OQ_toon.auto_role = 0 ;
  end
end

function oq.toggle_shout_caps( cb )
  if (cb:GetChecked()) then
    OQ_toon.shout_caps = 1 ;
  else
    OQ_toon.shout_caps = 0 ;
  end
end

function oq.toggle_btag_submit( cb )
  if (cb:GetChecked()) then
    OQ_data.ok2submit_tag = 1 ;
    OQ_data.btag_submittal_tm = utc_time() ;
  else
    OQ_data.ok2submit_tag = 0 ;
  end
end

function oq.toggle_ragequits( cb ) 
  if (cb:GetChecked()) then 
    OQ_toon.shout_ragequits = 1 ; 
  else 
    OQ_toon.shout_ragequits = 0 ; 
  end
end

function oq.toggle_autoaccept_mesh_request( cb )
  if (cb:GetChecked()) then 
    OQ_data.autoaccept_mesh_request = 1 ; 
  else 
    OQ_data.autoaccept_mesh_request = 0 ; 
  end
end

-- killing blow
function oq.on_party_kill( ... ) 
-- should already be populated in on_combat_log_event_unfiltered
--  _arg = { ... } ;
  local caster = _arg[5] ;
  local target = _arg[9] ;
  if (OQ_toon.shout_kbs == 1) and (_enemy ~= nil) and (target ~= nil) then
    if (caster == player_name) and (_enemy[target] ~= nil) then
      _nkbs = _nkbs + 1 ;
      print( OQ_SKULL_ICON .." killing blow: ".. target .."  (".. _nkbs .." so far)" ) ;
    end
  end
end

-- say sapped
function oq.on_spell_aura_applied( ... ) 
-- should already be populated in on_combat_log_event_unfiltered
--  _arg = { ... } ;
  local spellId = _arg[12] ;
  local target = _arg[9] ;
  local caster = _arg[5] ;
  
  if (OQ_toon.say_sapped == 1) then
    if ((spellId == 6770)
    and (target == player_name)
    and (_arg[2] == "SPELL_AURA_APPLIED" or _arg[2] == "SPELL_AURA_REFRESH"))
    then
      SendChatMessage(OQ.SAPPED, "SAY")
      DEFAULT_CHAT_FRAME:AddMessage("Sapped by: "..(caster or "(unknown)"))
    end
  end
end

-- who popped lust?
function oq.on_spell_cast_success( ... )
-- should already be populated in on_combat_log_event_unfiltered
--  _arg = { ... } ;

  local spellId = _arg[12] ;
  local caster  = _arg[5] ;
  if (OQ_toon.who_popped_lust == 1) and (_inside_bg) and (caster ~= nil) then
    -- _flags holding same faction player list by player name
    -- 
    if ((_arg[2] == "SPELL_CAST_SUCCESS") and (oq.WhoPoppedList_Ids[ spellId ] ~= nil) and (_flags[caster] ~= nil)) then
      _last_lust = OQ_SKULL_ICON .." ".. (caster or "(unknown)") .." popped ".. oq.WhoPoppedList_Ids[ spellId ] ;
      print( _last_lust ) ;
    end
  end
end

function oq.on_combat_log_event_unfiltered(...)
  -- first 2 args have been removed by the onEvent handler
  _arg = { ... } ;
  if (oq.combat_handler[ _arg[2] ] ~= nil) then
    oq.combat_handler[ _arg[2] ]( ... ) ;
  end
end

function oq.on_group_roster_update()
end

-- triggered by bn friends going online/offline
-- wait a half second to allow the data to populate before pulling
--
function oq.timer_bn_check_online()
  oq.timer_oneshot( 0.5, oq.bn_check_online ) ;
end

function oq.register_events() 
  oq.create_timer() ;

  oq.msg_handler = {} ;
  oq.msg_handler[ "ADDON_LOADED"                  ] = oq.on_addon_loaded ;
  oq.msg_handler[ "BN_CONNECTED"                  ] = oq.timer_bn_check_online ;
  oq.msg_handler[ "BN_FRIEND_ACCOUNT_OFFLINE"     ] = oq.timer_bn_check_online ;
  oq.msg_handler[ "BN_FRIEND_ACCOUNT_ONLINE"      ] = oq.timer_bn_check_online ;
  oq.msg_handler[ "BN_FRIEND_INVITE_ADDED"        ] = oq.on_bn_friend_invite_added ;
  oq.msg_handler[ "BN_SELF_ONLINE"                ] = oq.timer_bn_check_online ;
  oq.msg_handler[ "CHAT_MSG_ADDON"                ] = oq.on_addon_event ;
  oq.msg_handler[ "CHAT_MSG_BN_WHISPER"           ] = oq.on_bn_event ;
  oq.msg_handler[ "CHAT_MSG_CHANNEL"              ] = oq.on_channel_msg ;
  oq.msg_handler[ "CHAT_MSG_PARTY"                ] = oq.on_party_event ;
  oq.msg_handler[ "CHAT_MSG_PARTY_LEADER"         ] = oq.on_party_event ;
  oq.msg_handler[ "CHAT_MSG_RAID"                 ] = oq.on_party_event ;
  oq.msg_handler[ "CHAT_MSG_RAID_LEADER"          ] = oq.on_party_event ;
  oq.msg_handler[ "PARTY_INVITE_REQUEST"          ] = oq.on_party_invite_request ;
  oq.msg_handler[ "PARTY_MEMBER_DISABLE"          ] = oq.on_party_member_disable ;
  oq.msg_handler[ "GROUP_ROSTER_UPDATE"           ] = oq.on_party_members_changed ;
--  oq.msg_handler[ "PARTY_MEMBERS_CHANGED"         ] = oq.on_party_members_changed ;
--  oq.msg_handler[ "PLAYER_ENTERING_BATTLEGROUND"  ] = oq.bg_start ;
  oq.msg_handler[ "PLAYER_LEVEL_UP"               ] = oq.player_new_level ;
  oq.msg_handler[ "PLAYER_LOGOUT"                 ] = oq.on_logout ;
  oq.msg_handler[ "PLAYER_ENTERING_WORLD"         ] = oq.on_player_enter_world ;
  oq.msg_handler[ "PLAYER_TARGET_CHANGED"         ] = oq.on_player_target_change ;
  oq.msg_handler[ "PVP_RATED_STATS_UPDATE"        ] = oq.on_player_mmr_change ;
  
  oq.msg_handler[ "PVPQUEUE_ANYWHERE_SHOW"        ] = oq.on_bg_event ;
  oq.msg_handler[ "ROLE_CHANGED_INFORM"           ] = oq.check_my_role ;
-- too many messages for what i need.  changed to a check every 3-5 seconds via check_stats
--  oq.msg_handler[ "UNIT_AURA"                     ] = oq.check_for_deserter ;
  oq.msg_handler[ "UPDATE_BATTLEFIELD_SCORE"      ] = oq.on_bg_score_update ;
  oq.msg_handler[ "UPDATE_BATTLEFIELD_STATUS"     ] = oq.on_bg_status_update ;
  oq.msg_handler[ "WORLD_MAP_UPDATE"              ] = oq.on_world_map_change ;
  oq.msg_handler[ "CHANNEL_ROSTER_UPDATE"         ] = oq.on_channel_roster_update ;
  oq.msg_handler[ "COMBAT_LOG_EVENT_UNFILTERED"   ] = oq.on_combat_log_event_unfiltered ;
  
  oq.combat_handler = {} ;
  oq.combat_handler[ "PARTY_KILL"         ] = oq.on_party_kill ;
  oq.combat_handler[ "SPELL_AURA_APPLIED" ] = oq.on_spell_aura_applied ;
  oq.combat_handler[ "SPELL_AURA_REFRESH" ] = oq.on_spell_aura_applied ;
  oq.combat_handler[ "SPELL_CAST_SUCCESS" ] = oq.on_spell_cast_success ;
  
  oq.ui:SetScript( "OnShow", function( self ) oq.onShow( self ) ; end ) ;
  oq.ui.closepb:SetScript("OnHide",function(self) oq.onHide( self ) ; end) ;

  -- hook the world map show method so we can bring the OQ UI back up if it was forced-hidden  
  hooksecurefunc(WorldMapFrame, 'Show', function(self) oq.WorldMap_show() ; end) ;
  
  ------------------------------------------------------------------------
  --  register for events
  ------------------------------------------------------------------------
  oq.ui:RegisterEvent("ADDON_LOADED") ;
  oq.ui:RegisterEvent("PVPQUEUE_ANYWHERE_SHOW") ;
  oq.ui:RegisterEvent("BN_CONNECTED") ;
  oq.ui:RegisterEvent("BN_SELF_ONLINE") ;
  oq.ui:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE") ;
  oq.ui:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE") ;
  oq.ui:RegisterEvent("BN_FRIEND_INVITE_ADDED") ;
  oq.ui:RegisterEvent("CHANNEL_ROSTER_UPDATE") ;
  oq.ui:RegisterEvent("CHAT_MSG_ADDON") ;
  oq.ui:RegisterEvent("CHAT_MSG_CHANNEL") ;
  oq.ui:RegisterEvent("CHAT_MSG_BN_WHISPER") ;
  oq.ui:RegisterEvent("CHAT_MSG_PARTY") ;
  oq.ui:RegisterEvent("CHAT_MSG_PARTY_LEADER") ;
  oq.ui:RegisterEvent("CLOSE_WORLD_MAP") ;
  oq.ui:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") ;
--  oq.ui:RegisterEvent("COMBAT_LOG_EVENT") ;
  oq.ui:RegisterEvent("PARTY_INVITE_REQUEST") ;
  oq.ui:RegisterEvent("PARTY_MEMBER_DISABLE") ;
  oq.ui:RegisterEvent("GROUP_ROSTER_UPDATE") ;
--  oq.ui:RegisterEvent("PARTY_MEMBERS_CHANGED") ;
  oq.ui:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND") ;
  oq.ui:RegisterEvent("PLAYER_ENTERING_WORLD") ;
  oq.ui:RegisterEvent("PLAYER_LEVEL_UP") ;
  oq.ui:RegisterEvent("PLAYER_LOGOUT") ;
  oq.ui:RegisterEvent("PLAYER_TARGET_CHANGED") ;
  oq.ui:RegisterEvent("PVP_RATED_STATS_UPDATE") ;
  oq.ui:RegisterEvent("ROLE_CHANGED_INFORM") ;
  oq.ui:RegisterEvent("UNIT_AURA") ;
  oq.ui:RegisterEvent("UPDATE_BATTLEFIELD_SCORE") ;
  oq.ui:RegisterEvent("UPDATE_BATTLEFIELD_STATUS") ;
  oq.ui:RegisterEvent("WORLD_MAP_UPDATE") ;
  oq.ui:SetScript("OnEvent", oq.on_event ) ;
  if (RegisterAddonMessagePrefix( "OQ" ) ~= true) then
    print( "Error:  unable to register addon prefix: OQ" ) ;
  end
end

function oq.create_timer()
  oq.timers = {} ;
  oq.ui_timer = CreateFrame("Frame", "OQ_TimerFrame" ) ;
  oq.ui_timer:SetScript( "OnUpdate", function(self, elapsed) oq.timer_trigger( GetTime() ) ; end ) ;
  oq.ui_timer:SetSize( 10, 10 ) ;
  oq.ui_timer:Show() ;
end

function oq.init_bnet_friends()
  if ((OQ_data ~= nil) and (OQ_data.bn_friends == nil)) then
    OQ_data.bn_friends = {} ;
  elseif (OQ_data ~= nil) then
    for ndx,v in pairs( OQ_data.bn_friends ) do
      v.isOnline = nil ;
    end
  end
  if ((OQ_data ~= nil) and (OQ_data.btag_cache == nil)) then
    OQ_data.btag_cache = {} ;
  end
end

function oq.pass_bg_leader()
  if (not _inside_bg) then
    return ;
  end
  if (oq.raid.raid_token == nil) then
    return ;
  end
  if (not oq.IsRaidLeader()) then
    return ;
  end
  if (oq.iam_raid_leader()) then
    return ;
  end
  
  -- i'm in a BG, have BG leader, and should pass to OQ leader
  --
  local n = oq.raid.leader ;
  if (oq.raid.leader_realm ~= player_realm) then
    n = n .."-".. oq.raid.leader_realm ;
  end
  if (not UnitInRaid(n)) then
    return ;
  end
  if (UnitExists( n )) then
    print( "OQ: transferred BG leader to ".. n ) ;
    PromoteToLeader( n ) ;
  end
end

function oq.player_new_level()
  player_level = UnitLevel("player") ;
  if (my_group ~= 0) and (my_slot ~= 0) then
    oq.raid.group[my_group].member[my_slot].level = player_level ;
  end
  
  local minlevel, maxlevel = oq.get_player_level_range() ;
  if (minlevel == 0) then
    txt = "unavailable" ;
  elseif (minlevel == 90) then
    txt = "90" ;
  else
    txt = minlevel .." - ".. maxlevel ;
  end
  oq.tab3_level_range = txt ;
end

function oq.init_locals()
  oq.nwaitlist = 0 ;
  oq.nlistings = 0 ;
  oq._sktime_last_tm = 0 ;
  oq._sktime_last_dt = 0 ;
  oq.old_raids = {} ;
  oq.send_q = {} ;
  oq.premades  = {} ;
end

function oq.GetRealmName() 
  local name = GetRealmName() ;
  if (OQ.SHORT_BGROUPS[ name ] ~= nil) then
    -- normal realm name
    return name ;
  end
  -- special case
  if (OQ.REALMNAMES_SPECIAL[ name ] ~= nil) then
    return OQ.REALMNAMES_SPECIAL[ name ] ;
  end
  if (OQ.REALMNAMES_SPECIAL[ strlower( name ) ] ~= nil) then
    return OQ.REALMNAMES_SPECIAL[ strlower( name ) ] ;
  end
  return nil ;
end

function oq.onHyperlinkClick( self, link, text, button )
  local service = link:sub( 1, link:find( ":" ) -1 ) ;
  if (service ~= "oqueue") then
    if (oq.old_hyperlink_handler) then
      oq.old_hyperlink_handler( self, link, text, button ) ;
    end
    return ;
  end
  local token = link:sub( link:find( ":" ) +1, -1 ) ;
  if (button == "LeftButton") then
    -- wait list
    oq.check_and_send_request( token ) ;
  elseif (button == "RightButton") then
    -- ban list
    local premade = oq.premades[ token ] ;
    if (premade == nil) and (oq.old_raids ~= nil) and (oq.old_raids[token] ~= nil) then
      -- trolls may have disbanded, check if its on the 'old' list
      premade = { leader_rid = oq.old_raids[token].btag } ;
    end
    if (premade ~= nil) then
      local dialog = StaticPopup_Show("OQ_BanUser", premade.leader_rid) ;
      if (dialog ~= nil) then
        dialog.data2 = { flag = 4, btag = premade.leader_rid, raid_tok = token } ;
      end                                                            
    end
  end
end

function oq.on_init( now )
  if (oq.ui == nil) then
    print( "OQ ui not initalized properly" ) ;
  end
  oq.init_locals() ;
  oq.init_bnet_friends() ;
  oq.hook_options() ;
  oq.log_stop() ; -- just to make sure
  oq.init_table() ;
  oq.init_stats_data() ;
  oq.procs_init() ;    -- populates procs with all functions
  oq.procs_no_raid() ; -- remove in-raid only functions 
  oq.raid_init() ;
  oq.token_list_init() ;
  oq.my_tok = "C".. oq.token_gen() ;
  oq.make_frame_moveable( oq.ui ) ;
    
  if (OQ_data.log == nil) then
    oq.log_clear() ;
  end

  player_name      = UnitName("player") ;
  player_realm     = oq.GetRealmName() ;
  player_realm_id  = oq.realm_cooked( player_realm ) ;
  player_class     = OQ.SHORT_CLASS[ select(2, UnitClass("player")) ] ;
  player_level     = UnitLevel("player") ;
  player_ilevel    = oq.get_ilevel() ;
  player_resil     = oq.get_resil() ;
  player_realid    = select( 2, BNGetInfo() ) ;
  player_faction   = "H" ;
  if (strlower(select( 1, UnitFactionGroup("player"))) == "alliance") then
    player_faction = "A" ;
  end

  if (OQ_toon ~= nil) and (OQ_toon.raid ~= nil) and (OQ_toon.raid.type ~= nil) then
    oq.raid.type = OQ_toon.raid.type ;
  end
  oq.create_main_ui() ;
  oq.ui:SetFrameStrata( "MEDIUM" ) ;
  oq.marquee = oq.create_marquee() ;

  ChatFrame_AddMessageEventFilter( "CHAT_MSG_SYSTEM"           , oq.chat_filter ) ;
  ChatFrame_AddMessageEventFilter( "CHAT_MSG_BN_WHISPER"       , oq.chat_filter ) ;
  ChatFrame_AddMessageEventFilter( "CHAT_MSG_BN_WHISPER_INFORM", oq.chat_filter ) ;

  oq.old_hyperlink_handler = ChatFrame1:GetScript("OnHyperLinkClick") ;
  ChatFrame1:SetScript("OnHyperLinkClick", oq.onHyperlinkClick ) ;

  -- first time check
  oq.timer_oneshot( 2, oq.init_bn_custom_msg ) ;
  oq.on_bnet_friend_invite() ;
  oq.bn_check_online() ;
  
  -- define timers
  oq.timer( "chk4dead_premade"  ,   30, oq.remove_dead_premades          , true ) ;
  oq.timer( "join_OQGeneral"    ,   30, oq.join_oq_general               , nil  ) ; 
  oq.timer( "report_premades"   ,   20, oq.report_premades               , nil  ) ; 
  oq.timer( "report_submits"    ,   20, oq.timed_submit_report           , true ) ;
  oq.timer( "clear_the_dead"    ,   15, oq.clear_the_dead                , true ) ;
  oq.timer( "update_nfriends"   ,   15, oq.bn_check_online               , true ) ;
  oq.timer( "advertise_premade" ,   15, oq.advertise_my_raid             , true ) ;  
  oq.timer( "chk4dead_group"    ,   15, oq.check_for_dead_group          , true ) ;
  oq.timer( "auto_role_check"   ,   15, oq.auto_set_role                 , true ) ;
  oq.timer( "bnet_friend_req"   ,   10, oq.on_bnet_friend_invite         , true ) ;
  oq.timer( "reset_buttons"     ,    5, oq.normalize_static_button_height, true ) ;
  oq.timer( "find_requests"     ,    5, oq.process_find_requests         , true ) ;  
--  oq.timer( "pending_invites"   ,2.5, oq.check_pending_invites         , true ) ;
  oq.timer( "calc_pkt_stats"    ,    5, oq.calc_pkt_stats                , true ) ;
  oq.timer( "check_stats"       ,    4, oq.check_stats                   , true ) ;  -- check party and personal stats every 3 seconds; only send if changed
  oq.timer( "chk_bg_status"     ,    3, oq.check_bg_status               , true ) ;
  oq.timer( "waitlist update"   ,    1, oq.update_wait_times             , true ) ;
  oq.timer( "bn_send_q"         , 0.05, oq.BNSendQ_pop                   , true ) ; -- 20 times per second, throttles bn msgs
  
  oq.j2tw(1) ;
  
  oq.clear_report_attempts() ;
  oq.attempt_group_recovery() ;
  oq.show_version() ;

  if (OQ_toon.marquee_hide) then
    oq.marquee:Hide() ;
  else
    oq.marquee:Show() ;
  end

  OQ_MinimapButton_Reposition() ;
  if (OQ_toon.mini_hide) then
    OQ_MinimapButton:Hide() ;
  else
    OQ_MinimapButton:Show() ;
  end
  
  if (OQ_toon.my_toons == nil) then
    OQ_toon.my_toons = {} ;
  end
  
  oq.n_connections() ;
  -- initialize person bg ratings
  -- this will, hopefully, force the bg-rating info to come from the server (must be a better way)
  oq.timer_oneshot( 3, oq.cache_mmr_stats ) ;

  if (OQ.BGROUP_ICON == nil) or (OQ.BGROUPS == nil) or (OQ.SHORT_BGROUPS == nil) then  
    print( OQ_REDX_ICON .."  ".. OQ.ERROR_REGIONDATA ) ;
  end
end

function oq.cache_mmr_stats()
  if ((player_level >= 10) and PVPFrame) then
    PVPFrame:Show() ;
    PVPFrame:Hide() ;
  end
  oq.n_connections() ;
end

function oq.clear_report_attempts()
  if (OQ_toon.reports == nil) then
    OQ_toon.reports = {} ;
    return ;
  end
  for i,v in pairs(OQ_toon.reports) do
    v.last_tm       = 0 ;
    v.attempt       = nil ;
    v.submit_failed = nil ;
  end
end

-- returns deep copy of table object
function copyTable( tbl, copied )
  if (tbl == nil) then
    return copied ;
  end
  copied = copied or {} ;
  local copy = {} ;
  copied[tbl] = copy ;
  for i,v in pairs(tbl) do
    if (type(v) == "table") then
      if copied[v] then
        copy[i] = copied[v] ;
      else
        copy[i] = copyTable( v, copied ) ;
      end
    else
      copy[i] = v ;
    end
  end
  return copy ;
end

function oq.on_logout() 
  -- leave party & disband raid if you started one
--  oq.raid_disband() ;  -- only triggers if i am raid leader
--  oq.raid_announce( "leave_group,".. player_name ..",".. player_realm ) ;

  -- remove myself from other waitlists
  -- note:  doesn't work, no msgs sent
  oq.clear_pending() ;
  
  -- set the bn message without the OQ header
--  oq.reset_bn_custom_msg() ;
  
  -- leave channels
  oq.channel_leave( "OQGeneral" ) ;
  
  -- hang onto group data if still in an OQ_group (may come back)
  local disabled = OQ_toon.disabled ;
  
  if (OQ_toon == nil) then
    OQ_toon = {} ; 
    OQ_toon.auto_role  = 1 ;
  end
  if (OQ_toon.shout_kbs == nil) then
    OQ_toon.shout_kbs = 0 ;
  end
  if (OQ_toon.shout_caps == nil) then
    OQ_toon.shout_caps = 0 ;
  end
  if (OQ_toon.shout_ragequits == nil) then
    OQ_toon.shout_ragequits = 1 ;
  end
  if (OQ_data.autoaccept_mesh_request == nil) then
    OQ_data.autoaccept_mesh_request = 0 ;
  end
  if (OQ_data.show_premade_ads == nil) then
    OQ_data.show_premade_ads = 1 ;
  end
  if (OQ_data.ok2submit_tag == nil) then
    OQ_data.ok2submit_tag = 0 ;
  end
  if (OQ_toon.ok2gc == nil) then
    OQ_toon.ok2gc = 0 ;
  end
  OQ_toon.my_group         = my_group ;
  OQ_toon.my_slot          = my_slot ;
  OQ_toon.last_tm          = utc_time() ; 
  OQ_toon.player_role      = player_role;
  OQ_toon.disabled         = disabled ;
  OQ_toon.raid             = {} ;
  OQ_toon.waitlist         = {} ;
  if (oq.marquee ~= nil) then
    OQ_toon.marquee_x = max( 0, oq.marquee:GetLeft()) ;
    OQ_toon.marquee_y = max( 0, GetScreenHeight() - oq.marquee:GetTop()) ;
  end
  if (oq.raid.raid_token) then
    OQ_toon.raid     = copyTable( oq.raid ) ; 
    OQ_toon.waitlist = copyTable( oq.waitlist ) ; 
  end
  OQ_data.scores = copyTable( oq.scores ) ;
  OQ_data.bn_friends = nil ; -- clear out bnfriends; will reload next login
  OQ_data.reports    = nil ; -- old data; making sure it's cleaned out
  OQ_data.setup      = nil ; -- old data; making sure it's cleaned out
end

function oq.attempt_group_recovery() 
  local now = utc_time() ;
  if (OQ_data ~= nil) and (OQ_data.stats ~= nil) then
    -- correcting variable name
    if (OQ_data.stats.bg_tm ~= nil) and (OQ_data.stats.avg_bg_len == nil) then
      OQ_data.stats.avg_bg_len = OQ_data.stats.bg_tm ;
      OQ_data.stats.bg_tm      = nil ;
    end
    if (OQ_data.stats.down_tm ~= nil) and (OQ_data.stats.avg_down_tm == nil) then
      OQ_data.stats.avg_down_tm = OQ_data.stats.down_tm ;
      OQ_data.stats.down_tm     = nil ;
    end
  end
  
  if (OQ_data ~= nil) and (OQ_data.scores ~= nil) then
    oq.scores = copyTable( OQ_data.scores ) ;
    if (oq.scores.bg == nil) then
      oq.scores_init_bgs() ;
    end
    oq.update_scores() ;
  else
    oq.scores_init() ;
  end
  oq.color_blind_mode( OQ_data.colorblindshader ) ;
  
  if (OQ_toon) then
    -- class portrait
    if (OQ_toon.class_portrait == nil) then
      OQ_toon.class_portrait = 1 ;
    end
    if (OQ_toon.say_sapped == nil) then
      OQ_toon.say_sapped = 1 ;
    end
    if (OQ_toon.who_popped_lust == nil) then
      OQ_toon.who_popped_lust = 1 ;
    end
    if (OQ_toon.shout_kbs == nil) then
      -- not set... on by default. 0 == off
      OQ_toon.shout_kbs = 1 ;
    end
    if (OQ_toon.shout_caps == nil) then
      -- not set... on by default. 0 == off
      OQ_toon.shout_caps = 1 ;
    end
    if (OQ_toon.shout_ragequits == nil) then
      -- not set... on by default. 1 == on
      OQ_toon.shout_ragequits = 1 ;
    end
    if (OQ_data.autoaccept_mesh_request == nil) then
      -- default is on
      OQ_data.autoaccept_mesh_request = 1 ; 
    end
    if (OQ_data.show_premade_ads == nil) then
      -- default is on
      OQ_data.show_premade_ads = 1 ;
    end
    if (OQ_data.ok2submit_tag == nil) then
      -- default is on
      OQ_data.ok2submit_tag = 1 ; 
    end
    if (OQ_toon.ok2gc == nil) then
      -- default is gc off
      OQ_toon.ok2gc = 0 ;
    end
    oq.tab5_ar:SetChecked( (OQ_toon.auto_role == 1) ) ;
    oq.tab5_cp:SetChecked( (OQ_toon.class_portrait == 1) ) ;
    oq.tab5_gc:SetChecked( (OQ_toon.ok2gc == 1) ) ;
    oq.tab5_ss:SetChecked( (OQ_toon.say_sapped == 1) ) ;
    oq.tab5_wp:SetChecked( (OQ_toon.who_popped_lust == 1) ) ;
    oq.tab5_shoutkbs:SetChecked( (OQ_toon.shout_kbs == 1) ) ;
    oq.tab5_shoutads:SetChecked( (OQ_data.show_premade_ads == 1) ) ;
    oq.tab5_shoutcaps:SetChecked( (OQ_toon.shout_caps == 1) ) ;
    oq.tab5_ragequits:SetChecked( (OQ_toon.shout_ragequits == 1) ) ;
    oq.tab5_autoaccept_mesh_request:SetChecked( (OQ_data.autoaccept_mesh_request == 1) ) ;
    oq.tab5_ok2submit_btag:SetChecked( (OQ_data.ok2submit_tag == 1) ) ;
      
    -- more then 60 seconds passed, recovery not an option
    if ((now - OQ_toon.last_tm) <= OQ_GROUP_RECOVERY_TM) then
      my_group = OQ_toon.my_group or 0 ;
      my_slot  = OQ_toon.my_slot or 0 ;
      if (OQ_toon.raid.raid_token) then
        oq.raid  = copyTable( OQ_toon.raid ) ;
        oq.set_premade_type( OQ_toon.raid.type ) ;
        
        -- make sure all the sub tables are there
        if (not oq.raid.group) then
          oq.raid.group = {} ;
        end
        for i = 1,8 do
          if (not oq.raid.group[i]) then
            oq.raid.group[i] = {} ;
          end
          if (not oq.raid.group[i].member) then
            oq.raid.group[i].member = {} ;
          end
          for j=1,5 do
            if (not oq.raid.group[i].member[j]) then
              oq.raid.group[i].member[j] = {} ;
              oq.raid.group[i].member[j].flags = 0 ;
            end
            if (not oq.raid.group[i].member[j].bg) then
              oq.raid.group[i].member[j].bg = {} ;
            end
            if (not oq.raid.group[i].member[j].bg[1]) then
              oq.raid.group[i].member[j].bg[1] = {} ;
            end
            if (not oq.raid.group[i].member[j].bg[2]) then
              oq.raid.group[i].member[j].bg[2] = {} ;
            end
          end
        end
      end
    end
    player_role = OQ_toon.player_role or 3 ;
    
    -- update UI elements
    if (oq.raid.raid_token) then
      if (oq.iam_raid_leader()) then
        oq.ui_raidleader() ;
        oq.set_group_lead( 1, player_name, player_realm, player_class, player_realid ) ;
        oq.raid.group[1].member[1].resil  = player_resil ;
        oq.raid.group[1].member[1].ilevel = player_ilevel ;
        oq.get_group_hp() ;
        oq.check_for_deserter() ;
        oq.tab3_create_but:SetText( OQ.UPDATE_BUTTON ) ;
        
        oq.waitlist = copyTable( OQ_toon.waitlist ) ;
        oq.populate_waitlist() ;        
      else
        oq.ui_player() ;
      end
      for i=1,8 do
        local grp = oq.raid.group[i] ;
        for j=1,5 do
          local m = grp.member[j] ;
          if (j == 1) then
            oq.set_group_lead( i, m.name, m.realm, m.class, m.realid ) ;
          else
            oq.set_group_member( i, j, m.name, m.realm, m.class, m.realid, m.bg[1].type, m.bg[1].status, m.bg[2].type, m.bg[2].status ) ;
          end
          m.check = OQ_FLAG_CLEAR ;
        end
      end
      if (my_group ~= 0) and (my_slot ~= 0) then
        oq.raid.group[my_group].member[my_slot].level = player_level ;
      end

      -- update tab_1
      oq.tab1_name :SetText( oq.raid.name ) ;
      oq.tab1_notes:SetText( oq.raid.notes ) ;

      oq.update_tab1_stats() ;
      oq.update_tab3_info() ;

      -- activate in-raid only procs
      oq.procs_join_raid() ;
    end
  else
    OQ_toon = {} ;
  end
  if (OQ_toon.MinimapPos == nil) then
    OQ_toon.MinimapPos = 0 ;
  end
  if (OQ_data.show_premade_ads == nil) then
    OQ_data.show_premade_ads = 1 ;
  end
  if (OQ_data.stats ~= nil) then
    if (OQ_data.stats.tears == nil) then
      OQ_data.stats.tears = 0 ;
    end
    if (OQ_data.stats.total_tears == nil) then
      OQ_data.stats.total_tears = 0 ;
    end
    if (OQ_toon.wins == nil) and (OQ_data.stats.nWins ~= nil) then
      OQ_toon.wins = OQ_data.stats.nWins ;
    end
    if (OQ_toon.losses == nil) and (OQ_data.stats.nLosses ~= nil) then
      OQ_toon.losses = OQ_data.stats.nLosses ;
    end
  end
  
  if (oq.raid.enforce_levels == nil) then
    oq.raid.enforce_levels = 1 ;
  end
  oq.tab3_enforce:SetChecked( (oq.raid.enforce_levels == 1) ) ;
  
  if (OQ_toon.reports == nil) then
    OQ_toon.reports = {} ;
  end
  if (OQ_data.announce_spy == nil) then
    OQ_data.announce_spy = 1 ;
  end
  oq._sktime_notice_tm = 0 ;
end

function oq.closeInvitePopup()
  if (_inside_bg) then
    return ;
  end
  StaticPopup_Hide("PARTY_INVITE")
end

function oq.on_party_invite_request( leader_name ) 
  if (my_group <= 0) then
    return ;
  end
  local  grp_lead = oq.raid.group[ my_group ].member[1] ;
  local  n        = grp_lead.name ;
  if (grp_lead.realm ~= player_realm) then
    n = n .."-".. grp_lead.realm ;
  end

  if (n == leader_name) then
    AcceptGroup() ;
  end
end

function oq.join_oq_general()
  local name = "OQGeneral" ;
  oq.channel_join( name ) ;
  oq.timer( "hook_roster_update", 3, oq.hook_roster_update, true, name ) ;
end

--------------------------------------------------------------------------
-- timer functions
--------------------------------------------------------------------------
function oq.timer( id, dt_, func_, repeater, arg1_, arg2_, arg3_, arg4_, arg5_, arg6_, arg7_ )
  if (func_ == nil) then
    oq.timers[ id ] = nil ;
  else
    local t = GetTime() + dt_ ;
    oq.timers[ id ] = { dt = dt_, tm = t, one_shot = (not repeater), func = func_, 
                        arg1 = arg1_, arg2 = arg2_, arg3 = arg3_, arg4 = arg4_,
                        arg5 = arg5_, arg6 = arg6_, arg7 = arg7_ } ;
  end
end

function oq.timer_clear()
  oq.timers = nil ;
  oq.timers = {} ;
end

function oq.timer_dump() 
  print( "--[ timers ]------" ) ;
  for i,v in pairs( oq.timers ) do
    if (v.one_shot) then
      print( "  ".. string.format( "%02d", v.dt ) .."  ".. tostring(i) .."   one_shot" ) ;
    else
      print( "  ".. string.format( "%02d", v.dt ) .."  ".. tostring(i) ) ;
    end
  end  
  print( "--" ) ;
end

oq.one_shot = 0 ;
function oq.timer_oneshot( dt_, func_, arg1_, arg2_, arg3_, arg4_, arg5_, arg6_, arg7_ )
  oq.one_shot = oq.one_shot + 1 ;
  oq.timer( "one_shot.".. oq.one_shot, dt_, func_, nil, arg1_, arg2_, arg3_, arg4_, arg5_, arg6_, arg7_ ) ;  
end

-- resets timer to now + dt
function oq.timer_reset( id, dt )
  if (oq.timers[ id ] ~= nil) then
    local now = GetTime() ;
    if (dt == nil) then
      dt = oq.timers[ id ].dt ;
    end
    oq.timers[ id ].tm = now + dt ;
  end
end

function oq.garbage_collector()
  if (OQ_toon.ok2gc == nil) or (OQ_toon.ok2gc == 0) then
    return ;
  end
  local now = utc_time() ;
  if (oq._next_gc == nil) then
    oq._next_gc = 0 ;
  end
  if (now < oq._next_gc) then
    return ;
  end
  oq._next_gc = now + 5 ;
  
  collectgarbage() ;
end

function oq.timer_trigger( now )
  for i,v in pairs( oq.timers ) do
    if (v.tm < now) then
      local arg1 = v.arg1 ;
      if (arg1 == nil) or (arg1 == "#now") then
        arg1 = now ;
      end
      local retOK, rc = pcall( v.func, arg1, v.arg2, v.arg3, v.arg4, v.arg5, v.arg6, v.arg7 ) ;
      if (retOK == true) then 
        if (rc ~= nil) or (v.one_shot) then
          oq.timers[i] = nil ;
        else
          v.error_cnt = nil ;
          v.tm = now + v.dt ;
        end
      else
        v.error_cnt = (v.error_cnt or 0) + 1 ;
        if (v.error_cnt > 5) then
          print( "[oq.timer] error calling '".. tostring(i) .."'  removing timer" ) ;
          oq.timers[i] = nil ;
        end
      end
      
      -- garbage collection (memory was creeping up)
      oq.garbage_collector() ;
    end
  end
end

function oq.timer_trip( id )
  if (oq.timers[ id ] ~= nil) then
    oq.timers[ id ].tm = 0 ;
  end
end

function oq.ui_toggle()
  if (oq.get_battle_tag() == nil) then
    return ;
  end

  if (oq.ui:IsVisible()) then
    oq.ui:Hide() ;
    _ui_open = nil ;
  else
    oq.channel_join( "OQGeneral" ) ;  -- just in case
    if (OQ_toon.disabled) then
      OQ_toon.disabled = nil ;    
      print( OQ.ENABLED ) ;
    end
    oq.ui:Show() ;
    _ui_open = true ;
  end
end

function OQ_onLoad( self )
  oq.ui = self ;
  oq.ui.closepb = oq.closebox( oq.ui ) ;
  oq.register_events() ;
end

function oq.onHide( self )
  _ui_open = nil ;
  oq.ui.hide_tm = GetTime() ; -- hold this in-case the UI was forced-closed when the map was brought up
  PlaySound("igCharacterInfoClose") ;
end

function oq.hide_shade()
  if (oq.ui_shade ~= nil) and (oq.ui_shade:IsVisible()) then
    oq.ui_shade:Hide() ;
  end
end

function oq.onShow( self )
  _ui_open = true ;
  PlaySound("igCharacterInfoOpen") ;

  oq.hide_shade() ;  
  OQTabPage1:Hide() ;  -- my premade 
  OQTabPage2:Hide() ;  -- find premade
  OQTabPage3:Hide() ;  -- create premade
  OQTabPage4:Hide() ;  -- score
  OQTabPage5:Hide() ;  -- setup
  OQTabPage6:Hide() ;  -- waitlist
  OQTabPage7:Hide() ;  -- banlist

  if (oq.raid.raid_token == nil) and (oq.GetNumPartyMembers() > 0) then
    -- not in an oQueue group but in a party
    local islead = UnitIsGroupLeader("player") ;
    if (islead) then
      -- party leader straight to create premade
      PanelTemplates_SetTab(OQMainFrame, 3) ;
      OQTabPage3:Show() ;
    else
      PanelTemplates_SetTab(OQMainFrame, 1) ;
      OQTabPage1:Show() ;
    end
  elseif (oq.GetNumPartyMembers() > 0) or (oq.raid.raid_token ~= nil) then
    -- in an oQueue group
    PanelTemplates_SetTab(OQMainFrame, 1) ;
    OQTabPage1:Show() ;
  else
    -- solo toon, looking for raid
    PanelTemplates_SetTab(OQMainFrame, 2) ;
    OQTabPage2:Show() ;
  end

  -- set the text on the wait-list tab
  local nWaiting = oq.n_waiting() ;
  if (nWaiting > 0) then
    OQMainFrameTab7:SetText( string.format( OQ.TAB_WAITLISTN, nWaiting ) ) ;
  else
    OQMainFrameTab7:SetText( OQ.TAB_WAITLIST ) ;
  end
end

function oq.create_marquee()
  local cx = 135 ;
  local cy = 50 ;
  local f = oq.panel( UIParent, "OQMarquee", 100, 10, cx, cy ) ;
  f:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background", 
                          edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
                          tile=true, tileSize = 16, edgeSize = 16,
                          insets = { left = 4, right = 3, top = 4, bottom = 3 }
                         })
  f:SetBackdropColor(0.2,0.2,0.2,1.0);
  f:SetMovable(true) ;
  f:EnableMouse(true) ;
  f:RegisterForDrag( "LeftButton", "RightButton" ) ;
  f:SetScript( "OnDragStart", f.StartMoving ) ;
  f:SetScript( "OnDragStop", f.StopMovingOrSizing ) ;
  if (OQ_toon.marquee_y ~= nil) and (OQ_toon.marquee_x ~= nil) then
    oq.moveto( f, OQ_toon.marquee_x, OQ_toon.marquee_y ) ;
  else
    oq.moveto( f, (UIParent:GetWidth() - cx)/2, 10 ) ;
  end
  
  x = 5 ;
  y = 5 ;
  f.horde_emblem    = oq.texture( f, x, y+2, 18, 16, "Interface\\FriendsFrame\\PlusManz-Horde" ) ;

  x = x + 20 ;
  f.horde_label     = oq.label( f, x, y, 60, 20, "Horde" ) ;
  f.horde_label:SetFont(OQ.FONT, 10, "") ;
  f.horde_label:SetJustifyH("left") ;
  f.horde_label:SetJustifyV("center") ;
  
  x = x + 50 ;
  f.horde_score     = oq.label( f, x, y, 50, 20, "99,999" ) ;
  f.horde_score:SetFont(OQ.FONT, 10, "") ;
  f.horde_score:SetJustifyH("right") ;
  f.horde_score:SetJustifyV("center") ;

  x = 5 ;
  y = y + 20 ;
  f.alliance_emblem = oq.texture( f, x, y+2, 18, 16, "Interface\\FriendsFrame\\PlusManz-Alliance" ) ;
  
  x = x + 20 ;
  f.alliance_label  = oq.label( f, x, y, 60, 20, "Alliance" ) ;
  f.alliance_label:SetFont(OQ.FONT, 10, "") ;
  f.alliance_label:SetJustifyH("left") ;
  f.alliance_label:SetJustifyV("center") ;
  
  x = x + 50 ;
  f.alliance_score     = oq.label( f, x, y, 50, 20, "0" ) ;
  f.alliance_score:SetFont(OQ.FONT, 10, "") ;
  f.alliance_score:SetJustifyH("right") ;
  f.alliance_score:SetJustifyV("center") ;

--[[
--  f:SetScript( "OnShow", function() oq.update_marquee_gametime() ; oq.timer( "marquee_ticker", 0.5, oq.update_marquee_gametime, true ) ; end ) ;
--  f:SetScript( "OnHide", function() oq.timer( "marquee_ticker", 0.5, nil ) ; end ) ;

  x = 5 + 20 ;
  y = y + 18 ;
  
  f.timeleft_label  = oq.label( f, x, y, 60, 20, "Time left:" ) ;
  f.timeleft_label:SetFont(OQ.FONT, 8, "") ;
  f.timeleft_label:SetJustifyH("left") ;
  f.timeleft_label:SetJustifyV("center") ;
  f.timeleft_label:SetTextColor( 0.8, 0.8, 0.8, 1 ) ;

  x = x + 60 ;  
  f.timeleft  = oq.label( f, x, y, 50, 20, "168:17" ) ;
  f.timeleft:SetFont(OQ.FONT, 8, "") ;
  f.timeleft:SetJustifyH("right") ;
  f.timeleft:SetJustifyV("center") ;
  f.timeleft:SetTextColor( 0.8, 0.8, 0.8, 1 ) ;
]]

  f:Hide() ;
  return f ;
end

function oq.toggle_marquee()
  if (oq.marquee == nil) then
    return ;
  end

  if (oq.marquee:IsVisible()) then
    oq.marquee:Hide() ;
    OQ_toon.marquee_hide = true ;
  else
    oq.marquee:Show() ;
    OQ_toon.marquee_hide = nil ;
  end
end

function OQ_buttonLoad(self)
  oq.mini = self ;
  oq.mini:RegisterForClicks( "AnyUp" ) ;
  oq.mini:RegisterForDrag  ( "LeftButton", "RightButton" ) ;
  if (OQ_toon.mini_hide) then
    oq.mini:Hide() ;
  else
    oq.mini:Show() ;
  end
  oq.mini:SetScript("OnClick", OQ_buttonShow ) ;
  OQ_MinimapButton:SetToplevel(true) ;
end

function OQ_buttonShow(self, button, down)
  if (button == "RightButton") and (not down) then
    -- toggle marquee
    oq.toggle_marquee() ;
  elseif (button == "LeftButton") and (not down) then
    -- toggle main ui
    oq.ui_toggle() ;
  end
end

function OQ_MinimapButton_Reposition()
  local xpos
  local ypos
  local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
  if minimapShape == "SQUARE" then
    xpos = 110 * cos(OQ_toon.MinimapPos or 0)
    ypos = 110 * sin(OQ_toon.MinimapPos or 0)
    xpos = math.max(-82, math.min(xpos, 84))
    ypos = math.max(-86, math.min(ypos, 82))
  else
    xpos = 80 * cos(OQ_toon.MinimapPos or 0)
    ypos = 80 * sin(OQ_toon.MinimapPos or 0)
  end
  OQ_MinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 54-xpos, ypos-54)
end

function OQ_MinimapButton_DraggingFrame_OnUpdate()
  local xpos,ypos = GetCursorPosition()
  local xmin,ymin = Minimap:GetLeft() or 400, Minimap:GetBottom() or 400 ;

  local scale = OQ_MinimapButton:GetEffectiveScale()
  xpos = xmin-xpos/scale+70
  ypos = ypos/scale-ymin-70

  OQ_toon.MinimapPos = math.deg(math.atan2(ypos,xpos))
  OQ_MinimapButton_Reposition() -- move the button
end
