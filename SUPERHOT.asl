
 state("SH", "feb52017") {
 	uint kills : "mono.dll", 0x1F5510, 0x8, 0x4E4, 0x424, 0x85C, 0x0;
 	// realLevelId doesn't seem to have a valid pointer until a level has been entered, but can be used to track level changes.
 	ushort realLevelId : "mono.dll", 0x1F5510, 0x8, 0x4E4, 0x424, 0x85C, 0x14;
 	// only useful for starts
 	ushort levelId : 0xF3FEF0, 0x354, 0xF54, 0x7A4, 0x894, 0x10;
 }

 init
 {
	print("modules.First().ModuleMemorySize == " + "0x" + modules.First().ModuleMemorySize.ToString("X8"));

	if (modules.First().ModuleMemorySize == 0x10D0000) {
		version = "feb52017";
	}
 }
 
 start {
   return old.levelId == 54144 && current.levelId == 54032;
 }

 update
 {
 	print(current.realLevelId.ToString());
 }
 
 split {
 	return false;
 }