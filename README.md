# SuperInspect_Transmog

SuperInspect_Transmog is a plugin for SuperInspect. It adds the "Transmogrified to:" text to tooltips when using SuperInspect on Turtle WoW.

## Requirements
- SuperInspect
- SuperInspect_UI

## Installation

1. Place the `SuperInspect_Transmog` folder in `Interface/AddOns`.
2. Make sure `SuperInspect` and `SuperInspect_UI` are enabled.


## Notes

- Uses Turtle WoW's existing inspect transmog message flow instead of maintaining a separate transmog cache.
- Injects the transmog line into SuperInspect tooltips in the same style as Turtle's native InspectFrame.
- Includes duplicate protection so the line is not added twice when other tooltip addons are enabled.
