--[[
    Elemental staves for any mage job (LuAshitaCast on HorizonXI).

    What it does
      * When you cast, the staff of the spell's element goes into your main
        hand for the cast: Fire Staff for Fire spells, Ice Staff for Blizzard,
        Wind for Aero, Earth for Stone, Thunder for Thunder, Water for Water,
        Light Staff for Cure, Dia, Banish and the like, Dark Staff for Bio,
        Drain, Aspir, Sleep, Blind and friends. Summons and ninjutsu match
        their element too. The HQ staff (Vulcan's, Aquilo's, Auster's, Terra's,
        Jupiter's, Neptune's, Apollo's, Pluto's) is used whenever you own it.
      * When you sit down to rest, the Dark Staff (or Pluto's) goes on for
        the MP refresh while healing.
      * When you stand up or finish casting, your usual weapon comes back if
        you name it under IDLE_MAIN below. Leave it blank and whatever staff
        you last used simply stays in hand.
      * Nothing else is touched. Every other slot stays exactly as you have it.

    How to install (no folder needed)
      1. Go to Game\config\addons\luashitacast\ (make the luashitacast folder
         there if it does not exist yet).
      2. Copy this file in once per job, named YourName_JOB.lua, for example
         Eveebevee_WHM.lua, Eveebevee_BLM.lua, Eveebevee_RDM.lua. The name
         part is your character's name exactly as it appears in game.
      3. In game: /addon load luashitacast, then /lac load. Changing job
         picks up the matching file on its own from then on.

    The other way: in game type /lac newlua. That creates the per character
    folder Game\config\addons\luashitacast\YourName_<Id>\ with a blank
    JOB.lua for the job you are on; replace that blank file with this one.
    LuAshitaCast never creates the folder by itself, it only looks for one.

    A staff swap mid fight resets your TP, which is nothing for a mage, but
    if you melee on RDM you may want to leave this off that job.
--]]

local profile = {};

-- ======================= settings ==========================================
-- Your everyday weapon, put back when you stand up or stop casting.
-- Examples: 'Kukulcan\'s Staff', 'Solid Wand', 'Yew Wand +1'. Blank = leave the last staff on.
local IDLE_MAIN = '';

-- Prefer the HQ staff when you own it. Set to false to always use the NQ one.
local USE_HQ = true;

-- What goes on while resting. Dark is the MP refresh staff; change only if you know why.
local RESTING_ELEMENT = 'Dark';
-- ===========================================================================

-- The spell's element, as LuAshitaCast names it, to the HQ and NQ staff.
local STAVES = {
    Fire    = { 'Vulcan\'s Staff',  'Fire Staff'    },
    Ice     = { 'Aquilo\'s Staff',  'Ice Staff'     },
    Wind    = { 'Auster\'s Staff',  'Wind Staff'    },
    Earth   = { 'Terra\'s Staff',   'Earth Staff'   },
    Thunder = { 'Jupiter\'s Staff', 'Thunder Staff' },
    Water   = { 'Neptune\'s Staff', 'Water Staff'   },
    Light   = { 'Apollo\'s Staff',  'Light Staff'   },
    Dark    = { 'Pluto\'s Staff',   'Dark Staff'    },
};

-- Nothing here is worn by the profile; every set is empty on purpose so
-- LuAshitaCast never touches your armour. Only the main hand moves.
local sets = {
    Idle = {}, Resting = {}, TP = {}, Precast = {}, Midcast = {},
};
profile.Sets = sets;
profile.Packer = {};

-- Do you have this item, in inventory or a wardrobe? Cached for a while so
-- the bag scan does not run on every frame.
local ownedCache = {};
local function Owned(name)
    local hit = ownedCache[name];
    if (hit ~= nil) and ((os.clock() - hit.at) < 20) then
        return hit.yes;
    end
    local yes = false;
    local res = AshitaCore:GetResourceManager():GetItemByName(name, 0);
    if (res ~= nil) then
        local inv = AshitaCore:GetMemoryManager():GetInventory();
        for _, container in pairs({ 0, 8, 10, 11, 12 }) do
            for slot = 0, 80 do
                local it = inv:GetContainerItem(container, slot);
                if (it ~= nil) and (it.Id == res.Id) and ((it.Count or 0) > 0) then
                    yes = true;
                    break;
                end
            end
            if yes then break; end
        end
    end
    ownedCache[name] = { yes = yes, at = os.clock() };
    return yes;
end

-- The staff to use for an element: HQ if owned and wanted, else NQ if owned, else nothing.
local function StaffFor(element)
    local pair = STAVES[element];
    if (pair == nil) then return nil; end
    if USE_HQ and Owned(pair[1]) then return pair[1]; end
    if Owned(pair[2]) then return pair[2]; end
    return nil;
end

local function EquipMain(name)
    if (name ~= nil) and (name ~= '') then
        gFunc.Equip('Main', name);
    end
end

profile.OnLoad = function()
    print('[Staves] loaded: element staff on cast, ' .. RESTING_ELEMENT .. ' staff while resting'
        .. ((IDLE_MAIN ~= '') and (', ' .. IDLE_MAIN .. ' otherwise') or ''));
end

profile.OnUnload = function()
end

profile.HandleCommand = function(args)
end

profile.HandleDefault = function()
    local player = gData.GetPlayer();
    if (player == nil) then return; end
    if (player.Status == 'Resting') then
        EquipMain(StaffFor(RESTING_ELEMENT));
    else
        EquipMain(IDLE_MAIN);
    end
end

profile.HandleAbility = function()
end

profile.HandleItem = function()
end

profile.HandlePrecast = function()
end

-- The cast itself: the staff of the spell's element. Non-elemental spells
-- (Meteor, Impact) and anything without an element leave the hand alone.
profile.HandleMidcast = function()
    local action = gData.GetAction();
    if (action == nil) or (action.Element == nil) then return; end
    EquipMain(StaffFor(action.Element));
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile;
