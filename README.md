# Athena UI

A faithful recreation of the [Athena](https://getathena.gg/) client interface as a reusable Roblox UI library, written in Luau.

> Unofficial. This project is not affiliated with or endorsed by Athena or Roblox Corporation.

- Dark neutral shell, hairline borders and light primary pills taken from Athena's Automation screen.
- Top navigation with icons, active underline, badges and window controls.
- Cards, status banners, chips, grouped rows and stacked toasts.
- Toggle, slider, dropdown, keybind, textbox, label, separator and HSV colour picker.
- No images, fonts, modules or other dependencies. Icons are drawn with primitives.
- Responsive scaling, draggable window, minimize-to-pill and keyboard show/hide.
- One `loadstring` for use in game, plus a Rojo-ready module tree in `src/`.

## Quick start

```lua
local Athena = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Wiiffies/Athena-UI-lib/main/dist/Athena.luau"
))()

local Window = Athena:CreateWindow({
    Title = "My Application",
    Theme = "Athena",
})

local Tab = Window:CreateTab("Main")
local Section = Tab:CreateSection("General")

Section:CreateButton({
    Name = "Example Button",
    Callback = function()
        print("Clicked!")
    end,
})

Section:CreateToggle({
    Name = "Example Toggle",
    Default = false,
    Callback = function(Value)
        print(Value)
    end,
})
```

Press **RightShift** to hide or show the window. Pass `ToggleKey = false` to disable that.

A complete showcase that recreates the Automation screen and uses every component lives in
[`examples/Example.client.luau`](examples/Example.client.luau).

Full API reference: [`docs/API.md`](docs/API.md).

## Components

| Component | Creator | Returns |
| --- | --- | --- |
| Button | `Section:CreateButton` | `SetText`, `SetEnabled`, `Destroy` |
| Toggle | `Section:CreateToggle` | `Set`, `Get`, `Toggle`, `SetEnabled`, `Destroy` |
| Slider | `Section:CreateSlider` | `Set`, `Get`, `Destroy` |
| Dropdown | `Section:CreateDropdown` | `Set`, `Get`, `SetOptions`, `Open`, `Close`, `Destroy` |
| Keybind | `Section:CreateKeybind` | `Set`, `Get`, `Clear`, `Destroy` |
| Textbox | `Section:CreateTextbox` | `Set`, `Get`, `Destroy` |
| Label | `Section:CreateLabel` | `SetText`, `SetValue`, `Destroy` |
| Separator | `Section:CreateSeparator` | `Destroy` |
| Colour picker | `Section:CreateColorPicker` | `Set`, `Get`, `Destroy` |
| Card | `Tab:CreateCard` | `SetStatus`, `SetTitle`, `SetToggle`, `Destroy` |
| Banner | `Tab:CreateBanner` | `SetText`, `SetValue`, `Destroy` |
| Notification | `Athena:Notify` / `Window:Notify` | `Close` |

## Project layout

```
Athena-UI-lib/
├── dist/
│   └── Athena.luau              generated single-file library (loadstring)
├── docs/
│   └── API.md                   full API reference
├── examples/
│   └── Example.client.luau      LocalScript using every component
├── src/
│   └── Athena/
│       ├── init.luau            library entry point
│       ├── Window.luau          shell, navigation, panels, minimise pill
│       ├── Tab.luau             page header, actions and scrolling content
│       ├── Section.luau         grouped card of rows
│       ├── Notifications.luau   toasts and history
│       ├── Core/
│       │   ├── Theme.luau       design tokens and presets
│       │   ├── Util.luau        primitives, tweens, maid, colour helpers
│       │   ├── Icons.luau       asset-free vector icons
│       │   ├── Popup.luau       floating surfaces (dropdowns, pickers, panels)
│       │   └── Dragger.luau     drag with viewport clamping
│       └── Components/
│           ├── Button.luau
│           ├── Toggle.luau
│           ├── Slider.luau
│           ├── Dropdown.luau
│           ├── Keybind.luau
│           ├── Textbox.luau
│           ├── Label.luau
│           ├── Separator.luau
│           ├── ColorPicker.luau
│           ├── Banner.luau
│           └── Card.luau
├── build.py                     bundles src/ into dist/Athena.luau
└── default.project.json         Rojo project using src/
```

## Using the module tree in Studio

The `src/` folder is a normal Rojo project:

```json
{
  "name": "AthenaUI",
  "tree": {
    "$className": "Folder",
    "Athena": { "$path": "src/Athena" }
  }
}
```

Run `rojo serve` and sync `default.project.json`, then `require(AthenaModule)`. The same module
returns the library table, so Studio code and the loadstring build behave identically.

## Building the single file

After changing anything in `src/`:

```bash
python3 build.py
```

The bundler rewrites `require(script…)` to module keys, wraps each module, validates that every
required module exists, and writes `dist/Athena.luau`. No dependencies are needed.

## Theming

`Theme` accepts a preset name (`"Athena"`, `"Light"`) or a table merged over the Athena palette:

```lua
local Window = Athena:CreateWindow({
    Title = "My Application",
    Accent = Color3.fromRGB(20, 224, 163), -- quick accent override
    ThemeOverrides = {
        Surface = Color3.fromRGB(24, 25, 28),
        Border = Color3.fromRGB(48, 50, 56),
    },
})
```

Every token is listed in [`docs/API.md`](docs/API.md#theme-tokens).

## Design notes

The recreation follows the reference screen closely:

- `#131416` window, `#1A1B1E` cards, `#2C2E33` hairlines, `#EDEDEE` text.
- 30px bold page title with light pill actions on the right.
- Muted status banner, grouped card rows with 1px dividers and 14px inner padding.
- Automation cards with 50px artwork, title/subtitle, chips, status text, ghost `Edit`,
  light `Run` and a light-track switch.
- Active tab is white with a 2px coral underline; counts use compact coral badges.
- Motion is short and restrained (0.12–0.3s, Quint/Quad out) like the desktop app.
- Type uses Gotham/GothamMedium/GothamBold — the closest Roblox families to Athena's Geist/Inter.

## Licence and disclaimer

Use it in your own projects, modify it, ship it. Athena and Roblox are trademarks of their
respective owners; this repository is an independent, unofficial recreation of the interface.
