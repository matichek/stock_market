-- Adds Exchange as the first icon on the Player Information sidebar.
-- Shift+J is read directly. This game version rejects a key binding in ui.xml,
-- so a binding there prevents the whole screen from loading.

local LABEL = "Exchange"
local held = false

local function label()
	local read = ReadText(551001, 1)
	if type(read) == "string" and not string.find(read, "ReadText", 1, true) then
		return read
	end
	return LABEL
end

local function toggle()
	if StockMarket_Toggle then
		StockMarket_Toggle()
	else
		OpenMenu("StockMarketMenu", { 0, 0 }, nil)
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

local function addSidebarIcon(ftable, width)
	local row = ftable:addRow(true, { fixed = true, bgColor = Color["row_background_blue"] })
	row[1]:createButton({
		active = true,
		height = width,
		bgColor = Color["row_title_background"],
		mouseOverText = label(),
	}):setIcon("pi_transactionlog")
	row[1].handlers.onClick = toggle
end

local function attach(playerInfo)
	if playerInfo._stockMarketButton or not playerInfo.createLeftBar then
		return playerInfo._stockMarketButton == true
	end
	local original = playerInfo.createLeftBar
	playerInfo.createLeftBar = function(frame, offsetx, offsety)
		local origAdd = frame.addTable
		frame.addTable = function(self, cols, props)
			local ftable = origAdd(self, cols, props)
			if props and props.tabOrder == 3 and props.reserveScrollBar == false and not ftable._stockMarket then
				ftable._stockMarket = true
				local origAddRow = ftable.addRow
				ftable.addRow = function(t, ...)
					ftable.addRow = origAddRow
					addSidebarIcon(t, playerInfo.sideBarWidth or Helper.scaleX(Helper.sidebarWidth))
					return origAddRow(t, ...)
				end
			end
			return ftable
		end
		local ok, err = pcall(original, frame, offsetx, offsety)
		frame.addTable = origAdd
		if not ok then
			error(err, 0)
		end
	end
	playerInfo._stockMarketButton = true
	return true
end

local user32 = nil

local function keyHeld()
	if user32 == nil then
		local ok, lib = pcall(function()
			local ffi = require("ffi")
			pcall(ffi.cdef, "short GetAsyncKeyState(int vKey);")
			return ffi.load("user32")
		end)
		user32 = ok and lib or false
	end
	if not user32 then
		return false
	end
	local shift = tonumber(user32.GetAsyncKeyState(0x10)) or 0
	local j = tonumber(user32.GetAsyncKeyState(0x4A)) or 0
	return shift < 0 and j < 0
end

local function pollKey()
	local down = keyHeld()
	if down and not held then
		toggle()
	end
	held = down
	if Helper and Helper.addDelayedOneTimeCallbackOnUpdate and getElapsedTime then
		Helper.addDelayedOneTimeCallbackOnUpdate(pollKey, false, getElapsedTime() + 0.1)
	end
end

local tries = 0
local function schedule()
	local playerInfo = findPlayerInfo()
	if playerInfo and playerInfo.createLeftBar then
		attach(playerInfo)
	end
	if (not playerInfo or not playerInfo._stockMarketButton) and tries <= 30 and Helper and Helper.addDelayedOneTimeCallbackOnUpdate and getElapsedTime then
		tries = tries + 1
		Helper.addDelayedOneTimeCallbackOnUpdate(schedule, false, getElapsedTime() + 1)
	end
end

schedule()
pollKey()
