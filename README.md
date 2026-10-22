# Stock Market

A mod for **X4: Foundations** (base game). It adds a small private exchange where you buy and sell 14 in-universe companies with the credits you already have. Companies react to live station counts, station destructions, and capital ship battles in your galaxy.

Prices move every 10 seconds of game time, including while you are flying. Pause freezes them. Your holdings, fundamentals, and 24-tick price charts are stored in your save.

Needs X4 Foundations 7.00 or newer. No DLC and no other mods are required. The text is English.

## Install

1. Put this folder in the game’s `extensions` directory, so the game can see `extensions/stock_market/content.xml`.
2. Enable **Stock Market** in the Extensions menu.
3. Quit the game fully and start it again, then load a save. The first time the mod runs on that save, the logbook says where to find the screen.

## Where to find it

1. Open **Player Information** (the person icon on the top bar).
2. Click the first icon on the left sidebar. Its tooltip is **Exchange**.

## On the screen

**Holdings** lists every company you own:

- The price you paid
- Change since that buy (`+2%` in green, `-2%` in red)
- The new price
- How many shares you hold

The **Sum** row adds what you paid and what the book is worth now.

**Available** lists the companies you can buy, along with each company's live **Fair value** (`Low` in green when the stock is trading well below its fundamental value, `High` in red when trading well above). Hover any company name or Fair Value to see which faction/stations drive it, its current volatility (`Swing`), and its market sensitivity (`Beta`).

Set the amount to **1**, **10**, **100**, or **Max**, then Buy or Sell. The button shows the share count it will trade, for example `Buy (10)`. Sell never sells more shares than you hold. Max spends as much cash as that company can take. Buy and sell both charge a 1% commission.

**Graph** switches to two save-persistent line charts: the company you pick (with a horizontal **Bought** break-even line if you hold shares), and the value of everything you hold. **Table** returns to the holdings list.

**Notices on** / **Notices off** turns the 1-minute cumulative portfolio notification (`Portfolio +2% (+20000 Cr)`) on or off. News in the logbook still appears.

## How prices move & Live Universe link (CPU-safe)

- **Live War & Destruction Events**: When stations or L/XL capital ships are destroyed, the victim faction's stock takes a hit and loses Fair Value, the attacker rallies, and **Scale Plate Salvage** climbs on fresh wreckage. Headlines name the real sector where the battle happened.
- **Staggered Station Fundamentals**: On load, Fair Values calibrate from live galaxy station counts, and every 20 seconds the exchange scans one company at a time (zero frame lag) to adjust its **Fair value** as factions expand or lose territory.
- **10-Second Price Tick**: Every 10 seconds, prices gravitate toward each company's live **Fair value**, combined with market beta, momentum, and company volatility. When the Exchange menu is closed, no UI strings or Lua events are sent.

## Companies

Argon Prime Yards, Antigone Memorial Works, Teladi Profit Guarantee, Ministry Ledger, Paranid Sacred Lattice, Pontifex Reliquary, Zyarth Blood-Steel, Hatikvah Free Haul, Eighteen Billion Freight, Grand Exchange Mercantile, Nopileos Ore Trust, Second Contact Logistics, Black Hole Sun Mining, Scale Plate Salvage.
