local perkhelp = {
    name = "perkhelp",
    description = "Displays a list of Perkbot commands.",
    options = {},
    callback = function(ia, params, cmd)
        ia:reply({embeds={{description="/elo: Checks the Player's current elo. \n /elo <name>: Check another player's current elo\n /bracket: Displays a list of the top 16 players"}}}, true)
    end
}

return perkhelp