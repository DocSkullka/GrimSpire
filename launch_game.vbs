Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "D:\GrimSpire"
WshShell.Run """D:\GrimSpire\GrimSpire.exe"" --path ""D:\GrimSpire""", 1, False
