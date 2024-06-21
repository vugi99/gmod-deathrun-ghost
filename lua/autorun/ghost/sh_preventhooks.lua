-- all hooks to prevent some ghost actions

-- server side hooks
if SERVER then

	hook.Add("PlayerSpray", "DisableGhostSpray", function( ply )
		if ply:IsGhost() then
			return true
		end
	end )

	hook.Add("PlayerCanPickupWeapon", "DisableGhostPickupWeapons", function( ply, ent )
		if (ply:IsGhost()) then
			return false
		end
	end)

	hook.Add("AcceptInput", "FixGhostTeleport", function( ent, input, activator, caller, value )
		if (activator:IsPlayer() and activator:IsGhost()) then
			return true
		end
	end)

	hook.Add("PlayerUse", "DisableGhostPicking", function( ply )
		if (ply:IsGhost()) then
			return false
		end
	end)

	hook.Add("PlayerSwitchFlashlight", "PlayerSwitchFlashlight", function( ply, turningOn )
		if (ply:IsGhost()) then
			return false
		end
	end)

	hook.Add("PlayerShouldTakeDamage", "RemoveGhostDamage", function( target, dmg )
		if (target:IsPlayer() and target:IsGhost()) then
			return false
		end
	end)

	hook.Add("GetFallDamage", "RemoveFallDamageSound", function( ply, speed )
		if ply:IsPlayer() and ply:IsGhost() then
			return false
		end
	end)
end

-- client side hooks
if CLIENT then

	hook.Add("PrePlayerDraw", "DrawGhosts", function( ply )
		if (ply:IsGhost() and not LocalPlayer():IsGhost()) then
			for k, vpart in pairs( ply.pac_outfits or {} ) do
				vpart:SetHide(true)
			end
			ply:DrawShadow(false)

			if IsValid(ply.cl_PS2_trailEnt) then
				ply.cl_PS2_trailEnt:SetNoDraw(true)
			end
			return true
		end
	end)

	net.Receive( "GhostShowPlayers", function( len, sply )
		--print("GhostShowPlayers")

		for i, ply in ipairs(player.GetAll()) do
			if (ply ~= LocalPlayer()) then
				for k, vpart in pairs( ply.pac_outfits or {} ) do
					vpart:SetHide(false)
				end
				ply:DrawShadow(true)

				if IsValid(ply.cl_PS2_trailEnt) then
					ply.cl_PS2_trailEnt:SetNoDraw(false)
				end
			end
		end
	end )
end

-- shared hooks

hook.Add("PlayerFootstep", "RemoveGhostFootstep", function( ply )
	if ply:IsGhost() then
		return true
	end
end)

hook.Add("OnEntityCreated", "SetCustomCollisionToAllPlayers", function( ent )
	if IsValid(ent) and ent:IsPlayer() then ent:SetCustomCollisionCheck(true) end
end)

hook.Add("ShouldCollide", "RemoveGhostCollision", function( ent1, ent2 )
	return not (ent1:IsPlayer() and ent2:IsPlayer() and (ent1:IsGhost() or ent2:IsGhost()))
end)

hook.Add("EntityEmitSound", "DisableGhostSound", function( t )
	if t.Entity:IsPlayer() and t.Entity:IsGhost() then
		if CLIENT then
			-- dont return true, it will be apply changes to data table
			if t.Entity ~= LocalPlayer() then
				return false
			end
		else
			return false
		end
	end
end )