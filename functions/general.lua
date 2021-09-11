local discordia = require('discordia')
discordia.extensions()
local http = require("coro-http")
local json = require("json")
local settings = require("./settings")
local util = require("../functions/scripts")
local fs = require("fs")
local self = {}

self.decode = {}
self.commands = {}
self.PlayerData = {}
self.SortedData = {}
self.interfacedata = {}

function self.GetSpreadsheet()
    coroutine.wrap(function()
        local res, body = http.request("GET", settings.link)
        self.decode = json.decode(body)
        self.PlayerData = {}
        self.SortedData = {}
        self.interfacedata = {}
        if self.decode then
            for i, v in ipairs(self.decode.valueRanges[2].values) do
                self.PlayerData[i] = {
                    UID = v[1],
                    Name = v[2],
                    namelower = v[2]:lower(),
                    elo = v[3],
                    mplayed = v[4],
                    winloss = v[5]
                }
            end
            --sorted data by elo for CheckLeaderboard
            self.SortedData = table.deepcopy(self.PlayerData)
            table.sort(self.SortedData, function(a,b) return tonumber(a.elo)>tonumber(b.elo) end)
            --data from the USER INTERFACE sheet
            for _, v in pairs(self.decode.valueRanges[3].values) do
                table.insert(self.interfacedata, v)
            end
            --Placeholder insert so the ELODIFF1/2/3 calculations are correct
            for k, _ in pairs(self.interfacedata) do
                table.insert(self.interfacedata[k], "e")
            end
        end
    end)()
end

--Update elo command, Sends every players elo into a channel.
function self.SendElo(message)
    self.GetSpreadsheet()
    if self.decode ~= nil then
        if message.member.user.id == "553931341402472464" or "109199911441965056" then
            local counter = 0
            local send = {embed={fields = {}}}
            --for every 9, send a embed with those players, loop until all players have been sent.
            for k, _ in pairs(self.SortedData) do
                counter = counter + 1
                table.insert(send.embed.fields, {name = k .. ". ".. self.SortedData[k].Name, value = "Elo: ".. self.SortedData[k].elo .."\nMatches Played: ".. self.SortedData[k].mplayed .. "\nWin Percentage: " ..self.SortedData[k].winloss, inline = true})
                if counter == 9 or k == #self.SortedData then
                    message.channel:send(send)
                    send = {embed={fields = {}}}
                    counter = 0
                end
            end
        end
    end
end

function self.CheckElo(message, args)
    self:GetSpreadsheet()
    if self.decode ~= nil then
        local validname = false
        local uid = message.member.user.id --set uid if there's no args
        local user = args.user or "aaaaaaaaaaaaaaaaaaaaaaaa" -- don't want this to be nil, incase a name is nil for some reason.

        if args.user and args.user:find("<@!") then
            uid = args.user:gsub("<@!", ""):gsub(">", "") --if ping, set uid as pinged uid
        else
            uid = args.user or uid
        end

        for k, _ in pairs(self.PlayerData) do
            if self.PlayerData[k].namelower == user:lower() or self.PlayerData[k].UID == uid then
                local send =  "Elo: ".. self.PlayerData[k].elo .."\nMatches Played: ".. self.PlayerData[k].mplayed .. "\nWin Percentage: " ..self.PlayerData[k].winloss
                local image
                --i'm incompetent so i uploaded the files to github and use the links.
                --also because slash commands don't support attachments afaik, pain
                if args.card then
                    image = {url = "https://raw.githubusercontent.com/Makowo/Perkbot/cards/currentseason/".. self.PlayerData[k].namelower ..".png"}
                end
                message:reply{embeds={{fields = {{name = self.PlayerData[k].Name, value = send }},image = image or nil}}}
                validname = true
                break
            end
        end

        if not validname then
            message:reply("Name not found, make sure you are using their IGN!", true)
        end
    end
end
--Sends a message displaying the top 16 players in order of elo
function self.CheckLeaderboard(message)
    local send = ""
    local count = 1
    for k, v in ipairs(self.SortedData) do
        send = send .. "\n" .. tostring(count) .. ". ".. self.SortedData[k].Name .. ", Elo: ".. self.SortedData[k].elo
        if count >= 16 then
            message:reply{embeds={{description = send}}}
            break
        else
            count = count + 1
        end
    end
