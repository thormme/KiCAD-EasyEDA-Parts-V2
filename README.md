# KiCAD EasyEDA Parts

KiCAD Plugin to download footprints, symbols and 3D models from EasyEDA and convert them for KiCAD.

This is a wrapper for [easyeda2kicad.py](https://github.com/uPesy/easyeda2kicad.py) and adds a shortcut in KiCAD with a
little menu to download parts by their LCSC id.

Compatible with KiCad 10.0 and later.

## Installation

- Add [my repository](https://github.com/KoenLammers/KiCAD-EasyEDA-Parts-V2) to KiCAD:  
  `https://raw.githubusercontent.com/KoenLammers/KiCAD-EasyEDA-Parts-V2/main/PCM/repository.json`
- Download the `KiCAD EasyEDA Parts` plugin in the KiCAD Plugin and Content Manager.
  (The required Python dependency will be installed automatically.)

## Usage

- Click <img src="icon.png" width="20"/> in the toolbar (PCB Editor or Schematic Editor).
- Enter the LCSC id of the part you want to download and click Download.
- The files will then be downloaded to ./libs/easyeda/ in your project folder.
- Make sure you've added the libraries in Project Specific Libraries.