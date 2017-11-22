extends RigidBody2D

var addFakeSpeed = false
var dangerous = true

sync var rock_slave_pos = Transform2D()
sync var rock_slave_lin_vel = Vector2()
sync var rock_slave_ang_vel = 0
onready var shadowSprite = get_node("CollisionShape2D/shadow")

func _ready():
	if get_tree().is_network_server():
		set_physics_process(true)
	pass

func _on_body_entered( body ):
	if get_tree().is_network_server():
		if body.is_in_group("ground") and get_parent().get_name()=="rockShower":
			addFakeSpeed = true
			dangerous = false

func _physics_process(delta):
	if is_inside_tree() and get_tree().is_network_server():
		if addFakeSpeed:
			global_position.x-=get_parent().game.fakeSpeed*delta
			
		rset("rock_slave_pos",get_transform())
		rset("rock_slave_lin_vel",get_linear_velocity())
		rset("rock_slave_ang_vel",get_angular_velocity())
	elif !get_tree().is_network_server():
		set_transform(rock_slave_pos)
		linear_velocity = rock_slave_lin_vel
		angular_velocity = rock_slave_ang_vel
		
	elif !is_inside_tree():
		set_physics_process(false)
	if is_inside_tree():
		shadowSprite.global_position.y = 372
		shadowSprite.global_position.x = position.x
		shadowSprite.scale=Vector2(global_position.y+1000,global_position.y+2000)/5000
func _on_VisibilityNotifier2D_screen_exited():
	if get_tree().get_nodes_in_group("rocks").size()<=1:
		get_parent().removeRockShowerNode()
	if is_inside_tree():
		queue_free()
	pass # replace with function body