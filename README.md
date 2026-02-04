# Celerity.su

i do this library 4hours
code not was pasted Just ui looks like pasted script


# Documentation

## Loading Library
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/aidarkunakbaev2/MyPastedLibrary/refs/heads/main/source.lua", true))()
```

## Creating Window

```lua
local window = library:Window({name = "<font color=\"#92EAAA\">onetap.pub</font> | t.me/onetaprbx"})
```

### Creating Tabs

```lua
local aimbot = window:Page({Name = "aimbot"})
```

### Creating sections

```lua
local aimbot_section = aimbot:Section({Name = "players", size = 300})
```

### Creating Button

```lua
local button = aimbot_section:Button({Name = "Click here if you like ui", Callback = function() warn("thx i add dropdown") end})
```

### Creating Toggle
```lua
local toggle = aimbot_section:Toggle({Name = "cool toggle", Default = true, Callback = function(Value) print("value is"Value) end})
```
### Creating Label

```lua
local label = aimbot_section:Label({Name = "do you like ui?"})
```
### Creating Slider

```lua
local slider = aimbot_section:Slider({Name = "slider cool", Default = 10, Minimum = -10, Maximum = 30, Decimals = 10, Suffix = "%", Callback = function(val) warn(val) end})
```

#### If you want dropdown go to telegram channel t.me/onetaprbx

```lua
--I FORGOT MAKE A DROPDOWN LOL
```
