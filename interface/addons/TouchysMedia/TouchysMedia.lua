--[[
	SharedMedia was was created by Elkano and SharedMediaAdditionalFonts
	was created by "many people" and is maintained by pb_ee1. I looked at
	code in both of those addons before hacking this together.
	
	This code is responsible for accepting "registrations" of fonts, sounds,
	textures, borders, and backgrounds and then registering them with all of
	the different versions of libsharedmedia so that they can be used by any
	addon.
]]--

local libSharedMedia1 = LibStub("SharedMedia-1.0", true)
local libSharedMedia2 = LibStub("LibSharedMedia-2.0", true)
local libSharedMedia3 = LibStub("LibSharedMedia-3.0", true)

TouchysMedia = {}
TouchysMedia.revision = 1

TouchysMedia.media = { ["background"] = {}, ["border"] = {}, ["font"] = {}, ["sound"] = {}, ["texture"] = {} }

-- Collects the media that we're going to register with sharedmedia
function TouchysMedia:Register(mediaType, key, data, language)
	if not TouchysMedia.media[mediaType] then
		TouchysMedia.media[mediaType] = {}
	end
	-- call RegisterMedia here if you want to allow adding media at any time
	-- not just when the addon loads. Why would you want that?
	table.insert(TouchysMedia.media[mediaType], { key, data, language})
end

-- Inject some piece of media into libsharedmedia all the shared medias
function TouchysMedia:RegisterMedia(mediaType, key, data, language) 
	if libSharedMedia3 then
		libSharedMedia3:Register(mediaType, key, data, language)
	end
	if libSharedMedia2 then
		libSharedMedia2:Register(mediaType, key, data)
	end
	if libSharedMedia1 then
		libSharedMedia1:Register(mediaType, key, data)
	end
end

-- Called when the addon is fully loaded: do all of the actual work.
function TouchysMedia.eventHandler(this, event, ...)
	if not libSharedMedia3 then
		libSharedMedia3 = LibStub("LibSharedMedia-3.0", true)
	end
	if not libSharedMedia2 then
		libSharedMedia2 = LibStub("LibSharedMedia-2.0", true)
	end
	if not libSharedMedia1 then
		libSharedMedia1 = LibStub("SharedMedia-1.0", true)
	end
	for mediaType, data in pairs(TouchysMedia.media) do
		for _, mediaValues in ipairs(data) do
			TouchysMedia:RegisterMedia(mediaType, mediaValues[1], mediaValues[2], mediaValues[3])
		end
	end
end

TouchysMedia.frame = CreateFrame("Frame")
TouchysMedia.frame:SetScript("OnEvent", TouchysMedia.eventHandler)
TouchysMedia.frame:RegisterEvent("ADDON_LOADED")
