local util = require("../functions/scripts")
local gen = require("../functions/general")
local bracket = {
    name = "bracket",
    description = "Displays a list of the top 16 players",
    options = {},
    callback = function(ia, params, cmd)
        if table.find({"553931341402472464","109199911441965056"}, ia.member.user.id) then
            local success, err = pcall(gen.CheckLeaderboard, ia)
            if not success then
                ia:update("An error has occurred, The developer has been notified!", true)
                util.logError( err)
            end
        end
    end
}

return bracket