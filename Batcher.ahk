; ��������������ִ�� (GUI)
#SingleInstance Force

AppName := "Batcher"
AppVer := "1.1.0"
AppCopyRight := "Copyright (c) 2025 CataeroGong"
IniFile := A_ScriptDir . "\" . A_ScriptName . ".ini"


PH := "$$$" ; PlaceHolder

ST_N := "*" ; new
ST_R := "#" ; running
ST_P := "=" ; pause
ST_E := "." ; end

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

InitGUI:
{
	Gui, Add, Text, xm ym, ����ִ��·��
	Gui, Add, Edit, xm y+m w800 vEdtDir
	Gui, Add, Text, xm y+m, ����ģ�壨ģ����ʹ��
	Gui, Add, Edit, x+1 yp-3 h20 w50 vEdtPH gOnEdtPH, %PH%
	Gui, Add, Text, x+1 yp+3, �����������λ�ã����������е��������ظ������������޸ģ�
	Gui, Add, Edit, xm y+m w800 vEdtCmd
	Gui, Add, Text, xm y+m, ����
	Gui, Add, Edit, xm y+m w800 vEdtParam
	Gui, Add, Button, xm y+m Default gOnBtnAdd, �� ������� ��
	Gui, Add, Checkbox, x+20 yp h24 vChkClipboard gOnChkClipboard, ��ؼ����壨ʵʱ���أ�������������������Ϊ�����Զ������������ռ����塣�����������ɶ������
	Gui, Add, Text, xm y+m, ��״̬˵����"%ST_N%":�ȴ�ִ�� "%ST_R%":����ִ�� "%ST_P%":�ݲ�ִ�� "%ST_E%":ִ�����
	Gui, Add, ListView, xm y+m r10 w800 AltSubmit Grid NoSort -Multi NoSortHdr -LV0x10 vLstCmds gOnLstCmds, ״̬|����|·��
	LV_ModifyCol(2, 500)
	LV_ModifyCol(3, 400)
	Gui, Add, Text, xm y+10, �Ҽ�:�ݲ�ִ�� ˫��:�ȴ�ִ�� �Ҽ�˫��:ִ����� Ctrl+����:�༭����
	Gui, Add, Button, x+20 yp-5 gOnBtnSetAll vBtnSetAll, ȫ����Ϊ
	Gui, Add, DropDownList, x+1 yp w80 vDdlTaskState, �ȴ�ִ��||�ݲ�ִ��|ִ�����
	Gui, Add, Button, x+100 yp gOnBtnClrDone vBtnClrDone, �����ִ��
	Gui, Add, Button, x+m yp gOnBtnClrAll vBtnClrAll, ��ն���
	Gui, Add, Text, xm y+20, ����ڴ�С
	Gui, Add, DropDownList, x+1 yp-3 w50 vDdlWinSize, -|Min||Max|Hide
	Gui, Add, Checkbox, x+m yp h24 vChkParallel, ����ִ��
	Gui, Add, Button, x+m yp gOnBtnStart vBtnStart, ִ�ж���
	Gui, Add, Button, x+m yp Disabled gOnBtnStop vBtnStop, ִֹͣ��
	Gui, Add, Button, x+300 yp gOnBtnAbout, ����(&A)
	Gui, Add, Button, x+m yp vBtnExit gOnBtnExit, �˳�(&X)
    Gui, Add, StatusBar, ,
    SB_SetParts(50, 500)
	ShowProcess()

	Gui, +OwnDialogs
	Gui, Show, , %AppName% v%AppVer%


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
		cmd := StrReplace(cmd, PH, param)
		idx := LV_Add(, ST_N, cmd, dir)
		LV_Modify(idx, "BackColor" color)
	}
	Return
}

OnBtnAdd:
{
	GuiControlGet, dir, , EdtDir
	GuiControlGet, cmd, , EdtCmd
	GuiControlGet, param, , EdtParam
	NewTask(dir, cmd, param)
	GuiControl, , EdtParam,
	GuiControl, Focus, EdtParam
	Return
}

