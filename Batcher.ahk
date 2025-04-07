; ��������������ִ�� (GUI)
#SingleInstance Force
#NoTrayIcon

AppName := "Batcher"
AppVer := "1.2.2"
AppCopyRight := "Copyright (c) 2025 CataeroGong"
IniFile := A_ScriptDir . "\" . A_ScriptName . ".ini"


PH := "$$$" ; PlaceHolder

ST_N := "*" ; new
ST_R := "#" ; running
ST_P := "=" ; pause
ST_E := "." ; end
ST_X := "X" ; error

FLAG_STOP := true
RND := 0

;-----------------------------------------------------
; ������
Main:
{
	Gosub, InitGUI
	Gosub, LoadCfg
	Gosub, LoadTasks
	Return
}

SetEditCueBanner(HWND, Cue)
{
	Static EM_SETCUEBANNER := (0x1500 + 1)
	Return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
}

InitGUI:
{
	Gui, 1:New, +OwnDialogs, %AppName% v%AppVer%
	Gui, Add, Text, xm ym, ����ִ��·��
	Gui, Add, Edit, xm y+m w800 vEdtDir hwndHwndEdtDir
	Gui, Add, Text, xm y+m, ����ģ�壨ģ����ʹ��
	Gui, Add, Edit, x+1 yp-3 h20 w50 vEdtPH gOnEdtPH, %PH%
	Gui, Add, Text, x+1 yp+3, �����������λ�ã����������е��������ظ������������޸ģ�
	Gui, Add, Edit, xm y+m w800 vEdtCmd
	Gui, Add, Text, xm y+m, ����������������У�ÿ����������һ�����
	Gui, Add, Edit, xm y+m r5 w800 -Wrap +HScroll vEdtParam gOnEdtParam
	Gui, Add, Button, xm y+m gOnBtnAdd, �� ������� ��
	Gui, Add, Checkbox, x+20 yp h24 vChkClipboard gOnChkClipboard, ��ؼ����壨ʵʱ���أ�������������������Ϊ�����Զ������������ռ����塣�����������ɶ������
	Gui, Add, GroupBox, xm y+m h1 w800
	Gui, Add, ListView, xm y+10 r10 w800 AltSubmit Grid NoSort -Multi NoSortHdr -LV0x10 vLstCmds gOnLstCmds, ״̬|����|·��|��Ϣ
	LV_ModifyCol(2, 400)
	LV_ModifyCol(3, 300)
	LV_ModifyCol(4, 200)
	Gui, Add, Text, xm y+m, ��״̬˵����"%ST_N%":�ȴ�ִ�� "%ST_R%":����ִ�� "%ST_P%":�ݲ�ִ�� "%ST_E%":ִ����� "%ST_X%":��������
	Gui, Add, Text, xm y+10,���������Ҽ�:�ݲ�ִ�� ˫��:�ȴ�ִ�� �Ҽ�˫��:ִ����� Ctrl+����:�༭����
	Gui, Add, Button, x+20 yp-5 gOnBtnSetAll vBtnSetAll, ȫ����Ϊ
	Gui, Add, DropDownList, x+1 yp w80 vDdlTaskState, �ȴ�ִ��||�ݲ�ִ��|ִ�����
	Gui, Add, Button, x+20 yp gOnBtnClrDone vBtnClrDone, �����ִ��
	Gui, Add, Button, x+m yp gOnBtnClrAll vBtnClrAll, ��ն���
	Gui, Add, GroupBox, xm y+m h1 w800
	Gui, Add, Text, xm y+15, ����ڴ�С
	Gui, Add, DropDownList, x+1 yp-3 w50 vDdlWinSize, -|Min||Max|Hide
	Gui, Add, Checkbox, x+m yp h24 vChkParallel, ����ִ��
	Gui, Add, Button, x+m yp gOnBtnStart vBtnStart, ִ�ж���
	Gui, Add, Button, x+m yp Disabled gOnBtnStop vBtnStop, ִֹͣ��
	Gui, Add, Button, x1 y1 Hidden h20 w20 gOnBtnAbout vBtnAbout, i
    Gui, Add, StatusBar
    SB_SetParts(50, 500)
	ShowProcess()

	GuiControlGet, lst, Pos, LstCmds
	GuiControlGet, btn, Pos, BtnAbout
	GuiControl, Move, BtnAbout, % "x" . (lstX + lstW - btnW) . " ym"
	GuiControl, Show, BtnAbout
	Gui, Show

	SetEditCueBanner(HwndEdtDir, A_WorkingDir)

	Return
}

