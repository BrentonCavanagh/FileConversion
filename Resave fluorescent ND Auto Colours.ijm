/*
 * Script written by Brenton Cavanagh 2018 brentoncavanagh@rcsi.ie
 * Purpose: To open and resave ND files from metamorph
 * + the option to also output flattened PNG image
 */

//Generate user input
#@File (label="Folder to process",style="directory") dirIN
#@String (label="Saving location", description="Save tiff out put in subfolder, root folder or custom location", choices={"Input Folder","Subfolder","Custom"},value="Input Folder", style="radioButtonHorizontal") folder
#@File (label="Custom location",style="directory") dirCustom
#@Boolean (label="Autoscale images", description="Autoscale iamges while importing", style="checkbox") Autoscale
#@Boolean (label="Create thumbnail", description="Single RGB preview image", style="checkbox") Flatten

setBatchMode(true);
count = 0;

if(folder == "Input folder"){
	dirOUT = dirIN;
}
else if(folder == "Custom"){
	dirOUT = dirCustom;
}
else {
	dirOUT = dirIN+File.separator+"Tiff_output"+File.separator;
	File.makeDirectory(dirOUT);
}
//Recurse images in specified folders
list = getFileList(dirIN);
for (f=0; f<list.length; f++) { 
	filename =  dirIN+File.separator+list[f]; 
	if (endsWith(filename, ".nd")){
		if(Autoscale == 1){
		run("Bio-Formats Importer", "open=["+filename+"] autoscale color_mode=Default view=Hyperstack");	
		}
		else{
    	run("Bio-Formats Importer", "open=["+filename+"] color_mode=Default view=Hyperstack");	
		}
		print("Resaving "+list[f]);
    	name = File.nameWithoutExtension;
    	savename =  dirOUT+File.separator+name;
    	getDimensions(width, height, channels, slices, frames); 

    	//Get channel names and set colour
		colString = getInfo("Series 0 Name");
		rawColours = split(colString, "/");
		colours = newArray();
		for (i=0; i<rawColours.length; i++) {
			if (matches(rawColours[i], ".*DIC.*") || matches(rawColours[i], ".*Brightfield.*") || matches(rawColours[i], ".*Phase.*")) {
					colours = Array.concat(colours, "Grays");
			}
			else if (matches(rawColours[i], ".*DAPI.*")) {
					colours = Array.concat(colours, "Blue");
			}
			else if (matches(rawColours[i], ".*GFP.*")) {
					colours = Array.concat(colours, "Green");
			}
			else if (matches(rawColours[i], ".*CY3.*")) {
					colours = Array.concat(colours, "Red");
			}
			else if (matches(rawColours[i], ".*CY5.*")) {
					colours = Array.concat(colours, "Magenta");
			}
			else {
				print("unknown filterset @ position "+ i );
			}
	   	}
	   	Array.print(colours);
		   	   	
    	// Set colours
    	for (j=0; j<colours.length; j++){
				Stack.setChannel(j+1);
				run(colours[j]);
				}
	 	if (channels > 1){
	 		Stack.setDisplayMode("composite"); 	
	 		}
	 	
	    saveAs("tiff", savename);
	    
	    //optional creation of flattened image
	    if (Flatten == 1){
	    	run("Flatten");
			saveAs("jpg", savename+"_thumbnail");
	    }
	    //cleanup
	    run("Close All");
	    count++;
		}
	}
	
//Notify user that script is finished
print(" ");
print("Finished resaving "+count+" Images");

//Script updated by Brenton Cavanagh 20201015