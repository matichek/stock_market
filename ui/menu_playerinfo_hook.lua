-- Adds Exchange to Player Information.
-- The sidebar list is private to menu_playerinfo.lua. This file inserts an
-- icon when that list can be reached, and always adds a labeled Exchange
-- button beside the sidebar so the screen is reachable without a hotkey.

local MODE = "stockmarket"
local tries = 0

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

local function openExchange()
	OpenMenu("StockMarketMenu", { 0, 0 }, nil)
end

local function insertSidebarIcon(playerInfo)
	local sidebarConfig = upvalue(playerInfo.createLeftBar, "config")
	if not sidebarConfig or not sidebarConfig.leftBar then
		return false
	end
	for _, entry in ipairs(sidebarConfig.leftBar) do
		if entry.mode == MODE then
			return true
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

	if not playerInfo._stockMarketToggle then
		local originalToggle = playerInfo.buttonTogglePlayerInfo
		playerInfo.buttonTogglePlayerInfo = function(mode)
			if mode == MODE then
				openExchange()
				return
			end
			if originalToggle then
				return originalToggle(mode)
			end
		end
		playerInfo._stockMarketToggle = true
	end
	return true
end

local function attachButton(playerInfo)
	if playerInfo._stockMarketButton or not playerInfo.createLeftBar then
		return playerInfo._stockMarketButton == true
	end
	local original = playerInfo.createLeftBar
	playerInfo.createLeftBar = function(frame, offsetx, offsety)
		original(frame, offsetx, offsety)
		local sidebar = playerInfo.sideBarWidth or Helper.scaleX(Helper.sidebarWidth)
		local width = Helper.scaleX(180)
		local ftable = frame:addTable(1, {
			tabOrder = 7,
			scaling = false,
			borderEnabled = false,
			x = offsetx + sidebar + Helper.borderSize,
			y = offsety,
			width = width,
		})
		ftable:setColWidth(1, width, false)
		local row = ftable:addRow(true, { fixed = true })
		row[1]:createButton({
			active = true,
			height = Helper.scaleY(32),
			mouseOverText = ReadText(551001, 1),
		}):setText(ReadText(551001, 1), { halign = "center" })
		row[1].handlers.onClick = openExchange
	end
	playerInfo._stockMarketButton = true
	return true
end

local function install()
	local playerInfo = findPlayerInfo()
	if not playerInfo or not playerInfo.createLeftBar then
		return false
	end
	insertSidebarIcon(playerInfo)
	return attachButton(playerInfo)
end

local function schedule()
	if install() or tries > 30 then
		return
	end
	tries = tries + 1
	if Helper and Helper.addDelayedOneTimeCallbackOnUpdate and getElapsedTime then
		Helper.addDelayedOneTimeCallbackOnUpdate(schedule, false, getElapsedTime() + 1)
	end
end

schedule()
