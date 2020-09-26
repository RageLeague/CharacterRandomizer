function PlayerAct:SpawnQuests( options )
    TheGame:GetGameState():GetNotifications():EnableNotifications( false )

    local main_quest = options.main_quest or self.data.main_quest
    if main_quest then
        local quest, err = QuestUtil.SpawnQuest(main_quest, options.main_quest_params)
        if quest then
            TheGame:GetGameState():SetMainQuest(quest)
        else
            LOGWARN( "FAILED TO SPAWN: %s (%s)", main_quest, err )
            TheGame:GetDebug():CreatePanel(DebugTable( err ))
        end

    end

    local quests = options.quests or self.data.quests
    if quests then
        for k,v in ipairs(quests) do
            local ok, err = QuestUtil.SpawnQuest(v)
            if not ok then
                LOGWARN( "FAILED TO SPAWN: %s (%s)", v, err )
            end
        end
    end

    TheGame:GetGameState():GetNotifications():EnableNotifications( true )
end