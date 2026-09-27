Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "D:\GrimSpire"
WshShell.Run """D:\GrimSpire\GrimSpire.exe""", 1, False
