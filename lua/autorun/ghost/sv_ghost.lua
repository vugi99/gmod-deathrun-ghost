if SERVER then
    local TEAM_GHOST = 5
    local GHOST_COMMAND = "ghost"

    util.AddNetworkString( "GhostShowPlayers" )

    game.ConsoleCommand("mp_show_voice_icons 0")

    hook.Add("PlayerSay", "PlayerRequestGhostCheck", function(ply, text)
        text = string.lower(text)

        if text == "!" .. GHOST_COMMAND or text == "/" .. GHOST_COMMAND then
            if not ply:Alive() and ROUND:GetCurrent() == ROUND_ACTIVE then
                SetGhost(ply, true)
            elseif ply:IsGhost() then
                SetGhost(ply, false)
            else
                ply:ChatPrint("You cannot do it anymore.")

                return
            end
        end
    end)

    function SetGhost(ply, stat)
        if (stat ~= ply:IsGhost()) then
            if ((stat == true and ROUND:GetCurrent() == ROUND_ACTIVE) or (stat ~= true)) then
                ply:SetNWBool("IsGhost", stat)
                ply:DrawShadow(not stat)
                ply:SetAvoidPlayers(stat)

                if stat then
                    AddGhost(ply)
                else
                    RemoveGhost(ply)
                end
                net.Start( "GhostShowPlayers" )
                net.Send( ply )
            end
        end
    end

    function RemoveGhost(ply)
        ply:KillSilent()
        ply:SetBloodColor(0)
        ply:SetCollisionGroup(0)
        ply:SetTeam(TEAM_RUNNER)
        ply:BeginSpectate()
    end

    function AddGhost(ply)
        ply:SetTeam(TEAM_GHOST)
        ply:Spawn()
        ply:SetBloodColor(-1)
        ply:SetCollisionGroup(10)
        ply.SpawnSet = false
    end

    hook.Add("OnRoundSet", "RemoveAllGhosts", function()
        for _, v in ipairs(player.GetAll()) do
            if v:IsGhost() then
                SetGhost(v, false)
            end
        end
    end)

    hook.Add("DeathrunDeadToSpectator", "AutoGhostDToSpec", function(ply)
        if IsValid(ply) then
            if (ply:GetInfoNum("deathrun_autoghost_enabled", 0) == 1) then
                SetGhost(ply, true)
            end
        end
    end)

    hook.Add("PlayerInitialSpawn", "AutoGhostOnJoin", function(ply)
        timer.Simple( 3, function()
            if IsValid(ply) then
                if (not ply:Alive() and ply:Team() == TEAM_SPECTATOR) then
                    if (ply:GetInfoNum("deathrun_autoghost_enabled", 0) == 1) then
                        --print("InitialSpawn Ghost")
                        SetGhost(ply, true)
                    end
                end
            end
        end)
    end)
end
