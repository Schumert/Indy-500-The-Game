extends Node



# Ceza süresi (saniye)
const PENALTY_DURATION = 5.0  

var elapsed_time = 0.0
var duration = 8.0  #duration of reducing penalty counter

func _process(delta):
	pass
		

func on_offroad_enter(body):
	if body is CharacterBody2D and (body.collision_layer & (1 << 1) != 0 or body.collision_layer & (1 << 4) != 0):  
		if self.is_in_group("grass"):
			# Ceza puanını artır
			add_penalty(body)
			AudioManager.play_crash()
			if Global.game_world.penalty_points.get(body.car_id, 0) < 3:
				body.friction = -300
				body.engine_power /= 3
				

func on_offroad_exit(body):
	if body is CharacterBody2D and (body.collision_layer & (1 << 1) != 0 or body.collision_layer & (1 << 4) != 0):
		if Global.game_world.penalty_points.get(body.car_id, 0) < 3:
			body.friction = body.temp_friction
			body.engine_power = body.temp_engine_power
			
		


## 📌 Ceza Puanı Fonksiyonu
func add_penalty(body):
	var player_id = body.car_id 

	# Eğer oyuncunun ceza puanı yoksa, başlat
	if not Global.game_world.penalty_points.has(player_id):
		Global.game_world.penalty_points[player_id] = 0
		Global.gui.update_penalty_info(true, "PENALTY POINT: 0");

	# Ceza puanını artır
	Global.game_world.penalty_points[player_id] += 1
	print("Oyuncu ", player_id, " ceza puanı: ", Global.game_world.penalty_points[player_id])
	var message = "Player" + " penalty point: " + str(Global.game_world.penalty_points[player_id])

	Global.gui.update_penalty_info(true, message);

	# Eğer ceza puanı 3'e ulaştıysa, ağır ceza uygula
	if Global.game_world.penalty_points[player_id] >= 3:
		apply_penalty(body)


## 📌 Ağır Ceza Uygulama Fonksiyonu (3 Ceza Puanı Alınca)
func apply_penalty(body):
	print("Oyuncu ", body.car_id, " ağır penaltıya girdi! 🚨")
	Global.gui.update_penalty_info(true, "PENALTY IS ACTIVE!!!!!");

	body.engine_power = 1000
	body.power /= 3
	body.is_car_broken = true;
	
	

	# back to normal
	await get_tree().create_timer(PENALTY_DURATION).timeout

	body.engine_power = body.temp_engine_power
	body.is_car_broken = false;
	
	
	

	print("Oyuncu ", body.car_id, " tekrar normale döndü! 🏁")
	Global.gui.update_penalty_info(false, "");
	Global.game_world.penalty_points[body.car_id] = 0  # Ceza sonrası puanı sıfırla
