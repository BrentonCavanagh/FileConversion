/*
 * Script written by Brenton Cavanagh 2018 brentoncavanagh@rcsi.ie
 * Purpose: To open and resave ND2 files from the Nikon Eclipse 90i
 * as single RGB TIF with the correct colour order (BGR). 
 */
 
//Generate user input
#@File (label="Files to resave",style="directory") dirIN
#@String (label="Saving location", description="Either save to a subfolder, overwrite the original tif files or use a custom location", choices={"Subfolder","Input folder","Custom location"},value="Custom location", style="radioButtonHorizontal") folder
#@File (label="Custom save locatoin",style="directory") dirOUT

//Import libraries
import ij.IJ
import loci.plugins.BF
import loci.plugins.in.ImporterOptions
import java.awt.Color
import loci.common.DebugTools

if(folder == "Input folder"){
	dirOUT = dirIN
}
if(folder == "Subfolder"){
	dirOUT = new File(dirIN.path+File.separator+"WithScaling"+File.separator)
	dirOUT.mkdirs()
}

//Count number of images to process and show porgress
count = 0
countFiles(dirIN)
n =0

function countFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/")){
          	folder = replace(list[i], "/", "");
          	countFiles(""+dir+File.separator+folder);
          	}
          else {
          	  count++;}
  }
}

//Recurse images in specified folders
dirIN.eachFileRecurse { file ->    
	filename =  dirIN.path+File.separator+file.name 
	savename =  dirOUT.path+File.separator+file.name
    //open if file type is ND2
    if (filename.endsWith(".nd2")){
    	showProgress(n++, count);
	    //Bioformats options
    	options = new ImporterOptions();
		options.setId(filename);
		options.setAutoscale(false);
		options.setColorMode("Custom")
		options.setCustomColor(0,0,Color.BLUE)
		options.setCustomColor(0,1,Color.green)
		options.setCustomColor(0,2,Color.red)
    	//Open image
    	imp = BF.openImagePlus(options)
    	imp = imp[0]
		imp.setDisplayMode(IJ.COMPOSITE);
		imp.flattenStack();
		IJ.log("Resaving "+file.name);
		//Save image
		IJ.saveAs(imp, "Tiff", savename)
		imp.close()
		}
}
//Notify user that script is finished
IJ.log(" ");
IJ.log("Finished resaving "+count+" Images");
//Script updated by Brenton Cavanagh 20200622
