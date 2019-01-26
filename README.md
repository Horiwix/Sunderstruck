# Sunderstruck
(WoW 1.12.1 Addon)

## Information

Addon tracks Sunder Armor casts of players in party/raid and displays recent casts in a movable/resizeable/hideable panel. Each row displays player's name that casted Sunder and a color based on it's success (red - missed, green - hit).

A history of every sunder casted per player is kept internally and is refreshed when WoW GUI is reloaded (`/reload`) or user disconnects. To print history to chat - type `/ss history`.

**NOTE:** only tracks Sunder Armor casts of those who also use this addon!

![Sunderstruck GUI](https://i.imgur.com/E5C0EqI.gif)

## Requirements

Required dependency - [KLHThreatMeter](https://github.com/Linae-Kronos/KLH-Threat-Meter-17.35) (KTM 17.35)

Addon depends on KTM to bind on it's function to track when Sunder Armor is casted.
More information why tracking it is difficult on KTM's repository - [link](https://raw.githubusercontent.com/Linae-Kronos/KLH-Threat-Meter-17.35/master/KTM%2017.35/KLHThreatMeter/Readme/Warriors%20-%20Read%20Me!.txt)

## Installation

Installation is the same as any addon:

Download and put `Sunderstruck` folder in your `...\Interface\AddOns`

File structure should look like (make sure you have `KLHThreatMeter` installed):

```
Interface/
└── Addons/
    ├── Sunderstruck/
    ├── KLHThreatMeter/
    ├── ...
    ...
```

## Usage

type `/ss` to display usage information:

![Sunderstruck Usage](https://i.imgur.com/MA00COd.png)

```
/ss hide            -> hides display panel (still tracks and sends information)
/ss lock            -> locks display panel in place preventing moving and resizing
/ss alpha <0-1>     -> changes the alpha channel of panel's background (0 - invisible, 1 - fully visible)
/ss row_alpha <0-1> -> changes the alpha channel of player rows (0 - invisible, 1 - fully visible; Name will always be displayed)
/ss test            -> displays all player rows with test names
/ss clear           -> clears and reset the rows
/ss history         -> prints sunder count per player to chat (history resets on GUI reload)
```
