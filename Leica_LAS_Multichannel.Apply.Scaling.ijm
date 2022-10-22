/*
 * Script written by Brenton Cavanagh 2019 brentoncavanagh@rcsi.ie
 * Purpose: To apply scaling to a folder of multichannel captuers using
 *  leica LAS from ANX, XML & EAX or TXT calibration files.
 * Additionally RGB tiffs will be rearranged and composite images created.
 */


//Script updated by Brenton Cavanagh 20221021

#@File (label="Input Directory",style="directory") dirIN
#@File (label="Save location",style="directory") dirOUT

//Setup
setBatchMode(true);
count = 0;
var skipped = newArray();
var reason = newArray();
n = 0;
run("Clear Results");
run("Close All");
processFiles(dirIN);
saveerrors();
//Notify user that script is finished
print("Finished resaving "+count+" Images");

function processFiles(dir) {
	list = getFileList(dir);
	for (i=0; i<list.length; i++) {
	  if (endsWith(list[i], "/")){
	  		print(list[i]);
	  		folder = replace(list[i], "/", "");
	  		processFiles(""+dir+File.separator+folder);
	      }
	  else {
	    //showProgress(n++, count);
	    processFile(dir, list[i]);
	  }
	}
	mergelambda(dir, folder, list);
}

function processFile(dir, file) {
	if (endsWith(file, ".tif")){
		filename = dir+File.separator+file;
		if (endsWith(file, "_N21.tif") || endsWith(file, "_I3.tif") || endsWith(file, "_GFP.tif") || endsWith(file, "_A.tif")){
			print("Part of a lambda image");
		}			
		
		else if (file == "Overlay_Maximum.tif"){
			print("Skipping Overlay_Maximum.tif image");
		}
		
		else if (endsWith(file, "_EMP.tif")){
			print(filename);
			open(filename);
			shortname = File.nameWithoutExtension;
			savename = dirOUT+File.separator+shortname;
			getDimensions(width, height, channels, slices, frames);	
			if(channels > 1){
				run("Flatten");
			}
			setscale();
			savename = dirOUT+File.separator+folder+"__"+shortname;
			saveimg(savename);
		}
		
		else{
			print(filename);
			open(filename);
			shortname = File.nameWithoutExtension;
			savename = dirOUT+File.separator+shortname;
			getDimensions(width, height, channels, slices, frames);	
			if(channels > 1){
				run("Flatten");
			}
			setscale();
			saveimg(savename);
		}
	}
}

function mergelambda(dir, folder, list){
	print(" ");
	print("Processing lambda in "+folder);
	for (l=0; l<list.length; l++) {
		file = list[l];
		if (endsWith(file, ".tif")){
			filename = dir+File.separator+file;
			if (endsWith(file, "_N21.tif")){
				print(filename);
				open(filename);
				getDimensions(width, height, channels, slices, frames);	
				setscale();
				rename("Red");
				if(channels == 3){
					run("Arrange Channels...", "new=1");
					run("Red");					
				}
				else{
					errortable(folder, file, "Channels missing");
					if(channels > 1){
						run("Flatten");
						selectWindow("Red");
						close();
					}
					run("16-bit");
					run("Red");	
				}
			}			
			
			else if (endsWith(file, "_GFP.tif") || endsWith(file, "_I3.tif")){
				print(filename);
				open(filename);
				getDimensions(width, height, channels, slices, frames);
				setscale();
				rename("Green");
				if(channels == 3){
					run("Arrange Channels...", "new=2");
					run("Green");
				}
				else{
					errortable(folder, file, "Channels missing");
					if(channels > 1){
						run("Flatten");
						selectWindow("Green");
						close();
					}
					run("16-bit");
					run("Green");
				}
			}			
			
			else if (endsWith(file, "_A.tif")){
				print(filename);
				open(filename);
				getDimensions(width, height, channels, slices, frames);	
				setscale();
				rename("Blue");
				if(channels == 3){
					run("Arrange Channels...", "new=3");
					run("Blue");
				}
				else{
					errortable(folder, file, "Channels missing");
					if(channels > 1){
						run("Flatten");
						selectWindow("Blue");
						close();
					}
					run("16-bit");
					run("Blue");
				}
			}
			else{
				print(file+" not part of lamba");
			}
		}
	}
	openArray = newArray(nImages);
	if (openArray.length >= 1){
		run("Tile");
		wait(15);
		for (k=0; k<nImages; k++) { 
			selectImage(k+1); 
			openArray[k] = getTitle(); 
		}
		Array.sort(openArray);
		str = "";
		for (j=0; j<openArray.length-1; j++){ 
		str = str +"c"+(j+1)+"=["+openArray[j]+"] "; 
			}
		str = str +"c"+(j+1)+"=["+openArray[openArray.length-1]+"]";
	
		run("Merge Channels...", ""+str+" create");
		saveAs("tiff", dirOUT+File.separator+folder+".tif");
		run("Close All");
		count++;
	}

}

