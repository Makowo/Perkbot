local discordia = require('discordia')
discordia.extensions()
local scripts = require("scripts")
local settings = require("settings")
local client = discordia.Client()
local http = require("coro-http")
local json = require("json")
local clock = discordia.Clock()
local decode
local Names = {}
local nameslower = {}
local elo = {}
local mplayed = {}
local winloss = {}
local UID = {}
local GameOptions = {"Adding Titan Shifting", "Messing with perk's math", "Attack On Quest", "Bullying Ewan"}

local function setGame()
	client:setGame(GameOptions[math.random(#GameOptions)])
end

clock:on("min", function()
	setGame()
end)

client:on('ready', function()
	print('Logged in as '.. client.user.username)
    GetSpreadsheet()
    setGame()
end)

client:on('messageCreate', function(message)
	local args = message.content:split(" ")
    if not message.author.bot then
        if args[1] == '!updateelo' then
            if message.author.id == "553931341402472464" then
                local reply = message:reply('Updating Elo!')
                SendElo(message)
                reply:delete()
            else
                message.channel:send("You do not have permission to use this command.")
            end
        elseif args[1] == '!elo' then
            local reply = message.channel:send('Checking Elo!')
            CheckElo(message, args)
            reply:delete()
        elseif args[1] == '!bracket' then
            CheckLeaderboard(message)
        elseif table.find(args, "cringebot") or table.find(args, "Cringebot") then
            message:reply("no, you're cringe, " .. message.author.username)
        end
    end
end)

function GetSpreadsheet()
    coroutine.wrap(function()
        local res, body = http.request("GET", settings.link)
        decode = json.decode(body)
        Names = {}
        nameslower = {}
        elo = {}
        mplayed = {}
        winloss = {}
        for _, v in ipairs(decode.values) do
            table.insert(Names, v[1])
            table.insert(elo, v[2])
            table.insert(mplayed, v[3])
            table.insert(winloss, v[4])
            table.insert(UID, v[5])
        end
        for k,v in pairs(Names) do
            nameslower[k] = v:lower()
        end
    end)()
end

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

function CheckElo(message, args)
    GetSpreadsheet()
    if decode ~= nil then
        if args[2] ~= nil then
            if table.find(nameslower, args[2]:lower()) then
                local k = get_key_for_value(nameslower, args[2]:lower())
                local send =  "Elo: ".. elo[k] .."\nMatches Played: ".. mplayed[k] .. "\nWin Percentage: " ..winloss[k]
                message.channel:send{embed={fields = {{name = Names[k], value = send },}}}
            else
                message.channel:send("Name not found! Likely need caps.")
            end
        else
            if table.find(UID, message.author.id) then
                local k = get_key_for_value(UID, message.author.id)
                local send =  "Elo: ".. elo[k] .."\nMatches Played: ".. mplayed[k] .. "\nWin Percentage: " ..winloss[k]
                message.channel:send{embed={fields = {{name = Names[k], value = send },}}}
            else
                message.channel:send("UID not found! If you are part of the league, then yell (nicely) at perk to add your UID.")
            end
        end
    end
end

function CheckLeaderboard(message)
    local send = ""
    local count = 1
    for k, v in ipairs(mplayed) do
        if tonumber(v) >= 2 then
            send = send .. "\n" .. tostring(count) .. ". ".. Names[k] .. ", Elo: ".. elo[k]
            if count >= 16 then
                message.channel:send{embed={description = send}}
                break
            else
                count = count + 1
            end
        end
    end
end

clock:start()
client:run('Bot '.. settings.token)