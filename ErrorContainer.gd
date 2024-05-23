extends Control

@onready var Window_Ref : Panel = $ErrorWindow
@onready var Message_Title : Label = $ErrorWindow/VBoxContainer/TopPanel/Message_Title
@onready var Message_Body : Label = $ErrorWindow/VBoxContainer/MarginContainer/Message_Body
@onready var Deny_Button : Button = $ErrorWindow/VBoxContainer/ButtonContainer/Deny_Button
@onready var Confirm_Button : Button = $ErrorWindow/VBoxContainer/ButtonContainer/Confirm_Button

# Called when the node enters the scene tree for the first time.
func _ready():
	ErrorHandling.error_container_ref = self
	init()
	
func init():
	self.set_modulate(Color("ffffff00"))
	self.visible = false

func set_title(title):
	Message_Title.text = title

func set_body(body):
	Message_Body.text = body

func set_deny_text(text):
	Deny_Button.text = text

func set_confirm_text(text):
	Confirm_Button.text = text

func set_one_button():
	Deny_Button.visible = false

func set_two_button():
	Deny_Button.visible = true

func animate_on():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color("ffffffff"), 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func animate_off():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color("ffffff00"), 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	init()


func _on_confirm_button_pressed():
	animate_off()
	ErrorHandling.selection_made.emit(1)


func _on_deny_button_pressed():
	animate_off()
	ErrorHandling.selection_made.emit(0)
