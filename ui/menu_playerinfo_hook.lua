-- Adds Exchange to the Player Information sidebar.
-- The sidebar list is a local in menu_playerinfo.lua, so it is reached
-- through the createLeftBar upvalue. The click opens StockMarketMenu.

local MODE = "stockmarket"

local function upvalue(fn, name)
	if not debug or not debug.getupvalue or not fn then
		return nil
	end
	local index = 1
	while true do
		local found, value = debug.getupvalue(fn, index)
		if not found then
			return nil
		end
		if found == name then
			return value
		end
		index = index + 1
	end
end

local function findPlayerInfo()
	if not Menus then
		return nil
	end
	for _, entry in ipairs(Menus) do
		if entry.name == "PlayerInfoMenu" then
			return entry
		end
	end
end

local function install()
	local playerInfo = findPlayerInfo()
	if not playerInfo or not playerInfo.createLeftBar or playerInfo._stockMarketHooked then
		return
	end

	local sidebarConfig = upvalue(playerInfo.createLeftBar, "config")
	if not sidebarConfig or not sidebarConfig.leftBar then
		return
	end

	for _, entry in ipairs(sidebarConfig.leftBar) do
		if entry.mode == MODE then
			playerInfo._stockMarketHooked = true
			return
		end
	end

	local insertAt = #sidebarConfig.leftBar + 1
	for index, entry in ipairs(sidebarConfig.leftBar) do
		if entry.mode == "transactionlog" then
			insertAt = index + 1
			break
		end
	end

	table.insert(sidebarConfig.leftBar, insertAt, {
		name = ReadText(551001, 1),
		icon = "pi_transactionlog",
		mode = MODE,
		active = true,
	})

	local originalToggle = playerInfo.buttonTogglePlayerInfo
	playerInfo.buttonTogglePlayerInfo = function(mode)
		if mode == MODE then
			OpenMenu("StockMarketMenu", { 0, 0 }, nil)
			return
		end
		if originalToggle then
			return originalToggle(mode)
		end
	end

	playerInfo._stockMarketHooked = true
end

install()
