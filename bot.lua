local discordia = require('discordia')
local slash = require("discordia-slash")
discordia.extensions()
local util = require("./functions/scripts")
local gen = require("./functions/general")
local settings = require("./settings")
local client = discordia.Client():useSlashCommands()
local clock = discordia.Clock()
local timer = 0
local devmode = true
local guild --TODO Change to AOQ discord
local GameOptions = {"Adding titan shifting", "Messing with perk's math", "Attack On Quest", "Bullying Ewan", "Practicing chop skims", "Crying in a corner", "Trashing Timmys", "Watching Quest Taker", "Watching Calactic", "Super jumping", "Searching for fuel in Shiganshina", "Taking a water break", "Summoning boss titans in 1v1s", "Unlocking the lobby in a 1v1", "On US server", "Hanging out with Perk", "🅱️erk", "Killing Jim’s lackies", "Requesting titan shifting", "Requesting colossal titan", "Requesting PVP", "Arguing with Dyno", "Having an existential crisis", "Breaking Mako’s code", "Error 404 message not found", "!Perkhelp", "Losing my small amount of remaining sanity", "Listening to hopes and dreams by Toby Fox", "Help help get me out", "I’m not a bot please I’m trapped", "I’m being held here against my will", "Doing Perk’s math homework", "Don’t dm me for modmail", "Waiting for my next update"}

local function setGame()
	client:setGame(GameOptions[math.random(#GameOptions)])
    guild.me:setNickname(nil)
end

clock:on("min", function()
    timer = timer + 1
    if timer == 10 then
        timer = 0
        setGame()
    end
end)

client:on('slashCommandsReady', function()
    local logChannel = "857450532423073812"
	print('Logged in as '.. client.user.username)
    if devmode then
        guild = client:getGuild("540633273110364161")
    else
        guild = client:getGuild("808112859372060672")
        logChannel = "882065076041961514"
    end
    discordia.storage.logChannel = client:getGuild(guild):getChannel(logChannel)
    discordia.storage.client = client
    gen:GetSpreadsheet()
    gen:LoadCommands()
    setGame()
    local success, err = pcall(function(...)
        for _, v in pairs(gen.commands) do
            guild:slashCommand(v)
        end
    end)
    if not success then
        util.logError(err)
    end
end)

clock:start()
client:run('Bot '.. settings.token)