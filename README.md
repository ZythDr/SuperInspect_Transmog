# SuperInspect_Transmog

SuperInspect_Transmog is a Turtle WoW addon for WoW 1.12.1 that adds Turtle's native `Transmogrified to:` tooltip line to SuperInspect item slot tooltips.

## Requirements

- Turtle WoW client with inspect transmog support
- SuperInspect
- SuperInspect_UI

## Installation

1. Place the `SuperInspect_Transmog` folder in `Interface/AddOns`.
2. Make sure `SuperInspect` and `SuperInspect_UI` are enabled.
3. Reload the UI.

## Version

Current release: `1.0`

## Notes

- Uses Turtle WoW's existing inspect transmog message flow instead of maintaining a separate transmog cache.
- Injects the transmog line into SuperInspect tooltips in the same style as Turtle's native InspectFrame.
- Includes duplicate protection so the line is not added twice when other tooltip addons are enabled.