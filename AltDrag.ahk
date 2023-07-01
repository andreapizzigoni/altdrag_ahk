CoordMode( "Mouse", "Screen" )
SetWinDelay( -1 )

global SERVICE := 0 

global LR_BOUND_SENSIVITY  := 100
global TOP_BOUND_SENSIVITY := 50

global EVENT_SYSTEM_MOVESIZESTART := 0x000A
global EVENT_SYSTEM_MOVESIZEEND   := 0x000B


; Starting Point: https://www.youtube.com/watch?v=BMI5ZGLWWvw&pp=ugMICgJpdBABGAHKBQxhbHQgZHJhZyBhaGs%3D

; ------  ------
; ------ DRAG FINESTRA ------
Alt & LButton::{

    global mouse_start_x
    global mouse_start_y
    global HWND_window

    MouseGetPos( &mouse_start_x, &mouse_start_y, &HWND_window )
	window_minmax := WinGetMinMax( HWND_window )
    monitor_number_start := getMonitorFromMouse()

	
    ; Se è restored ed è un doppio click --> MASSIMIZZO
    if( !window_minmax && A_PriorHotkey == "Alt & LButton" && A_TimeSincePriorHotkey < 170 ){

        WinMaximize( HWND_window ) 

        return
    }

    ; Se è massimizzata calcolo la posizione relativa e la mantengo dopo il restore
    if( window_minmax ){
    	
    	WinGetPos( &window_start_x, &window_start_y, &window_width, &window_height, HWND_window )

		perc_width  := Floor(( ABS(window_start_x - mouse_start_x) / window_width  )  * 100 )
		perc_height := Floor(( ABS(window_start_y - mouse_start_y) / window_height ) * 100 )
    
		; Restore della finestra e la sposto per mantenere la posizione relativa
        WinRestore( HWND_window )
        WinGetPos( &window_start_x, &window_start_y, &window_width, &window_height, HWND_window )

        new_x := mouse_start_x - (Floor((window_width  / 100)  * perc_width  ))
        new_y := mouse_start_y - (Floor((window_height / 100) * perc_height ))
        
        WinMove( new_x, new_y, window_width, window_height, HWND_window )
               
    }	

    ; Creo evento di spostamento per attivare le FancyZones ---> Premi SHIFT per attivare
    ; SOURCE: https://www.reddit.com/r/AutoHotkey/comments/h9eu9z/comment/fuy12xq/
    ; https://learn.microsoft.com/en-us/windows/win32/winauto/event-constants
    ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-notifywinevent
    DllCall('User32\NotifyWinEvent', 'uint', EVENT_SYSTEM_MOVESIZESTART, 'ptr', HWND_window, 'int', 0, 'int', 0)
    
    ; Inizio lo spostamento
    SetTimer dragWindow, 15
    return

    ; ---------------------------------------------------------------------------------------------
    ; ---------------------------------------------------------------------------------------------

    dragWindow(){

        ; Ottengo le coordinate del mouse e della finestra da spostare
        MouseGetPos( &mouse_current_x, &mouse_current_y )											
        WinGetPos( &window_start_x, &window_start_y, &window_width, &window_height, HWND_window )

        ; Termino il drag se il tast Sx del mouse non è più premuto
        if( !GetKeyState("LButton", "P") ){

            ; Termino lo spostamento
            SetTimer dragWindow, 0
             
            ; Termino evento di spostamento per attivare le FancyZones
            DllCall('User32\NotifyWinEvent', 'uint', EVENT_SYSTEM_MOVESIZEEND, 'ptr', HWND_window, 'int', 0, 'int', 0)
    
            ; TODO: rimouvere o disattivare se SHIFT è premuto
            handleSnapping()

            return
        }

        ; Recupero la distanza fatta dal mouse e muovo la finestra
        delta_x := mouse_current_x - mouse_start_x
        delta_y := mouse_current_y - mouse_start_y
        
        new_x := window_start_x + delta_x
        new_y := window_start_y + delta_y

        ; Porto in primo piano la finestra e la sposto
        WinActivate( HWND_window )
        WinMove( new_x, new_y, window_width, window_height, HWND_window )
        
        ; Imposto il nuovo punto di partenza del mouse	
        mouse_start_x := mouse_current_x																	
        mouse_start_y := mouse_current_y

        return
    }

    handleSnapping(){
        
        MouseGetPos( &mouse_current_x, &mouse_current_y )
        monitor_number := getMonitorFromMouse()


        ; Se la finestra era massimizzata ed ha cambiato schermo --> MASSIMIZZO
        if( window_minmax = 1 && ( monitor_number_start != monitor_number ) )
        {
            WinMaximize( HWND_window )
            window_minmax := 0 ; <--- ???? TODO: da ricontrollare forse non serve

            return
        }

        ; Controllo posizione per attivazione snaps ai bordi dello schermo
        MonitorGetWorkArea( monitor_number, &left_bound, &top_bound, &right_bound, &bottom_bound )

        if( mouse_current_x >= (right_bound - LR_BOUND_SENSIVITY) ){

            snapDx()
            SetTimer dragWindow, 0
            
            return
        }
        if( mouse_current_x <= (left_bound + LR_BOUND_SENSIVITY) ){

            snapSx()
            SetTimer dragWindow, 0
            
            return
        }
        if( mouse_current_y <= (top_bound + TOP_BOUND_SENSIVITY) ){

            snapTOP()
            SetTimer dragWindow, 0
            
            return
        }

        snapDx(){
        
            new_x := left_bound + (Abs(Abs(right_bound) - Abs(left_bound)) - 16) / 2
            new_y := top_bound

            new_width  := (Abs((Abs(right_bound) - Abs(left_bound))) + 30) / 2
            new_height := (Abs(Abs(bottom_bound) - Abs(top_bound))) + 6
            
            WinMove( new_x, new_y, new_width, new_height, HWND_window )

            return
        }

        snapSx(){
            
            new_x := left_bound - 7
            new_y := top_bound

            new_width  := (Abs((Abs(right_bound) - Abs(left_bound))) + 26) / 2
            new_height := (Abs(Abs(bottom_bound) - Abs(top_bound))) + 6
            
            WinMove( new_x, new_y, new_width, new_height, HWND_window )
        
            return
        }

        snapTOP(){
            
            WinMaximize( HWND_window )
        
            return
        }

    }

}

getMonitorFromMouse(){

	MouseGetPos( &mouse_x, &mouse_y )

	monitor_count := MonitorGetCount()

	Loop monitor_count {
		MonitorGetWorkArea( A_Index, &left_bound, &top_bound, &right_bound, &bottom_bound )

        if (mouse_x >= left_bound) && (mouse_x < right_bound) && (mouse_y >= top_bound) && (mouse_y < bottom_bound){

			monitor_number := A_Index
			
            break
		}

	}

	return monitor_number
}