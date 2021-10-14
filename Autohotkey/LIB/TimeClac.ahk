TimeCalc(month, day, hour, min)
{
	if(StrLen(day) < 2) {
		day := 0 . day
	}
	
	DueString := "2021" . month . day . hour . min
	NowString := "2021" . A_MM . A_DD . A_Hour . A_Min

	if(DueString < NowString)
	{
		return "���� ����"
	}

	EnvSub, DueString, %NowString%, Min
	
	SetFormat, Float, 0.0
	
	DayLeft := floor((DueString/60)/24) ; Day
	MinuteLeft := Mod(DueString, 60)
	HourLeft := (DueString - (DayLeft * 1440) - MinuteLeft) / 60
	
	resultString := ""

	if(DayLeft > 0)
	{
		if(StrLen(DayLeft) < 2) {
			DayLeft := 0 . DayLeft
		}
		resultString := DayLeft . "�� "
	} else if(DayLeft = 0) {
		resultString := "00�� "
	}
	
	if(HourLeft > 0)
	{
		if(StrLen(HourLeft) < 2) {
			HourLeft := 0 . HourLeft
		}
		
		resultString := resultString . HourLeft . "�ð� "
	}
	else if(HourLeft = 0)
	{
		resultString := resultString . "00�ð� "
	}

	if(MinuteLeft > 0)
	{
		if(StrLen(MinuteLeft) < 2) {
			MinuteLeft := 0 . MinuteLeft
		}
		resultString := resultString . MinuteLeft . "�� "
	} else {
		resultString := resultString . "00�� "
	}

	return resultString
}