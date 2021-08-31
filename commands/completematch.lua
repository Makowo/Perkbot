local util = require("../functions/scripts")
local slash = require("discordia-slash")
local gen = require("../functions/general")
local completematch = {
    name = "completematch",
    description = "Admin only command, but we can't hide this so hi!",
    options = {
        {
            name = "player1",
            description = "UID of player 1",
            type = slash.enums.optionType.string,
            required = true
        },
        {
            name = "player2",
            description = "UID of player2",
            type = slash.enums.optionType.string,
            required = true
        }
    },
    callback = function(ia, params, cmd)
        if table.find({"553931341402472464","109199911441965056"}, ia.member.user.id) then
            local success, err = pcall(gen.CompleteMatch, ia, params)
            if not success then
                ia:reply("An error has occurred, The developer has been notified!", true)
                util.logError( err)
            end
        else
            ia:reply("You do not have permission to use this command.", true)
        end
    end
}

return completematch