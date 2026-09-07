# Layout helpers for IHP-SG13G2
This project is a collection of layout helpers for IHP-SG13G2 process to be used in Klayout.

# In this repo

## Guard Rings 

draws ready to use guard rings by providing:
- Substrate type: Psub, Nwell
- Width and Height
- Rings (number of contact rings)
- Mode: All, North, South, West, East (entire ring or one of the sides) 

## Contact Array 

draws a matrix of contacts by providing (can be drawn on any layer for now, will be coerced to Cont.drawing later):
- Layer (default Cont.drawing)
- number of Rows and Columns
- size of the contacts (default *160nm*)
- Include Metal: Yes, No (will include a Metal1.drawing)
- Include GatPoly/Active: No, GatPoly, Activ (will include GatPoly.drawing or Activ.drawing)
- Enclosure/Enclosure position (for Metal1.drawing)

## Contact Line

similar to Contact Array, but works with length, provided options:
- Layer (default Cont.drawing)
- Length
- Size
- Minimum spacing
- Padding (space at start and end of the line)
- Number of lines
- Vertical spacing type: Square (same spacing as calculated horizontal), Min. Spacing, Custom Vertical Spacing (specified)
- Custom Vertical Spacing: spacing to apply in case of custom vertical spacing selected.

## Via Array

draws an matrix of vias on Via(n=1-4).drawing and TopVia(n=1-2).drawing, by providing:
- number of Rows and Columns
- Size of the via (temporarily, later, must be coerced to the selected via)
- Clearance (space left from the origin)
- Enclosure and Enclosure position
- Source layer (starting layer)
- Destination layer (ending layer)

# How to use
- Clone the repo ```git clone https://github.com/vihreapsi/layout-helpers-ihp.git```
- Klayout > Macro Development (F5) > Ruby (tab) > Add Location > \[Select the cloned repo directory\]
- Run ```QSLib```

To insert a helper cell: Instance > Editor Options > Instance > Library > \[Select Libaray: *QSLib - Quadratische Spezereien Library for IHP-SG13G2*\]
The helpers should then appear in **Cell** dropdown
