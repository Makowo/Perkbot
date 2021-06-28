local discordia = require('discordia')
discordia.extensions()
local util = require("./scripts")
local settings = require("./settings")
local client = discordia.Client()
local http = require("coro-http")
local json = require("json")
local clock = discordia.Clock()
local timer = 0
local decode
local Names = {}
local nameslower = {}
local elo = {}
local mplayed = {}
local winloss = {}
local UID = {}
local sorteddata = {}
local interfacedata = {}
local logChannel
local GameOptions = {"Adding titan shifting", "Messing with perk's math", "Attack On Quest", "Bullying Ewan", "Practicing chop skims", "Crying in a corner", "Trashing Timmys", "Watching Quest Taker", "Watching Calactic", "Super jumping", "Searching for fuel in Shiganshina", "Taking a water break", "Summoning boss titans in 1v1s", "Unlocking the lobby in a 1v1", "On US server", "Hanging out with Perk", "🅱️erk", "Killing Jim’s lackies", "Requesting titan shifting", "Requesting colossal titan", "Requesting PVP", "Arguing with Dyno", "Having an existential crisis", "Breaking Mako’s code", "Error 404 message not found", "!Perkhelp", "Losing my small amount of remaining sanity", "Listening to hopes and dreams by Toby Fox", "Help help get me out", "I’m not a bot please I’m trapped", "I’m being held here against my will", "Doing Perk’s math homework", "Don’t dm me for modmail", "Waiting for my next update"}
local function setGame()
	client:setGame(GameOptions[math.random(#GameOptions)])
    local guild = client:getGuild("808112859372060672") --TODO Change to AOQ discord
    guild.me:setNickname(nil)
end

clock:on("min", function()
    timer = timer + 1
    if timer == 10 then
        timer = 0
        setGame()
    end
end)

client:on('ready', function()
	print('Logged in as '.. client.user.username)
    logChannel = client:getGuild("540633273110364161"):getChannel("857450532423073812")
    GetSpreadsheet()
    setGame()
end)

client:on('messageCreate', function(message)
    local success, err = pcall(function(...)
        local content = message.content:lower()
        local args = content:split(" ")
        if not message.author.bot then
            --force bot channel to prevent spam
            if message.channel.id == "763264210800869386" then
                if args[1] == '!elo' then
                    local reply = message.channel:send('Checking Elo!')
                    CheckElo(message, args)
                    reply:delete()
                elseif args[1] == '!bracket' then
                    CheckLeaderboard(message)
                elseif args[1] == '!perkhelp' then
                    local reply = "!elo: Checks the User's elo and IGN \n!elo [IGN]: Checks the elo and stats of the IGN included \n!bracket: Displays a list of the top 16 qualified people for the finals"
                    message:reply{embed={description = reply}}
                elseif args[1] == '!buttontest' then
                    
                end
            --Update elo command, admin only and limited to specific channel
            elseif message.channel.id == "814918813346168893" then
                if args[1] == '!updateelo' then
                    if message.author.id == "553931341402472464" or "109199911441965056" then
                        local reply = message:reply('Updating Elo!')
                        SendElo(message)
                        reply:delete()
                    else
                        message.channel:send("You do not have permission to use this command.")
                    end
                end
            end
            if args[1] == '!completematch' then
                if message.author.id == "553931341402472464" or "109199911441965056" then
                    CompleteMatch(message, args)
                end
            end
        end
    end)
    if not success then
        util.logError(logChannel, err)
    end
end)

function GetSpreadsheet()
    coroutine.wrap(function()
        local res, body = http.request("GET", settings.link)
        decode = json.decode(body)
        --tprint(decode)
        Names = {}
        nameslower = {}
        elo = {}
        mplayed = {}
        winloss = {}
        UID = {}
        sorteddata = {}
        interfacedata = {}
        for _, v in ipairs(decode.valueRanges[2].values) do
            table.insert(UID, v[1])
            table.insert(Names, v[2])
            table.insert(elo, v[3])
            table.insert(mplayed, v[4])
            table.insert(winloss, v[5])
        end
        --sorted data by elo for CheckLeaderboard
        for _, v in pairs(decode.valueRanges[1].values) do
            table.insert(sorteddata, v)
        end
        --data from the USER INTERFACE sheet
        for _, v in pairs(decode.valueRanges[3].values) do
            table.insert(interfacedata, v)
        end
        --Placeholder insert so the ELODIFF1/2/3 calculations are correct
        for k, _ in pairs(interfacedata) do
            table.insert(interfacedata[k], "e")
        end
        --tprint(interfacedata)
        for k,v in pairs(Names) do
            nameslower[k] = v:lower()
        end
    end)()
end
--Update elo command, Sends every players elo into a channel.
function SendElo(message)
    GetSpreadsheet()
    if decode ~= nil then
        if message.author.id == "553931341402472464" or "109199911441965056" then
            for k, _ in ipairs(decode.values) do
                local send =  "Elo: ".. elo[k] .."\nMatches Played: ".. mplayed[k] .. "\nWin Percentage: " ..winloss[k]
                message.channel:send{embed={fields = {{name = Names[k], value = send },}}}
            end
        end
    end
end
--elo command, for any user wishing to check a player's elo.
function CheckElo(message, args)
    GetSpreadsheet()
    if decode ~= nil then
        if args[2] ~= nil then
            --User is checking another player
            if table.find(nameslower, args[2]:lower()) then
                local k = util.get_key_for_value(nameslower, args[2]:lower())
                local send =  "Elo: ".. elo[k] .."\nMatches Played: ".. mplayed[k] .. "\nWin Percentage: " ..winloss[k]
                message.channel:send{embed={fields = {{name = Names[k], value = send },}}}
            else
                message.channel:send("Name not found!")
            end
        else
            --User is checking self
            if table.find(UID, message.author.id) then
                local k = util.get_key_for_value(UID, message.author.id)
                local send =  "Elo: ".. elo[k] .."\nMatches Played: ".. mplayed[k] .. "\nWin Percentage: " ..winloss[k]
                message.channel:send{embed={fields = {{name = Names[k], value = send },}}}
            else
                message.channel:send("UID not found! If you are part of the league, then yell (nicely) at Perk to add your UID.")
            end
        end
    end
end
--Sends a message displaying the top 16 players in order of elo
function CheckLeaderboard(message)
    local send = ""
    local count = 1
    for k, v in ipairs(sorteddata) do
        send = send .. "\n" .. tostring(count) .. ". ".. sorteddata[k][2] .. ", Elo: ".. sorteddata[k][3]
        if count >= 16 then
            message.channel:send{embed={description = send}}
            break
        else
            count = count + 1
        end
    end
end
--Allows for admins to easily complete a match via a command instead of manually updating the spreadsheet
function CompleteMatch(message, args)
    GetSpreadsheet()
    local memberServer = client:getGuild("540633273110364161") --TODO: Change to AOQ server
    local player1 = message.mentionedUsers.first or memberServer:getMember(args[2]).user
    local player2 = message.mentionedUsers.last or memberServer:getMember(args[3]).user
    if player1 and player2 then
        local winningplayer
        local lostplayer
        local reply = message:reply{
            content = "Please @ the winner or post their UID.",
            components = {{type = 1,components = {
                {type = 2, style = 1, label = player1.name, custom_id = "player_1", disabled = false},
                {type = 2, style = 1, label = player2.name, custom_id = "player_2", disabled = false}
            }}}}
        --Wait for response of either @ or UID
        client:waitFor("buttonPressed", 20000, function(buttonid, member)
            print(member)
            if message.author.id == member.user.id then
                --if mentioned is nil, it'll always be player 1
                if buttonid == "player_1" then
                    winningplayer = player1.id
                    lostplayer = player2.id
                elseif buttonid == "player_2" then
                    winningplayer = player2.id
                    lostplayer = player1.id
                end
                message:delete()
                return true
            end
          end)
        --Wait for response of either @ or UID
        if winningplayer ~= nil then
            --print("WP:" .. tostring(winningplayer))
            local winrow = GetNotation(winningplayer)
            local lossrow = GetNotation(lostplayer)
            local p1diff, p2diff = CalculateEloDiff(winningplayer,lostplayer)
            local winner = "Winner: ".. memberServer:getMember(winningplayer).user.tag .. " UID:" .. winningplayer
            local loser = "Loser: ".. memberServer:getMember(lostplayer).user.tag .. " UID:" .. lostplayer
            local err = winner.." Elo Diff:"..p1diff.."\n"..loser.." Elo Diff:"..p2diff

            WriteDataToSheet(winrow, p1diff, true)
            WriteDataToSheet(lossrow, p2diff, false)
            reply:update({content = winner.. " Elo Diff:".. p1diff.."\n" .. loser..  " Elo Diff:".. p2diff.."\nPlease verify this is correct in the sheet!"})
            util.logMatch(logChannel, err, message)
        else
            reply:setContent("Error: Ping ID does not match either player or the command timed out! Please try again.")
        end
    end
end
--Compiles and writes data to our sheet using SpreadAPI
function WriteDataToSheet(row, elodiff, winner)
    --print("Row:".. row)
    --lots of -1 because some data excludes the first row of the sheet, due to column names not being needed
    local data = interfacedata[row-1]
    local Wins = data[4]
    local matches = mplayed[row-1]
    if winner then
        Wins = Wins + 1
    end
    local playerdata = {
        ["method"] = "PUT",
        ["sheet"] = "USER INTERFACE",
        ["key"] = settings.key,
        ["id"] = row,
        ["payload"] = {
            ["Name"] = {"=('ELO TEST'!B"..row..")"},
            ["ELO"] = {"=('ELO TEST'!D"..row..")"},
            ["Matches Played"] = {matches+1},
            ["Wins"] = {Wins}

        }
    }
    --tprint(data)
    for i, v in ipairs(data) do
        if i >= 5 and i ~= #data then
            playerdata.payload["ELO DIFF"..i-4] = {v}
        elseif i >= 5 and i == #data then
            playerdata.payload["ELO DIFF"..i-4] = {elodiff}
            break
        end
    end
    --tprint(playerdata)
    local body = json.encode(playerdata)
    --print(body)
    --local decode2 = json.decode(body)
    --tprint(decode2)
    coroutine.wrap(function()
        local res, body = http.request("POST", settings.write_link , {headers = { ["Content-Type"] = "application/x-www-form-urlencoded" }}, body)
        --print(body)
        --tprint(res)
    end)()
end
--Gets the row of the player based on UID, should probably rename this.
function GetNotation(winner)
    if table.find(UID, winner) then
        local k = util.get_key_for_value(UID, winner)
        --print("K:" .. tostring(k))
        return k + 1
    else
        return "256"
    end
end
--Calculates the elo difference between players
function CalculateEloDiff(player1, player2)
    local player1elo
    local player2elo
    if table.find(UID, player1) then
        local k = util.get_key_for_value(UID, player1)
        --print("K:" .. tostring(k))
        player1elo = tonumber(elo[k])
        --print(player1elo)
    end
    if table.find(UID, player2) then
        local k = util.get_key_for_value(UID, player2)
        --print("K:" .. tostring(k))
        player2elo = tonumber(elo[k])
        --print(player2elo)
    end
    local p1diff = player1elo - player2elo
    local p2diff = player2elo - player1elo
    --print(p1diff)
    --print(p2diff)
    return p1diff, p2diff
end

clock:start()
client:run('Bot '.. settings.token)