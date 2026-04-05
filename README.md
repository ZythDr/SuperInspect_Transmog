# SuperInspect_Transmog

SuperInspect_Transmog is a plugin for Turtle WoW players who use the [SuperInspect](https://github.com/vakos1/SuperInspect) Addon. It adds the missing "Transmogrified to:" text when using [SuperInspect](https://github.com/vakos1/SuperInspect), and it also adds a texture indicator to any transmogrified armor slot. 

<img width="668" height="847" alt="image" src="https://github.com/user-attachments/assets/9b4afe1b-4204-4d63-b5b3-8cac74c3ccfa" />


## Dependencies
- [SuperInspect](https://github.com/vakos1/SuperInspect)

## Recommended Installation

1. Copy the current page URL `https://github.com/ZythDr/SuperInspect_Transmog` and paste it into the Turtle Launcher/GitAddonsManager/Wuddle.
2. Done.

## Manual Installation

1. Download the addon from the green `Code` button above, or download the latest [Release](https://github.com/ZythDr/SuperInspect_Transmog/releases/latest) and extract the zip file.
2. Place the `SuperInspect_Transmog` folder in `Interface/AddOns`.
3. Make sure `SuperInspect` and `SuperInspect_UI` are both enabled.


## Notes

- Uses Turtle WoW's existing inspect transmog message flow instead of maintaining a separate transmog cache.
- Injects the transmog line into SuperInspect tooltips in the same style as Turtle's native InspectFrame.
- Includes duplicate protection so the line is not added twice when other tooltip addons are enabled.
