extends Control

signal selection_made

var error_container_ref : Control

func new_onebutton_window(title, body, button):
	error_container_ref.init()
	error_container_ref.set_title(title)
	error_container_ref.set_body(body)
	error_container_ref.set_confirm_text(button)
	error_container_ref.set_one_button()
	error_container_ref.visible = true
	error_container_ref.animate_on()

func new_twobutton_window(title, body, confirm, deny):
	error_container_ref.init()
	error_container_ref.set_title(title)
	error_container_ref.set_body(body)
	error_container_ref.set_confirm_text(confirm)
	error_container_ref.set_deny_text(deny)
	error_container_ref.set_two_button()
	error_container_ref.visible = true
	error_container_ref.animate_on()