function setscale(){
	fileType = newArray(".anx",".eax",".cal.xml",".txt");
	if (File.exists(dir+File.separator+".Metadata"+File.separator) == true){
		caldir = dir+File.separator+".Metadata"+File.separator;
		}
	else{
		caldir = dir+File.separator;
		}
	
	//check for calibration file
	for (e = 0; e < fileType.length; e++) {
		calname = caldir+file+fileType[e];
		ext = fileType[e];
		if (File.exists(calname) == true){
			print("Found "+ file + ext);
	    	
	    	//extract scaling info
	    	s = File.openAsString(calname);
			lines = split(s, "\n");
			for (j=0; j<lines.length; j++) {
				  line = lines[j];
				  if (ext == ".anx" || ext == ".eax"){
			      	if (indexOf(line,"<MetresPerPixel>")!=-1) {
			          	idx1 = indexOf(line, "<MetresPerPixel>");
			            idx2 = indexOf(line, "</MetresPerPixel>");
						value = substring(line, idx1+16, idx2);
						if (lengthOf(value) > 1){
							convert(); //convert from exp meters/pixel to micron/pixe;
							}
						else{							
							skipped = Array.concat(skipped, file);
							reason = Array.concat(reason, "Invalid Scale");
							print("Invalid Scale");
							print("");
							close();
							errortable(folder, file, "Invalid Scale");				
							}
						e=10;
						}
			      }
		           else if(ext == ".cal.xml"){
				      	if (indexOf(line,"<XMetresPerPixel>")!=-1) {
				      		idx1 = indexOf(line, "<XMetresPerPixel>");
				            idx2 = indexOf(line, "</XMetresPerPixel>");
							value = substring(line, idx1+17, idx2);
							if (lengthOf(value) > 1){
								convert(); //convert from exp meters/pixel to micron/pixel
								}
							else{								
								skipped = Array.concat(skipped, file);
								reason = Array.concat(reason, "Invalid Scale");
								print("Invalid Scale");
								print("");
								close();
								errortable(folder, file, "Invalid Scale");				
								}
						e=10;		
						}          	
					}   
				}		    	
			}
		}
		
	//no calibration file found
	if (e == 4){
		skipped = Array.concat(skipped, file);
		reason = Array.concat(reason, "Calibration missing");
		print("Resaving "+ file);
		print("Calibration missing");
		print("");
		errortable(folder, file, "Calibration missing");
	}
}

function convert() {
	idx3 = indexOf(value, "E");
	number = substring(value, 0, idx3);
	power = substring(value, idx3+2, idx3+4);
	expon = pow(10, (power));
	sign = substring(value, idx3+1, idx3+2);
	if (sign == "-"){
		scale = ((1/expon)*number)*1000000;
		print("Applying scale: "+scale);
		print("");
		//Apply scaling to image
		run("Set Scale...", "distance=1 known="+scale+" pixel=1 unit=micron");
		}
	else{
		 scale = expon*number;
		 print("WARNING! "+scale+" um/pixel, are you sure the scale is correct?");
		}
}			

function saveimg(savename){
	saveAs("tiff", savename);
	run("Close All");
	count++;
	}

function errortable(folder, file, reasontext){
				print("Error Found");
				skipped = Array.concat(skipped, folder+file);
				reason = Array.concat(reason, reasontext);
				setResult("Folder", nResults, folder);
				setResult("File", nResults-1, file);	
				setResult("Error", nResults-1, reasontext);	
				updateResults();
}

function saveerrors(){
	//Print skipped files
	if (skipped.length != 0){
		print("The following "+skipped.length+" files had errors, please see the error table or errorlog.txt");
		Array.print(skipped);
		print("");
		text = File.open(dirOUT+File.separator+"errorlog.txt");
	    for (i=0; i<skipped.length; i++){
	      print(text, skipped[i]+"\t"+reason[i]);
		}
	}
	else{
		print("No errors found");
	}
}
