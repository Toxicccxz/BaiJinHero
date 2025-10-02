extends Control
signal request_resume
signal request_settings
signal request_goto_title
signal request_quit

@onready var btn_resume   := $Panel/Buttons/BtnResume
@onready var btn_settings := $Panel/Buttons/BtnSettings
@onready var btn_title    := $Panel/Buttons/BtnTitle
@onready var btn_quit     := $Panel/Buttons/BtnQuit

func _ready():
	btn_resume.pressed.connect(   func(): emit_signal("request_resume"))
	btn_settings.pressed.connect( func(): emit_signal("request_settings"))
	btn_title.pressed.connect(    func(): emit_signal("request_goto_title"))
	btn_quit.pressed.connect(     func(): emit_signal("request_quit"))
