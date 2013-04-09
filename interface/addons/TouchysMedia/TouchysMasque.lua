--[[
	This uses the bundled resource to add a skin to Masque so that your
	buffs/debuffs can have nice square borders.
	See http://www.wowace.com/addons/masque/pages/api/skin-data/
	
	Backdrop = {...},
	Icon = {...},
	Flash = {...},
	Cooldown = {...},
	Pushed = {...},
	Normal = {...},
	Disabled = {...},
	Checked = {...},
	Border = {...},
	AutoCastable = {...},
	Highlight = {...},
	Gloss = {...},
	HotKey = {...},
	Count = {...},
	Name = {...},
	Duration = {...},
	AutoCast = {...},
	
	Jesus christ the documentation for this stuff sucks on horse cocks.  It seems like "normal" w/h
	controls the "size" of the thing that gets drawn.  If normal is 32 then icon = 32 means icon is
	full size.  Borders seem a littl emore complex than that.

	Other sizes are relative to the size of
	normal. It looks like theres a 1.4x multiplier with raven at 30px:  40 -> 56px	
	768/1080 0.71111111111
	
	1080/768 1.40625

]]--

local Masque = LibStub("Masque", true)

if not Masque then return end

--[[
 Small skin for "little buffs".
 Assuming 32px grid, want 24px buff icons including 1px border + 4px space all sides.
 raven buffs:
	x: 0 	y: 97.04	icon: 32		scale: 1 		space: 0
]]--
Masque:AddSkin(
	"Touchy 32px buffs", {
		Author 			= "Touchymcfeel",
		Version			= "1.0",
		Shape			= "Square",
		Masque_Version 	= 40200,
		Backdrop = {
			Hide = true,
		},
		Icon = {
			Width = 27,
			Height = 27,
		},
		Normal = {
			Hide = true,
		},
		Border = {
			Hide = true,
		},
		Name = {
			Hide = true,
		},
		Count = {
			Hide = true,
		},
		HotKey = {
			Hide = true,
		},
		Duration = {
			Hide = true,
		},
		AutoCast = {
			Hide = true,
		},
		Flash = {
			Hide = true,
		},
		Cooldown = {
			Hide = true,
		},
		Pushed = {
			Hide = true,
		},
		Disabled = {
			Hide = true,
		},
		Checked = {
			Hide = true,
		},
		Gloss = {
			Hide = true,
		},
		Highlight = {
			Hide = true,
		},
	},
	true
)

-- big skin for important buffs.
-- assuming 64 pixel grid I want 4px on any side of a 56px icon centered in its box.
-- raven important buffs:
-- bargroup: buffs 	x:0		y: -64		size:64		spacing: 0
Masque:AddSkin(
	"Touchy 64px buffs", {
		Author 			= "Touchymcfeel",
		Version			= "1.0",
		Shape			= "Square",
		Masque_Version 	= 40200,
		Backdrop = {
			Hide = true,
		},
		Icon = {
			Width = 31.5,
			Height = 31.5,
		},
		Normal = {
			Hide = true,
		},
		Border = {
			Hide = true,
		},
		Name = {
			Hide = true,
		},
		Count = {
			Hide = true,
		},
		HotKey = {
			Hide = true,
		},
		Duration = {
			Hide = true,
		},
		AutoCast = {
		},
		Flash = {
			Hide = true,
		},
		Cooldown = {
			Hide = true,
		},
		Pushed = {
			Hide = true,
		},
		Disabled = {
			Hide = true,
		},
		Checked = {
			Hide = true,
		},
		Gloss = {
			Hide = true,
		},
		Highlight = {
			Hide = true,
		},
	},
	true
)
