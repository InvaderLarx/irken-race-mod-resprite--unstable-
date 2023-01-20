require "/scripts/util.lua"
require "/quests/scripts/questutil.lua"
require("/quests/scripts/portraits.lua")

function init()
  self.radioMessages = config.getParameter("radioMessages")
  storage.techStored = storage.techStored or player.equippedTech("legs")
  storage.techEquipped = storage.techEquipped or false
  storage.item = storage.item or false
  storage.timer = storage.timer or 0
  storage.techSwapped = storage.techSwapped or false
  storage.debug = config.getParameter("debug") or false
  message.setHandler("techChangeOn", function(...) onTechChangeEquipped(...) end)
  --message.setHandler("techChangeOff", function(...) onTechChangeOff(...) end)

end

function onTechChangeEquipped(message, isLocal, techName)
	local eqTech = player.equippedTech("legs")
	if eqTech ~= techName then
		storage.techStored = player.equippedTech("legs") or false --just for legs right now. hopefully this works
		storage.techEquipped = techName
		storage.item = player.equippedItem("back").name
		if storage.debug then
			local messageTemp = self.radioMessages.received
			messageTemp.text="Activated Tech "..techName.." ( replaced "..storage.techStored.." ) on "..storage.item
			player.radioMessage(messageTemp)
		end
		player.makeTechAvailable(techName)
		player.enableTech(techName)
		player.equipTech(techName)
		storage.techSwapped = true
	elseif storage.debug then
		local messageTemp = self.radioMessages.received
		messageTemp.text="Duplicate launch detected, attempted to treat tech ".. techName.." as replaced tech ("..storage.techStored..")"
		player.radioMessage(messageTemp)
	end
end

--[[function onTechChangeOff(message, isLocal, ...)
	player.equipTech(storage.techStored)
	local messageTemp = self.radioMessages.received
	messageTemp.text="Item "..storage.item.." removed. Restoring tech "..storage.techStored
	player.radioMessage(messageTemp)
end]]--

function questStart()
	storage.timer = 0
	storage.techEquipped = false
	
end

function questComplete()
	questutil.questCompleteActions()
end

function update(dt)
	local itemTemp = ""
	if player.equippedItem("back") then
		itemTemp = player.equippedItem("back").name
	end
	if storage.techEquipped and storage.item then --don't want it to die while waiting for the message
		if itemTemp ~= storage.item then --check if player is still wearing the item
			if storage.techSwapped then
				if storage.techStored then
					player.equipTech(storage.techStored)
				end
				player.makeTechUnavailable(storage.techEquipped)
				if storage.debug then
					local messageTemp = self.radioMessages.received
					messageTemp.text="Item "..storage.item.." removed. Restoring tech "..storage.techStored
					player.radioMessage(messageTemp)
				end
				storage.techSwapped = false
			end
		elseif not player.hasItem({name = storage.item}) then --check if player HAS the item at all
			quest.complete()
		elseif player.equippedTech("legs") ~= storage.techEquipped and storage.techSwapped then --if the tech changed, assume player kinda wants it to change when they take the item off
			storage.techStored = player.equippedTech("legs")
			player.equipTech(storage.techEquipped)
		end
	end
	--[[elseif storage.timer < 120 then --just in case. hope message arrives faster than that.
		storage.timer = storage.timer + dt
	else
		quest.complete()
	end
	quest.setProgress(math.min(1.0,(storage.timer/120)))]]--
end