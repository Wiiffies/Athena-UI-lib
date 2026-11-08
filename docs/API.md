# Athena UI · API reference

Everything is optional except the objects you want to create. Callbacks are wrapped in `pcall`,
so a mistake in your script logs a warning instead of breaking the interface.

```lua
local Athena = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Wiiffies/Athena-UI-lib/main/dist/Athena.luau"
))()
```

---

## Athena

| Member | Description |
| --- | --- |
| `Athena.Version` | Library version string. |
| `Athena.Themes` | Table of preset themes (`Athena`, `Light`). |
| `Athena:CreateWindow(options)` | Creates a window and returns it. |
| `Athena:Notify(options)` | Shows a toast in the top right (creates the interface if needed). |
| `Athena:SetTheme(nameOrTable)` | Sets the theme used by notifications and future windows. |
| `Athena:GetWindows()` | Returns every live window. |
| `Athena:Destroy()` | Removes every window, toast and the ScreenGui. |
| `Athena.Util` | Helper table (`ColorToHex`, `HexToColor`, `FormatNumber`, …). |

### `Athena:CreateWindow(options)`

| Option | Type | Default | Notes |
| --- | --- | --- | --- |
| `Title` | string | `"Athena"` | Shown in the title bar and on the minimised pill. |
| `Theme` | string or table | `"Athena"` | Preset name or a partial theme table. |
| `ThemeOverrides` | table | – | Tokens merged over the resolved theme. |
| `Accent` | Color3 | `#F2555A` | Shortcut for `ThemeOverrides.Accent`. |
| `Size` | UDim2 or Vector2 | `880 × 600` | Base size; the window scales to the viewport. |
| `ToggleKey` | Enum.KeyCode or `false` | `RightShift` | Keyboard show/hide. |
| `Parent` | Instance | `PlayerGui` | Where the ScreenGui is parented. |
| `Animated` | boolean | `true` | Fade/scale intro animation. |

### Window methods

| Method | Description |
| --- | --- |
| `Window:CreateTab(nameOrOptions)` | Creates a tab. A plain string becomes the title. |
| `Window:SelectTab(tabOrIndex)` | Shows a tab. |
| `Window:GetTabs()` | Returns the tabs in order. |
| `Window:Notify(options)` | Same as `Athena:Notify`. |
| `Window:Toggle()` | Hide if visible, show if hidden, restore if minimised. |
| `Window:Show(instant)` / `Window:Hide(instant)` | Animated visibility. |
| `Window:Minimize()` / `Window:Restore()` | Collapse to the corner pill and back. |
| `Window:ToggleMaximize()` / `Window:SetMaximized(bool)` | Expand the window to fill the viewport and back. |
| `Window:SetTitle(text)` | Updates the title bar. |
| `Window:Close()` | Animates out and destroys the window. |
| `Window:Destroy()` | Destroys immediately. |

---

## Tabs

```lua
local Tab = Window:CreateTab("Main")
local Page = Window:CreateTab({
    Title = "Automation",
    Icon = "bolt",          -- icon name, see below
    Badge = 1,              -- optional nav badge
    Description = "Optional subtitle under the page title",
    Selected = false,       -- select on creation
    OnSelected = function(tab) end,
})
```

| Method | Description |
| --- | --- |
| `Tab:CreateSection(nameOrOptions)` | Returns a Section. A string becomes the title. |
| `Tab:CreateBanner(options)` | Full width status strip. |
| `Tab:CreateCard(options)` | Automation card. |
| `Tab:CreateLabel(options)` | Page level label (wrapping paragraph). |
| `Tab:AddAction(options)` | Header pill button (`Name`, `Icon`, `Style`, `Callback`). |
| `Tab:SetTitle(text)` | Updates the page title. |
| `Tab:SetBadge(value)` | Updates the nav badge (`nil` or `0` hides it). |
| `Tab:Select()` | Selects the tab. |
| `Tab:Destroy()` | Removes the page and every component. |

`Style` for actions: `"Primary"` (light fill), `"Secondary"` (outlined), `"Ghost"` (text).

### Banner

```lua
Tab:CreateBanner({ Text = "1 automation is running.", Icon = "dot" })
Tab:CreateBanner({
    Text = "Notifications",
    Description = "Toasts appear in the top right.",
    Icon = "info",
    Tone = "Accent",     -- Neutral | Accent | Success | Warning | Error | Info
    Value = "12",        -- optional right aligned value
})
```

### Card

