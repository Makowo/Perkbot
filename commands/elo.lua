local util = require("../functions/scripts")
local slash = require("discordia-slash")
local gen = require("../functions/general")
local elo = {
        name = "elo",
        description = "Checks the Player's current elo",
        options = {
            {
                name = "user",
                description = "Check another Player's elo",
                type = slash.enums.optionType.string,
                required = false
            },
            {
                name = "card",
                description = "Show this Player's stat card, the cards are not updated in real time.",
                type = slash.enums.optionType.boolean,
                required = false
            }
        },
        callback = function(ia, params, cmd)
            local success, err = pcall(gen.CheckElo, ia, params)
            if not success then
                ia:update("An error has occurred, The developer has been notified!", true)
                util.logError(err)
            end
        end
    }

return elo