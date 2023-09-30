-- Made by Omeruin, Idea by Silver Sokolova#3576
function init()
    if (not player.getProperty("irk_ItemDrop") and player.species()=="irken") then
      player.giveItem("PAKback")
      if player.hasItem("PAKback",false) then
        player.setProperty("irk_ItemDrop", 1)
      elseif player.ownShipWorldId() then
        -- You can either uncomment this by removing the "--" or delete these lines entirely. This is if you want your own custom radio messages for when the item is dropped and whatnot!
        -- player.radioMessage("om_rtpickUpWarning2", 1)
      else
        -- player.radioMessage("om_rtpickUpWarning")
        world.spawnItem("PAKback", world.entityPosition(entity.id()), 1)
      end
    end
    script.setUpdateDelta(60)
end

function update(dt)
    if (not player.getProperty("irk_ItemDrop") and player.species()=="irken" and (player.worldId() ~= player.ownShipWorldId())) then
        -- player.radioMessage("om_rtpickUpWarning")
        world.spawnItem("PAKback", world.entityPosition(player.id()), 1)
    end
    script.setUpdateDelta(0)
end