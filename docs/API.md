# Athena · API reference

Everything is optional except the objects you want to create. Callbacks are wrapped in `pcall`,
so a mistake in your script logs a warning instead of breaking the interface.

```lua
local Athena = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Wiiffies/Athena-UI-lib/main/dist/Athena.luau?v=1.2.10"
))()

local Window = Athena:CreateWindow({
    Title = "Athena",
    DynamicIsland = { Enabled = true },
})
Window:SetDynamicIslandEnabled(true)
```

---

## Athena

| Member | Description |
| --- | --- |
| `Athena.Version` | Library version string; also shown as a small tag beside the window brand. |
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
| `Logo` | string or number | drawn mark | Image asset for the title bar mark (`rbxassetid://…` or an id). |
| `Theme` | string or table | `"Athena"` | Preset name or a partial theme table. |
| `ThemeOverrides` | table | – | Tokens merged over the resolved theme. |
| `Accent` | Color3 | `#EEF0F2` | Shortcut for `ThemeOverrides.Accent`. |
| `Size` | UDim2 or Vector2 | `880 × 600` | Base size; the window scales to the viewport. |
| `ToggleKey` | Enum.KeyCode or `false` | `RightShift` | Keyboard show/hide. |
| `QuickMenu` | boolean or table | `true` | Bottom-right command palette, visible with the window; `false` disables it. |
| `QuickMenuKey` | Enum.KeyCode or `false` | `K` | Hide/show the window and quick menu together. |
| `DynamicIsland` | boolean or table | `true` | Draggable live session HUD pinned to the top centre that expands downward without moving its top edge. `false` disables it; table accepts `Enabled`, `Expanded`, `Animated`. |
| `Parent` | Instance | `PlayerGui` | Where the ScreenGui is parented. |
| `Animated` | boolean | `true` | Fade/scale intro animation. |
| `Footer` | string | – | Faint centered credit line near the bottom of the window. |
| `Plan` | string | – | Optional label appended to the version tag, e.g. `"Freemium"`. |

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
| `Window:SetTitle(text)` | Updates the title bar and re-measures the space reserved for it. |
| `Window:Center(animated)` | Tween the window to the viewport centre (`animated = false` snaps). |
| `Window:SetToggleKey(key)` | Change the show/hide hotkey, or disable it with `false`. |
| `Window:ToggleDynamicIsland()` | Show or hide the dynamic island. |
| `Window:SetDynamicIslandEnabled(bool)` / `Window:IsDynamicIslandEnabled()` | Set or read island visibility. |
| `Window:ToggleQuickMenu()` / `OpenQuickMenu()` / `CloseQuickMenu()` | Drive the quick command palette from code. |
| `Window:Close()` | Animates out and destroys the window. |
| `Window:Destroy()` | Destroys immediately. |

### Dynamic island

Every window creates a small draggable HUD pinned 8px from the top edge and centred horizontally.
The collapsed pill shows the local player's avatar, `@username`, runtime, FPS and ping. Click it
to expand memory, player count and local time alongside uptime, FPS and ping. Drag it anywhere;
it clamps to the viewport without clipping. It is independent of the main window, so **K** can
hide the window while the island stays visible.

```lua
Window:ToggleDynamicIsland()
Window:SetDynamicIslandEnabled(false)

local island = Window.DynamicIsland
if island then
    island:ToggleExpanded()
    island:SetExpanded(true)
    island:SetVisible(true)
    print(island:GetUptime())
end
```

| Island method | Description |
| --- | --- |
| `SetVisible(bool, instant)` | Animate the island in or out (`instant = true` snaps it). |
| `Toggle()` | Flip the current visibility. |
| `SetExpanded(bool)` / `ToggleExpanded()` | Open or close the uptime, FPS, ping, memory, players and local-time panel. |
| `GetUptime()` | Seconds since the island was created. |
| `Destroy()` | Remove the island and disconnect its updates. |

