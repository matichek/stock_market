-- Stock Market exchange menu.
-- State arrives from Mission Director as:
--   id,price,shares,avg;...||headline

local menu = {
	name = "StockMarketMenu",
	amountMode = 1,
	stocks = {},
	headline = "",
	status = nil,
	shown = false,
	viewMode = "table",
	graphId = nil,
	notices = true,
	history = {},
	portHistory = {},
	lastGen = nil,
}

local config = {
	layer = 5,
}

local STOCK_TEXT = {
	argon_yards = 30,
	antigone_works = 31,
	teladi_profit = 32,
	ministry_ledger = 33,
	paranid_lattice = 34,
	pontifex_reliquary = 35,
	zyarth_steel = 36,
	hatikvah_haul = 37,
	eighteen_freight = 38,
	grand_exchange = 39,
	nopileos_ore = 40,
	second_contact = 41,
	black_hole_mining = 42,
	scale_plate = 43,
}

local function init()
	Menus = Menus or {}
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end

	RegisterEvent("stockmarket.state", menu.onState)
	RegisterEvent("stockmarket.reject", menu.onReject)

	local previousHotkey = onHotkey
	function onHotkey(action)
		if previousHotkey then
			previousHotkey(action)
		end
		if action == "INPUT_ACTION_OPEN_STOCK_MARKET" then
			if menu.shown then
				menu.onCloseElement("close")
			else
				OpenMenu("StockMarketMenu", { 0, 0 }, nil)
			end
		end
	end
	SetScript("onHotkey", onHotkey)
end

local function stockName(id)
	local textId = STOCK_TEXT[id]
	if textId then
		return ReadText(551001, textId)
	end
	return id
end

local function moneyText(amount)
	return ConvertMoneyString(amount, false, true, 0, true) .. " " .. ReadText(1001, 101)
end

local function changeText(bought, current)
	if not bought or bought <= 0 then
		return "0%", Color["text_normal"]
	end
	local pct = math.floor(((current - bought) * 100 / bought) + 0.5)
	if pct > 0 then
		return "+" .. pct .. "%", Color["text_positive"]
	elseif pct < 0 then
		return pct .. "%", Color["text_negative"]
	end
	return "0%", Color["text_normal"]
end

local function findStock(id)
	for _, stock in ipairs(menu.stocks) do
		if stock.id == id then
			return stock
		end
	end
end

local function unitCost(price, buying)
	local unit = math.floor(price * (buying and 101 or 99) / 100)
	if buying and unit < 1 then
		unit = 1
	end
	return unit
end

function menu.resolveQty(stock, side)
	if menu.amountMode == "max" then
		if side == "sell" then
			return stock.shares
		end
		local unit = unitCost(stock.price, true)
		if unit < 1 then
			return 0
		end
		return math.floor(GetPlayerMoney() / unit)
	end
	return menu.amountMode
end

function menu.trade(side, id)
	local stock = findStock(id)
	if not stock then
		return
	end
	local qty = menu.resolveQty(stock, side)
	if not qty or qty < 1 then
		menu.status = ReadText(551001, side == "buy" and 18 or 19)
		menu.display()
		return
	end
	AddUITriggeredEvent("StockMarket", side .. "_" .. id, qty)
end

function menu.parse(blob)
	blob = tostring(blob or "")
	local body, headline, notices, gen = blob:match("^(.-)||(.*)||([01])||(%d+)$")
	if not body then
		body, headline = blob:match("^(.-)||(.*)$")
		notices = "1"
		gen = nil
	end
	if not body then
		body = blob
		headline = ""
	end
	menu.headline = headline or ""
	menu.notices = notices ~= "0"
	menu.pendingGen = gen and tonumber(gen) or nil
	menu.stocks = {}
	for rec in body:gmatch("[^;]+") do
		local id, price, shares, avg = rec:match("([^,]+),([^,]+),([^,]+),([^,]+)")
		if id then
			table.insert(menu.stocks, {
				id = id,
				price = tonumber(price) or 0,
				shares = tonumber(shares) or 0,
				avg = tonumber(avg) or 0,
			})
		end
	end
end

function menu.record()
	if menu.pendingGen ~= nil and menu.pendingGen == menu.lastGen then
		return
	end
	if menu.pendingGen ~= nil then
		menu.lastGen = menu.pendingGen
	end
	local total, owned = 0, 0
	for _, stock in ipairs(menu.stocks) do
		local series = menu.history[stock.id]
		if not series then
			series = {}
			menu.history[stock.id] = series
		end
		table.insert(series, stock.price)
		while #series > 24 do
			table.remove(series, 1)
		end
		if stock.shares > 0 then
			total = total + stock.price * stock.shares
			owned = owned + 1
		end
	end
	if owned > 0 then
		table.insert(menu.portHistory, total)
		while #menu.portHistory > 24 do
			table.remove(menu.portHistory, 1)
		end
	end
