CoordMode( "Mouse", "Screen" )
SetWinDelay( -1 )

global WIDTH_STEP  := 60
global HEIGHT_STEP := 40

; ------  ------  ------  ------
; ------ GESTIONE window DA TASTIERA ------
Alt & \::{

    global SERVICE := 1   

    KeyWait "Alt"
    
    global SERVICE := 0 
    
    return
}

#HotIf ( SERVICE == 1 && GetKeyState("Shift") ) 

    Alt & Left::{
        
        WinGetPos( &x, &y, &width, &height, WinGetTitle("A") )
        WinMove( x, y, width - WIDTH_STEP, height, WinGetTitle("A") )
    
    }

    Alt & Right::{
      
        WinGetPos( &x, &y, &width, &height, WinGetTitle("A") )
        WinMove( x, y, width + WIDTH_STEP, height, WinGetTitle("A") )
    
    }

    Alt & Up::{
       
        WinGetPos( &x, &y, &width, &height, WinGetTitle("A") )
        WinMove( x, y, width, height - HEIGHT_STEP, WinGetTitle("A") )
   
   }

    Alt & Down::{
       
        WinGetPos( &x, &y, &width, &height, WinGetTitle("A") )
        WinMove( x, y, width, height + HEIGHT_STEP, WinGetTitle("A") )
   
    }

#HotIf ( SERVICE == 1 && !GetKeyState("Shift")) 

    Alt & +::{
       
        WinGetPos( &x, &y, &width, &height, WinGetTitle("A") )
        MonitorGetWorkArea( getMonitorFromMouse(), &left_bound, &top_bound, &right_bound, &bottom_bound )

        new_x := x - (WIDTH_STEP  / 2)
        new_y := y - (HEIGHT_STEP / 2)
        
        new_width  := width  + WIDTH_STEP
        new_height := height + HEIGHT_STEP

        if( new_x < left_bound ){
            new_x := left_bound - 6
        }
    
        if( new_y < top_bound ){
            new_y := top_bound
        }

        if( (new_x + new_width) > right_bound ){
            new_width := new_width - ((new_x + new_width) - right_bound) + 6
        }
         
        if( (new_y + new_height) > bottom_bound ){
            new_height := new_height - ((new_y + new_height) - bottom_bound) + 6
        }

        WinMove( new_x, new_y, new_width, new_height, WinGetTitle("A") )
    
    }  

    Alt & -::{
       
        WinGetPos( &x, &y, &width, &height, WinGetTitle("A") )
        MonitorGetWorkArea( getMonitorFromMouse(), &left_bound, &top_bound, &right_bound, &bottom_bound )

        new_x := x + (WIDTH_STEP  / 2)
        new_y := y + (HEIGHT_STEP / 2)
        
        new_width  := width  - WIDTH_STEP
        new_height := height - HEIGHT_STEP

        WinMove( new_x, new_y, new_width, new_height, WinGetTitle("A") )
    
    } 
    
    Alt & Enter::{

        MonitorGetWorkArea( getMonitorFromMouse(), &left_bound, &top_bound, &right_bound, &bottom_bound )
        WinGetPos( &x, &y, &width, &height, WinGetTitle("A") )

        window_center_x := width  / 2
        window_center_y := height / 2

        monitor_center_x := left_bound   + ((right_bound - left_bound) / 2)
        monitor_center_y := bottom_bound + ((top_bound - bottom_bound) / 2)

        WinMove( monitor_center_x - window_center_x, monitor_center_y - window_center_y, width, height, WinGetTitle("A") )
    
    }

    Alt & Left::{
       
        WinGetPos( &x, &y, &width, &height, WinGetTitle("A") )
        WinMove( x - 50, y, width, height, WinGetTitle("A") )
    
    }

    Alt & Right::{
   
        WinGetPos( &x, &y, &width, &height, WinGetTitle("A") )
        WinMove( x + 50, y, width, height, WinGetTitle("A") )
  
    }

    Alt & Up::{
   
        WinGetPos( &x, &y, &width, &height, WinGetTitle("A") )
        WinMove( x, y - 50, width, height, WinGetTitle("A") )
  
    }

    Alt & Down::{
   
        WinGetPos( &x, &y, &width, &height, WinGetTitle("A") )
        WinMove( x, y + 50, width, height, WinGetTitle("A") )
  
    }

#HotIf

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