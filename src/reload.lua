---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,
-- 	so only assign to values or define things here.


function postfix_EquipMetaUpgrades()
	if config.toggleSwitch == false then
		rom.log.debug("CentaurToggle is false, removing trait")
		local metaUpgradeName = "MaxHealthPerRoom"
		local metaUpgradeData = GameState.MetaUpgradeState[ metaUpgradeName ]
		local metaUpgradeCardData = MetaUpgradeCardData[ metaUpgradeName ]
		if metaUpgradeCardData and metaUpgradeData.Equipped and metaUpgradeCardData.TraitName and not metaUpgradeCardData.ActiveWhileDead then
			RemoveWeaponTrait( metaUpgradeCardData.TraitName )
		end
		metaUpgradeData.Unlocked = false
		metaUpgradeData.Equipped = false
	end
end