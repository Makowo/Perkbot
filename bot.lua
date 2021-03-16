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
local GameOptions = {"Adding Titan Shifting", "Messing with perk's math","Attack On Quest"}

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

    if args[1] == '!updateelo' then
        if message.author.id == "553931341402472464" or "109199911441965056" then
            local reply = message:reply('Updating Elo!')
            --message:delete()
            SendElo(message)
            reply:delete()
        else
            message.channel:send("You do not have permission to use this command.")
        end
    elseif args[1] == '!elo' then
		local reply = message.channel:send('Checking Elo!')
        --message:delete()
        CheckElo(message, args)
        reply:delete()
	end
end)

function GetSpreadsheet()
    coroutine.wrap(function()
        local res, body = http.request("GET", settings.link)
        decode = json.decode(body)
        --print(body)
        --print(decode.values[1][1])
        Names = {}
        nameslower = {}
        elo = {}
        mplayed = {}
        winloss = {}
        for _, v in ipairs(decode.values) do
            --print(v[k])
            table.insert(Names, v[1])
            table.insert(elo, v[3])
            table.insert(mplayed, v[4])
            table.insert(winloss, v[31])
        end
        for k,v in pairs(Names) do
            nameslower[k] = v:lower()
        end
        --tprint(Names)
        --tprint(elo)
        --tprint(mplayed)
        --tprint(winloss)
    end)()
end

function SendElo(message)
    GetSpreadsheet()
    if decode ~= nil then
        if message.author.id == "553931341402472464" or "109199911441965056" then
            for k, _ in ipairs(decode.values) do
                --print(v[k])
                local send =  "Elo: ".. elo[k] .."\nMatches Played: ".. mplayed[k] .. "\nW/L: " ..winloss[k]
                message.channel:send{
                    embed={
                        fields = {
                            {name = Names[k], value = send },
                        }
                    }}
            end
        end
    end
end

function CheckElo(message, args)
    GetSpreadsheet()
    if decode ~= nil then
        if args ~= nil then
            if table.find(nameslower, args[2]:lower()) then
                local k = get_key_for_value(nameslower, args[2])
                print("found!")
                local send =  "Elo: ".. elo[k] .."\nMatches Played: ".. mplayed[k] .. "\nW/L: " ..winloss[k]
                message.channel:send{
                    embed={
                        fields = {
                            {name = Names[k], value = send },
                        }
                    }}
            else
                message.channel:send("Name not found! Likely need caps.")
            end
        end
    end
end
clock:start()
client:run('Bot '.. settings.token)