LoadCfg:
{
	IniRead, s, %IniFile%, %AppName%, Dir, %A_Space%
	GuiControl, , EdtDir, %s%
	IniRead, s, %IniFile%, %AppName%, Cmd, %A_Space%
	GuiControl, , EdtCmd, %s%
	IniRead, s, %IniFile%, %AppName%, PlaceHolder, %PH%
	GuiControl, , EdtPH, %s%
	IniRead, s, %IniFile%, %AppName%, WinSize, Min
	GuiControl, ChooseString, DdlWinSize, %s%
	IniRead, s, %IniFile%, %AppName%, Parallel, 0
	GuiControl, , ChkParallel, %s%
	Return
}
SaveCfg:
{
	GuiControlGet, s, , EdtDir
	IniWrite, %s%, %IniFile%, %AppName%, Dir
	GuiControlGet, s, , EdtPH
	IniWrite, %s%, %IniFile%, %AppName%, PlaceHolder
	GuiControlGet, s, , EdtCmd
	IniWrite, %s%, %IniFile%, %AppName%, Cmd
	GuiControlGet, s, , DdlWinSize
	IniWrite, %s%, %IniFile%, %AppName%, WinSize
	GuiControlGet, s, , ChkParallel
	IniWrite, %s%, %IniFile%, %AppName%, Parallel
	Return
}

OnEdtPH:
{
	GuiControlGet, PH, , EdtPH
}

