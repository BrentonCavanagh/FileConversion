/*
 * Script written by Brenton Cavanagh 2021 brentoncavanagh@rcsi.ie
 * Purpose: To resave multiscene CZI files from the Carl Zeiss as 
 * single channel tiff images.
 * + the option to save each scene as a mulitpage tiff
 */

//Script updated by Brenton Cavanagh 20220309

//Generate user input
#@File (label="File to resave",style="file") filename
#@File (label="Save location",style="directory") dirOUT
#@String(label="Filename prefix", description="Custom file name to preceeded scene info") customname
#@String(label="Create individual images", description="Saves each scene as as individual tif image", choices={"Yes","No",},value="Yes", style="radioButtonHorizontal") saveindividual
#@String(label="Create scene image", description="Saves each scene as a single tif image", choices={"Yes","No",},value="No", style="radioButtonHorizontal") savescene

setBatchMode(true);
count = 0;

//Recurse images in specified folders
if (endsWith(filename, ".czi")){
	run("Bio-Formats Macro Extensions");
	Ext.setId(filename);
 	Ext.getSeriesCount(seriesCount);
	print(filename+" contains "+seriesCount+" Positions");
	print(" ");

	for (j=0; j<seriesCount; j++) {    		
	    Ext.setSeries(j);
	    run("Bio-Formats Importer", "open=["+filename+"] autoscale color_mode=Default view=Hyperstack series_"+d2s(j+1,0));
        name =  File.nameWithoutExtension;
        namecorrected = replace(name, ".", "-");
        getDimensions(width, height, channels, slices, frames); 
        getDateAndTime(year, month, week, day, hour, min, sec, msec);
			print(hour+":"+min+":"+sec+" - "+(j+1) + " of " + seriesCount);
			print("Processing ...");

			//get scene number
			title = getTitle();
			if (endsWith(title, "- label image")){
				print("skipping overview");
			}
			else{
			idx2 = indexOf(title, ".czi #");
			scenenumber = substring(title, idx2+6, lengthOf(title));
			  			
			//Get well number & position
			wellnumber = getInfo("Information|Image|S|Scene|ArrayName #"+scenenumber);
			positionnumber = getInfo("Information|Image|S|Scene|Name #"+scenenumber);
			
			//savename
			savename = customname+"_S"+scenenumber+"_"+positionnumber+"_"+wellnumber;
			print("Scene : "+scenenumber+" => Well: "+wellnumber+" Position: "+positionnumber);
			if (frames > 1 || slices > 1){
				rename(savename);
				}
			else{
				rename(savename+"_c");
				}
			//print(savename);
			if (saveindividual == "Yes"){
				print("Saving individual images");
				run("Image Sequence... ", "dir=["+dirOUT+"] format=TIFF digits=1");
			}
		    
	    //optional creation of flattened image
	    if (savescene == "Yes"){
	    	if (channels > 1){
	 			Stack.setDisplayMode("composite"); 	
	 			}
	    	print("Saving Scene images");
	    	saveAs("tiff", dirOUT+File.separator+savename);
	    	}
		}
    //cleanup
    close();
    count++;
    print("");
	}
}
else{
	print("This is not a CZI file.");
}

	
//Notify user that script is finished

print("Finished resaving "+count+" Images");
