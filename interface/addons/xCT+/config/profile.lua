--[[   ____    ______      
      /\  _`\ /\__  _\   __
 __  _\ \ \/\_\/_/\ \/ /_\ \___ 
/\ \/'\\ \ \/_/_ \ \ \/\___  __\
\/>  </ \ \ \L\ \ \ \ \/__/\_\_/
 /\_/\_\ \ \____/  \ \_\  \/_/
 \//\/_/  \/___/    \/_/
 
 [=====================================]
 [  Author: Dandruff @ Whisperwind-US  ]
 [  xCT+ Version 3.x.x                 ]
 [  �2012. All Rights Reserved.        ]
 [====================================]]

 -- This file is a static default profile.  After your first profile is created, editing this file will do nothing.
local ADDON_NAME, addon = ...

-- =====================================================
-- CreateMergeSpellEntry(
--    default,       [bool] - This specs current activated spell (only one per spec)
--    spellID,        [int] - the spell id to watch for
--    watchUnit,   [string] - look for the spell id on this unit
--  )
--    Creates a merge settings entry for a spell.
-- =====================================================
local function CreateComboSpellEntry(default, spellID, watchUnit)
  return {
       enabled = default,
            id = spellID,
          unit = watchUnit  or "player",
    }
end

addon.defaults = {
  profile = {
    showStartupText = true,
    
    blizzardFCT = {
      blizzardHeadNumbers = false,
      enabled = false,
      font = "Homespun (xCT+)",
      fontName = [[Interface\AddOns\]] .. ADDON_NAME .. [[\media\HOOGE.TTF]],
      fontSize = 32,
      fontOutline = "4MONOCHROMEOUTLINE",
      
      -- CVars
      ["CombatThreatChanges"] = false,
      ["CombatDamage"] = false,
      ["CombatHealing"] = false,
      ["PetMeleeDamage"] = false,
      ["CombatLogPeriodicSpells"] = false,
    },
    
    frameSettings = {
      clearLeavingCombat = false,
      showGrid = true,
      frameStrata = "5HIGH",
    },
    
    megaDamage = {
      enableMegaDamage = false,
      thousandSymbol = "|cffFF8000K|r",
      millionSymbol = "|cffFF0000M|r",
    },
    
    frames = {
      general = {
        ["enabledFrame"] = true,
        ["secondaryFrame"] = 0,
        ["insertText"] = "bottom",
        ["alpha"] = 100,
        
      -- position
        ["X"] = 0,
        ["Y"] = 224,
        ["Width"] = 512,
        ["Height"] = 128,
        
      -- fonts
        ["font"] = "Homespun (xCT+)",
        ["fontSize"] = 20,
        ["fontOutline"] = "4MONOCHROMEOUTLINE",
        ["fontJustify"] = "CENTER",

      -- font colors
        ["customColor"] = false,
        ["fontColor"] = nil,
        
      -- scrollable
        ["enableScrollable"] = false,
        ["scrollableLines"] = 10,
        
      -- fading text
        ["enableCustomFade"] = false,
        ["enableFade"] = true,
        ["fadeTime"] = 0.3,
        ["visibilityTime"] = 5,
        
      -- special tweaks
        ["showInterrupts"] = true,
        ["showDispells"] = true,
        ["showPartyKills"] = true,
        ["showBuffs"] = true,
        ["showDebuffs"] = true,
        ["showLowManaHealth"] = true,
        ["showCombatState"] = true,
        ["showRepChanges"] = true,
        ["showHonorGains"] = true,
      },
      
      outgoing = {
        ["enabledFrame"] = true,
        ["secondaryFrame"] = 0,
        ["insertText"] = "bottom",
        ["alpha"] = 100,
        
      -- position
        ["X"] = 480,
        ["Y"] = 0,
        ["Width"] = 196,
        ["Height"] = 320,
        
      -- fonts
        ["font"] = "Homespun (xCT+)",
        ["fontSize"] = 20,
        ["fontOutline"] = "4MONOCHROMEOUTLINE",
        ["fontJustify"] = "RIGHT",
        
      -- font colors
        ["customColor"] = false,
        ["fontColor"] = nil,
        
      -- icons
        ["iconsEnabled"] = true,
        ["iconsSize"] = 16,
        
      -- scrollable
        ["enableScrollable"] = false,
        ["scrollableLines"] = 10,
        
      -- fading text
        ["enableCustomFade"] = false,
        ["enableFade"] = true,
        ["fadeTime"] = 0.3,
        ["visibilityTime"] = 5,
        
      -- special tweaks
        ["enableOutDmg"] = true,
        ["enableOutHeal"] = true,
        ["enablePetDmg"] = true,
        ["enableAutoAttack"] = true,
        ["enableDotDmg"] = true,
        ["enableHots"] = true,
        ["enableImmunes"] = true,
        ["enableMisses"] = true,
      },
      
      critical = {
        ["enabledFrame"] = true,
        ["secondaryFrame"] = 0,
        ["insertText"] = "bottom",
        ["alpha"] = 100,
      
      -- position
        ["X"] = 256,
        ["Y"] = 0,
        ["Width"] = 256,
        ["Height"] = 128,
        
      -- fonts
        ["font"] = "Homespun (xCT+)",
        ["fontSize"] = 30,
        ["fontOutline"] = "4MONOCHROMEOUTLINE",
        ["fontJustify"] = "RIGHT",
        
      -- font colors
        ["customColor"] = false,
        ["fontColor"] = nil,
        
      -- critical appearance
        ["critPrefix"] = "|cffFF0000*|r",
        ["critPostfix"] = "|cffFF0000*|r",
        
      -- icons
        ["iconsEnabled"] = true,
        ["iconsSize"] = 16,
        
      -- scrollable
        ["enableScrollable"] = false,
        ["scrollableLines"] = 10,
        
      -- fading text
        ["enableCustomFade"] = false,
        ["enableFade"] = true,
        ["fadeTime"] = 0.3,
        ["visibilityTime"] = 5,
        
      -- special tweaks
        ["showSwing"] = true,
        ["prefixSwing"] = true,
      },
      
      damage = {
        ["enabledFrame"] = true,
        ["secondaryFrame"] = 0,
        ["insertText"] = "top",
        ["alpha"] = 100,
        
      -- position
        ["X"] = -448,
        ["Y"] = -88,
        ["Width"] = 128,
        ["Height"] = 144,
        
      -- fonts
        ["font"] = "Homespun (xCT+)",
        ["fontSize"] = 20,
        ["fontOutline"] = "4MONOCHROMEOUTLINE",
        ["fontJustify"] = "LEFT",
        
      -- font colors
        ["customColor"] = false,
        ["fontColor"] = nil,
        
      -- scrollable
        ["enableScrollable"] = false,
        ["scrollableLines"] = 10,
        
      -- fading text
        ["enableCustomFade"] = false,
        ["enableFade"] = true,
        ["fadeTime"] = 0.3,
        ["visibilityTime"] = 5,
      
      -- Special Tweaks
        ["showDodgeParryMiss"] = true,
        ["showDamageReduction"] = true,
      },

      healing = {
        ["enabledFrame"] = true,
        ["secondaryFrame"] = 0,
        ["insertText"] = "bottom",
        ["alpha"] = 100,
      
      -- positioon
        ["X"] = -320,
        ["Y"] = 88,
        ["Width"] = 384,
        ["Height"] = 144,
        
      -- fonts
        ["font"] = "Homespun (xCT+)",
        ["fontSize"] = 20,
        ["fontOutline"] = "4MONOCHROMEOUTLINE",
        ["fontJustify"] = "LEFT",
        
      -- font colors
        ["customColor"] = false,
        ["fontColor"] = nil,
        
      -- scrollable
        ["enableScrollable"] = false,
        ["scrollableLines"] = 10,
        
      -- fading text
        ["enableCustomFade"] = false,
        ["enableFade"] = true,
        ["fadeTime"] = 0.3,
        ["visibilityTime"] = 5,
        
      -- special tweaks
        ["showFriendlyHealers"] = true,
        ["enableClassNames"] = true,
        ["enableRealmNames"] = true,
        ["enableOverHeal"] = true,
      },
      
      class = {
        ["enabledFrame"] = true,
        ["alpha"] = 100,
        
      -- position
        ["X"] = 0,
        ["Y"] = 64,
        ["Width"] = 64,
        ["Height"] = 64,
        
      -- fonts
        ["font"] = "HOOGE (xCT)",
        ["fontSize"] = 32,
        ["fontOutline"] = "4MONOCHROMEOUTLINE",
        
      -- font colors
        ["customColor"] = false,
        ["fontColor"] = nil,
      },
      
      power = {
        ["enabledFrame"] = true,
        ["secondaryFrame"] = 0,
        ["insertText"] = "bottom",
        ["alpha"] = 100,
        
      -- position
        ["X"] = 0,
        ["Y"] = -64,
        ["Width"] = 256,
        ["Height"] = 128,
        
      -- fonts
        ["font"] = "Homespun (xCT+)",
        ["fontSize"] = 20,
        ["fontOutline"] = "4MONOCHROMEOUTLINE",
        ["fontJustify"] = "CENTER",
        
      -- font colors
        ["customColor"] = false,
        ["fontColor"] = nil,
        
      -- scrollable
        ["enableScrollable"] = false,
        ["scrollableLines"] = 10,
        
      -- fading text
        ["enableCustomFade"] = false,
        ["enableFade"] = true,
        ["fadeTime"] = 0.3,
        ["visibilityTime"] = 5,
        
      -- special tweaks
        ["showEnergyGains"] = true,
        ["showPeriodicEnergyGains"] = true,
      },
      
      procs = {
        ["enabledFrame"] = true,
        ["secondaryFrame"] = 0,
        ["insertText"] = "top",
        ["alpha"] = 100,
        
      -- position
        ["X"] = -256,
        ["Y"] = -64,
        ["Width"] = 256,
        ["Height"] = 128,
        
      -- fonts
        ["font"] = "Homespun (xCT+)",
        ["fontSize"] = 20,
        ["fontOutline"] = "4MONOCHROMEOUTLINE",
        ["fontJustify"] = "CENTER",
        
      -- font colors
        ["customColor"] = false,
        ["fontColor"] = nil,
        
      -- scrollable
        ["enableScrollable"] = false,
        ["scrollableLines"] = 10,
        
      -- fading text
        ["enableCustomFade"] = false,
        ["enableFade"] = true,
        ["fadeTime"] = 0.3,
        ["visibilityTime"] = 5,
      },
      
      loot = {
        ["enabledFrame"] = true,
        ["secondaryFrame"] = 0,
        ["insertText"] = "top",
        ["alpha"] = 100,
        
      -- position 
        ["X"] = 0,
        ["Y"] = -224,
        ["Width"] = 512,
        ["Height"] = 128,
        
      -- fonts
        ["font"] = "Homespun (xCT+)",
        ["fontSize"] = 20,
        ["fontOutline"] = "4MONOCHROMEOUTLINE",
        ["fontJustify"] = "CENTER",
        
      -- font colors
        ["customColor"] = false,
        ["fontColor"] = nil,
        
      -- icons
        ["iconsEnabled"] = true,
        ["iconsSize"] = 16,
        
      -- scrollable
        ["enableScrollable"] = false,
        ["scrollableLines"] = 10,
        
      -- fading text
        ["enableCustomFade"] = false,
        ["enableFade"] = true,
        ["fadeTime"] = 0.3,
        ["visibilityTime"] = 5,
        
      -- special tweaks
        ["showItems"] = true,
        ["showMoney"] = true,
        ["showItemTotal"] = true,
        ["showCrafted"] = true,
        ["showQuest"] = true,
        ["colorBlindMoney"] = false,
        ["filterItemQuality"] = 3,
      },
    },

    spells = {
      enableMerger = true,        -- enable/disable spam merger
      enableMergerDebug = false,  -- Shows spell IDs for debugging merged spells
      
      mergeHealing = true,
      
      mergeSwings = true,
      mergeRanged = true,
      
      -- Only one of these can be true
      mergeDontMergeCriticals = true,
      mergeCriticalsWithOutgoing = false,
      mergeCriticalsByThemselves = false,
      
      
      combo = {
        ["DEATHKNIGHT"] = {
          [1] = {                                         -- Blood
            CreateComboSpellEntry(true, 49222),           --   Bone Shield
          },
          [2] = { },    -- Frost
          [3] = {                                         -- Unholy
            CreateComboSpellEntry(true, 91342, "pet"),    --   Shadow Infusion
          },
        },
        
        ["DRUID"] = {
          [1] = {                                         -- Balance
            CreateComboSpellEntry(true, 81192),           --   Lunar Shower
          },
          [2] = {                                         -- Feral
            [COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT] = true,
          }, 
          [3] = { },    -- Guardian
          [4] = { },    -- Restoration
        },
      
        ["HUNTER"] = {
          [1] = {                                         -- Beast Mastery
            CreateComboSpellEntry(true, 19615, "pet"),    --   Frenzy Effect
          },
          [2] = {                                         -- Marksman
            CreateComboSpellEntry(true, 82925),           --   Ready, Set, Aim...
          },
          [3] = {                                         -- Survival
            CreateComboSpellEntry(true, 56453),           --   Lock 'n Load
          },
        },
        
        ["MAGE"] = {
          [1] = { },    -- Arcane
          [2] = { },    -- Fire
          [3] = { },    -- Frost
        },
        
        ["MONK"] = {
          [CHI] = true,
          
          -- DO NOT USE - MONKS GET CHI
          [1] = { },    -- Brewmaster
          [2] = { },    -- Mistweaver
          [3] = { },    -- Windwalker
        },
        
        ["PALADIN"] = {
          [HOLY_POWER] = true,
        
          -- DO NOT USE - PALADINS GET HOLY POWER
          [1] = { },    -- Holy
          [2] = { },    -- Protection
          [3] = { },    -- Retribution
        },
        
        ["PRIEST"] = {
          [1] = {                                         -- Discipline
            CreateComboSpellEntry(true, 81661),           --   Evangelism
          },    
          [2] = {                                         -- Holy
            CreateComboSpellEntry(true, 63735),           --   Serendipity
            CreateComboSpellEntry(false, 114255),         --   Surge of Light
          },    
          -- DO NOT USE - SHADOW PRIEST GET SHADOW ORBS
          [3] = {                                         -- Shadow
            [SHADOW_ORBS] = true,
            -- 87160 Surge of Darkness
          },    
        },
        
        ["ROGUE"] = {
          [COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT] = true,
        
          -- DO NOT USE - ROGUES GET COMBO POINTS
          [1] = { },    -- Assassination
          [2] = { },    -- Combat
          [3] = { },    -- Subtlety
        },

        ["SHAMAN"] = {
          [1] = {                                         -- Elemental
            CreateComboSpellEntry(true, 88767),           --   Fulmination
          },    
          [2] = {                                         -- Enhancement
            CreateComboSpellEntry(true, 53817),           --   Maelstrom Weapon
          },
          [3] = {                                         -- Restoration
            CreateComboSpellEntry(true, 53390),           --   Tidal Waves
          },
        },

        ["WARLOCK"] = {
          -- DO NOT USE - AFFLICTION WARLOCKS GET SOUL SHARDS
          [1] = { [SOUL_SHARDS] = true },                 -- Affliction
          
          -- DO NOT USE - DEMONOLOGY WARLOCKS GET DEMONIC FURY
          [2] = { [DEMONIC_FURY] = true },                -- Demonology
          
          -- DO NOT USE - DESTRUCTION WARLOCKS GET BURNING EMBERS
          [3] = { [BURNING_EMBERS] = true },              -- Destruction
        },
        
        ["WARRIOR"] = {
          [1] = { },    -- Arms
          [2] = { },    -- Fury
          [3] = { },    -- Protection
        },
        
      },
      
      -- yes this is supposed to be blank :P
      -- it is generated in merge.lua
      merge = { },
    
      -- yes this is supposed to be blank :P
      -- it is dynamically generated in core.lua
      items = { },
    },
    
    spellFilter = {
      ["whitelistBuffs"]    = false,
      ["whitelistDebuffs"]  = false,
      ["whitelistSpells"]   = false,

      ["trackSpells"]       = false,
      
      listBuffs    = { },  -- Used to filter gains/fades of buffs    (Spell Name)
      listDebuffs  = { },  -- Used to filter gains/fades of debuffs  (Spell Name)
      listSpells   = { },  -- Used to filter outgoing spells         (Spell ID)
      
      -- Minimal Spell Amount
      filterPowerValue = 0,
      filterOutgoingDamageValue = 0,
      filterOutgoingHealingValue = 0,
      filterIncomingDamageValue = 0,
      filterIncomingHealingValue = 0,
    },
  },
}
