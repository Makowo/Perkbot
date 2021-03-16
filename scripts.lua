--some things i've just stolen from google over the days, no idea where from.

function tprint (tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
      formatting = string.rep("  ", indent) .. k .. ": "
      if type(v) == "table" then
        print(formatting)
        tprint(v, indent+1)
      else
        print(formatting .. v)
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
function get_key_for_value( t, value )
    for k,v in pairs(t) do
      if v==value then return k end
    end
    return nil
  end
