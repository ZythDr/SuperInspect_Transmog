# SuperInspect_Transmog

SuperInspect_Transmog is a plugin for SuperInspect. It adds the "Transmogrified to:" text to tooltips when using SuperInspect on Turtle WoW.  
It also adds a small "indicator" texture to transmogrified armor slots in the form of a bottom-right triangle.  

<img width="685" height="890" alt="Screenshot_20260405_041502" src="https://github.com/user-attachments/assets/66f06f64-fb81-425f-961a-8f1ecdff4389" />

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
