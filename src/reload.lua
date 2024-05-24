---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,
-- 	so only assign to values or define things here.


function postfix_EquipMetaUpgrades()
	
	local metaUpgradeName = "MaxHealthPerRoom"
	local metaUpgradeData = GameState.MetaUpgradeState[ metaUpgradeName ]
	local metaUpgradeCardData = MetaUpgradeCardData[ metaUpgradeName ]
	if config.toggleSwitch == false then
		rom.log.debug("CentaurToggle is false, removing trait")
		if metaUpgradeCardData and metaUpgradeData.Equipped and metaUpgradeCardData.TraitName and not metaUpgradeCardData.ActiveWhileDead then
			RemoveWeaponTrait( metaUpgradeCardData.TraitName )
		end
		metaUpgradeData.Unlocked = false
		metaUpgradeData.Equipped = false
	else
		metaUpgradeData.Unlocked = true
		metaUpgradeData.Equipped = true
	end
end