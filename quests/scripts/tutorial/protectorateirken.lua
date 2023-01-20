require("/quests/scripts/portraits.lua")
require("/quests/scripts/questutil.lua")

function init()
end

function questStart()
  player.giveItem("PAKback")
  storage.starterBack = player.equippedItem("back")
end

function questComplete()
  questutil.questCompleteActions()
end

function update(dt)
	if player.equippedItem("back").name == "PAKback" then
          quest.complete()
	end
end

function uninit()
end
