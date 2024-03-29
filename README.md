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
__Nikon NIS Elements__ 
Scripts designed for files generated in NIS Elements V xx.xx

[_Resave Brightfield:_](Nikon_NIS.Elements_Resave.brightfield.groovy) Will resave each ND2 files of a folder as a single RBG TIF file with the correct metadata.

[_Resave Fluorescence:_](Nikon_NIS.Elements_Resave.fluorescence.ijm) Will resave all ND2 files of a folder as a single RBG TIF file with the correct metadata. Requires the user to input the colour of individual channels in the order of acquisition.

__Leica LAS__

[_Apply scaling:_](Leica_LAS_Apply.Scaling.ijm) Is designed for files generated in Leica LAS V3 and V4.5. It will read scaling information from .anx, .eax & .cal.xml files and apply it to the corresponding TIF file.

[_Apply scaling to multichannel images:_](Leica_LAS_Multichannel.Apply.Scaling.ijm) Is designed for files generated in Leica LAS V3 and V4.5. It will read scaling information from .anx, .eax & .cal.xml files and apply it to the corresponding TIF file. It will also combine individual images found in each folder into multipage tif for use in FIJI.

__Metamorph__

[_Resave Fluorescence:_](Metamorph_Resave.fluorescence.ijm) Is designed for files generated in Metamorph. It will read scaling information and apply a LUT based on the filterset and apply it to the corresponding TIF file. 

__Hitachi H7650__

[_Apply Scaling:_](Hitachi_H7650_Apply.Scaling.ijm) Is designed for .tif files generated using AMT Image Capture Engine V5.42.540a on the Hitachi H7650 transmission microscope. It will read the scaling information present in the metadata and apply it to both the original and a cropped version of the file.

__Zeiss Zen__

[_Zeiss_Zen_Multiscene.as.TIF:_](Zeiss_Zen_Multiscene.as.TIF.ijm) Is designed to resave multiscene CZI files as single channel TIF images. With the option to save each scene as a mulitpage TIF.