The complete example wires these controls into **Settings → Dynamic island**. Disable it at
construction with `DynamicIsland = false`, or start it hidden with
`DynamicIsland = { Enabled = false }`. The quick menu also contains a **Toggle dynamic island**
command.

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
        { Name = "Run", Style = "Primary", Callback = function() end },
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
    Tooltip = "Runs the example callback.", -- shown while hovering the pill
    Style = "Primary",         -- Primary | Secondary | Ghost; primary is flat white with no icon
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
the value is rounded to `Step` and clamped to `Min`/`Max`. The rail is white in the Athena theme.
Grabbing the thumb keeps the current value instead of snapping its centre to the pointer, the thumb
never leaves the rail while dragging, and the page does not scroll during a drag. Programmatic
`Set` calls animate; dragging stays immediate.

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

### Quick menu

Every window gets a bottom-right command palette that is visible while the window is visible. Press
**K** to hide/show the window and palette together. Type to filter commands; commands run without
dismissing the palette. It includes centre, minimise, hide/show, test notification, clear
notifications, dynamic-island toggle and a jump-to-tab command for every tab. The panel springs in
and command rows cascade into place.

```lua
Window:OpenQuickMenu()
Window:ToggleQuickMenu()
Window:CloseQuickMenu()
```

Disable it with `QuickMenu = false`, or change the key with `QuickMenuKey = Enum.KeyCode.J`. If the
same key is used for both `ToggleKey` and `QuickMenuKey`, pressing it hides or shows both.

### Keybind

```lua
local bind = Section:CreateKeybind({
    Name = "Quick action",
    Default = Enum.KeyCode.G,
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
    Text = "Athena",
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
    Default = Color3.fromRGB(238, 240, 242),
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
stored in the bell panel in the title bar. Unread notifications show a count badge on the bell; opening
the panel marks them read. The panel groups entries by tone with an icon, title, time and body, has
an empty state and a `Clear` action.

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
| Controls | `Primary`, `PrimaryHover`, `PrimaryPressed`, `PrimaryText`, `Track`, `TrackFill`, `ToggleOn`, `ToggleOff`, `Knob`, `KnobOn`, `Chip`, `Scrim` |
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
        Accent = Color3.fromRGB(238, 240, 242),
    },
    ThemeOverrides = { AccentText = Color3.fromRGB(14, 15, 18) },
})
```

---

## Icons

Icons use public Lucide image assets (`rbxassetid`), with the original vector Athena brand mark and a
circle fallback for unknown names. Available names:

`athena`, `bell`, `bolt`, `check`, `chevronDown`, `chevronLeft`, `chevronRight`, `chevronUp`,
`clock`, `close`, `code`, `dot`, `gamepad`, `gear`, `grid`, `home`, `info`, `maximize`, `minus`,
`pause`, `play`, `plus`, `pulse`, `refresh`, `search`, `smartphone`, `trash`, `warning`.

Pass the name to `Icon` anywhere an icon is accepted. Names are colour-tinted and animate on
hover and press automatically.

---

## Behaviour and cleanup

- The window is draggable from the top bar and clamped to the viewport, with a 44px top safe
  area. The island sits 8px from the top edge and clamps on every side without clipping.
- Title bar controls: tab search, notification panel, minimise, expand and close (hovering close
  tints it with the accent colour).
- `UIScale` keeps the layout proportional on small and large screens; the base size never changes,
  so rows, gaps and type keep their proportions.
- Popups (dropdown, colour picker, bell, search) close on outside click, Escape, tab change,
  drag and viewport resize.
- `Section:Destroy()`, `Tab:Destroy()` and `Window:Destroy()` disconnect everything they created.
- Errors thrown inside callbacks are caught and reported with `warn("[Athena] …")`.
- `RightShift` toggles the window unless `ToggleKey = false` is passed. Avoid binding either
  `RightShift` or the quick-menu key (`K` by default) with `CreateKeybind`.
- If `ToggleKey` and `QuickMenuKey` are the same, the key hides and shows both the window and the
  palette.

---

## Utility helpers

```lua
Athena.Util.ColorToHex(color)   --> "#EEF0F2"
Athena.Util.HexToColor("#EEF0F2") --> Color3
Athena.Util.FormatNumber(12.5)  --> "12.5"
Athena.Util.Round(value, step)
Athena.Util.Measure(text, size, font, width) --> Vector2
Athena.Util.Maid.new()          --> lifetime helper (:Add, :Clean)
```
