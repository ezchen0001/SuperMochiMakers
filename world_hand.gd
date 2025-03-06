class_name WorldHand
extends Node2D

const PORT: int = 4242
const WATER_RADIUS = 180
const MOCHI_RADIUS = 300

var wet = false


var server: UDPServer

var joints = []
var connections = []
var left_hand: Hand
var right_hand: Hand

func _ready() -> void:
	server = UDPServer.new()
	server.listen(PORT)
	
	left_hand = _create_new_hand()
	right_hand = _create_new_hand()
	
	for i in range(left_hand.NUM_LANDMARKS):
		joints.append($Center.duplicate())
		add_child(joints.back())
		joints.back().name = "Joint_%s" % i
		joints.back().modulate = Color(1,1,1,0.5)
	$Center.modulate = Color.RED
	for i in left_hand.HAND_LINES_MAPPING:
		connections.append($Connection.duplicate())
		var connection = connections.back()
		add_child(connection)
		connection.modulate = Color(1,1,1,0.5)
		#connection.name = "Connection_%s" % i
		

func _create_new_hand() -> Hand:
	var hand_instance := Hand.new()
	add_child(hand_instance)
	return hand_instance

func _parse_hands_from_packet(data: PackedByteArray) -> Dictionary:
	var json_string = data.get_string_from_utf8()
	var json = JSON.new()
	
	var error = json.parse(json_string)
	assert(error == OK)
	
	var data_received = json.data
	assert(typeof(data_received) == TYPE_DICTIONARY)
	
	return data_received

var color = Color(1,1,1,1)

func _process(_delta: float) -> void:
	server.poll()
	if server.is_connection_available():
		var peer = server.take_connection()
		var data = peer.get_packet()
		var hands_data = _parse_hands_from_packet(data)
		
		
		
		if hands_data["left"] != null:
			modulate = color
			$Center.position = (left_hand.pos_average(hands_data["left"])) 
			left_hand.reposition_node_landmarks(joints,hands_data["left"])
			#left_hand.parse_hand_landmarks_from_data(hands_data["left"])
			var i = 0
			for v in left_hand.HAND_LINES_MAPPING:
				var connection = connections[i]
				connection.points[0] = joints[v[0]].position
				connection.points[1] = joints[v[1]].position
				i += 1
		elif hands_data["right"] != null:
			modulate = color
			$Center.position = (left_hand.pos_average(hands_data["right"])) 
			left_hand.reposition_node_landmarks(joints,hands_data["right"])
			#left_hand.parse_hand_landmarks_from_data(hands_data["left"])
			var i = 0
			for v in left_hand.HAND_LINES_MAPPING:
				var connection = connections[i]
				connection.points[0] = joints[v[0]].position
				connection.points[1] = joints[v[1]].position
				i += 1
		else:
			var tween = create_tween()
			tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
		#if hands_data["right"] != null:
		#	right_hand.parse_hand_landmarks_from_data(hands_data["right"])
	if not wet and ($Center.global_position - get_parent().get_node("Water").global_position).length() < WATER_RADIUS:
		make_wet()
		pass
	
	if wet and ($Center.global_position - get_parent().get_node("WoodBowl").global_position).length() < MOCHI_RADIUS:
		make_dry()
		get_parent().get_node("WoodBowl").make_wet()
		pass

func make_wet():
	if wet:
		return
	wet = true
	add_child(VFX.create_splash($Center.global_position))
	color = Color.SKY_BLUE
	$Splash.play()
	
func make_dry():
	if not wet:
		return
	wet = false
	add_child(VFX.create_splash($Center.global_position))
	color = Color.WHITE
	$Splash.play()
