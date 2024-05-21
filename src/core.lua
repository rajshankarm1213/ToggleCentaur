--[[
    ToggleCentaur
    Author:
        gunjou1213 (Discord: gunjou1213)

    Enables toggling of the Arcana "The Centaur" in a savefile for speedruns that make use of the White Antler keepsake.
]]

local mod = ToggleCentaur

function mod.CentaurToggle(upgradeName)
    if mod.Config.Enabled then
        -- if ToggleSwitch is false, the arcana must not be added
        if mod.Config.ToggleSwitch == false then
            if upgradeName == "MaxHealthPerRoom" then
                return false
            end
        end
        return true
    end
end

function on_ready()
    rom.game.ModUtil.Path.Override("InitializeMetaUpgradeState", function ()
        if not GameState.MetaUpgradeCardLayout or not GameState.MetaUpgradeState then
            GameState.MetaUpgradeCardLayout = DeepCopyTable( MetaUpgradeDefaultCardLayout )
        end
        if IsEmpty( GameState.MetaUpgradeState ) then
            GameState.MetaUpgradeState = {}
        end
    
        for metaUpgradeName, initialData in pairs( MetaUpgradeCardData ) do
            if not GameState.MetaUpgradeState[metaUpgradeName] then
                GameState.MetaUpgradeState[metaUpgradeName] = {}
                if initialData.StartUnlocked and mod.CentaurToggle(metaUpgradeName) then
                    rom.game.ModUtil.Print("MetaUpgrade " .. metaUpgradeName .. " is unlocked.")
                    GameState.MetaUpgradeState[metaUpgradeName].Unlocked = true
                else
                    rom.game.ModUtil.Print("MetaUpgrade " .. metaUpgradeName .. " is not unlocked.")
                end
                if initialData.StartEquipped then
                    GameState.MetaUpgradeState[metaUpgradeName].Equipped = true
                end
            end
            GameState.MetaUpgradeState[metaUpgradeName].Level = GameState.MetaUpgradeState[metaUpgradeName].Level or 1
        end
    end)
    rom.game.ModUtil.Path.Override("EquipMetaUpgrades", function ( hero, args )
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
            if mod.CentaurToggle(metaUpgradeName) then
                rom.game.ModUtil.Print("MetaUpgrade " .. metaUpgradeName .. " is unlocked.")
                AddTraitToHero({ 
                    SkipNewTraitHighlight = skipTraitHighlight, 
                    TraitName = MetaUpgradeCardData[ metaUpgradeName ].TraitName, 
                    Rarity = TraitRarityData.RarityUpgradeOrder[ GetMetaUpgradeLevel( metaUpgradeName )],
                    CustomMultiplier = cardMultiplier,
                    SourceName = metaUpgradeName,
                    })
            end
            end
        end
    end)
    rom.game.ModUtil.Path.Override("CheckAutoEquipRequirements", function (requirementData)
        print("debug2")
            local metaUpgradeCosts = {}
        local totalMetaUpgrades = 0
        for metaUpgradeName, metaUpgradeData in pairs( GameState.MetaUpgradeState ) do
            if MetaUpgradeCardData[ metaUpgradeName ] and metaUpgradeData.Equipped and not MetaUpgradeCardData[ metaUpgradeName ].AutoEquipRequirements then
                local cost = MetaUpgradeCardData[ metaUpgradeName ].Cost or 0
                IncrementTableValue( metaUpgradeCosts, cost )
                totalMetaUpgrades = totalMetaUpgrades + 1
            end
        end
    
        if requirementData.HasCostsThrough then
            if CentaurToggle() then
                print("debug3")
                return false
            end
            for cost = 1, requirementData.HasCostsThrough do
                if not metaUpgradeCosts[cost] then
                    return false
                end
            end
        end
    
        if requirementData.HasCosts then
            for i, cost in pairs( requirementData.HasCosts ) do
                if not metaUpgradeCosts[cost] then
                
                    return false
                end
            end
        end
    
        if requirementData.MaxDuplicateCount then
            for cost, amount in pairs( metaUpgradeCosts ) do
                if amount > requirementData.MaxDuplicateCount then
                    return false
                end
            end
        end
        if requirementData.MinDuplicateCount then
            local hasDuplicate = false
            for cost, amount in pairs( metaUpgradeCosts ) do
                if amount >= requirementData.MinDuplicateCount then
                    hasDuplicate = true
                end
            end
            if not hasDuplicate then
                return false
            end
        end
        if requirementData.RequiredMetaUpgradesMax then
            if totalMetaUpgrades > requirementData.RequiredMetaUpgradesMax then
                return false
            end
        end
        if requirementData.SurroundAllEquipped then
            local sourceCoords = GetMetaUpgradeCardCoords( requirementData.MetaUpgradeName )
            if not sourceCoords then
                return false
            end
            local coordsCheck = GetNeighboringCoords( sourceCoords.Row, sourceCoords.Column, true )
            for i, coords in pairs(coordsCheck) do
                local metaUpgradeName = GameState.MetaUpgradeCardLayout[ coords.Row ][ coords.Column ]
                if not GameState.MetaUpgradeState[metaUpgradeName] or not GameState.MetaUpgradeState[metaUpgradeName].Equipped then
                    return false
                end
            end
        end
    
        if requirementData.OtherRowEquipped then
            local sourceCoords = GetMetaUpgradeCardCoords( requirementData.MetaUpgradeName )
            if not sourceCoords then
                return false
            end
            local hasOtherRowEquipped = false
            for i=1, GetZoomLevel() do
                local rowEquipped = true
                if i == sourceCoords.Row then
                    rowEquipped = false
                else
                    local coordsCheck = GetCoordsInRow( i )
                    rowEquipped = true	
                    for i, coords in pairs(coordsCheck) do
                        local metaUpgradeName = GameState.MetaUpgradeCardLayout[ coords.Row ][ coords.Column ]
                        if not GameState.MetaUpgradeState[metaUpgradeName] or not GameState.MetaUpgradeState[metaUpgradeName].Equipped then
                            rowEquipped = false
                        end
                    end
                end
                if rowEquipped then
                    hasOtherRowEquipped = true
                    break
                end
            end
            if not hasOtherRowEquipped then
                return false
            end
        end
        return true
    end)
    
end


rom.mods["SGG_Modding-LoadUtil"].auto_single().queue.post_import_file('Main.lua',on_ready, nil)