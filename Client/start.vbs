set ws=WScript.CreateObject("WScript.Shell") 
Currentpath = CreateObject("Scripting.FileSystemObject").GetFile(Wscript.ScriptFullName).ParentFolder.Path
fullPath = Currentpath &"\bin\main.bat"
ws.Run fullPath,0