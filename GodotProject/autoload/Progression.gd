extends Node
#this will be registered as a singleton. 
#track the progress of all riddles and base the walkthrough on it
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
