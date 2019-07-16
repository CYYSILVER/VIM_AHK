#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


  
; Ini file
; 光标向左移动
IniDir_ := A_WorkingDir
Ini_ := IniDir_ . "\silverAHKBind.ini"
Section_ := "Include Window"

; Application groups {{{
GroupDelimiter := ","
GroupN := 0

; Enable _ mode for following applications
DefaultAcWindows :=                             "ahk_exe notepad.exe"   ; NotePad
DefaultAcWindows := DefaultAcWindows . GroupDelimiter . "ahk_exe wordpad.exe"   ; WordPad
DefaultAcWindows := DefaultAcWindows . GroupDelimiter . "ahk_exe TeraPad.exe"   ; TeraPad
DefaultAcWindows := DefaultAcWindows . GroupDelimiter . "ahk_exe POWERPNT.exe"  ; PowerPoint
DefaultAcWindows := DefaultAcWindows . GroupDelimiter . "ahk_exe WINWORD.exe"   ; Word
DefaultAcWindows := DefaultAcWindows . GroupDelimiter . "ahk_exe Evernote.exe"  ; Evernote
DefaultAcWindows := DefaultAcWindows . GroupDelimiter . "ahk_exe onenote.exe"   ; OneNote Desktop
DefaultAcWindows := DefaultAcWindows . GroupDelimiter . "OneNote"               ; OneNote in Windows 10
DefaultAcWindows := DefaultAcWindows . GroupDelimiter . "ahk_exe texworks.exe"  ; TexWork
DefaultAcWindows := DefaultAcWindows . GroupDelimiter . "ahk_exe texstudio.exe" ; TexStudio
DefaultAcWindows := DefaultAcWindows . GroupDelimiter . "ahk_class TXGuiFoundation"



; 读取配置文件
GroupKey := "WindowGroup"
Group_ := Utility.readIni(Section_, GroupKey)
GroupName := "Group_" . GroupN

IconVim := A_WorkingDir . "\icons\vim.ico"
IconDisabled := A_WorkingDir . "\icons\disabled.ico"
Loop, Parse, % Group_, % GroupDelimiter
{
  if(A_LoopField != ""){
    GroupAdd, %GroupName%,  %A_LoopField%
  }
}
SetTimer, StatusCheckTimer, 1000

; 创建Setting菜单
Menu, Tray, Tip, SILVER'S LIKE_ SHORTCUT
Menu, Tray, Add
Menu, Tray, Add, Settings, SettingsHandler
return

StatusCheckTimer: 
  if WinActive("ahk_group" . GroupName) {
      Menu, Tray, Icon, %IconVim%
  } else {
      Menu, Tray, Icon, %IconDisabled%
  }
return

SettingsHandler:
  ; 为菜单栏创建子菜单:
  ; Gui, Settings:+Resize
  Content := Utility.readIni(Section_, GroupKey)
  Gosub, DecodeText
  Gui, Settings:Add, Text, w400, 要更改要启用本程序的窗口，请在下面添加或删除
  Gui, Settings:Add, Edit, r20 vContent w400, % Content
  Gui, Settings:Add, Button, Default, 保存
  Gui, Settings:Add, Button, Default, 重置
  Gui, Settings:Show
  ; MsgBox, % Content 
  return

  SettingsGuiClose:
    MsgBox, 3,, 是否保存退出？
    
    IfMsgBox, Yes 
    {
      Gui, Submit, NoHide
      Gosub, WriteTextToFile
      Gui, Destroy
    }
    else IfMsgBox, No
    {
      Gui, Destroy
    }
    else
    {
      ; donothing
    }
  return 

  SettingsButton保存:
    Gui, Submit, NoHide
    Gosub, WriteTextToFile
  return 
  
  SettingsButton重置:
    MsgBox, 1, , 是否回复配置文件为默认值?
    IfMsgBox, Ok
    {
      Content := DefaultAcWindows
      Gosub, DecodeText
      Gosub, WriteTextToFile 
    } 
  return 

  DecodeText:
    SettingsTmpText := ""
    Loop, Parse, % Content, % GroupDelimiter
    {
       SettingsTmpText := SettingsTmpText . A_LoopField . "`n"
    }
    Content := SettingsTmpText
  return

  EncodeText: 
    ; 移除掉前后的回车
    Content := Trim(Content, " `n`t")
    SettingsTmpText := ""
    Loop, Parse, % Content, `n
    {
      SettingsTmpText := SettingsTmpText . Trim(A_LoopField) . GroupDelimiter
    }
  return 

  WriteTextToFile:
    GuiControl, Text, Content, % Content
    Gosub, EncodeText 
    Utility.writeIni(Section_, GroupKey, SettingsTmpText) 
  return 
Return




; 定时器，用于定期更新图标
; 根据窗口选则是否启动
#If WinActive("ahk_group" . GroupName)
; 光标向下移动
!j::
send, {Down}
return

; 光标向上移动
!k::
send, {Up}
return

!h:: 
send, {Left}
return

; 光标向右移动
!l::
send, {Right}
return

; 进入normal模式 (vim)
!n::
send, {Esc}
return 

; 进入visual模式 (vim)
!i::
send, {Esc}
send, {v}
return 

; 向左移动一个词
!,::
send, ^{Left}
return

; 向右移动一个词
!.::
send, ^{Right}
return

; 向左移动一个词
!b::
send, ^{Left}
return

; 向右移动一个词
!e::
send, ^{Right}
return

; 开启功能键
^k::
return 

; Home
^h::
  if (Utility.IslAstHotKey("^k")) {
    Send, {Home}
  }
return
; End
^l::
  if (Utility.IsLastHotKey("^k")) {
    Send, {End}
  }
return


class Utility {

  static CtrlKPressedTimeout := 800
  isLastHotkey(key)
  {
      return (A_PriorHotkey == key and A_TimeSincePriorHotkey < this.CtrlKPressedTimeout)
  }

  readIni(Section, Key) {
    global
    OutputVar := ""
    if FileExist(Ini_) {
      IniRead, OutputVar,  % Ini_, % Section, % Key
      return Trim(OutputVar, ",") 
    } else {
      MsgBox, 未检测到配置文件，已创建配置文件在 %Ini_%
      IniWrite, % Key . "=", % Ini_, % Section 
      return OutputVar 
    }
  }

  writeIni(Section, Key, Value) {
    global Ini_
    IniWrite, % Value, % Ini_, % Section, % Key 
  }
}