```lua
Tab:CreateCard({
    Name = "Adopt Me farm",
    Description = "[UPD] Adopt Me! · Every day 00:00 to 23:59",
    Image = "rbxassetid://1234567890",  -- optional, initials are used otherwise
    Tags = { "devscripts", "1 script" },
    Status = "Opening clients",
    Actions = {
        { Name = "Edit", Style = "Ghost", Callback = function() end },
        { Name = "Run", Style = "Primary", Icon = "play", Callback = function() end },
    },
    Toggle = {
        Default = true,
        Callback = function(value) print(value) end,
    },
})
```

Methods: `SetStatus(text)`, `SetTitle(text)`, `SetDescription(text)`, `SetToggle(value, silent)`,
`GetToggle()`, `Destroy()`.

---

## Sections

```lua
local Section = Tab:CreateSection("General")
local Section = Tab:CreateSection({ Title = "Activity", Icon = "clock", Count = 1 })
```

| Method | Returns |
| --- | --- |
| `Section:CreateButton(options)` | Button |
| `Section:CreateToggle(options)` | Toggle |
| `Section:CreateSlider(options)` | Slider |
| `Section:CreateDropdown(options)` | Dropdown |
| `Section:CreateKeybind(options)` | Keybind |
| `Section:CreateTextbox(options)` | Textbox |
| `Section:CreateLabel(options)` | Label |
| `Section:CreateSeparator(options)` | Separator |
| `Section:CreateColorPicker(options)` | ColorPicker |
| `Section:SetTitle(text)` | – |
| `Section:Destroy()` | – |

Every component accepts `Name` and an optional `Description` (muted second line), plus its own
options below. All components share the same row height and padding so mixed sections line up.

### Button

```lua
Section:CreateButton({
    Name = "Example Button",
    Description = "Runs the callback.",
    ButtonText = "Run",        -- text shown on the pill (default "Run")
    Icon = "play",             -- optional icon inside the pill
    Style = "Primary",         -- Primary | Secondary | Ghost
    Enabled = true,
    Callback = function() end,
})
```

Methods: `SetText(text)`, `SetEnabled(bool)`, `Destroy()`. Clicking the row or the pill fires
`Callback`.

### Toggle

```lua
local toggle = Section:CreateToggle({
    Name = "Example Toggle",
    Default = false,
    Callback = function(value) print(value) end,
})
```

Methods: `Set(value, silent)`, `Get()`, `Toggle()`, `SetEnabled(bool)`, `Destroy()`.
Clicking anywhere on the row flips it.

### Slider

```lua
local slider = Section:CreateSlider({
    Name = "Walk speed",
    Min = 0,
    Max = 100,
    Default = 32,
    Step = 1,
    Suffix = "%",              -- optional unit appended to the value
    Callback = function(value) end,
})
```

Methods: `Set(value, silent)`, `Get()`, `Destroy()`. Drag or click anywhere on the track;
the value is rounded to `Step` and clamped to `Min`/`Max`.

### Dropdown

```lua
local dropdown = Section:CreateDropdown({
    Name = "Region",
    Options = { "Automatic", "Europe", "North America" },
    -- or: { { Name = "Europe", Value = 1 }, { Name = "Asia", Value = 2 } }
    Default = "Automatic",
    Placeholder = "Select…",
    Callback = function(value, text) end,
})
```

Methods: `Set(value, silent)`, `Get()`, `GetSelected()`, `SetOptions(list)`, `Open()`, `Close()`,
`Toggle()`, `Destroy()`. The first option is selected when `Default` is omitted.

### Keybind

```lua
local bind = Section:CreateKeybind({
    Name = "Quick action",
    Default = Enum.KeyCode.K,
    Callback = function(key) print("pressed", key) end,
    OnChanged = function(key) print("now bound to", key) end,
})
```

Methods: `Set(key, silent)`, `Get()`, `Clear()`, `Destroy()`.

Click the pill and press any key or mouse button to bind it. `Backspace`/`Delete` clears the bind,
`Escape` cancels listening. `Callback` fires every time the bound input is pressed (ignored while a
TextBox is focused). Pass an `Enum.KeyCode`, `Enum.UserInputType.MouseButton1/2/3`, or `nil`.

### Textbox

```lua
local box = Section:CreateTextbox({
    Name = "Display name",
    Placeholder = "Type here",
    Default = "",
    Numeric = false,          -- strips everything except digits, "-" and "."
    Callback = function(text, enterPressed) end,
})
```

Methods: `Set(text, silent)`, `Get()`, `Destroy()`. `Callback` fires on Enter or when focus is lost.

### Label

```lua
Section:CreateLabel("A single line of text")

Section:CreateLabel({
    Text = "Athena UI",
    Description = "Long paragraphs wrap automatically to the card width.",
})

Section:CreateLabel({ Text = "Version", Value = "1.0.0" })  -- two column row
```

