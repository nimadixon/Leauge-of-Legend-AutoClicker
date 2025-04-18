#SingleInstance force
#Persistent
#include Lib\AutoHotInterception.ahk

; ایجاد نمونه از کلاس AutoHotInterception
AHI2 := new AutoHotInterception()

; شناسایی صفحه‌کلید با VID و PID
keyboardId := AHI2.GetKeyboardId(0x1C4F, 0x0002)

; ثبت رویداد برای فشار کلیدها
AHI2.SubscribeKeyboard(keyboardId, false, Func("KeyboardEvent").Bind(keyboardId))

; برای نگهداری وضعیت کلید Ctrl و متغیر زمان Cooldown
global ctrlPressed := false
global coolDownTime := 0 ; مدت زمان Cooldown در میلی‌ثانیه
global attackPerSecond := 1.324 ; مقدار حمله در ثانیه (تعداد شلیک‌ها در هر ثانیه)
global lastAttackTime := 0 ; زمان آخرین حمله

return

; این تابع برای بررسی فشار کلیدها و ارسال پیام در صورت فشار دادن Ctrl است
KeyboardEvent(id, code, state) {
    global ctrlPressed, coolDownTime, attackPerSecond, lastAttackTime

    ; اگر Ctrl فشار داده شده باشد
    if (code = 0x1D && state = 0) { ; وقتی کلید Ctrl (کد 0x1D) فشار داده می‌شود
        ; محاسبه زمان Cooldown بر اساس مقدار attackPerSecond
        coolDownTime := 1000 / attackPerSecond ; زمان Cooldown بر اساس حمله در ثانیه

        ; بررسی اینکه آیا زمان کافی برای شلیک مجدد گذشته است
        currentTime := A_TickCount
        if (currentTime - lastAttackTime >= coolDownTime) {
            ; ارسال کلیک چپ ماوس برای شلیک
            send {LButton}
            sleep 260
            send {RButton}  ; ارسال کلیک راست ماوس برای هدف‌گیری

            lastAttackTime := currentTime ; بروزرسانی زمان آخرین حمله
        }
    }
}

; تغییر مقدار attackPerSecond با فشردن F2 (وارد کردن دستی مقدار جدید)
F2::
    InputBox, userInput, Enter Attack Per Second, Please enter the new value for attackPerSecond:, HIDE
    if (ErrorLevel) {
        return ; اگر ورودی لغو شده باشد، هیچ کاری انجام نده
    }
    
    ; تبدیل ورودی به عدد و اعمال آن
    attackPerSecond := userInput
    Tooltip, Attack per second set to: %attackPerSecond%  ; نمایش مقدار جدید
    SetTimer, RemoveTooltip, -1500  ; بعد از 1.5 ثانیه پیام را پاک کن
return

; برای خروج از اسکریپت با فشار دادن Ctrl+Esc
Esc:: 
    ExitApp

; حذف پیام نمایش داده شده (Tooltip)
RemoveTooltip:
    Tooltip
return
