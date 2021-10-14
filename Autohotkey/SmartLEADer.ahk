#Include Crypt.ahk
#Include CryptConst.ahk
#Include CryptFoos.ahk
#include ReadUrl.ahk
#Include TimeClac.ahk ; Time calculation algorithm

; === Check First attemp ===
StateOfStart := 0
OnlyNotSubQuiz := 0
global AutoLogin := 0

if(!ConnectedToInternet()) 
{
	MsgBox, 48, �Ѹ� SmartLEADer, ���ͳ� ������ �Ҿ��� �մϴ�.`n��Ʈ��ũ ���¸� Ȯ���� �ּ���.
	Exitapp
}

Version := "Valpha.0.1"
goto, CodeStart ; place for version check - for github
Return

CodeStart:
IDPre = 
PWPre = 
CheckedCH = 

TaskLoadCheck := False

if(FileExist("info.gof"))
{
	IniRead,IDRead, info.gof, ID
	IniRead,PWRead, info.gof, PW
	IDPre := Crypt.Encrypt.StrDecrypt(IDRead, "CryptoKey", 7, 6)
	PWPre := Crypt.Encrypt.StrDecrypt(PWRead, "CryptoKey", 7, 6)
	CheckedCH = Checked
	
	IniRead, AutoLoginLoad, info.gof, AUTO
	if(AutoLoginLoad = 1) 
	{
		ID := IDPre
		PW := PWPre
		AutoLogChBox := "checked"
		AutoLogin := 1
		
		goto, LoginB
	}
}

Gui,2: Add, Edit, x12 y19 w140 h20 vID +number, %IDPre%
Gui,2: Add, Edit, x12 y49 w140 h20 vPW Password, %PWPre%
Gui,2: Add, Button, x162 y19 w100 h50 gLoginB, �α���
Gui,2: Add, CheckBox, x82 y74 w80 h20 gAutoLogCheck vAutoLogCheck %AutoLogChBox%, �ڵ� �α���
GUi,2: Add, Checkbox, x172 y74 w100 h20 vSaveID %CheckedCH%, ID/PW ����
Gui,2: Show, w279 h110, SmartLEADer �α���
return

AutoLogCheck:
gui,2:submit,NoHide
if(AutoLogCheck = 0) {
	GuiControl,enabled,SaveID
} else {
	GuiControl,Disabled,SaveID
	GuiControl,,SaveID,1
}
return

LoginB:
gui,2: submit,nohide
data := "username=" . ID . "&password=" . PW
if(StateOfStart = 0)
{
	Progress, H80,, SmartLead ���� ������..., �Ѹ� SmartLEADer
}
Winhttp := ComObjCreate("WinHttp.WinHttpRequest.5.1") ; ������Ʈ ����
Winhttp.open("POST","https://smartlead.hallym.ac.kr/login/index.php")
winhttp.SetRequestHeader("Host","smartlead.hallym.ac.kr")
winhttp.SetRequestHeader("Connection","keep-alive")
winhttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
winhttp.SetRequestHeader("Referer", "https://smartlead.hallym.ac.kr/login.php")

winHttp.Send(data)
Winhttp.WaitForResponse
CallData := winhttp.responsetext

Winhttp.open("GET","https://smartlead.hallym.ac.kr/local/ubmessage/")
winHttp.Send()
Winhttp.WaitForResponse
LoginCallData := winhttp.responsetext

IfNotInString, LoginCallData,��� �������� ǥ��
{
	Progress, off
	MsgBox, 16, SmartLEADer, ���̵�/��й�ȣ�� ��ġ���� �ʽ��ϴ�.
	FileDelete, info.gof
	return
	;goto, CodeStart
}


if(SaveID = 1 || AutoLoginLoad = 1)
{
	IDPack := Crypt.Encrypt.StrEncrypt(ID, "CryptoKey", 7, 6)
	PWPack := Crypt.Encrypt.StrEncrypt(PW, "CryptoKey", 7, 6)
	IniWrite, %IDPack%, Info.gof, ID
	IniWrite, %PWPack%, Info.gof, PW
	
	if(AutoLogCheck = 1)
	{
		IniDelete, Info.gof, AUTO
		IniWrite, 1, Info.gof, AUTO
		AutoLogin := 1
	}	
	
	if(SaveID = 1) 
	{
		IniDelete, Info.gof, SAVE
		IniWrite, 1, Info.gof, SAVE
		IDPWSaveLoad := 1
	}
}
else
{
	FileDelete, Info.gof
}
Gui,2: Destroy

; === �α��� �Լ� ���� ===

classRoom := Array()
className := Array()
classLabel := Array()
classLabelUnder := Array()
profName := Array()
classID := Array()
SaveClassName := Array()


CallCutBase := SubStr(CallData, 34000, 20000)

StrCheckArr := StrSplit(CallCutBase,"course_label_")
CourseCount := StrCheckArr.MaxIndex() - 1 ;���� ���� = Array - 1

BaseYPos := (CourseCount - 7) * 13 + 22

Menu, MenuBar, Add, ����, Settings
Menu, MenuBar, Add, ����/�ǵ��, feedBack
Menu, MenuBar, Add, About, About
Gui,1: Menu, MenuBar
Gui,1: Add, Text, x0 y19 w658 h20 vInfoBox Right,
Gui,1: Add, ListView, x12 y49 w650 h50 gListGOne vListVOne, ������ |���Ǹ� |���� |���� ��� 

LVOneNoticePos := 185 + BaseYPos
Gui,1: Add, Text, x0 y%LVOneNoticePos% w680 h20 Center C0F6350, ����Ʈ�� ����Ŭ�� �Ͻø� ���õ� ������ ���� ���� ������ Ȯ�� �� �� �ֽ��ϴ�.

TaskInfoBoxYPos := 213+BaseYPos
Gui,1: Add, Text, x300 y%TaskInfoBoxYPos% w358 h20 vTaskInfoBox Right CFF0000 +BackgroundTrans, 

OnlyNotSubYPos := 210+BaseYPos
Gui,1: Add, CheckBox, x12 y%OnlyNotSubYPos% w120 h20 vOnlyNotSub gOnlyNotSub disabled, ������ ������ ����

AfterToday := 210+BaseYPos
Gui,1: Add, CheckBox, x140 y%OnlyNotSubYPos% w130 h20 vAfterToday gAfterToday disabled, ���� ���� ���� �ʱ� ;vAfterToday gAfterToday

TaskReloadYPos := 208+BaseYPos
Gui,1: Add, Button, x275 y%TaskReloadYPos% w100 h20 gTaskReload vTaskReload disabled, ���ΰ�ħ

ListVTwoYPos := 230+BaseYPos
Gui,1: Add, ListView, x12 y%ListVTwoYPos% w650 h200 gListGTwo vListVTwo , ���Ǹ� | ���� | ���� ���� | ���� �ð� | ���� ���� | ����

ShowBottomTextOneYPos := 435+BaseYPos
Gui,1: Add, Text, x0 y%ShowBottomTextOneYPos% w680 h20 vShowBottomTextOne Center C0F6350, ����Ʈ�� ����Ŭ�� �Ͻø� ���õ� �׸��� SmartLEAD ���� �������� �̵��մϴ�

ZoomInfoBoxYPos := 460 + BaseYPos
Gui,1: Add, Text, x300 y%ZoomInfoBoxYPos% w358 h20 vZoomInfoBox Right CFF0000,

OnlyNotSubYPos := 458 + BaseYPos
Gui,1: Add, CheckBox, x12 y%OnlyNotSubYPos% w120 h20 disabled vOnlyNotSubQuiz gOnlyNotSubQuiz , ������ ��� ���� ; vOnlyNotSub gOnlyNotSub

ZoomRefreshYPos := 458 + BaseYPos
Gui,1: Add, Button, x137 y%ZoomRefreshYPos% w100 h20 disabled vQuizRefresh gQuizRefresh, ���ΰ�ħ
ListVThrYPos := 480 + BaseYPos
Gui,1: Add, ListView, x12 y%ListVThrYPos% w650 h200 gListGThr vListVThr , ���Ǹ� | ���� | ���� ���� | ���� ���� |����
ShowBottomTextTwoYPos := 685 + BaseYPos

GUIHeight := 720 + BaseYPos

Gui,1: Default

RegExMatch(CallData,"hidden-xs\C>(.*?)</li>", Name) ;�̸� �ҷ�����

GuiControl,1: ,InfoBox, %Name1% | %CourseCount%�� ����

Progress, 10, 10`% �Ϸ�, SmartLead�� ���� �ҷ�������..., �Ѹ� SmartLEADer
Gui,1:ListView,ListVOne
Loop, %CourseCount%
{
	pos := RegExMatch(CallCutBase, "course_box\C>(.*?)</div></div></a></div></li>", Course)
	
	RegExMatch(Course1, "href=\C(.*?)\C class", classRoomTemp)
	RegExMatch(Course1, "<h3>(.*?)</h3>", classNameTemp)
	RegExMatch(Course1, "label-course\C>(.*?)</div>", classLabelTemp)
	RegExMatch(Course1, "label-under\C>(.*?)</div>", classLabelUnderTemp)
	RegExMatch(Course1, "lass=\Cprof\C>(.*?)</p>", profNameTemp)
	
	IfInString, classNameTemp, "NEW"
	{
		RegExMatch(classNameTemp1, "(.*?)<span", SpanCut)
		className[A_Index] := SpanCut1
	}
	else
	{
		className[A_Index] := classNameTemp1
	}
	SaveClassName[A_Index] := className[A_Index]
	classRoom[A_Index] := classRoomTemp1
	classLabel[A_Index] := classLabelTemp1
	classLabelUnder[A_Index] := classLabelUnderTemp1
	profName[A_Index] := profNameTemp1
	classID[A_Index] := regExReplace(classRoomTemp1, "[^0-9]")
	
	CallCutBase := SubStr(CallCutBase, pos + strLen(Course1), 20000)
	;Msgbox, % classRoom[A_Index] . " " . className[A_Index] . " " . classLabel[A_Index] . " " . classLabelUnder[A_Index] . " " . profName[A_Index]
	LV_Add(,profName[A_Index] . "  ",className[A_Index],classLabelUnder[A_Index] . "  ",classLabel[A_Index])
}
LV_ModifyCol()

ListViewHeight := (16 * CourseCount) + 35
heightText = %ListViewHeight%
GuiControl, Move, ListVOne, h%heightText%

BaseYPos := (CourseCount - 7) * 10

if(StateOfStart = 0)
{
	Progress, 40, 40`% �Ϸ�, SmartLead�� ���� �ҷ�������..., �Ѹ� SmartLEADer
}
; === ���� �ҷ����� ���� ===
TaskReload:
TaskLoadCheck := False

GuiControl,1: disabled,OnlyNotSub
GuiControl,1: disabled,���ΰ�ħ
GuiControl,1: disabled,AfterToday

ClassNameArr := Array()
TaskWeekArr := Array()
TaskNameArr := Array()
TaskDueArr := Array()
TaskStatArr := Array()
TaskLinkArr := Array()
TaskLeftTimeArr := Array()
PassedAssignment := 0

Gui,1:ListView,ListVTwo
LV_Delete()
Count := 1
Loop, %CourseCount%
{
	Winhttp.Open("GET","https://smartlead.hallym.ac.kr/mod/assign/index.php?id=" . ClassID[A_Index])
	winHttp.Send()
	Winhttp.WaitForResponse

	RegExMatch(winhttp.responsetext, "<span itemprop=\Ctitle\C>(.*?)</span>", ClassName)

	RegExMatch(winhttp.responsetext, "<table class=\Cgeneraltable\C>(.*?)</table>", FocusTaskOne)
	RegExMatch(FocusTaskOne1, "<tbody>(.*?)</tbody>", FocusTaskTwo)

	trCheckArr := StrSplit(FocusTaskTwo1,"<tr class")
	TaskCount := trCheckArr.MaxIndex() - 1 ;���� ���� = Array - 1
	;~ Msgbox, % TaskCount

	Loop, %TaskCount%
	{
		ClassNameArr[Count] := ClassName1
		
		RegExMatch(FocusTaskTwo1, "<tr(.*?)</tr>", FocusTaskEachTemp)
		FocusTaskTwo1 := SubStr(FocusTaskTwo1, StrLen(FocusTaskEachTemp), 10000)
		
		RegExMatch(FocusTaskEachTemp, "cell c0(.*?)/td>", TaskWeekTemp) ;cell c0
		RegExMatch(TaskWeekTemp1, "\C>(.*?)<", TaskWeek)
		TaskWeekArr[Count] := subStr(TaskWeek1,1,21)
		
		RegExMatch(FocusTaskEachTemp, "cell c1(.*?)/a>", TaskNameTemp) ;cell c1
			; === Link �ҷ����� ===
			RegExMatch(TaskNameTemp1, "href=\C(.*?)\C>", TaskLinkTemp)
			TaskLinkArr[Count] := TaskLinkTemp1
			
		TaskNamePos := RegExMatch(TaskNameTemp1, "\C>(.*?)<", TaskNameTempOne)
		TaskCut := SubStr(TaskNameTemp1, TaskNamePos + 5, 10000)
		RegExMatch(TaskCut, "\C>(.*?)<", TaskName)
		TaskNameArr[Count] := subStr(TaskName1,1,20)
		
		RegExMatch(FocusTaskEachTemp, "cell c2(.*?)/td>", TaskDueTemp) ;cell c2
		RegExMatch(TaskDueTemp1, "\C>(.*?)<", TaskDue)
		TaskDueArr[Count] := TaskDue1
		
		StringSplit, DueCutter, TaskDue1, -
		StringSplit, timeCutter, DueCutter3, " "
		StringSplit, hourCutter, timeCutter2, :
		
		leftMonth := DueCutter2
		leftDay := timeCutter1
		leftHour := hourCutter1
		leftMin := hourCutter2
		
		TaskLeftTimeArr[Count] := TimeCalc(leftMonth,leftDay,leftHour,leftMin)
		
		;Msgbox, % leftMonth " - " leftDay " - " leftHour " - " leftMin
		
		RegExMatch(FocusTaskEachTemp, "cell c3(.*?)/td>", TaskStatTemp) ;cell c3
		RegExMatch(TaskStatTemp1, "\C>(.*?)<", TaskStat)
		
		IfInString,TaskStat1,grading
		{
			TaskStatArr[Count] := "���� �Ϸ�"
		}
		else ifinstring,TaskStat1,No
		{
			TaskStatArr[Count] := "������"
		}
		else
		{
			TaskStatArr[Count] := TaskStat1
		}
		
		if(TaskLeftTimeArr[Count] = "���� ����" && TaskStatArr[Count] = "������")
		{
			PassedAssignment++
		}

		Count++
	}
}

NotDoneTaskCount := 0
ListedCount := 1
ListedTaskArr := Array()
if(StateOfStart = 0)
{
	Progress, 70, 70`% �Ϸ�, SmartLead�� ���� �ҷ�������..., �Ѹ� SmartLEADer
}
Loop, % ClassNameArr.MaxIndex()
{
	Count := A_Index
	if(SubStr(TaskDueArr[Count],1,4) = A_Year)
	{
		ArrToString := TaskStatArr[Count]
		IfInString, ArrToString, ������
		{
			NotDoneTaskCount++
		}
		
		if(OnlyNotSub = 1 && AfterToday = 1) ; ������ + �������� ���� �ʱ�
		{
			if(TaskStatArr[A_Index] = "������" && TaskLeftTimeArr[A_Index] != "���� ����")
			{
				LV_Add(,ClassNameArr[A_Index],TaskWeekArr[A_Index], TaskNameArr[A_Index], TaskLeftTimeArr[A_Index], TaskDueArr[A_Index], TaskStatArr[A_Index])
				LV_ModifyCol()
				
				ListedTaskArr[ListedCount++] := A_Index
			}
		}
		else
		{
			if(OnlyNotSub = 1) ; �����⸸
			{
				if(TaskStatArr[A_Index] = "������")
				{
					LV_Add(,ClassNameArr[A_Index],TaskWeekArr[A_Index], TaskNameArr[A_Index], TaskLeftTimeArr[A_Index], TaskDueArr[A_Index], TaskStatArr[A_Index])
					LV_ModifyCol()
					
					ListedTaskArr[ListedCount++] := A_Index
				}
			}
			else ; Nothing selected
			{
				LV_Add(,ClassNameArr[A_Index],TaskWeekArr[A_Index], TaskNameArr[A_Index], TaskLeftTimeArr[A_Index], TaskDueArr[A_Index], TaskStatArr[A_Index])
				LV_ModifyCol()
			}
		}
	}
}

LV_ModifyCol(4,"Sort")
DoneTaskCount := ClassNameArr.MaxIndex() - NotDoneTaskCount
NotDoneTaskCount -= PassedAssignment
GuiControl,1: ,TaskInfoBox, %NotDoneTaskCount%�� ������ %PassedAssignment%���� ���� ���� 

if(StateOfStart != 0)
{
	TaskLoadCheck := True
	GuiControl,1: enabled,OnlyNotSub
	GuiControl,1: enabled,���ΰ�ħ
	GuiControl,1: enabled,AfterToday
	return
}

; [Data Load] Quiz - Quiz �ҷ����� ����
QuizRefresh:
Gui,1:ListView,ListVThr
GuiControl,1: disabled,���ΰ�ħ
LV_Delete()
quizClassNameArr := Array()
quizWeekArr := Array()
quizLinkArr := Array()
quizNameArr := Array()
quizDueArr := Array()
quizScoreArr := Array()
ArrCount := 0
notAssignCount := 0


; === ���� Data ===
Loop, %CourseCount%
{
	Winhttp.Open("GET", "https://smartlead.hallym.ac.kr/mod/quiz/index.php?id=" . ClassID[A_Index])
	WinHttp.Send()
	Winhttp.WaitForResponse
	checkData := winhttp.responsetext

	IfInString, checkData, tbody
	{	
		CallData := SubStr(winhttp.responsetext, 30000, 100000)
		RegExMatch(CallData, "<tbody>(.*?)</tbody>", tBodyData)

		trCheckArr := StrSplit(tBodyData1,"<tr class")
		quizCount := trCheckArr.MaxIndex() - 1 ;���� ���� = Array - 1
		
		quizFocus := tBodyData
		
		Loop, % quizCount
		{
			RegExMatch(checkData, "<span itemprop=\Ctitle\C>(.*?)</span>", ClassName)
			quizClassNameArr[ArrCount] := ClassName1
			
			RegExMatch(quizFocus, "<tr(.*?)</tr>", quizFocusTableTemp)
			quizFocus := SubStr(quizFocus, StrLen(quizFocusTableTemp1), 10000)
			
			RegExMatch(quizFocusTableTemp1, "cell c0(.*?)/td>", quizWeekTemp) ;cell c0
			RegExMatch(quizWeekTemp1, "\C>(.*?)<", quizWeek)
			quizWeekArr[ArrCount] := quizWeek1
			
			RegExMatch(quizFocusTableTemp1, "cell c1(.*?)/a>", quizNameTemp) ;cell c1
				; === Link �ҷ����� ===
				LinkPos := RegExMatch(quizNameTemp1, "href=\C(.*?)\C>", quizLinkTemp)
				quizLinkArr[ArrCount] := quizLinkTemp1
			
			quizNameCut := SubStr(quizNameTemp1, LinkPos, 10000)
			RegExMatch(quizNameCut, "\C>(.*?)<", quizNameTemp)
			quizNameArr[ArrCount] := quizNameTemp1
			
			RegExMatch(quizFocusTableTemp1, "cell c2(.*?)/td>", quizDueTemp) ;cell c2
			RegExMatch(quizDueTemp1, "\C>(.*?)<", quizDue)
			quizDueArr[ArrCount] := quizDue1
			
			RegExMatch(quizFocusTableTemp1, "cell c3(.*?)/td>", quizScoreTemp) ;cell c3
			RegExMatch(quizScoreTemp1, "\C>(.*?)<", quizScore)
			IfNotInString, quizScore1, /
			{
				Winhttp.Open("GET", "https://smartlead.hallym.ac.kr/mod/quiz/" . quizLinkArr[ArrCount])
				WinHttp.Send()
				Winhttp.WaitForResponse
				
				quizSignInCheck := winhttp.responsetext
				
				IfInString, quizSignInCheck, �����
				{
					quizScoreArr[ArrCount] := "���� �Ϸ�"
				}
				else
				{
					quizScoreArr[ArrCount] := "������"
					notAssignCount++
				}
			}
			else
			{
				quizScoreArr[ArrCount] := quizScore1
			}

			;~ if(SubStr(quizDueArr[ArrCount],1,4) = A_Year)
			;~ {
				;~ LV_Add(,quizClassNameArr[ArrCount],quizWeekArr[ArrCount],quizNameArr[ArrCount],quizDueArr[ArrCount],quizScoreArr[ArrCount])
			;~ }
			
			ArrCount++
		}
	}
}

NotDoneQuizCount := 0

Loop, % quizClassNameArr.MaxIndex()
{
	Count := A_Index
	if(SubStr(quizDueArr[Count],1,4) = A_Year)
	{
		ArrToString := quizScoreArr[Count]
		IfInString, ArrToString, ������
		{
			NotDoneQuizCount++
		}
		
		if(OnlyNotSubQuiz = 1)
		{
			if(quizScoreArr[A_Index] = "������")
			{
				LV_Add(,quizClassNameArr[A_Index],quizWeekArr[A_Index],quizNameArr[A_Index],quizDueArr[A_Index],quizScoreArr[A_Index])
				LV_ModifyCol()
			}
		}
		else
		{
			LV_Add(,quizClassNameArr[A_Index],quizWeekArr[A_Index],quizNameArr[A_Index],quizDueArr[A_Index],quizScoreArr[A_Index])
			LV_ModifyCol()
		}
	}
}

DoneQuizCount := QuizClassNameArr.MaxIndex() - NotDoneQuizCount
GuiControl,1: ,ZoomInfoBox, %NotDoneQuizCount%�� ������

if(StateOfStart = 0)
{
	Progress, 100, 100`% �Ϸ�, ������ �ε尡 �Ϸ� �Ǿ����ϴ�, �Ѹ� SmartLEADer
}
TaskLoadCheck := True
GuiControl,1: enabled,OnlyNotSub
GuiControl,1: enabled,OnlyNotSubQuiz
GuiControl,1: enabled,���ΰ�ħ
GuiControl,1: enabled,QuizRefresh
Gui,1: Show, w680 h%GUIHeight%, �Ѹ� SmartLEADer

Progress, off
if(StateOfStart = 0)
{
	StateOfStart := 1
}
return
; === End whole request ===

ListGOne: ; [Quick Link] Course Status
Gui,Submit, nohide
Gui,1:ListView,ListVOne
ColumnCount := LV_GetNext(0)
if(A_Guievent = "DoubleClick")
{
	LV_GetText(findProfName, LV_GetNext(0), 1)
	LV_GetText(findClassName, LV_GetNext(0), 2)
	LV_GetText(findLabelUName, LV_GetNext(0), 3)
	LV_GetText(findLabelName, LV_GetNext(0), 4)
	
	;Msgbox, % findProfName " | " findClassName " | " findLabelUName " = " findLabelName
 	
	Loop, % profName.MaxIndex()
	{
		if(TaskLoadCheck && ColumnCount != 0)
		{
			if(profName[A_Index] . "  " = findProfName && SaveClassName[A_Index] = findClassName && classLabelUnder[A_Index] . "  " = findLabelUName && classLabel[A_Index] = findLabelName)
			{	;Msgbox, % classID[A_Index]
				Winhttp.open("GET","https://smartlead.hallym.ac.kr/report/ubcompletion/user_progress.php?id=" . classID[A_Index])
				winHttp.Send()
				Winhttp.WaitForResponse
				VideoData := winhttp.responsetext
				

				
				checkWeekName := Array()
				checkVideoCount := Array()
				checkVideoPurpose := Array()
				checkVideoDone := Array()
				checkVideoStat := Array()
				currentVideo := Array()
				currentVideoIndex := Array()
				checkWeekState := Array()
				checkVideoWeek := Array()
				checkWeekTriger := 1
				cVCount := 1
				weekCount := 0
				courseString := " "
				
				StringGetPos, tBodyPos, VideoData, ���� �ڷ�
				Data := SubStr(VideoData,tBodyPos)
				
				if(tBodyPos = -1)
				{
					MsgBox, 262160, SmartLead, %findClassName% ���Ǵ� ���� ��Ȳ�� �������� �ʽ��ϴ�.
					return
				}
				
				Gui,4: Add, ListView, x12 y69 w810 h350 vCheckLV,���� |���� ���� |�䱸 |�н� |�⼮ ��Ȳ 
				Gui,4: Show, w834 h429, % findClassName " ���� ��Ȳ"
				Gui,4:Default
				
				
				
				Loop { ; Seperate by Week
					pos := RegExMatch(Data, "sectiontitle(.*?)sectiontitle", ClassName)
					
					IfNotInString, ClassName1, text-center
					{
						break
					}
					
					weekCount++
					RegExMatch(Data, "<div class=\Csectiontitle\C title=\C(.*?)\C>(.*?)</div>", focusWeek) ; get current Week
					;weekCheckData := focusWeek1
					checkWeekName[A_Index] := focusWeek1 ;MsgBox, %focusWeek1% ; Additional
					
					
					searchTime := ClassName1
					formerIndex := A_Index
					Loop {
						checkWeekState[checkWeekTriger++] := weekCount
						timePos := RegExMatch(searchTime, "<td class=\Ctext-center hidden-xs hidden-sm\C>(.*?)</td>", purposeTime)
						RegExMatch(searchTime, "<td class=\Ctext-center\C>(.*?)<br/>", userTime)
						
						IfNotInString, purposeTime1, :
						{
							break
						}
						
						checkVideoCount[formerIndex] := A_Index
						
						; define 2D array
						if(A_Index == 1) {
							currentVideoIndex[formerIndex] := Array()
							checkVideoPurpose[formerIndex] := Array()
							checkVideoDone[formerIndex] := Array()
							checkVideoWeek[formerIndex] := Array()
						}
						
						; Get current video name
						RegExMatch(searchTime, "icon\C alt=\C\C />(.*?)</td>",currentVideo)
						courseString=%courseString%%currentVideo1%`n
						
						; purposetime = �⼮���� �䱸�ð�
						; userTime = �� �н��ð�
						checkVideoPurpose[formerIndex][A_Index] := purposeTime1
						checkVideoDone[formerIndex][A_Index] := userTime1
						checkVideoWeek[formerIndex][A_Index] := focusWeek2
						
						;Msgbox, %purposeTime1% | %userTime1%
						searchTime := SubStr(searchTime, timePos + StrLen(purposeTime) + 100)
					}
					Data := SubStr(Data,pos + StrLen(ClassName1))
				}

				StringSplit, courseSplit, courseString, `n
				stringCount := 1
				
				checkWeekAddCount := 1
				
				weekStatus := Array()
				
				Loop, %weekCount%
				{
					formerIndex := A_Index
					videoDoneCnt := 0
					Loop, % checkVideoCount[A_index]
					{
						purpose := checkVideoPurpose[formerIndex][A_Index]
						watched := checkVideoDone[formerIndex][A_Index]
						weekCheck := checkVideoWeek[formerIndex][A_Index]

						purposeTiem := regExReplace(purpose, "[^0-9]")
						watchedTiem := regExReplace(watched, "[^0-9]")
						
						doneCheck := (purposeTiem <= watchedTiem) ? "O" : "X"
						(doneCheck = "O") ? videoDoneCnt++
						LV_Add(,weekCheck . "       ",LTrim(courseSplit%stringCount%),purpose,watched,doneCheck . "            ")
						stringCount++
					}
					weekStatus[A_index] := (videoDoneCnt = 0) ? "�Ἦ" : (videoDoneCnt = checkVideoCount[A_index]) ? "�⼮" : "����"
					
					if(!checkVideoCount[A_index] || !weekStatus[A_index])
					{
						weekStatus[A_index] := "-"
					}
				}
				LV_ModifyCol()
				
				weekStatusXPos := 12
				weekStatusYPos := 20 ; Height
				
				;[Course Status] Week Calc
				startDate = 202108300000
				NowString := A_Year . A_MM . A_DD . A_Hour . A_Min
					
				EnvSub, NowString, %startDate%, Hour

				Loop, 16
				{
					weekStatusXPos := 13 + ((A_Index - 1) * 50)
					if(A_Index = Ceil((NowString/24)/7)) 
					{
						Gui,4: Add, Text, x%weekStatusXPos% y%weekStatusYPos% w50 h20 C0023FF Center,%A_Index%����
					}
					else
					{
						Gui,4: Add, Text, x%weekStatusXPos% y%weekStatusYPos% w50 h20 Center,%A_Index%����
					}
					weekStatusYPos2Lv := weekStatusYPos + 20
					
					
					textColor := (weekStatus[A_index] = "�⼮") ? "338ccc" : (weekStatus[A_index] = "�Ἦ") ? "dc5648" : (weekStatus[A_index] = "-") ? "999999" : "000000"
					Gui,4: Add, Text, x%weekStatusXPos% y%weekStatusYPos2Lv% w50 h20 Center C%textColor%,% weekStatus[A_index]
					;dc5648 �Ἦ
					;338ccc �⼮
				}
			}
		}
	}
}
return

ListGTwo: ; [Quick Link] Task
Gui,Submit, nohide
Gui,1:ListView,ListVTwo
ColumnCount := LV_GetNext(0)
if(A_Guievent = "DoubleClick")
{
	LV_GetText(findClassName, LV_GetNext(0), 1)
	LV_GetText(findTaskWeek, LV_GetNext(0), 2)
	LV_GetText(findTaskName, LV_GetNext(0), 3)
	LV_GetText(findTaskLeft, LV_GetNext(0), 4)
	LV_GetText(findTaskDate, LV_GetNext(0), 5)
	LV_GetText(findTaskStat, LV_GetNext(0), 6)
	
	Loop, % ClassNameArr.MaxIndex()
	{
		if(TaskLoadCheck && ColumnCount != 0)
		{
			if(ClassNameArr[A_Index] = findClassName && TaskWeekArr[A_Index] = findTaskWeek && TaskNameArr[A_Index] = findTaskName && TaskLeftTimeArr[A_Index] = findTaskLeft && TaskDueArr[A_Index] = findTaskDate && TaskStatArr[A_Index] = findTaskStat)
			{
				ColumnCount := LV_GetNext(0) 
				Text := "[" . ClassNameArr[A_Index] . "]�� [" . TaskNameArr[A_Index] . "]������ Ȯ���Ͻðڽ��ϱ�?"
				MsgBox, 262177, �Ѹ� SmartLEADer,  % Text
				
				IfMsgBox, OK
				{
					Run, % TaskLinkArr[A_Index]
				}
			}
		}
	}
}
return


ListGThr: ; [Quick Link] Quiz
Gui,Submit, nohide
Gui,1:ListView,ListVThr
ColumnCount := LV_GetNext(0)
if(A_Guievent = "DoubleClick")
{
	LV_GetText(quizFindCourseName, LV_GetNext(0), 1) ; course name
	LV_GetText(findQuizWeek, LV_GetNext(0), 2) ; quiz week
	LV_GetText(findQuizName, LV_GetNext(0), 3) ; Quiz Name
	LV_GetText(findQuizLeft, LV_GetNext(0), 4) ; Due date
	LV_GetText(findQuizScore, LV_GetNext(0), 5) ; Score
	
	; Msgbox, % quizFindCourseName " - " findQuizWeek " - " findQuizName " - " findQuizLeft " - " findQuizScore
	Loop, % quizClassNameArr.MaxIndex()
	{
		if(TaskLoadCheck && ColumnCount != 0)
		{
			if(quizClassNameArr[A_Index] = quizFindCourseName && quizWeekArr[A_Index] = findQuizWeek && quizNameArr[A_Index] = findQuizName && quizDueArr[A_Index] = findQuizLeft && quizScoreArr[A_Index] = findQuizScore)
			{
				ColumnCount := LV_GetNext(0) 
				Text := "[" . quizClassNameArr[A_Index] . "]�� [" . quizNameArr[A_Index] . "]��� Ȯ���Ͻðڽ��ϱ�?"
				MsgBox, 262177, �Ѹ� SmartLEADer,  % Text
				
				IfMsgBox, OK
				{
					Run, %  "https://smartlead.hallym.ac.kr/mod/quiz/" . quizLinkArr[A_Index]
				}
			}
		}
	}
}
return


; === �������� ������ ���� ===
OnlyNotSub:
Gui,Submit, Nohide
Gui,1:ListView,ListVTwo
LV_Delete()

ListedCount := 1
ListedTaskArr := Array()

Loop, % ClassNameArr.MaxIndex()
{
	if(SubStr(TaskDueArr[A_Index],1,4) = A_Year)
	{
		if(OnlyNotSub = 1)
		{
			if(TaskStatArr[A_Index] = "������")
			{
				LV_Add(,ClassNameArr[A_Index],TaskWeekArr[A_Index], TaskNameArr[A_Index], TaskLeftTimeArr[A_Index], TaskDueArr[A_Index], TaskStatArr[A_Index])
				LV_ModifyCol()
				
				ListedTaskArr[ListedCount++] := A_Index
			}
			
			GuiControl, enabled, ���� ���� ���� �ʱ�
		}
		else
		{
			LV_Add(,ClassNameArr[A_Index],TaskWeekArr[A_Index], TaskNameArr[A_Index], TaskLeftTimeArr[A_Index], TaskDueArr[A_Index], TaskStatArr[A_Index])
			LV_ModifyCol()
			
			GuiControl, disabled, ���� ���� ���� �ʱ�
			GuiControl,,���� ���� ���� �ʱ�,0
		}
	}
}
LV_ModifyCol(4,"Sort")
return

; === ���� ���� ���� �ʱ� ===
AfterToday:
Gui,Submit, Nohide
Gui,1:ListView,ListVTwo

ListedCount := 1
ListedTaskArr := Array()

LV_Delete()

Loop, % ClassNameArr.MaxIndex()
{
	if(SubStr(TaskDueArr[A_Index],1,4) = A_Year)
	{
		if(OnlyNotSub = 1 && AfterToday = 1)
		{
			if(TaskStatArr[A_Index] = "������" && TaskLeftTimeArr[A_Index] != "���� ����")
			{
				LV_Add(,ClassNameArr[A_Index],TaskWeekArr[A_Index], TaskNameArr[A_Index], TaskLeftTimeArr[A_Index], TaskDueArr[A_Index], TaskStatArr[A_Index])
				LV_ModifyCol()
				
				ListedTaskArr[ListedCount++] := A_Index
			}
		}
		else
		{
			if(OnlyNotSub = 1)
			{
				if(TaskStatArr[A_Index] = "������")
				{
					LV_Add(,ClassNameArr[A_Index],TaskWeekArr[A_Index], TaskNameArr[A_Index], TaskLeftTimeArr[A_Index], TaskDueArr[A_Index], TaskStatArr[A_Index])
					LV_ModifyCol()
					
					ListedTaskArr[ListedCount++] := A_Index
				}
			}
			else 
			{
				LV_Add(,ClassNameArr[A_Index],TaskWeekArr[A_Index], TaskNameArr[A_Index], TaskLeftTimeArr[A_Index], TaskDueArr[A_Index], TaskStatArr[A_Index])
				LV_ModifyCol()
			}
		}
	}
}
LV_ModifyCol(4,"Sort")
return

OnlyNotSubQuiz:
Gui,Submit, Nohide
Gui,1:ListView,ListVThr
LV_Delete()

Loop, % quizClassNameArr.MaxIndex()
{
	Count := A_Index
	if(SubStr(quizDueArr[Count],1,4) = A_Year)
	{	
		if(OnlyNotSubQuiz = 1)
		{
			if(quizScoreArr[A_Index] = "������")
			{
				LV_Add(,quizClassNameArr[A_Index],quizWeekArr[A_Index],quizNameArr[A_Index],quizDueArr[A_Index],quizScoreArr[A_Index])
				LV_ModifyCol()
			}
		}
		else
		{
			LV_Add(,quizClassNameArr[A_Index],quizWeekArr[A_Index],quizNameArr[A_Index],quizDueArr[A_Index],quizScoreArr[A_Index])
			LV_ModifyCol()
		}
	}
}
return

Settings: ; [MENU] Settings
if(TaskLoadCheck)
{
	
	;~ if(ListSaveLoad = 1) {
		;~ ListSaveC := "checked"
	;~ }
	
	if(AutoLogin = 1) {
		LogDataC := "checked"
		IDPWSaveC := "checked disabled"
		IDPWSaveLoad := 1
	}

	if(IDPWSaveLoad = 1) {
		IDPWSaveC := "checked"
		
		if(AutoLogin = 1) {
			IDPWSaveC := "checked disabled"
		}
	}
	
	;~ Gui,3: Add, CheckBox, x12 y9 w220 h20 vListSave gListSave %ListSaveC%, ��� üũ ���� ����
	Gui,3: Add, CheckBox, x12 y19 w120 h20 vCheckAutoLogin gCheckAutoLogin %LogDataC%, �α��� ���� ����
	Gui,3: Add, CheckBox, x142 y19 w90 h20 vIDPWSave gIDPWSave %IDPWSaveC%, ID/PW ����
	Gui,3: Add, Button, x12 y49 w220 h30 gSave, ����
	Gui,3: Show, w249 h98, ����
}
return


ListSave: ; Not for use
return

CheckAutoLogin:
Gui,3: submit, nohide

if(CheckAutoLogin = 1) {
	GuiControl,Disabled,IDPWSave
	GuiControl,,IDPWSave,1
} else {
	GuiControl,Enabled,IDPWSave
}
return


IDPWSave: ; Not for use
return

Save:
gui,submit,nohide

;~ Msgbox, % ID " . " PW

if(FileExist("info.gof")) {
	if(CheckAutoLogin = 0 && IDPWSave = 0) {
		FileDelete, Info.gof
	} else if(CheckAutoLogin = 0) {
		IniDelete, Info.gof, AUTO
		IniWrite, 0, Info.gof, AUTO
	} else if(IDPWSave = 0)	{
		IniDelete, Info.gof, SAVE
		IniWrite, 0, Info.gof, SAVE
	}
}

if(ListSave) {
	Gui,1:submit, nohide
	IniWrite, %OnlyNotSub%, Info.gof, main_ONS
	IniWrite, %AfterToday%, Info.gof, main_AT
	IniWrite, %OnlyNotSub%, Info.gof, main_ONS
}

gui,3: Destroy
MsgBox, 262208, �Ѹ� SmartLEADer, ����Ǿ����ϴ�.
return


About: ; [MENU] About
if(TaskLoadCheck)
{
	MsgBox, 262208, About �Ѹ� SmartLEADer,
	(
�Ѹ� SmartLEADer
  Copyright ��2020-%A_Year% Gangsu Kim
  
���� ����
  %Version% 2021Sep20
  
�� ���α׷��� ����� �ǸŸ� �����մϴ�.
	)
}
return


feedBack: ; [MENU] Report / FeedBack
if(TaskLoadCheck)
{
	MsgBox, 36, �Ѹ� SmartLEADer, ����/�ǵ�� ����Ʈ�� �̵��Ͻðڽ��ϱ�?`n(Google Form ���)
	IfMsgBox, Yes
	{
		run, http://server.go-guma.com/smartlead/feedBack.html
	}
}
return

^!A:: ; [Developer] TestNetChecking
NetCheck := ReadURL("http://server.go-guma.com/GOLocker/NetTest.php")
Msgbox,,Admin, %NetCheck%
return


2GuiClose: ; [GuiCloseCommand] Main GUI
GuiClose: ; [GuiCloseCommand] Login GUI
ExitApp

3GuiClose: ; [GuiCloseCommand] Setting GUI
gui,3: Destroy
return

4GUIClose: ; [GuiCloseCommand] Course Status GUI
Gui,1:Default
Gui,4: Destroy
return

ConnectedToInternet(flag=0x40) { ; [Status] Get network Status
	Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag,"Int",0)
}