end

function menu.onState(_, blob)
	menu.parse(blob)
	menu.record()
	menu.status = nil
	if menu.shown then
		menu.display()
	end
end

function menu.onReject(_, reason)
	if tostring(reason) == "funds" then
		menu.status = ReadText(551001, 18)
	else
		menu.status = ReadText(551001, 19)
	end
	if menu.shown then
		menu.display()
	end
end

function menu.cleanup()
	menu.shown = false
	menu.infoFrame = nil
end

local function addAmountButton(row, col, label, mode)
	local selected = menu.amountMode == mode
	row[col]:createButton({
		bgColor = selected and Color["row_background_selected"] or Color["button_background_default"],
		height = Helper.standardButtonHeight,
	}):setText(label, { halign = "center" })
	row[col].handlers.onClick = function ()
		menu.amountMode = mode
		menu.display()
	end
end

local headerText = {
	font = Helper.standardFontBold,
}

local function drawBars(frame, x, y, width, title, samples)
	local count = math.max(#samples, 1)
	local chart = frame:addTable(count, { tabOrder = 4, width = width, x = x, y = y, highlightMode = "off" })
	local titleRow = chart:addRow(false, { fixed = true, bgColor = Color["row_title_background"] })
	titleRow[1]:setColSpan(count):createText(title, headerText)
	if #samples < 2 then
		local waitRow = chart:addRow(false, { fixed = true })
		waitRow[1]:setColSpan(count):createText(ReadText(551001, 84))
		return chart
	end
	local low, high = samples[1], samples[1]
	for _, value in ipairs(samples) do
		if value < low then
			low = value
		end
		if value > high then
			high = value
		end
	end
	local span = high - low
	if span < 1 then
		span = 1
	end
	local rows = 8
	for level = rows, 1, -1 do
		local row = chart:addRow(false, { fixed = true })
		for col, value in ipairs(samples) do
			local filled = math.floor(((value - low) / span) * (rows - 1) + 1.5)
			if filled < 1 then
				filled = 1
			end
			local previous = samples[col - 1] or value
			local color = Color["text_normal"]
			if value > previous then
				color = Color["text_positive"]
			elseif value < previous then
				color = Color["text_negative"]
			end
			if level <= filled then
				row[col]:createText("|", { halign = "center", color = color })
			else
				row[col]:createText(" ", { halign = "center" })
			end
		end
	end
	local scale = chart:addRow(false, { fixed = true })
	scale[1]:setColSpan(count):createText(ReadText(551001, 85) .. "  " .. moneyText(low) .. "    " .. ReadText(551001, 86) .. "  " .. moneyText(high), { halign = "right" })
	return chart
end

local function setColumns(ftable)
	ftable:setColWidthPercent(1, 28)
	ftable:setColWidthPercent(2, 16)
	ftable:setColWidthPercent(3, 14)
	ftable:setColWidthPercent(4, 16)
	ftable:setColWidthPercent(5, 10)
	ftable:setColWidthPercent(6, 16)
end

function menu.display()
	Helper.clearDataForRefresh(menu, config.layer)

	local frame = Helper.createFrameHandle(menu, {
		standardButtons = { back = true, close = true },
		width = Helper.viewWidth,
		height = Helper.viewHeight,
		x = 0,
		y = 0,
		layer = config.layer,
	})
	frame:setBackground("solid", { color = Color["frame_background_semitransparent"] })
	menu.infoFrame = frame

	local width = Helper.viewWidth - 2 * Helper.frameBorder
	local x = Helper.frameBorder
	local y = Helper.frameBorder

	local header = frame:addTable(6, { tabOrder = 1, width = width, x = x, y = y, highlightMode = "off" })
	setColumns(header)

	local title = header:addRow(false, { fixed = true })
	title[1]:setColSpan(4):createText(ReadText(551001, 1), { font = Helper.titleFont, fontsize = Helper.titleFontSize })
	title[5]:setColSpan(2):createText(ReadText(551001, 12) .. "  " .. moneyText(GetPlayerMoney()), { halign = "right", font = Helper.standardFontBold })

	local amountRow = header:addRow(false, { fixed = true })
	amountRow[1]:createText(ReadText(551001, 16), { halign = "left" })
	addAmountButton(amountRow, 2, "1", 1)
	addAmountButton(amountRow, 3, "10", 10)
	addAmountButton(amountRow, 4, "100", 100)
	addAmountButton(amountRow, 5, ReadText(551001, 15), "max")
	amountRow[6]:createText(ReadText(551001, 17), { halign = "right", color = Color["text_normal"] })

	local switchRow = header:addRow(false, { fixed = true })
	switchRow[1]:setColSpan(2):createButton({
		bgColor = menu.viewMode == "graph" and Color["row_background_selected"] or Color["button_background_default"],
	}):setText(menu.viewMode == "graph" and ReadText(551001, 81) or ReadText(551001, 80), { halign = "center" })
	switchRow[1].handlers.onClick = function ()
		menu.viewMode = menu.viewMode == "graph" and "table" or "graph"
		menu.display()
	end
	switchRow[3]:setColSpan(2):createButton({
		bgColor = menu.notices and Color["row_background_selected"] or Color["button_background_default"],
	}):setText(menu.notices and ReadText(551001, 82) or ReadText(551001, 83), { halign = "center" })
	switchRow[3].handlers.onClick = function ()
		AddUITriggeredEvent("StockMarket", menu.notices and "notices_off" or "notices_on")
	end
	switchRow[5]:setColSpan(2):createText("", { halign = "right" })

	if menu.status and menu.status ~= "" then
		local statusRow = header:addRow(false, { fixed = true })
		statusRow[1]:setColSpan(6):createText(menu.status, { color = Color["text_negative"] })
	end
	if menu.headline and menu.headline ~= "" then
		local newsRow = header:addRow(false, { fixed = true })
		newsRow[1]:setColSpan(6):createText(menu.headline, { color = Color["text_normal"] })
	end

	y = header.properties.y + header:getVisibleHeight() + Helper.borderSize

	if menu.viewMode == "graph" then
		if not menu.graphId and menu.stocks[1] then
			menu.graphId = menu.stocks[1].id
		end
		local selected = findStock(menu.graphId) or menu.stocks[1]
		local series = selected and menu.history[selected.id] or {}
		local priceChart = drawBars(frame, x, y, width, selected and stockName(selected.id) or ReadText(551001, 80), series or {})
		y = priceChart.properties.y + priceChart:getVisibleHeight() + Helper.borderSize
		local portChart = drawBars(frame, x, y, width, ReadText(551001, 87), menu.portHistory)
		y = portChart.properties.y + portChart:getVisibleHeight() + Helper.borderSize

		local picker = frame:addTable(4, { tabOrder = 5, width = width, x = x, y = y, highlightMode = "off" })
		picker:setColWidthPercent(1, 40)
		picker:setColWidthPercent(2, 20)
		picker:setColWidthPercent(3, 20)
		picker:setColWidthPercent(4, 20)
		for _, stock in ipairs(menu.stocks) do
			local picked = selected and stock.id == selected.id
			local row = picker:addRow(stock.id, { fixed = true })
			row[1]:createButton({
				bgColor = picked and Color["row_background_selected"] or Color["button_background_default"],
			}):setText(stockName(stock.id), { halign = "center" })
			row[1].handlers.onClick = function ()
				menu.graphId = stock.id
				menu.display()
			end
			row[2]:createText(moneyText(stock.price), { halign = "right" })
			local qty = menu.resolveQty(stock, "buy")
			local pay = unitCost(stock.price, true) * math.max(qty, 0)
			row[3]:createButton({ mouseOverText = ReadText(551001, 22) .. "  " .. moneyText(pay) }):setText(ReadText(551001, 10), { halign = "center" })
			row[3].handlers.onClick = function ()
				menu.trade("buy", stock.id)
			end
			row[4]:createButton({}):setText(ReadText(551001, 11), { halign = "center" })
			row[4].handlers.onClick = function ()
				menu.trade("sell", stock.id)
			end
		end
		frame:display()
		return
	end

	local holdings = frame:addTable(6, { tabOrder = 2, width = width, x = x, y = y, highlightMode = "off" })
	setColumns(holdings)

	local holdTitle = holdings:addRow(false, { fixed = true, bgColor = Color["row_title_background"] })
	holdTitle[1]:setColSpan(6):createText(ReadText(551001, 13), headerText)

	local holdHead = holdings:addRow(false, { fixed = true, bgColor = Color["row_background"] })
	holdHead[1]:createText(ReadText(551001, 4), headerText)
	holdHead[2]:createText(ReadText(551001, 5), headerText)
	holdHead[3]:createText(ReadText(551001, 6), headerText)
	holdHead[4]:createText(ReadText(551001, 7), headerText)
	holdHead[5]:createText(ReadText(551001, 8), headerText)
	holdHead[6]:createText("", headerText)

	local sumCost, sumValue, owned = 0, 0, 0
	for _, stock in ipairs(menu.stocks) do
		if stock.shares > 0 then
			owned = owned + 1
			local cost = stock.avg * stock.shares
			local value = stock.price * stock.shares
			sumCost = sumCost + cost
			sumValue = sumValue + value
			local pct, color = changeText(stock.avg, stock.price)
			local row = holdings:addRow(stock.id, { fixed = true })
			row[1]:createText(stockName(stock.id))
			row[2]:createText(moneyText(stock.avg), { halign = "right" })
			row[3]:createText(pct, { halign = "right", color = color })
			row[4]:createText(moneyText(stock.price), { halign = "right" })
			row[5]:createText(tostring(stock.shares), { halign = "right" })
			local proceeds = unitCost(stock.price, false) * menu.resolveQty(stock, "sell")
			row[6]:createButton({ mouseOverText = ReadText(551001, 23) .. "  " .. moneyText(proceeds) }):setText(ReadText(551001, 11), { halign = "center" })
			row[6].handlers.onClick = function ()
				menu.trade("sell", stock.id)
			end
		end
	end

	if owned == 0 then
		local empty = holdings:addRow(false, { fixed = true })
		empty[1]:setColSpan(6):createText(ReadText(551001, 3))
	end

	local sumPct, sumColor = changeText(sumCost, sumValue)
	local sumRow = holdings:addRow(false, { fixed = true, bgColor = Color["row_title_background"] })
	sumRow[1]:createText(ReadText(551001, 9), { font = Helper.standardFontBold })
	sumRow[2]:createText(owned > 0 and moneyText(sumCost) or "-", { halign = "right", font = Helper.standardFontBold })
	sumRow[3]:createText(owned > 0 and sumPct or "", { halign = "right", color = sumColor, font = Helper.standardFontBold })
	sumRow[4]:createText(owned > 0 and moneyText(sumValue) or "-", { halign = "right", font = Helper.standardFontBold })
	sumRow[5]:createText("", { font = Helper.standardFontBold })
	sumRow[6]:createText("", { font = Helper.standardFontBold })

	y = holdings.properties.y + holdings:getVisibleHeight() + Helper.borderSize

	local market = frame:addTable(6, { tabOrder = 3, width = width, x = x, y = y, highlightMode = "off" })
	setColumns(market)

	local marketTitle = market:addRow(false, { fixed = true, bgColor = Color["row_title_background"] })
	marketTitle[1]:setColSpan(6):createText(ReadText(551001, 14), headerText)

	local marketHead = market:addRow(false, { fixed = true, bgColor = Color["row_background"] })
	marketHead[1]:createText(ReadText(551001, 4), headerText)
	marketHead[2]:setColSpan(2):createText(ReadText(551001, 7), headerText)
	marketHead[4]:setColSpan(2):createText(ReadText(551001, 22), headerText)
	marketHead[6]:createText("", headerText)

	for _, stock in ipairs(menu.stocks) do
		local qty = menu.resolveQty(stock, "buy")
		local pay = unitCost(stock.price, true) * math.max(qty, 0)
		local row = market:addRow(stock.id, { fixed = true })
		row[1]:createText(stockName(stock.id))
		row[2]:setColSpan(2):createText(moneyText(stock.price), { halign = "right" })
		row[4]:setColSpan(2):createText(qty > 0 and moneyText(pay) or "-", { halign = "right" })
		row[6]:createButton({ mouseOverText = ReadText(551001, 22) .. "  " .. moneyText(pay) }):setText(ReadText(551001, 10), { halign = "center" })
		row[6].handlers.onClick = function ()
			menu.trade("buy", stock.id)
		end
	end

	frame:display()
end

function menu.onShowMenu()
	menu.shown = true
	menu.display()
	AddUITriggeredEvent("StockMarket", "sync")
end

menu.updateInterval = 0.5

function menu.onUpdate()
	if menu.infoFrame then
		menu.infoFrame:update()
	end
end

function menu.onCloseElement(dueToClose)
	Helper.closeMenu(menu, dueToClose)
	menu.cleanup()
end

function menu.viewCreated()
end

init()
