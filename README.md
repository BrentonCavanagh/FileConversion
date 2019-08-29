# FileConversion
A series of tools to aid the convesion of various complicated or obsolete microscopy file formats to TIFF using the macro language in ImageJ/FIJI.

# Prerequisites
These scripts are designed to be run in FIJI on single folders of file that require conversion to TIF.

# Getting Started
Install FIJI from https://fiji.sc/
 - unzip
 - run ImageJ-win64.exe

Drag and drop the respective Script into the main window of FIJI. Use 'RUN' in the new window to start the script & follow the prompts.

# Script descriptions
Nikon Elements 
Scripts designed for files generated in NIS Elements V xx.xx
Brightfield: Will resave all .ND2 files in a folder as a sinlge RBG .tif file with metadata.
Fluorescence: Will resave all .ND2 files in a folder as a sinlge RBG .tif file with metadata. Requires User input in the form of channel colour order.

Leica LAS
Scripts designed for files generated in Leica LAS V 4.5
Will read scaling information from .anx, .eax & .cal.xml files and apply it to the .tif image file.

Metamorph
