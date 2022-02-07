/*
 * Script written by Brenton Cavanagh 2018 brentoncavanagh@rcsi.ie
 * Purpose: To open and resave ND2 files from the Nikon Eclipse 90i
 * Define the correct channel colours and save as multipage TIF with
 * the option to also output flattened image in PNG
 */

//Generate user input
#@File (label="Files to resave",style="directory") dirIN
#@File (label="Files to resave",style="directory") dirOUT
#@String(label="Channel one", description="Set colour for channel one", choices={"None","BrightField","Red","Green","Blue","Cyan","Magenta","Yellow","Grays"}, value="None") chanOne
#@String(label="Channel two", description="Set colour for channel two", choices={"None","BrightField","Red","Green","Blue","Cyan","Magenta","Yellow","Grays"}, value="None") chanTwo
#@String(label="Channel three", description="Set colour for channel three", choices={"None","BrightField","Red","Green","Blue","Cyan","Magenta","Yellow","Grays"}, value="None") chanThree
#@String(label="Channel four", description="Set colour for channel four", choices={"None","BrightField","Red","Green","Blue","Cyan","Magenta","Yellow","Grays"}, value="None") chanFour
//#@String(label="Channel five", description="Set colour for channel five", choices={"None","BrightField","Red","Green","Blue","Cyan","Magenta","Yellow","Grays"}, value="None") chanFive
//#@String(label="Channel six", description="Set colour for channel six", choices={"None","BrightField","Red","Green","Blue","Cyan","Magenta","Yellow","Grays"}, value="None") chanSix
//#@String(label="Preview PNG?", description="Save a PNG copy of the image", choices={"Yes","No",},value="No", style="radioButtonHorizontal") Flatten

setBatchMode(true);
count = 0;

//Remove channels that are "none"
//strings = newArray(chanOne, chanTwo, chanThree, chanFour, chanFive, chanSix);
strings = newArray(chanOne, chanTwo, chanThree, chanFour);
colours = newArray();
	c = 0;	
   	while (c<strings.length) {
		if (strings[c] == "None") {
			//print("found: "+strings[i]);			
		} else {
			colours = Array.concat(colours, strings[c]);
		}
   		c++;
   	}

//Recurse images in specified folders
list = getFileList(dirIN);
errors = newArray();
for (i=0; i<list.length; i++) { 
	filename =  dirIN+File.separator+list[i]; 
	savename =  dirOUT+File.separator+list[i];
    if (endsWith(filename, ".nd2")){
    	run("Bio-Formats Importer", "open=["+filename+"] color_mode=Default view=Hyperstack");	
		print("Resaving "+list[i]);
		getDimensions(width, height, channels, slices, frames);

		if (channels >= colours.length) {
					
    	// Set colours
    	for (j=0; j<colours.length; j++){
			if (colours[j] !="BrightField" && channels == 1){
				run(colours[j]);
				}
			else if (colours[j] !="BrightField"){
				Stack.setChannel(j+1)
				run(colours[j]);
				Stack.setDisplayMode("composite");
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
		     	run("Merge Channels...", ""+str+" create keep");
		     	Stack.setDisplayMode("composite");
			}
	    }
	    saveAs("tiff", savename);
	    
	    //cleanup
	    run("Close All");
	    count++;
		}
	else{
		error  = "ERROR: "+ channels + " channels found, " + colours.length + " colours assigned -- skipping";
		print(error);
		errors =  Array.concat(errors, list[i]);
		run("Close All");
		}
	}
}

if (errors.length != 0){
		print(" ");
		print("The following "+errors.length+" files were skipped, please see reasons in the log above.");
		Array.print(errors);
		}
	
//Notify user that script is finished
print(" ");
print("Finished resaving "+count+" Images");

//Script updated by Brenton Cavanagh 20220120
