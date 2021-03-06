;=====================================================================
; IME auto off
;   Last Changed: 26 Jul 2013.
;=====================================================================

#NoTrayIcon
#InstallKeybdHook
#UseHook

; ターゲットウィンドウ
is_target() {
    IfWinActive,ahk_class Vim ; GVim
        Return 1
    IfWinActive,ahk_class PuTTY ; Putty
        Return 1
    IfWinActive,ahk_class ConsoleWindowClass ; Cygwin
        Return 1
}

;-----------------------------------------------------------
; IMEの状態をセット
; @param  flag    1:ON / 0:OFF
; @return 0:成功 / 0以外:失敗
; @see IME.ahk http://www6.atwiki.jp/eamat/pages/17.html
;-----------------------------------------------------------
IME_SET(flag) {
    ControlGet,hwnd,HWND,,,A
    ptrSize := !A_PtrSize ? 4 : A_PtrSize
    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
    NumPut(cbSize, stGTI,  0, "UInt") ; DWORD cbSize
    hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI) ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          ,  Int, 0x006   ;wParam  : IMC_SETOPENSTATUS
          ,  Int, flag) ;lParam  : 0 or 1
}

#If is_target()
~Esc::	IME_SET(0) ; Esc
~^[::	IME_SET(0) ; Ctrl-[
~^C::	IME_SET(0) ; Ctrl-C
