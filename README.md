# FileConversion
A series of tools to aid the conversion of various complicated or obsolete microscopy file formats to TIFF using the macro language in ImageJ/FIJI.

# Prerequisites
These scripts are designed to be run in FIJI on single folders of files that require conversion to TIF.

# Getting Started
Install FIJI from https://fiji.sc/
 - unzip
 - run ImageJ-win64.exe

Drag and drop the respective script into the main window of FIJI. Use 'RUN' in the new window to start the script & follow the prompts.

# Script descriptions
__Nikon Elements__ 

Scripts designed for files generated in NIS Elements V xx.xx

[_Brightfield:_](NIS%20Elements_Resave%20brightfield.groovy) Will resave all .ND2 files in a folder as a single RBG .tif file with metadata.

[_Fluorescence:_](NIS%20Elements_Resave%20fluorescence.ijm) Will resave all .ND2 files in a folder as a single RBG .tif file with metadata. Requires User input in the form of channel colour order.

__Leica LAS__

[_Apply scaling:_](Leica%20LAS_Apply%20scaling.ijm) is designed for files generated in Leica LAS V3 and V4.5. It will read scaling information from .anx, .eax & .cal.xml files and apply it to the .tif image file.

__Metamorph__
_coming soon ..._

__Hitachi H7650__

[_Apply Scaling:_](Hitachi%20H7650_Apply.Scaling.ijm) is designed for .tif files generated using AMT Image Capture Engine V5.42.540a. It will read the scaling information present in the metadata and apply it to both the original file and a cropped version of the file.