Methods: `SetText(text)`, `SetValue(value)`, `GetValue()`, `Destroy()`.

### Separator

```lua
Section:CreateSeparator()
Section:CreateSeparator({ Text = "Advanced" })
```

Method: `Destroy()`.

### Color picker

```lua
local picker = Section:CreateColorPicker({
    Name = "Accent color",
    Default = Color3.fromRGB(242, 85, 90),
    Callback = function(color) end,
})
```

Methods: `Set(color, silent)`, `Get()`, `Destroy()`. The popup contains a saturation/value canvas,
a hue strip, a hex field and a live preview.

---

## Notifications

```lua
Athena:Notify({
    Title = "Saved",
    Text = "Your configuration was saved.",
    Tone = "Success",       -- Info | Success | Warning | Error | Accent
    Icon = "check",         -- optional icon override
    Duration = 5,           -- seconds, 0 keeps it open
})
```

`Window:Notify` is an alias. Toasts stack (maximum four), animate in, show a progress line and are
stored in the clock/bell panel in the title bar. Unread notifications show a dot on the bell.

Returns `{ Close = function() end }`.

---

## Theme tokens

`Theme` accepts `"Athena"`, `"Light"`, a table of overrides, or a full custom table.

| Group | Tokens |
| --- | --- |
| Surfaces | `Window`, `WindowTop`, `Surface`, `SurfaceAlt`, `SurfaceHover`, `SurfaceActive`, `Overlay` |
| Lines | `Border`, `BorderSoft`, `Highlight` |
| Type | `Text`, `TextSoft`, `TextMuted`, `TextFaint` |
| Accent | `Accent`, `AccentText`, `AccentSoft`, `Success`, `Warning`, `Error`, `Info` |
| Controls | `Primary`, `PrimaryHover`, `PrimaryText`, `Track`, `TrackFill`, `ToggleOn`, `ToggleOff`, `Knob`, `KnobOn`, `Chip`, `Scrim` |
| Typography | `Font`, `FontMedium`, `FontBold`, `FontMono`, `TextSize`, `TextSizeSmall`, `TextSizeTitle` |
| Metrics | `Corner`, `CornerCard`, `CornerSmall`, `CornerChip`, `TopbarHeight` |
| Motion | `Speed`, `SpeedSlow` |

Custom theme example:

```lua
local Window = Athena:CreateWindow({
    Theme = {
        Name = "Midnight",
        Window = Color3.fromRGB(12, 14, 20),
        Surface = Color3.fromRGB(18, 21, 29),
        SurfaceAlt = Color3.fromRGB(26, 30, 40),
        Border = Color3.fromRGB(38, 44, 58),
        Accent = Color3.fromRGB(20, 224, 163),
    },
    ThemeOverrides = { AccentText = Color3.fromRGB(4, 19, 13) },
})
```

---

## Icons

Icons are drawn from primitives, so no assets are needed. Available names:

`athena`, `bell`, `bolt`, `check`, `chevronDown`, `chevronLeft`, `chevronRight`, `chevronUp`,
`clock`, `close`, `code`, `dot`, `gamepad`, `gear`, `grid`, `home`, `info`, `maximize`, `minus`,
`pause`, `play`, `plus`, `pulse`, `refresh`, `search`, `trash`, `warning`.

Pass the name to `Icon` anywhere an icon is accepted. `Athena.Util` exposes helpers if you want to
draw icons yourself.

---

## Behaviour and cleanup

- The window is draggable from the top bar and clamped to the viewport.
- Title bar controls: tab search, notification panel, minimise, expand and close (hovering close
  tints it with the accent colour).
- `UIScale` keeps the layout proportional on small and large screens; the base size never changes,
  so rows, gaps and type keep their proportions.
- Popups (dropdown, colour picker, bell, search) close on outside click, Escape, tab change,
  drag and viewport resize.
- `Section:Destroy()`, `Tab:Destroy()` and `Window:Destroy()` disconnect everything they created.
- Errors thrown inside callbacks are caught and reported with `warn("[Athena] …")`.
- `RightShift` toggles the window unless `ToggleKey = false` is passed. Avoid binding the same key
  with `CreateKeybind`.

---

## Utility helpers

```lua
Athena.Util.ColorToHex(color)   --> "#F2555A"
Athena.Util.HexToColor("#f2555a") --> Color3
Athena.Util.FormatNumber(12.5)  --> "12.5"
Athena.Util.Round(value, step)
Athena.Util.Measure(text, size, font, width) --> Vector2
Athena.Util.Maid.new()          --> lifetime helper (:Add, :Clean)
```
