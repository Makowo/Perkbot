--some things i've just stolen from google over the days, no idea where from.
local discordia = require("discordia")
local util = {}
util.tprint = function (tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
      formatting = string.rep("  ", indent) .. k .. ": "
      if type(v) == "table" then
        print(formatting)
        util.tprint(v, indent+1)
      else
        print(formatting .. tostring(v))
      end
    end
  end
function table.find(t,value)
    if t and type(t)=="table" and value then
        for _, v in ipairs (t) do
            if v == value then
                return true;
            end
        end
        return false;
    end
    return false;
end
 util.get_key_for_value= function( t, value )
    for k,v in pairs(t) do
      if v==value then return k end
    end
    return nil
  end
util.logError = function(logChannel, err)
  return logChannel:send{
    content="<@109199911441965056>",
		embed = {
			title = "Bot errored!",
			description = "```\n"..err.."```",
			color = discordia.Color.fromHex("ff0000").value,
			timestamp = discordia.Date():toISO('T', 'Z'),
			footer = {
				text = "if you're seeing this, i'm sad."
			}
		}
	}
end
util.logMatch = function(logChannel, err, message)
  return logChannel:send{
		embed = {
			title = "Match Complete!",
			description = "```\n"..err.."```",
			color = discordia.Color.fromHex("#008000").value,
			timestamp = discordia.Date():toISO('T', 'Z'),
			footer = {
				text = "Done By: " .. message.author.tag,
        icon_url = message.author.avatarURL
			}
		}
	}
end
return util