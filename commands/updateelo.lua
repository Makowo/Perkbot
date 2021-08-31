local util = require("../functions/scripts")
local gen = require("../functions/general")
local updateelo = {
    name = "updateelo",
    description = "Admin only command, but we can't hide this so hi!",
    options = {},
    callback = function(ia, params, cmd)
        if table.find({"553931341402472464","109199911441965056"}, ia.member.user.id) then
            ia:reply("Spam commencing!", true)
            local success, err = pcall(gen.SendElo, ia)
            if not success then
                ia:update("An error has occurred, The developer has been notified!", true)
                util.logError( err)
            end
        else
            ia:reply("You do not have permission to use this command.", true)
        end
    end
}

return updateelo