end
--Allows for admins to easily complete a match via a command instead of manually updating the spreadsheet
function self.CompleteMatch(ia, args)
    self.GetSpreadsheet()
    local client = discordia.storage.client
    local memberServer = client:getGuild("540633273110364161") --TODO: Change to AOQ server
    local player1 = memberServer:getMember(args.player1:gsub("<@!", ""):gsub(">", ""))
    local player2 = memberServer:getMember(args.player2:gsub("<@!", ""):gsub(">", ""))

    if player1 and player2 then
        local winningplayer
        local lostplayer
        --Create the buttons to select winner.
        ia:reply{
            content = "Please select the winner.",
            components = {{type = 1,components = {
                {type = 2, style = 1, label = player1.user.name, custom_id = "player_1", disabled = false},
                {type = 2, style = 1, label = player2.user.name, custom_id = "player_2", disabled = false}
            }}}}
        --Wait for response of button press
        coroutine.wrap(function()
            client:waitFor("buttonPressed", 30000, function(buttonid, member)
            if ia.member.user.id == member.user.id then
                if buttonid == "player_1" then
                    winningplayer = player1.user.id
                    lostplayer = player2.user.id
                elseif buttonid == "player_2" then
                    winningplayer = player2.user.id
                    lostplayer = player1.user.id
                end
                return true
            end
          end)
        --Calculate elo diff and send sheet data
        if winningplayer ~= nil then
            local winrow = self.GetRow(winningplayer)
            local lossrow = self.GetRow(lostplayer)
            local p1diff, p2diff = self.CalculateEloDiff(winningplayer,lostplayer)
            local winner = "Winner: ".. memberServer:getMember(winningplayer).user.tag .. " UID:" .. winningplayer
            local loser = "Loser: ".. memberServer:getMember(lostplayer).user.tag .. " UID:" .. lostplayer
            local err = winner.." Elo Diff:"..p1diff.."\n"..loser.." Elo Diff:"..p2diff

            self.WriteDataToSheet(winrow, p1diff, true)
            self.WriteDataToSheet(lossrow, p2diff, false)
            ia:update({content = winner.. " Elo Diff:".. p1diff.."\n" .. loser..  " Elo Diff:".. p2diff.."\nPlease verify this is correct in the sheet!",components = {}})
            util.logMatch(err, ia)
        else
            ia:update("Error: ID does not match either player or the command timed out! Please try again.")
        end
        end)()
    else
        ia:reply("Error: One or more UID's are incorrect or aren't in the server! \nPlayer 1: " .. tostring(args.player1) .. "\nPlayer 2: " .. tostring(args.player2), true)
    end
end

--Compiles and writes data to our sheet using SpreadAPI
function self.WriteDataToSheet(row, elodiff, winner)
    --lots of -1 because some data excludes the first row of the sheet, due to column names not being needed
    local data = self.interfacedata[row-1]
    local Wins = data[4]
    local matches = self.PlayerData[row -1].mplayed
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

    for i, v in ipairs(data) do
        if i >= 5 and i ~= #data then
            playerdata.payload["ELO DIFF"..i-4] = {v}
        elseif i >= 5 and i == #data then
            playerdata.payload["ELO DIFF"..i-4] = {elodiff}
            break
        end
    end

    local body = json.encode(playerdata)

    coroutine.wrap(function()
        local res, body = http.request("POST", settings.write_link , {headers = { ["Content-Type"] = "application/x-www-form-urlencoded" }}, body)
    end)()
end
--Gets the row of the player based on UID, should probably rename this.
function self.GetRow(winner)
    for k, _ in pairs(self.PlayerData) do
        if self.PlayerData[k].UID == winner then
            print(self.PlayerData[k].Name)
            return k + 1
        end
    end
    return "256"
end
--Calculates the elo difference between players
function self.CalculateEloDiff(player1, player2)
    local player1elo
    local player2elo
    for k, _ in pairs(self.PlayerData) do
        if self.PlayerData[k].UID == player1 then
            player1elo = tonumber(self.PlayerData[k].elo)
        elseif self.PlayerData[k].UID == player2 then
            player2elo = tonumber(self.PlayerData[k].elo)
        end
    end
    local p1diff = player1elo - player2elo
    local p2diff = player2elo - player1elo

    return p1diff, p2diff
end

function self.LoadCommands()
    for _,filename in ipairs(fs.readdirSync("commands")) do
		local command = require("../commands/"..filename)
		self.commands[command.name] = command
	end
end

return self