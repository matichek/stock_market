# Stock Market

Buy and sell in-universe companies with credits. Prices move every 10 seconds of game time.

## Where to find it

1. Enable **Stock Market** in the game’s Extensions menu, then load a save.
2. Open **Player Information** (the person icon on the top bar).
3. Click **Exchange**. It is the button at the top of that screen, just to the right of the sidebar icons. A sidebar icon with the same name is there too when the game allows it.

**Shift+J** opens the same screen from the cockpit.

**Graph** switches the screen to bar charts: one for the company you pick, and one for the value of everything you hold. Each bar is one 10-second tick. Green is a step up, red is a step down. **Table** returns to the holdings list.

**Notices on** / **Notices off** turns the flying portfolio banner on or off. News in the logbook still appears. A refused buy still warns you.

The first time the mod runs on a save, the logbook also says where Exchange is.

## On the screen

**Holdings** lists every company you own:

- Bought price
- Change since that buy (`+2%` in green, `-2%` in red)
- New price
- Shares

The **Sum** row adds what you paid and what the book is worth now.

**Available** lists the companies you can buy. Set the amount to 1, 10, 100, or Max, then Buy or Sell. Max spends as much cash as that company can take. There is no cap on how much you can put into one company, or across all of them. The only stop is the credits you have.

Buy and sell include a 1% commission.

## How prices move

One shared market move hits every company each tick, the way a real exchange has up days and down days. Calm names (Ministry Ledger, Teladi Profit Guarantee) only take a little of that move and barely twitch on their own. Wild names (Zyarth Blood-Steel, Hatikvah Free Haul, Scale Plate Salvage) take more of the market and jump further by themselves.

A move also lingers for a tick or two, so a rise tends to keep rising before it fades. Teladi and Nopileos start leaning up. Zyarth and Scale Plate start leaning down. Those habits are not fixed. About every 3 minutes, one company changes: it can grow calmer or wilder, follow the market more or less, or flip its long-term lean. The logbook and the Exchange headline say which one changed. A news shock is still a one-company jump, then that move fades like the others.

## While you fly

Prices keep moving with the menu closed. Pause freezes them. If you own shares and the portfolio total changes, a small banner shows the move, for example `Portfolio +2% (+12,400 Cr)`.