MonitorClipboard()
{
	Global PH, ST_N, IniFile, AppName
	ToolTip, %AppName% ���ڼ�ؼ�����
	If (Clipboard)
	{
		GuiControlGet, dir, , EdtDir
		GuiControlGet, cmd, , EdtCmd
		Loop, Parse, Clipboard, `n, `r
		{
			NewTask(dir, cmd, A_LoopField)
		}
		Clipboard := ""
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
EdtCmd:
{
	idx := LV_GetNext(0, "F")
	If (idx > 0)
	{
		LV_GetText(cmd, idx, 2)
		LV_GetText(dir, idx, 3)
		Gui, 3:New, +Owner1 +ToolWindow +Border
		Gui, 3:Add, Text, Hidden Disabled vEdtIdx, %idx%
		Gui, 3:Add, Text, xm ym, ִ��·��
		Gui, 3:Add, Edit, xm y+m w600 vEdtDir
		Gui, 3:Add, Text, xm y+m, ����
		Gui, 3:Add, Edit, xm y+m w600 vEdtCmd
		Gui, 3:Add, Button, xm y+m Default, Ok
		Gui, 3:Add, Button, x+m yp, Cancel
		Gui, 1:+Disabled
		Gui, 3:Show, AutoSize, �༭����
		GuiControl, 3:, EdtDir, %dir%
		GuiControl, 3:, EdtCmd, %cmd%
		GuiControl, 3:Focus, EdtCmd
	}
	Return
}
3ButtonOk:
{
	GuiControlGet, idx, 3:, EdtIdx
	GuiControlGet, dir, 3:, EdtDir
	GuiControlGet, cmd, 3:, EdtCmd
	Gui, 1:-Disabled
	Gui, 3:Destroy
	Gui, 1:Default
	LV_Modify(idx, "Col2", cmd)
	LV_Modify(idx, "Col3", dir)
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
				If (st == ST_P || st == ST_E)
					st := ST_N
				Else
					st := ""
			Case "RightClick":  ; ���ȴ�ִ�С�������Ϊ���ݲ�ִ�С�
				If (st == ST_N)
					st := ST_P
				Else
					st := ""
			Case "R":  ; ��Ϊ��ִ����ϡ�
				If (st == ST_N || st == ST_P)
					st := ST_E
				Else
					st := ""
			Case "Normal":
				If (GetKeyState("Ctrl") && st != ST_R)
				{
					LV_Modify(A_EventInfo, "Col1", ST_P)
					Gosub, EdtCmd
					LV_Modify(A_EventInfo, "Col1", st)
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
	Global FLAG_STOP, IniFile, AppName, ST_N, ST_R, ST_P, ST_E
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
			; IniWrite, % PackTask(st, cmd, dir), %IniFile%, %AppName%.Tasks, %A_Index%
			ShowProcess(cmd, dir)
			If (parallel)
				Run, %cmd%, %dir%, %winsize%
			Else
				RunWait, %cmd%, %dir%, %winsize%
			st := ST_E
			LV_Modify(A_Index, "Col1", st)
			; IniWrite, % PackTask(st, cmd, dir), %IniFile%, %AppName%.Tasks, %A_Index%
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
OnBtnExit:
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
	Gui, 2:+Owner1 +ToolWindow
	Gui, 2:Add, Picture, xm ym Icon1, %A_ScriptName%
	Gui, 2:Font, Bold
	Gui, 2:Add, Text, xm+40 yp+20, %AppName% v%AppVer%
	Gui, 2:Font
	Gui, 2:Add, Text, , %AppCopyRight%
	Gui, 2:Add, Button, y+20 gABOUTOK Default w75, &OK

	Gui, 2:Show, , %AppName% - About

	Gui, 1:+Disabled

	return
}
2GuiClose:
2GuiEscape:
ABOUTOK:
{
	Gui, 1:-Disabled
	Gui, 2:Destroy
	return
}
