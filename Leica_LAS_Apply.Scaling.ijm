/*
 * Script written by Brenton Cavanagh 2019 brentoncavanagh@rcsi.ie
 * Purpose: To apply scaling to tiff files captured in leica LAS 
 * from ANX, XML & EAX or TXT calibration files.
 * + the option to also output flattened image in TIF or PNG
 */

#@File (label="Files to resave",style="directory") dir1
#@String(label="Saving location", description="Either save to subfolder or overwrite the original tif files", choices={"Subfolder","Overwrite"},value="Subfolder", style="radioButtonHorizontal") folder

//setup
setBatchMode(true);
list = getFileList(dir1);
count = 0;
skipped = newArray();
reason = newArray();

if(folder == "Overwrite"){
	print("Overwrite set");
	dir2 = dir1;
}
else {
	print("Subfolder set");
	dir2 = dir1+File.separator+"WithScaling"+File.separator;
	File.makeDirectory(dir2);
}

//Start of process
for (i=0; i<list.length; i++) {
	filename = dir1+File.separator+list[i];
	file = list[i];
	if (endsWith(filename, ".tif")){
		open(filename);		
		//run("Bio-Formats Importer", "open=["+filename+"] color_mode=Default view=Hyperstack");
		shortname = File.nameWithoutExtension;
		savename = dir2+File.separator+shortname;
		fileType = newArray(".anx",".eax",".cal.xml",".txt");
		if (File.exists(dir1+File.separator+".Metadata"+File.separator) == true){
			caldir = dir1+File.separator+".Metadata"+File.separator;
			}
		else{
			caldir = dir1+File.separator;
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
									}
							e=10;		
							}          	
						}   
					}		    	
				}
			}
		//no calibration file found
		if (e == 3){
			skipped = Array.concat(skipped, file);
			reason = Array.concat(reason, "Calibration missing");
			print("Resaving "+ file);
			print("Calibration missing");
			print("");
			close();
			}
		}
	}

saveerrors();

//Notify user that script is finished
print("Finished resaving "+count+" Images");

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
		//Apply scaling to image and save
		apply();
		}
	else{
		 scale = expon*number;
		 print("WARNING! "+scale+" um/pixel, are you sure the scale is correct?");
		}
}			

function apply() {
    //Apply scaling    
	selectWindow(file);
	run("Set Scale...", "distance=1 known="+scale+" pixel=1 unit=micron");
	saveAs("tiff", savename);
	close();
	count++;
	}

function saveerrors(){
	//Print skipped files
	if (skipped.length != 0){
		print("The following "+skipped.length+" files were skipped, please see errorlog.txt");
		Array.print(skipped);
		print("");
		text = File.open(dir2+"errorlog.txt");
	    for (i=0; i<skipped.length; i++){
	      print(text, skipped[i]+"\t"+reason[i]);
		}
	}
}

//Script updated by Brenton Cavanagh 20190830
    
