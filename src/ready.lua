---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.


modutil.mod.Path.Wrap("EquipMetaUpgrades", function (base,...)
	local rets = table.pack(base(...))
	postfix_EquipMetaUpgrades()
	return table.unpack(rets)
end)

