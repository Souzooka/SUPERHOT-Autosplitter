
 state("SH", "feb52017") {
 	uint kills : "mono.dll", 0x1F3094, 0x62C, 0x200, 0x54, 0x154, 0x0;
 	// realLevelId doesn't seem to have a valid pointer until a level has been entered, but can be used to track level changes.
 	ushort realLevelId : "mono.dll", 0x1F3094, 0x62C, 0x200, 0x54, 0x154, 0x14;
 	// only useful for starts
 	ushort levelId : "mono.dll", 0x1F3094, 0x784, 0xEDC, 0x704, 0x894, 0x10;
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
 	
 }
 
 split {
 	if (current.realLevelId != old.realLevelId && current.realLevelId != 54144 && old.realLevelId != 54144 && current.realLevelId != 0 && old.realLevelId != 0) {
 		print(current.realLevelId.ToString());
 		print(old.realLevelId.ToString());
 		return true;
 	}
 }