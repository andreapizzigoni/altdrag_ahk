CoordMode( "Mouse", "Screen" )
SetWinDelay( -1 )

; ------  ------
; ------ RESIZE FINESTRA O MINIMIZE ------
Alt & RButton::{

    MouseGetPos( &mouse_start_x, &mouse_start_y, &HWND_window )
    WinGetPos( &window_start_x, &window_start_y, &window_width, &window_height, HWND_window )
    classe := WinGetClass( HWND_window )
	
    ; Ignoro elementi del desktop e barre di sistema
    try{
		if( classe == "Progman" || classe == "Shell_TrayWnd" || classe == "Shell_SecondaryTrayWnd" || classe == "WorkerW" ){
			return ; TODO: fix this mess
		}
	}
		
    WinActivate( HWND_window )
	window_minmax := WinGetMinMax( HWND_window )

	; Ridimensionamento finestra
	if( mouse_start_x >= ( window_start_x + (window_width / 2)) ){
	
        SetTimer resizeWindowDx_Down, 15

    }else{

		SetTimer resizeWindowSx_Down, 15

    }

    return

    ; ---------------------------------------------------------------------------------------------
    ; ---------------------------------------------------------------------------------------------

    resizeWindowDx_Down(){

        MouseGetPos( &mouse_current_x, &mouse_current_y )											
        WinGetPos( &window_start_x, &window_start_y, &window_width, &window_height, HWND_window )

        window_minmax := WinGetMinMax( HWND_window )

        if( window_minmax != 1 ){

            delta_x := mouse_current_x - mouse_start_x
            delta_y := mouse_current_y - mouse_start_y
            
            new_width  := window_width  + delta_x
            new_height := window_height + delta_y

            WinMove( window_start_x, window_start_y, new_width, new_height, HWND_window )

            mouse_start_x := mouse_current_x						
		    mouse_start_y := mouse_current_y

        }

        if( !GetKeyState("RButton", "P") ){
        
            if ( A_TimeSinceThisHotkey < 100 ){
                WinMinimize( HWND_window )
            }
            
            SetTimer resizeWindowDx_Down, 0
        
        }

        return
    }

   resizeWindowSx_Down(){

        MouseGetPos( &mouse_current_x, &mouse_current_y )											
        WinGetPos( &window_start_x, &window_start_y, &window_width, &window_height, HWND_window )

        window_minmax := WinGetMinMax( HWND_window )

        if( window_minmax != 1){

            delta_x := mouse_current_x - mouse_start_x
            delta_y := mouse_current_y - mouse_start_y
            
            new_x := window_start_x + delta_x
		    
            new_width  := window_width  - delta_x
            new_height := window_height + delta_y

            WinMove( new_x, window_start_y, new_width, new_height, HWND_window )

            mouse_start_x := mouse_current_x						
		    mouse_start_y := mouse_current_y

        }

        ; Termino Resize
        if( !GetKeyState("RButton", "P") ){
        
            ; Se è un click singolo minimizzo la window    
            if ( A_TimeSinceThisHotkey < 100 ){
                WinMinimize( HWND_window )
            }

            SetTimer resizeWindowSx_Down, 0
        
        }
        
        return
    }

}
