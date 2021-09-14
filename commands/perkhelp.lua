local perkhelp = {
    name = "perkhelp",
    description = "Displays a list of Perkbot commands.",
    options = {},
    callback = function(ia, params, cmd)
        ia:reply({embeds={{description="/elo: Checks your current elo.\n /elo <name or @> <card>\n<name or @>, string: Check another player's current elo.\n<card>, boolean: Displays the Player's stat card. Note this isn't updated in real time.\n/bracket: Displays a list of the top 16 players"}}}, true)
    end
}

return perkhelp