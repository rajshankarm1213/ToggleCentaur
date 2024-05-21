---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,
-- 	so only assign to values or define things here.


function EquipMetaUpgrades_override(hero, args)
	if GetNumShrineUpgrades( "NoMetaUpgradesShrineUpgrade" ) >= 1 then
		return
	end

	local skipTraitHighlight = args.SkipTraitHighlight or false
	
	for metaUpgradeName, metaUpgradeData in pairs( GameState.MetaUpgradeState ) do
		if MetaUpgradeCardData[ metaUpgradeName ] and metaUpgradeData.Equipped and MetaUpgradeCardData[ metaUpgradeName ].TraitName and not HeroHasTrait( MetaUpgradeCardData[ metaUpgradeName ].TraitName ) then
			
		local cardMultiplier = 1
		if GameState.MetaUpgradeState[ metaUpgradeName ].AdjacencyBonuses and GameState.MetaUpgradeState[ metaUpgradeName ].AdjacencyBonuses.CustomMultiplier then
			cardMultiplier = cardMultiplier + GameState.MetaUpgradeState[ metaUpgradeName ].AdjacencyBonuses.CustomMultiplier
		end
		-- MOD START
		if CentaurToggle(metaUpgradeName) then
			print("debug: CentaurToggle is true, adding trait")
			GameState.MetaUpgradeState[metaUpgradeName].Unlocked = true
			AddTraitToHero({
				SkipNewTraitHighlight = skipTraitHighlight, 
				TraitName = MetaUpgradeCardData[ metaUpgradeName ].TraitName, 
				Rarity = TraitRarityData.RarityUpgradeOrder[ GetMetaUpgradeLevel( metaUpgradeName )],
				CustomMultiplier = cardMultiplier,
				SourceName = metaUpgradeName,
				})
		else
			if metaUpgradeName == "MaxHealthPerRoom" then
				print("debug: CentaurToggle is false, removing trait")
				GameState.MetaUpgradeState[metaUpgradeName].Unlocked = false
			end
		end
		-- MOD END
		end
	end
end

function CentaurToggle(upgradeName)
	-- if toggleSwitch is false, we want to remove the arcana
	if config.toggleSwitch == false then
		if upgradeName == "MaxHealthPerRoom" then
			return false
		end
		return true
	end
end
