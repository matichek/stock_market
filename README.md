# Stock Market

A mod for **X4: Foundations** (base game). It adds a small private exchange where you buy and sell fictional companies with the credits you already have. The companies are named after the X4 setting. They are not live factions, stations, or wares, and they do not change the economy.

Prices move every 10 seconds of game time, including while you are flying. Pause freezes them. The book is stored in your save.

Needs X4 Foundations 7.00 or newer. No DLC and no other mods are required. The text is English.

## Install

1. Put this folder in the game’s `extensions` directory, so the game can see `extensions/stock_market/content.xml`.
2. Enable **Stock Market** in the Extensions menu.
3. Quit the game fully and start it again, then load a save. The first time the mod runs on that save, the logbook says where to find the screen.

## Where to find it

1. Open **Player Information** (the person icon on the top bar).
2. Click the first icon on the left sidebar. Its tooltip is **Exchange**.

**Shift+J** opens the same screen from the cockpit, and closes it if it is already open. That key is handled by the mod. It does not show up in the control options.

## On the screen

**Holdings** lists every company you own:

- The price you paid
- Change since that buy (`+2%` in green, `-2%` in red)
- The new price
- How many shares you hold

The **Sum** row adds what you paid and what the book is worth now.

**Available** lists the companies you can buy. Set the amount to **1**, **10**, **100**, or **Max**, then Buy or Sell. The button shows the share count it will trade, for example `Buy (10)`. Sell never sells more shares than you hold. Max spends as much cash as that company can take.

There is no cap on one company, or on the whole book. The only stop is the credits you have. Buy and sell both charge a 1% commission.

Each company also shows the last 10-second move and where the price sits against its start, for example `+3% (+8%)`. Green is up, red is down.

**Graph** switches to two line charts: the company you pick, and the value of everything you hold. Each point is one 10-second tick. The line is green when that series is up from its start, and red when it is down. **Table** returns to the holdings list.

**Notices on** / **Notices off** turns the flying portfolio banner on or off. News in the logbook still appears. A buy you cannot afford still warns you.

## How prices move

One shared market move hits every company each tick, the way a real exchange has up days and down days. Calm names (Ministry Ledger, Teladi Profit Guarantee) only take a little of that move and barely twitch on their own. Wild names (Zyarth Blood-Steel, Hatikvah Free Haul, Scale Plate Salvage) take more of the market and jump further by themselves.

A move also lingers for a tick or two, so a rise tends to keep rising before it fades. Teladi and Nopileos start leaning up. Zyarth and Scale Plate start leaning down. Those habits are not fixed. About every 3 minutes, one company changes: it can grow calmer or wilder, follow the market more or less, or flip its long-term lean. The logbook and the Exchange headline say which one changed. A news shock is a one-company jump, then that move fades like the others.

## While you fly

Prices keep moving with the menu closed. If you own shares and the portfolio total changes, a small banner shows the move, for example `Portfolio +2% (+12,400 Cr)`.

## Companies

Argon Prime Yards, Antigone Memorial Works, Teladi Profit Guarantee, Ministry Ledger, Paranid Sacred Lattice, Pontifex Reliquary, Zyarth Blood-Steel, Hatikvah Free Haul, Eighteen Billion Freight, Grand Exchange Mercantile, Nopileos Ore Trust, Second Contact Logistics, Black Hole Sun Mining, Scale Plate Salvage.
