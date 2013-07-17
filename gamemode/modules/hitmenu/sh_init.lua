local plyMeta = FindMetaTable("Player")
local hitmanTeams = {}

function plyMeta:isHitman()
	return hitmanTeams[self:Team()]
end

function plyMeta:hasHit()
	return IsValid(self:getHitTarget())
end

function plyMeta:getHitTarget()
	return self:getDarkRPVar("hitTarget")
end

function plyMeta:getHitPrice()
	return self:getDarkRPVar("hitPrice") or GAMEMODE.Config.minHitPrice
end

function DarkRP.addHitmanTeam(job)
	if not job or not RPExtraTeams[job] then
		error([[The server owner is trying to add a hitman job, but the job doesn't exist. Get them to fix this.
		Note: This is the fault of the owner/scripter of this server.]], 0)
	end
	hitmanTeams[job] = true
end

function DarkRP.hooks:canRequestHit(hitman, customer, target, price)
	if not hitman:isHitman() then return false, DarkRP.getPhrase("player_not_hitman") end
	if customer:GetPos():Distance(hitman:GetPos()) > GAMEMODE.Config.minHitDistance then return false, DarkRP.getPhrase("distance_too_big") end
	if hitman == target then return false, DarkRP.getPhrase("hitman_no_suicide") end
	if hitman == customer then return false, DarkRP.getPhrase("hitman_no_self_order") end
	if not customer:CanAfford(price) then return false, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("hit")) end
	if price < GAMEMODE.Config.minHitPrice then return false, DarkRP.getPhrase("price_too_low") end
	if hitman:hasHit() then return false, DarkRP.getPhrase("hitman_already_has_hit") end
	if IsValid(target) and ((target:getDarkRPVar("lastHitTime") or 0) > CurTime() - GAMEMODE.Config.hitTargetCooldown) then return false, DarkRP.getPhrase("hit_target_recently_killed_by_hit") end
	if IsValid(customer) and ((customer.lastHitAccepted or 0) > CurTime() - GAMEMODE.Config.hitCustomerCooldown) then return false, DarkRP.getPhrase("customer_recently_bought_hit") end

	return true
end

/*---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------*/
DarkRP.declareChatCommand{
	command = "hitprice",
	description = "Set the price of your hits",
	condition = plyMeta.isHitman,
	delay = 10
}

DarkRP.declareChatCommand{
	command = "requesthit",
	description = "Request a hit from the player you're looking at",
	delay = 5
}
