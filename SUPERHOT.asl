
 state("SH", "feb52017") {
 	uint kills : "mono.dll", 0x1F5510, 0x8, 0x4E4, 0x424, 0x85C, 0x0;
 }

 init
 {
	print("modules.First().ModuleMemorySize == " + "0x" + modules.First().ModuleMemorySize.ToString("X8"));

	if (modules.First().ModuleMemorySize == 0x10D0000) {
		version = "feb52017";
	}
 }
 
 start {
   
 }

 update
 {

 }
 
 split {
 	return false;
 }