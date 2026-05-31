extends Node
#this will be registered as a singleton. 
#track the progress of all riddles and base the walkthrough on it

#signal, that will change every time player completes quest
signal stage_changed(new_stage_text: String)

var riddles = {
	"cable_hex": false,
	"button_order": false,
	"wire_loop": false,
	"circuit_gta": false,
	"chess_password": false,
	"fifty_fifty_button": false,
	"locker_key_found": false,
	"locker_unlocked": false,
	"captcha_riddle": false
}

func complete_riddle(riddle_id: String):
		if(riddles.has(riddle_id)):
			riddles[riddle_id] = true
			#for debugging
			print(riddle_id, " solved!")
			
			# send signal with new text for UI
			stage_changed.emit(get_current_stage_text())
			

#function that controls, where player currently is
func get_current_stage_text() -> String:
	if not riddles["cable_hex"]:
		return "CURRENT OBJECTIVE: find and repair damaged cables"
	if not riddles["button_order"]:
		return "CURRENT OBJECTIVE: enter the correct button order"
	if not riddles["wire_loop"]:
		return "CURRENT OBJECTIVE: connect the wires"
	if not riddles["circuit_gta"]:
		return "CURRENT OBJECTIVE: crash into the circuit board"
	if not riddles["chess_password"]:
		return "CURRENT OBJECTIVE: solve the chess cipher"
	if not riddles["fifty_fifty_button"]:
		return "CURRENT OBJECTIVE: good luck with this button my nigga"
	if not riddles["locker_key_found"]:
		return "CURRENT OBJECTIVE: find key from the locker"
	if not riddles["locker_unlocked"]:
		return "CURRENT OBJECTIVE: unlock locker"
	if not riddles["captcha_riddle"]:
		return "CURRENT OBJECTIVE: solve the final Captcha code to escape"
		
	return "All tasks completed! Escape!"
