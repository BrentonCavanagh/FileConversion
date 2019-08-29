/*
 * Script written by Brenton Cavanagh 2018 brentoncavanagh@rcsi.ie
 * Purpose: To open and resave ND2 files from the Nikon Eclipse 90i
 * Define the correct channel colours and save as multipage TIF with
 * the option to also output flattened image in TIF or PNG
 */

//Generate user input
#@File (label="Files to resave",style="directory") dirIN
#@String(label="Saving location", description="Either save to subfolder or same folder as the ND2", choices={"Subfolder","Input Folder"},value="Input Folder", style="radioButtonHorizontal") folder
#@String(label="Channel one", description="Set colour for channel one", choices={"None","BrightField","Red","Green","Blue","Cyan","Magenta","Yellow","Grays"}, value="None") chanOne
#@String(label="Channel two", description="Set colour for channel one", choices={"None","BrightField","Red","Green","Blue","Cyan","Magenta","Yellow","Grays"}, value="None") chanTwo
#@String(label="Channel three", description="Set colour for channel one", choices={"None","BrightField","Red","Green","Blue","Cyan","Magenta","Yellow","Grays"}, value="None") chanThree
#@String(label="Channel four", description="Set colour for channel one", choices={"None","BrightField","Red","Green","Blue","Cyan","Magenta","Yellow","Grays"}, value="None") chanFour
#@String(label="Channel five", description="Set colour for channel one", choices={"None","BrightField","Red","Green","Blue","Cyan","Magenta","Yellow","Grays"}, value="None") chanFive
#@String(label="Channel six", description="Set colour for channel one", choices={"None","BrightField","Red","Green","Blue","Cyan","Magenta","Yellow","Grays"}, value="None") chanSix
#@String(label="Create PNG?", description="Save a PNG copy of the iamge", choices={"Yes","No",},value="No", style="radioButtonHorizontal") Flatten

setBatchMode(true);
count = 0;
if(folder == "Input folder"){
	dirOUT = dirIN;
}
else {
	dirOUT = dirIN+File.separator+"WithScaling"+File.separator;
	File.makeDirectory(dirOUT);
}
//Remove channels that are "none"
strings = newArray(chanOne, chanTwo, chanThree, chanFour, chanFive, chanSix);
colours = newArray();
	i = 0;	
   	while (i<strings.length) {
		if (strings[i] == "None") {
			//print("found: "+strings[i]);			
		} else {
			colours = Array.concat(colours, strings[i]);
		}
   		i++;
   	}

//Recurse images in specified folders
list = getFileList(dirIN);
for (i=0; i<list.length; i++) { 
	filename =  dirIN+File.separator+list[i]; 
	savename =  dirOUT+File.separator+list[i];
    if (endsWith(filename, ".nd2")){
    	run("Bio-Formats Importer", "open=["+filename+"] color_mode=Default view=Hyperstack");	
		print("Resaving "+list[i]);
    	// Set colours
    	for (j=0; j<colours.length; j++){
			if (colours[j] !="BrightField"){
				Stack.setChannel(j+1);
				run(colours[j]);
				}
			
			//Create RGB Brightfield image and grayscale
			if (colours[j] =="BrightField"){
				run("Duplicate...", "duplicate channels=1-"+j);
				rename("FL");
				selectWindow(list[i]);
				run("Duplicate...", "duplicate channels="+(j+1)+"-"+(j+3));
				rename("BF");
				Stack.setChannel(1);
				run("Blue");
				Stack.setChannel(2);
				run("Green");	
				Stack.setChannel(3);
				run("Red");
				Stack.setDisplayMode("composite");
				run("Flatten");
				saveAs("tiff", savename+"_BF");
				rename("zBF");
				run("16-bit");
				close(list[i]);
				selectWindow("FL");
				rename(list[i]);
				}
    		}
	    
	    //Merge open images into single image
	    selectWindow(list[i]);
	    getDimensions(width, height, channels, slices, frames);
	    if (channels > 1){
		    run("Split Channels");
		    selectWindow("C1-"+list[i]);
		    }
	    
	    //generate and sort list of open images
	    openArray = newArray(nImages);
	    for (k=0; k<nImages; k++) { 
	 		selectImage(k+1); 
	 		openArray[k] = getTitle(); 
	 		}
	 	Array.sort(openArray);
	 	str = "";
	 	for (l=0; l<openArray.length-1; l++){ 
        	str = str +"c"+(l+1)+"=["+openArray[l]+"] "; 
	 		}
     	str = str +"c"+(l+1)+"=["+openArray[openArray.length-1]+"]"; 
  //print("str= "+str);
	 	
	 	
	  	run("Merge Channels...", ""+str+" create keep");
	    saveAs("tiff", savename);
	    
	    //optional creation of flattened image
	    if (Flatten == "Yes"){
	    	Stack.setDisplayMode("composite");
			run("Flatten");
			saveAs("PNG", savename+"_Merged");
	    }
	    //cleanup
	    run("Close All");
	    count++;
		}
	}
	
//Notify user that script is finished
print(" ");
print("Finished resaving "+count+" Images");

//Script updated by Brenton Cavanagh 20190829
