/*
 * Script written by Brenton Cavanagh 2019 brentoncavanagh@rcsi.ie
 * Purpose: To apply scaling to tiff files captured in leica LAS 
 * from ANX, XML & EAX or TXT calibration files.
 * + the option to also output flattened image in TIF or PNG
 */

#@File (label="Files to resave",style="directory") dir1
#@String(label="Saving location", description="Either save to subfolder or overwrite the original tif files", choices={"Subfolder","Overwrite"},value="Subfolder", style="radioButtonHorizontal") folder

setBatchMode(true);
list = getFileList(dir1);
count = 0;
if(folder == "Overwrite"){
	dir2 = dir1;
}
else {
	dir2 = dir1+File.separator+"WithScaling"+File.separator;
	File.makeDirectory(dir2);
}
Skipped = newArray();
for (i=0; i<list.length; i++) {
	filename = dir1+File.separator+list[i];
	file = list[i];
	if (endsWith(filename, ".tif")){
		open(filename);		
		//run("Bio-Formats Importer", "open=["+filename+"] color_mode=Default view=Hyperstack");
		shortname = File.nameWithoutExtension;
		savename = dir2+shortname;
		fileType = newArray(".anx",".eax",".cal.xml",".txt");
		for (e = 0; e < fileType.length; e++) {
			calname = dir1+File.separator+file+fileType[e];
			ext = fileType[e];
			if (File.exists(calname) == true){
				print("Resaving "+ file);
		    	//extract scaling info
		    	extract(calname, ext); 
		    	e=10;
				}
			if (e == 3){
				Skipped = Array.concat(Skipped, file);
				close();					   	
			}
		}
	}
}
//Print skipped files
if (Skipped.length != 0){
	print("No calibration found, the following "+Skipped.length+" files were skipped");
	Array.print(Skipped);
	print("");
	text = File.open(dir2+"Skipped_Files.txt");
    for (i=0; i<Skipped.length; i++){
      print(text, Skipped[i]);
	}
}
//Notify user that script is finished
print("Finished resaving "+count+" Images");

function extract(calname, ext) {
	s = File.openAsString(calname);
	lines = split(s, "\n");
	for (j=0; j<lines.length; j++) {
		  line = lines[j];
	      if (ext == ".anx" || ext == ".eax"){
	      	if (indexOf(line,"<MetresPerPixel>")!=-1) {
	          	idx1 = indexOf(line, "<MetresPerPixel>");
	            idx2 = indexOf(line, "</MetresPerPixel>");
				value = substring(line, idx1+16, idx2);
				convert(value);
	      		}		
			}
	      else if(ext == ".cal.xml"){
	      	if (indexOf(line,"<XMetresPerPixel>")!=-1) {
	      		idx1 = indexOf(line, "<XMetresPerPixel>");
	            idx2 = indexOf(line, "</XMetresPerPixel>");
				value = substring(line, idx1+17, idx2);
				//convert from exp meters/pixel to micron/pixel
				convert(value);
				}          	
	      	}   
	}
}
	          	          
function convert(value) {
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
		apply(file, scale, savename);
		}
	else{
		 scale = expon*number;
		 print("WARNING! "+scale+" um/pixel, are you sure the scale is correct?");
		}
}			

function apply(file, scale, savename) {
    //Apply scaling    
	selectWindow(file);
	run("Set Scale...", "distance=1 known="+scale+" pixel=1 unit=micron");
	saveAs("tiff", savename);
	close();
	count++;
	}

//Script updated by Brenton Cavanagh 20190829
    
