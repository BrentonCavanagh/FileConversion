//Input and output directory
#@File (label="Files to analyse",style="directory") dir1
#@String(label="File type", choices={".png",".tif",},value=".tif") FileType
#@String(label="Create Cropped Image", description="Removes the text below the image", choices={"Yes","No",},value="Yes", style="radioButtonHorizontal") Cropped
#@String(label="Create CLAHE Image", description="Creates a enhanced local contrast image", choices={"Yes","No",},value="No", style="radioButtonHorizontal") CLAHE
//Count number of images processed
count = 0;

list = getFileList(dir1);
setBatchMode(true);

//List of scales
List.set("700", "0.007882");
List.set("1000", "0.0112605");
List.set("1200", "0.013513");
List.set("1500", "0.016891");
List.set("2000", "0.022521");
List.set("2500", "0.028151");
List.set("3000", "0.033782");
List.set("4000", "0.045042");
List.set("5000", "0.056303");
List.set("6000", "0.067563");
List.set("7000", "0.078824");
List.set("8000", "0.090084");
List.set("10000", "0.112605");
List.set("12000", "0.135126");
List.set("15000", "0.168908");
List.set("20000", "0.22521");
List.set("25000", "0.281513");
List.set("30000", "0.337815");
List.set("40000", "0.45042");
List.set("50000", "0.563026");
List.set("60000", "0.675631");
List.set("70000", "0.788236");
List.set("80000", "0.900841");
List.set("100000", "1.126");
List.set("120000", "1.351");
List.set("150000", "1.689");
List.set("200000", "2.252");

// List.get("25000"); 
   
//Loop through files names in Source folder
for (i=0; i<list.length; i++) {
	filename =  dir1+File.separator+list[i];
	
	if (endsWith(filename, FileType)){
		run("Bio-Formats Importer", "open=["+filename+"] color_mode=Default view=Hyperstack");
 	 	mag = getInfo("Magnification");
 	 	title = getInfo("Sample Name");
 	 	//faulty file names fix
 	 	//title = replace(title, "\\W", "");
 	 	print(title);
 	 	name = File.nameWithoutExtension;
 	 	savename =  dir1+File.separator+name;
 	 	print(name+" magnification = " + mag);
	 	run("Set Scale...", "distance="+List.get(mag)+" known=1 pixel=1 unit=nm");
		saveAs("tiff", filename);
		if (Cropped == "Yes"){
			makeRectangle(0, 0, 1696, 1696);
			run("Crop");
			saveAs("tiff", dir1+File.separator+title+"_"+mag+"x_"+name);
		}
		if (CLAHE == "Yes"){
			run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=2.50 mask=*None* fast_(less_accurate)");
			saveAs("tiff", dir1+File.separator+title+"_"+mag+"x_"+name+"_CLAHE");
		}
		close();
		count++;
	}
}
//Notify user that script is finished
Notification = "Finished resaving "+count+" Images";
#@OUTPUT String  Notification

//Script updated by Brenton Cavanagh 20180704