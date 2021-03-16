local discordia = require('discordia')
discordia.extensions()
local scripts = require("scripts")
local settings = require("settings")
local client = discordia.Client()
local http = require("coro-http")
local json = require("json")
local decode
local Names = {}
local elo = {}
local mplayed = {}
local winloss = {}

client:on('ready', function()
	print('Logged in as '.. client.user.username)
    GetSpreadsheet()
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
    elseif args[1] == '!checkelo' then
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
        for _, v in ipairs(decode.values) do
            --print(v[k])
            table.insert(Names, v[1])
            table.insert(elo, v[2])
            table.insert(mplayed, v[3])
            table.insert(winloss, v[4])
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
            for k, v in ipairs(decode.values) do
                print(v[k])
                local send = "**"..v[1].."**" .. ": ".. v[2] .."\n**Matches Played**: ".. v[3] .. "\n**W/L**: " ..v[4]
                message.channel:send(send)
            end
        end
    end
end

function CheckElo(message, args)
    GetSpreadsheet()
    if decode ~= nil then
        if args ~= nil then
            if table.find(Names, args[2]) then
                local k = get_key_for_value(Names, args[2])
                print("found!")
                local send = "**"..Names[k].."**" .. ": ".. elo[k] .."\n**Matches Played**: ".. mplayed[k] .. "\n**W/L**: " ..winloss[k]
                message.channel:send(send)
            end
        end
    end
end

client:run('Bot '.. settings.token)