
 state("SH", "feb52017") {

 }

 // mono.mono_set_defaults+22C9
 // goes to code 0x500 off start of module, module size 0xF1000
 // 0x53F offset, call code we want
 // goes to code in module we want, 0x5A8 from start, module size 0x5F000
 // 



 startup
 {
 	vars.watchers = new MemoryWatcherList();
 }

 init
 {
	vars.killsTarget = new SigScanTarget(2,
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

	vars.killsCodeAddr = (IntPtr)0;

	// "380" is main menu
	vars.levelHexTrim = "380";
	vars.levelHexTrimOld = "placeholder";
	vars.levelHexTrimCurrent = "placeholder";
	vars.levelHexTrimCore = "placeholder";
 }
 
 start {

 }

 update
 {
 	if (vars.killsCodeAddr == IntPtr.Zero) {
 		foreach (var page in memory.MemoryPages()) {
			var bytes = memory.ReadBytes(page.BaseAddress, (int)page.RegionSize);
			if (bytes == null) {
				continue;
			}
			var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
			vars.killsCodeAddr = scanner.Scan(vars.killsTarget); 
		
			//print(String.Format("0x{0:X} {1} {2} {3}", (long)page.BaseAddress, page.RegionSize, page.Protect, page.Type));
			if (vars.killsCodeAddr != IntPtr.Zero) {
				print("found at 0x" + vars.killsCodeAddr.ToString("X"));
				// Finally
				print("kills address:" + memory.ReadValue<int>((IntPtr)vars.killsCodeAddr).ToString("X"));
				vars.killsAddr = memory.ReadValue<int>((IntPtr)vars.killsCodeAddr);
				print("levelID address:" + ((IntPtr)vars.killsAddr + 0x14).ToString("X"));
				vars.levelIDAddr = ((IntPtr)vars.killsAddr + 0x14);

				vars.killsValue = new MemoryWatcher<int>((IntPtr)vars.killsAddr);
				vars.levelIDValue = new MemoryWatcher<int>((IntPtr)vars.levelIDAddr);


				vars.watchers.Clear();
				vars.watchers.AddRange(new MemoryWatcher[]
				{
					vars.killsValue,
					vars.levelIDValue
				});

				break;
			}
		}
 	}

 	vars.watchers.UpdateAll(game);
 }

 exit
 {
 	timer.IsGameTimePaused = false;
 	vars.killsAddr = IntPtr.Zero;
 }
 
 split {
	if (vars.levelIDValue.Current != vars.levelIDValue.Old && vars.levelIDValue.Old != 0) {

		if (vars.levelIDValue.Old != 0) {
	 	 	vars.levelHexTrimOld = (vars.levelIDValue.Old).ToString("X");
	 		vars.levelHexTrimOld = vars.levelHexTrimOld.Substring(vars.levelHexTrimOld.Length - 3);
	 		print(vars.levelHexTrimOld);
	 	}

 		vars.levelHexTrimCurrent = ((int)vars.levelIDValue.Current).ToString("X");
 		vars.levelHexTrimCurrent = vars.levelHexTrimCurrent.Substring(vars.levelHexTrimCurrent.Length - 3);
 		print(vars.levelHexTrimCurrent.ToString());

 		// kill me now
 		if (vars.levelHexTrimOld == "EE0" || vars.levelHexTrimOld == vars.levelHexTrimCore) {
 			if (vars.levelHexTrimCurrent == "E70" || vars.levelHexTrimCurrent == "380") {
 				return true;
 			}
 			vars.levelHexTrimCore = vars.levelHexTrimCurrent;
 			return false;
 		}


 		// if we enter or leave the main menu
		if (vars.levelHexTrimCurrent == "380" || vars.levelHexTrimOld == "380") {
			return false;
		}
		// Longway transition
		if (vars.levelHexTrimCurrent == "F50") {
			return false;
		}
		// Longway to Core
		if (vars.levelHexTrimOld == "F50" && vars.levelHexTrimCurrent == "EE0") {
			return true;
		}
		// Core's IDs are not stable
		if (vars.levelHexTrimOld == "EE0" || vars.levelHexTrimCurrent == "EE0") {
			return false;
		}
		if (vars.levelHexTrimCurrent == "D90") {
			return false;
		}
		if (vars.levelHexTrimCurrent == "E00") {
			return false;
		}
		return true;
	}

	if (vars.levelHexTrimCurrent == "D90" && vars.killsValue.Current == 1) {
		return true;
	}


 }