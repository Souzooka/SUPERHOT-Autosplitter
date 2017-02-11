
 state("SH", "feb52017") {

 }

 startup
 {
 	vars.watchers = new MemoryWatcherList();

	// ptr: address of the offset (not the start of the instruction!)
	// offsetSize: the number of bytes of the offset
	// remainingBytes: the number of bytes until the end of the instruction (not including the offset bytes)
	vars.ReadOffset = (Func<Process, IntPtr, int, int, IntPtr>)((proc, ptr, offsetSize, remainingBytes) =>
	{
		byte[] offsetBytes;
		if (ptr == IntPtr.Zero || !proc.ReadBytes(ptr, offsetSize, out offsetBytes))
			return IntPtr.Zero;

		int offset;
		switch (offsetSize)
		{
			case 1:
				offset = offsetBytes[0];
				break;
			case 2:
				offset = BitConverter.ToInt16(offsetBytes, 0);
				break;
			case 4:
				offset = BitConverter.ToInt32(offsetBytes, 0);
				break;
			default:
				throw new Exception("Unsupported offset size");
		}
		return ptr + offsetSize + remainingBytes + offset;
	});

	vars.killsTarget = new SigScanTarget(44,
		"8B 0D ?? ?? ?? ??",	// mov ecx,05E1DEB4 ; kills address
		"41",					// inc ecx
		"B8 ?? ?? ?? ??",		// mov eax,05E1DEB4
		"89 08",				// mov [eax],ecx
		"8B 45 08",				// mov eax,[ebp+08]
		"8B 40 54",				// mov eax,[eax+54]
		"83 EC 08",				// sub esp,08
		"68 ?? ?? ?? ??",		// push 05DFEFC0
		"50"					// push eax
		);
 }

 init
 {
 	var module = modules.First();

 	int baseAddress = 0x28CBD000;
 	var baseAddressOffset = Int32.Parse(module.BaseAddress.ToString());
 	baseAddress += baseAddressOffset;
 	var baseAddressPtr = new IntPtr(baseAddress);
	var scanner = new SignatureScanner(game, baseAddressPtr, 0x53000);
	print(scanner.Scan(vars.killsTarget).ToString());
	print(modules.ToString());


	print("modules.First().ModuleMemorySize == " + "0x" + modules.First().ModuleMemorySize.ToString("X8"));

	if (modules.First().ModuleMemorySize == 0x10D0000) {
		version = "feb52017";
	}
 }
 
 start {

 }

 update
 {
 	vars.watchers.UpdateAll(game);
 }

 exit
 {
 	timer.IsGameTimePaused = false;
 }
 
 split {

 }