PackTask(st, cmd, dir)
{
	Return ("__ST__ " . st . " __CMD__ " . cmd . " __DIR__ " . dir . " __END__")
}
UnpackTask(ini_kv_str) ;  1=__ST__ * __CMD__ cmd.exe /c echo OK __DIR__ C:\
{
	obj := {idx:"", st:"", cmd:"", dir:""}
	p := RegExMatch(ini_kv_str, "O)^(?<idx>\d+)=__ST__ (?<st>.) __CMD__ (?<cmd>.+) __DIR__ (?<dir>.*) __END__$", mo)
	obj.idx := mo["idx"]
	obj.st := mo["st"]
	obj.cmd := mo["cmd"]
	obj.dir := mo["dir"]
	Return obj
}
SaveTasks:
{
	IniDelete, %IniFile%, %AppName%.Tasks
	Loop % LV_GetCount()
	{
		LV_GetText(st, A_Index, 1)
		LV_GetText(cmd, A_Index, 2)
		LV_GetText(dir, A_Index, 3)
		IniWrite, % PackTask(st ,cmd, dir), %IniFile%, %AppName%.Tasks, %A_Index%
	}
	Return
}
LoadTasks:
{
	LV_Delete()
	If FileExist(IniFile)
	{
		IniRead, s, %IniFile%, %AppName%.Tasks
		Loop, Parse, s, `n
		{
			t := UnpackTask(A_LoopField)
			if (t.cmd)
				LV_Add(, t.st, t.cmd, t.dir)
		}
	}
	Return
}

NewTask(dir, cmd, param)
{
	Global PH, IniFile, AppName, ST_N
	if (cmd && param)
	{
		if (!dir)
			dir := A_WorkingDir
		cmd := StrReplace(cmd, PH, param)
		idx := LV_Add(, ST_N, cmd, dir)
		Return true
	}
	Return false
}

NewTasks(params)
{
	GuiControlGet, dir, , EdtDir
	GuiControlGet, cmd, , EdtCmd
	cnt := 0
	Loop, Parse, params, `n, `r`t%A_Space%
	{
		If (NewTask(dir, cmd, A_LoopField))
			cnt ++
	}
	Return cnt
}
OnEdtParam:
{
	If (GetKeyState("Ctrl") && GetKeyState("Enter"))
	{
		Gosub, OnBtnAdd
	}
	Return
}
OnBtnAdd:
{
	GuiControlGet, param, , EdtParam
	NewTasks(param)
	GuiControl, , EdtParam,
	GuiControl, Focus, EdtParam
	Return
}

MonitorClipboard:
{
	ToolTip, %AppName% ���ڼ�ؼ�����
	If (Clipboard)
	{
		cnt := NewTasks(Clipboard)
		Clipboard := ""
		If (cnt)
		{
			ToolTip, �½� %cnt% ������
		}
	}
	Return
}
OnChkClipboard:
{
	Clipboard := ""
	GuiControlGet, cb, , ChkClipboard
	If (cb)
	{
		SetTimer, MonitorClipboard
	}
	Else
	{
		SetTimer, MonitorClipboard, Off
		ToolTip
	}
	Return
}

OnBtnClrDone:
{
	idx := 1
	Loop % LV_GetCount()
	{
		LV_GetText(st, idx, 1)
		If (st != ST_N && st != ST_P)
		{
			LV_Delete(idx)
			st := ""
		}
		Else
			idx += 1
	}
	Gosub, SaveTasks
	Return
}
OnBtnClrAll:
{
	LV_Delete()
	Gosub, SaveTasks
	Return
}
OnBtnSetAll:
{
	GuiControlGet, st, , DdlTaskState
	Switch (st)
	{
		Case "�ȴ�ִ��":
			st := ST_N
		Case "�ݲ�ִ��":
			st := ST_P
		Case "ִ�����":
			st := ST_E
		Default:
			st := ""
	}
	If (st)
	{
		Loop % LV_GetCount()
		{
			LV_Modify(A_Index, "Col1", st)
		}
		Gosub, SaveTasks
	}
	Return
}
ShowCmdEditWin(idx)
{
	Global W3EdtIdx, W3EdtDir, W3EdtCmd
	If (idx > 0)
	{
		LV_GetText(cmd, idx, 2)
		LV_GetText(dir, idx, 3)
		Gui, 3:New, +Owner +ToolWindow +Border
		Gui, 3:Add, Text, Hidden Disabled vW3EdtIdx, %idx%
		Gui, 3:Add, Text, xm ym, ִ��·��
		Gui, 3:Add, Edit, xm y+m w600 vW3EdtDir
		Gui, 3:Add, Text, xm y+m, ����
		Gui, 3:Add, Edit, xm y+m w600 vW3EdtCmd
		Gui, 3:Add, Button, xm y+m, Ok
		Gui, 3:Add, Button, x+m yp, Cancel
		Gui, 1:+Disabled
		Gui, 3:Show, AutoSize, �༭����
		GuiControl, 3:, W3EdtDir, %dir%
		GuiControl, 3:, W3EdtCmd, %cmd%
		GuiControl, 3:Focus, W3EdtCmd
	}
	Return WinActive("A")
}
3ButtonOk:
{
	GuiControlGet, idx, 3:, W3EdtIdx
	GuiControlGet, dir, 3:, W3EdtDir
	GuiControlGet, cmd, 3:, W3EdtCmd
	Gui, 1:Default
	LV_Modify(idx, "Col2", cmd)
	LV_Modify(idx, "Col3", dir)
	Gosub, 3GuiClose
	Return
}
3GuiClose:
3GuiEscape:
3ButtonCancel:
{
	Gui, 1:-Disabled
	Gui, 3:Destroy
	Return
}
OnLstCmds:
{
	If (A_EventInfo)
	{
		LV_GetText(st, A_EventInfo, 1)
		Switch A_GuiEvent
		{
			Case "DoubleClick":  ; ��Ϊ���ȴ�ִ�С�
				If (st == ST_P || st == ST_E || st == ST_X)
					st := ST_N
				Else
					st := ""
			Case "RightClick":  ; ���ȴ�ִ�С�������Ϊ���ݲ�ִ�С�
				If (st == ST_N || st == ST_X)
					st := ST_P
				Else
					st := ""
			Case "R":  ; ��Ϊ��ִ����ϡ�
				If (st == ST_N || st == ST_P || st == ST_X)
					st := ST_E
				Else
					st := ""
			Case "Normal":
				If (GetKeyState("Ctrl") && st != ST_R)
				{
					LV_Modify(A_EventInfo, "Col1", ST_P)
					WinWaitClose, % "ahk_id " . ShowCmdEditWin(A_EventInfo)
					Gui, 1:Default
					LV_Modify(A_EventInfo, "Col1", st)
					st := ""
				}
			Default:
				st := ""
		}
		If (st)
		{
			LV_Modify(A_EventInfo, "Col1", st)
		}
	}
	Return
}

ShowRunning(running := true)
{
	Global RND, ST_R, ST_E
	If (running)
		RND ++
	SB_SetText((running ? ST_R : ST_E) . "R:" . RND, 1)
}
ShowProcess(cmd:="", dir:="")
{
	SB_SetText("CMD: " . cmd, 2)
	SB_SetText("DIR: " . dir, 3)
}
Worker()
{
	Global FLAG_STOP, IniFile, AppName, ST_N, ST_R, ST_P, ST_E, ST_X
	If (!FLAG_STOP)
	{
		ShowRunning(true)
		GuiControl, Disable, BtnStart
		GuiControl, Disable, BtnClrDone
		GuiControl, Disable, BtnClrAll
		GuiControl, Disable, BtnSetAll
		GuiControl, Disable, DdlTaskState
		GuiControl, Disable, DdlWinSize
		GuiControl, Disable, ChkParallel
		GuiControl, Enable, BtnStop
	}
	GuiControlGet, winsize, , DdlWinSize
	GuiControlGet, parallel, , ChkParallel
	If (winsize == "-")
		winsize := ""
	need_save := false
	Loop % LV_GetCount()
	{
		If (FLAG_STOP)
			Break
		LV_GetText(st, A_Index, 1)
		If (st == ST_N)
		{
			LV_GetText(cmd, A_Index, 2)
			LV_GetText(dir, A_Index, 3)
			st := ST_R
			LV_Modify(A_Index, "Col1", st)
			LV_Modify(A_Index, "Col4", "")
			ShowProcess(cmd, dir)
			If (dir)
			{
				d := FileExist(dir)
				If (!d)
				{
					LV_Modify(A_Index, "Col4", "ִ��·�������ڣ��Զ�����")
					FileCreateDir, %dir%
					d := FileExist(dir)
				}
			}
			Else
			{
				d := "D"
			}
			If (InStr(d, "D"))
			{
				Try
				{
					If (parallel)
						Run, %cmd%, %dir%, %winsize%
					Else
						RunWait, %cmd%, %dir%, %winsize%
					st := ST_E
				}
				Catch e
				{
					LV_Modify(A_Index, "Col4", "��������" . e.Message . " " . e.Extra)
					st := ST_X
				}
			}
			Else
			{
				LV_Modify(A_Index, "Col4", "ִ��·������һ��Ŀ¼")
				st := ST_X
			}
			LV_Modify(A_Index, "Col1", st)
			ShowProcess()
			need_save := true
			Sleep, 100
		}
	}
	If (FLAG_STOP)
	{
		GuiControl, Disable, BtnStop
		GuiControl, Enable, BtnStart
		GuiControl, Enable, BtnClrDone
		GuiControl, Enable, BtnClrAll
		GuiControl, Enable, BtnSetAll
		GuiControl, Enable, DdlTaskState
		GuiControl, Enable, DdlWinSize
		GuiControl, Enable, ChkParallel
	}
	If (need_save)
		Gosub, SaveTasks
	ShowRunning(false)
}

OnBtnStart:
{
	FLAG_STOP := false
	RND := 0
	Worker()
	If (!FLAG_STOP)
		SetTimer, Worker, 1000
	Return
}
OnBtnStop:
{
	FLAG_STOP := true
	Worker()
	SetTimer, Worker, Off
	Return
}

GuiClose:
{
	Gosub, OnBtnStop
	Gosub, SaveCfg
	Gosub, SaveTasks
	ExitApp
	Return
}

;------------------------------------------------------------------------------
; About
OnBtnAbout:
{
	Gui, 1:+OwnDialogs
	Gui, ABOUT:+Owner +ToolWindow
	Gui, ABOUT:Font, Bold
	Gui, ABOUT:Add, Text, , %AppName% v%AppVer%
	Gui, ABOUT:Font
	Gui, ABOUT:Add, Text, , %AppCopyRight%
	Gui, ABOUT:Add, Text, ,

	Gui, ABOUT:Show, , About

	Gui, 1:+Disabled

	return
}
ABOUTGuiClose:
ABOUTGuiEscape:
{
	Gui, 1:-Disabled
	Gui, ABOUT:Destroy
	return
}
