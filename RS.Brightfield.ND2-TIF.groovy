/*
 * Script written by Brenton Cavanagh 2018 brentoncavanagh@rcsi.ie
 * Purpose: To open and resave ND2 files from the Nikon Eclipse 90i
 * as single RGB TIF or PNG files with the collect colour order (BGR) 
 */
 
//Generate user input
#@File (label="Files to analyse",style="directory") dirIN
#@File (label="Save results here",style="directory") dirOUT
#@String(label="File type", description="Set colour for channel one", choices={"PNG","TIF",},value="TIF") FileType

//Import libraries
import ij.IJ
import loci.plugins.BF
import loci.plugins.in.ImporterOptions
import java.awt.Color

//Count number of images processed
count = 0

//Recurse images in specified folders
dirIN.eachFileRecurse { file ->    
	filename =  dirIN.path+File.separator+file.name 
	savename =  dirOUT.path+File.separator+file.name
	//open if file type is ND2
	if (filename.endsWith(".nd2")){
		//Bioformats options
		options = new ImporterOptions();
			options.setId(filename);
			options.setAutoscale(false);
			options.setColorMode("Custom")
			options.setCustomColor(0,0,Color.BLUE)
			options.setCustomColor(0,1,Color.green)
			options.setCustomColor(0,2,Color.red)
		ij.log("Resaving "+file.name);
		//Open image
		imp = BF.openImagePlus(options)
		imp = imp[0]
		imp.setDisplayMode(IJ.COMPOSITE);
		imp.flattenStack();
		//Save image
		IJ.saveAs(imp, FileType, savename)
		imp.close()
		//add to number of images proccessed
		count++
    	}
}
//Notify user that script is finished
ij.log("")
ij.log("Finished resaving "+count+" images")

//Script updated by Brenton Cavanagh 20190702
