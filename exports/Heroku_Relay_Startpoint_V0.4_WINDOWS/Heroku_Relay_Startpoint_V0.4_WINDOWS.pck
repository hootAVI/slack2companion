GDPC                                                                                          X   res://.godot/exported/133200997/export-1ea1666b9e7c9227f3425d55cfdad62b-command_line.scnp      <      ��?���C��5�,.g�    P   res://.godot/exported/133200997/export-3070c538c03ee49b7677ff960a3f5195-main.scn�`      )      ��?d)L	{Z�CB    ,   res://.godot/global_script_class_cache.cfg  ��             ��Р�8���8~$}P�    H   res://.godot/imported/Trash.png-8431cd6d3690fc057ca327a6a124bc11.ctex   �7      V      ّ��k��[�izL��r    D   res://.godot/imported/icon.svg-c9c2a32fd2d5f8bc98ecd887f02eeda7.ctex`      �      �̛�*$q�*�́     P   res://.godot/imported/spinner_progress.png-86f02dffcaf2116a7c246c69b3b15eff.ctex +      �      ����s`�D7��       res://.godot/uid_cache.bin  ��      �       dr�NA����Ϡ�{       res://ErrorContainer.gd ��      �      �	Nz���3�M�M�p�    (   res://Scenes/CommandLine/Command_Line.gd        g      ��+��e3��������    0   res://Scenes/CommandLine/command_line.tscn.remap��      i       Q�K���C#�t�zͥ        res://Scripts/CommandMapping.gd �            �E��6K�P,�:�sÖ       res://Scripts/Debugger.gd   �      �      P��E l�<%Lh��    $   res://Singletons/CommandMapper.gd   `            '�H��SA�ƛ�    $   res://Singletons/ErrorHandling.gd   �      �      L�{�N����_MB�       res://UI/Trash.png.import   �B      �       ��{M��,�A� q0�       res://UI/icon.svg   ��      �      C��=U���^Qu��U3       res://UI/icon.svg.import@*      �       ����|�s��g4�;�]    $   res://UI/spinner_progress.png.import�6      �       {6ɚNA�Ү�݌�        res://main.gd   �C            ��Q�Q�Q�9쓒���j       res://main.tscn.remap   P�      a       �J�Sw� ������       res://project.binary`�      [      =��H���1H8Zq�ei                extends Panel

@onready var sc_line : LineEdit = $MarginContainer/HBoxContainer/SC_LineEdit
@onready var cc_line : LineEdit = $MarginContainer/HBoxContainer/CC_LineEdit

@export var id : int

var key : String = ""
var value : String = ""
var command_pair : Dictionary = {"":""}

func update_text(sc : String, cc : String):
	sc_line.text = sc
	key = sc
	
	cc_line.text = cc
	value = cc

func _on_delete_button_pressed():
	CommandMapper.command_dict.erase(str(id))
	CommandMapper.save_commands()
	
	self.queue_free()


func _on_sc_line_edit_text_changed(new_text):
	key = new_text
	command_pair = {key : value}
	CommandMapper.command_dict[str(id)] = command_pair
	CommandMapper.save_commands()


func _on_cc_line_edit_text_changed(new_text):
	value = new_text
	command_pair = {key : value}
	CommandMapper.command_dict[str(id)] = command_pair
	CommandMapper.save_commands()
         RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script )   res://Scenes/CommandLine/Command_Line.gd ��������
   Texture2D    res://UI/Trash.png �;
N6�s      local://PackedScene_o2ruw M         PackedScene          	         names "   %      Command_Line    custom_minimum_size    size_flags_horizontal    script    Panel    MarginContainer    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical %   theme_override_constants/margin_left &   theme_override_constants/margin_right    HBoxContainer    size_flags_vertical 	   SC_Label    text    Label    SC_LineEdit 	   LineEdit    Spacer    size_flags_stretch_ratio    Control 	   CC_Label    CC_LineEdit    Spacer2    DeleteButton    icon    icon_alignment    expand_icon    Button    _on_sc_line_edit_text_changed    text_changed    _on_cc_line_edit_text_changed    _on_delete_button_pressed    pressed    	   variants       
         B                                 �?                        Slack Command:    �>      Companion API Call      �>
      B   B                     node_count    
         nodes     �   ��������       ����                                        ����                     	      
                                         ����                                      ����            	                    ����                                ����                  
                    ����                                ����                                ����                                      ����                                           conn_count             conns               !                         !   "              	       $   #                    node_paths              editable_instances              version             RSRC    extends MarginContainer

@onready var command_line_scene = preload("res://Scenes/CommandLine/command_line.tscn")
@onready var command_holder = $Main_VBox/CommandScroller/CommandHolder

#TODO add a "defaults" button that overwrites "last_saved_commands" with the first time user dictionary.
#TODO add a universal error window to prevent stupid mistakes like the default button, or deleting a command

func _ready():
	CommandMapper.command_mapping_screen_ref = self
	CommandMapper.load_commands()
	ErrorHandling.selection_made.connect(set_defaults)


func add_command_line(sc:String, cc:String, id:String):
	var new_command = command_line_scene.instantiate()
	new_command.id = id
	command_holder.add_child(new_command)
	new_command.update_text(sc, cc)

func _on_button_pressed():
	var id = str(randi())
	add_command_line("", "", id)
	CommandMapper.add_command("", "", id)

func _on_default_button_pressed():
	ErrorHandling.new_twobutton_window("Restore Defaults", "Would you like to replace all currently mapped commands with the defaults?\n(Not undo-able)", "Yes", "No")

func set_defaults(selection):
	match selection:
		0:
			print("no")
		1:
			print("yes")
			CommandMapper.save_defaults()
			for i in command_holder.get_children():
				i.queue_free()
			CommandMapper.load_commands()
        extends Control
	
@onready var http_line_edit = $VBoxContainer/PostRequest_LineEdit
@onready var http_output_log = $VBoxContainer/PostRequest_Log
@onready var command_output_log = $VBoxContainer/LogHolder/CommandOutput

func update_logs():
	if CommandMapper.command_dict.size() > 0:
		command_output_log.text = JSON.stringify(CommandMapper.command_dict, "\t")

func _on_button_pressed():
	$HTTPRequest.cancel_request()
	$HTTPRequest.request(http_line_edit.text, [], HTTPClient.METHOD_POST)
	http_output_log.text = "COMMAND: " + http_line_edit.text + "\n Waiting for reply..."


func _on_http_request_request_completed(result, response_code, headers, body):
	http_output_log.text = "COMMAND: " + http_output_log.text + "\n"
	http_output_log.text += "RESULT: " + str(result) + "\nRESPONSE_CODE: " + str(response_code) + "\nHEADERS: " + str(headers) + "\nBODY: " + str(body) + "\nBODY (utf8): " + str(body.get_string_from_utf8())
 extends Node

var command_mapping_screen_ref
var filepath : String = "user://last_saved_commands.conf"
var command_dict : Dictionary = {}
#command_id(int): {slack_command(string) : companion_command(string)}

	#TODO - Make it so commands are saved to disk every time a command_line is changed
	# Also make it so on first launch, a set of default commands are saved

func load_commands():
	if FileAccess.file_exists(filepath):
		print("file found")
		var file = FileAccess.open(filepath, FileAccess.READ)
		var content = file.get_as_text()
		command_dict = JSON.parse_string(content)
		file.close()

	else:
		print("no file found")
		save_defaults()
		
	for i in command_dict:
		command_mapping_screen_ref.add_command_line(command_dict[i].keys()[0], command_dict[i].values()[0], str(i))

func save_commands():
	print("saved")
	print(command_dict)
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	file.store_line(JSON.stringify(command_dict))
	file.close()

func save_defaults():
	command_dict = {
		"1":
			{"/lights-on":"/api/custom-variable/LightStatus/value?value=1"},
		"2":
			{"/lights-off":"/api/custom-variable/LightStatus/value?value=0"},
		"3":
			{"/backup-record":"/api/custom-variable/BackupRecord/value?value=1"},
		"4":
			{"/backup-stop":"/api/custom-variable/BackupRecord/value?value=0"}
	}
	save_commands()

func add_command(slack_command : String, companion_command : String, command_id : String):
	var command_pair : Dictionary = {slack_command : companion_command}
	command_dict[int(command_id)] = command_pair
	save_commands()
            extends Control

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
   GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح�m�m������$$P�����එ#���=�]��SnA�VhE��*JG�
&����^x��&�+���2ε�L2�@��		��S�2A�/E���d"?���Dh�+Z�@:�Gk�FbWd�\�C�Ӷg�g�k��Vo��<c{��4�;M�,5��ٜ2�Ζ�yO�S����qZ0��s���r?I��ѷE{�4�Ζ�i� xK�U��F�Z�y�SL�)���旵�V[�-�1Z�-�1���z�Q�>�tH�0��:[RGň6�=KVv�X�6�L;�N\���J���/0u���_��U��]���ǫ)�9��������!�&�?W�VfY�2���༏��2kSi����1!��z+�F�j=�R�O�{�
ۇ�P-�������\����y;�[ ���lm�F2K�ޱ|��S��d)é�r�BTZ)e�� ��֩A�2�����X�X'�e1߬���p��-�-f�E�ˊU	^�����T�ZT�m�*a|	׫�:V���G�r+�/�T��@U�N׼�h�+	*�*sN1e�,e���nbJL<����"g=O��AL�WO!��߈Q���,ɉ'���lzJ���Q����t��9�F���A��g�B-����G�f|��x��5�'+��O��y��������F��2�����R�q�):VtI���/ʎ�UfěĲr'�g�g����5�t�ۛ�F���S�j1p�)�JD̻�ZR���Pq�r/jt�/sO�C�u����i�y�K�(Q��7őA�2���R�ͥ+lgzJ~��,eA��.���k�eQ�,l'Ɨ�2�,eaS��S�ԟe)��x��ood�d)����h��ZZ��`z�պ��;�Cr�rpi&��՜�Pf��+���:w��b�DUeZ��ڡ��iA>IN>���܋�b�O<�A���)�R�4��8+��k�Jpey��.���7ryc�!��M�a���v_��/�����'��t5`=��~	`�����p\�u����*>:|ٻ@�G�����wƝ�����K5�NZal������LH�]I'�^���+@q(�q2q+�g�}�o�����S߈:�R�݉C������?�1�.��
�ڈL�Fb%ħA ����Q���2�͍J]_�� A��Fb�����ݏ�4o��'2��F�  ڹ���W�L |����YK5�-�E�n�K�|�ɭvD=��p!V3gS��`�p|r�l	F�4�1{�V'&����|pj� ߫'ş�pdT�7`&�
�1g�����@D�˅ �x?)~83+	p �3W�w��j"�� '�J��CM�+ �Ĝ��"���4� ����nΟ	�0C���q'�&5.��z@�S1l5Z��]�~L�L"�"�VS��8w.����H�B|���K(�}
r%Vk$f�����8�ڹ���R�dϝx/@�_�k'�8���E���r��D���K�z3�^���Vw��ZEl%~�Vc���R� �Xk[�3��B��Ğ�Y��A`_��fa��D{������ @ ��dg�������Mƚ�R�`���s����>x=�����	`��s���H���/ū�R�U�g�r���/����n�;�SSup`�S��6��u���⟦;Z�AN3�|�oh�9f�Pg�����^��g�t����x��)Oq�Q�My55jF����t9����,�z�Z�����2��#�)���"�u���}'�*�>�����ǯ[����82һ�n���0�<v�ݑa}.+n��'����W:4TY�����P�ר���Cȫۿ�Ϗ��?����Ӣ�K�|y�@suyo�<�����{��x}~�����~�AN]�q�9ޝ�GG�����[�L}~�`�f%4�R!1�no���������v!�G����Qw��m���"F!9�vٿü�|j�����*��{Ew[Á��������u.+�<���awͮ�ӓ�Q �:�Vd�5*��p�ioaE��,�LjP��	a�/�˰!{g:���3`=`]�2��y`�"��N�N�p���� ��3�Z��䏔��9"�ʞ l�zP�G�ߙj��V�>���n�/��׷�G��[���\��T��Ͷh���ag?1��O��6{s{����!�1�Y�����91Qry��=����y=�ٮh;�����[�tDV5�chȃ��v�G ��T/'XX���~Q�7��+[�e��Ti@j��)��9��J�hJV�#�jk�A�1�^6���=<ԧg�B�*o�߯.��/�>W[M���I�o?V���s��|yu�xt��]�].��Yyx�w���`��C���pH��tu�w�J��#Ef�Y݆v�f5�e��8��=�٢�e��W��M9J�u�}]釧7k���:�o�����Ç����ս�r3W���7k���e�������ϛk��Ϳ�_��lu�۹�g�w��~�ߗ�/��ݩ�-�->�I�͒���A�	���ߥζ,�}�3�UbY?�Ӓ�7q�Db����>~8�]
� ^n׹�[�o���Z-�ǫ�N;U���E4=eȢ�vk��Z�Y�j���k�j1�/eȢK��J�9|�,UX65]W����lQ-�"`�C�.~8ek�{Xy���d��<��Gf�ō�E�Ӗ�T� �g��Y�*��.͊e��"�]�d������h��ڠ����c�qV�ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[             [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://jnq6wqehaclh"
path="res://.godot/imported/icon.svg-c9c2a32fd2d5f8bc98ecd887f02eeda7.ctex"
metadata={
"vram_texture": false
}
 GST2   x   x      ����               x x        r  RIFFj  WEBPVP8L^  /w��$I��6��C���]�Q3k��!��$A��?��u���5l�ο��K�A�-���=v�6g۶���mo�m�Ӽ�F8����Hp�H�$�F��Q�sT���mgR!��������=�w���s��^:�J� �A%�^�r����C�!�"���1���xYD2Kf��4!�h��t;�*���DOX0��Nt#}���MqT��~N� 
N�"LH �r�C#���-�+-'	W�
NR��{U�E���O�8&�-4���rF��Y��$z�f�+b���%�$|򙅌��.�k�!�F#nqy�U�/�4}ƿ���	K,�+Q�xYT��XFa��Ir�^	6"> �Sq��7���E�@�R5�+�ؽI��\{)�GDڽ�Z�
={{=5׊��!��u
k��R3�����}kM;���`�!>&*eD�ў�5z�/�s�Foz���35t)�G|P4�ŵc�Ѣ�͈~2z�k;R2���jeD�:��Sސ̬�3��a�{�nu�}��\�DK�ۍ�Wo�ݪ���t��â|�gv��k8�1�P1<�9ڝܾH�1׺���uq�1�d��s�v��ؿNa�ì�!TB-hb���nD[�pqU�s�0@m�J̧��Sc+Z���{	���MNW $���9�1�n7z����Jף�7w�{�vϯw��� �t1Ƭk]����Q�7#�f=��sG�8��V�r�����g=���9)�]��u}�:��~��\�$v��#[sy3����o=v�k��Z�:���>Ćl-K�������	���\���/�vgʺʚ/(A[�[Ćڵ�Mn� e}P��bOf=��쾾�J�x�ƍω��W;..R(�>�8�xC�0��M�>�"#6�=�\7���@zcj�g<���x@BB������;,v�p�@�]�.��ZW	s|<��t�*��]�Ha�qb#g ����J��&}�ZB�;	���4����A� 6���z�Ss|<h-�C�Pх6��Ll܄�'o�15�ǣ��o�����.r�x�Ss|<l�ǣ�م�����D|/D���-����à�a�����2�A���@���w4!�A���B��X�8��XB���`vQw������b���'���s��4�|�� ��ׄ���ӕj{`.�?������zRq|��Ñ��=�S���u�����Nj^r���7=�����W��O���?�	����+�73f�;�-�7Z�g<��A��*��Ͼpm�I�ZD���qw�p�8�W0Ʈ�ݯ!4��d������x�1&�v�kA���� |Ҽ��O�l�ZhwjB�����	�}��YCDn_���� Z���]�ǸIr||2P��D,�Ö��u��p�:�W����O����j¯�8N�f�
�m�7QOx||DO�Mn��t��K>��+�	����~�n�^I����r��@%նX/�K�?��+�M jj���1�_fj�/@f����/>����������ʏ��3��������&�
&�7z����������_�������K� �-��/9��7�|��"Z�z�e#Ղ�ń��	�}-��e�j�� �f]�C���� ��w{���;�G]�E�o5B�6v�^_o�B�r��Kff�{`5��+��4��������-v�^��˘u�#6��TM-��5�%�E��o��������G��=1v��7aƌ��:�����c�����9��;�������qܫ�h8�����ρ�=Ps����=�ab3�u=���'�h�{ �H��m)��D�\����h4Z����3K5�wp� `v�*�L�ǣ� ��&؇����+��)A.�7qo;��3�AM4����z^��fJ�`�	�t�0`E�`ڝ��y�ad5r�	�p�B�uA�7���y��ƍBC��z�$"ņ�Ѩz�_;�ч9�f��&ب'-0��A�+����)�f�B�Ct�&{<��!��%��}:���k<wM�P1~Ata�=���A�}>��W�ԕɄ%��]�����Ly����
ox�	�wYW�0q�P�h�ޞI=��!y(���C� I�n]a� K�]h@�A��w*i>8������X�1��KK���;Ćt5!�z�R!X���tf�	v0!!ua�`?b����A5��u�S�2Ď���ZW���화$$X�[L�PA�$q�qf��ԛ���Y�V^��\+�0�ub*&/z�����4R�W��h/�h���;c�҅	��E��������T�5�Į�����[0���+�r�w�6[S�4��#�E-�{h e� �1˘�{��|�&(��'^_�W��k��)�f�'�O�2Zfo��l���n��%Z���n���7�n�7���9��J��WP��C��/⣢������=WJ��D4|4�T���s����c��e�	:��7�|��1LM�n�գgD��bg�:NM{��c=��[��s��S�1CkǌY��6}	l��'rp�;֮c�\{����{-�����سv��D�(ӛ�8�W���z�\+bk� V�w�=���#�^sK�J{��aw!�?��\_yO=���c��^��W�I�����O�s|<��qfC��=��a9Ο[��缦�833@#�⥗V�`�`p�D��jb��4�_��M!5���Ni
� �T>�[LoqO=z�����x��;���r�C�3P[nW"�pq�����%Im ���?��]�?����p���7����# -���}l6�@����4��o(5cS���ei4��r@&�/��=j�`�� *��/��؏�Xa�h��y���L d<�	L�n=�      [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://pacg6l4c4cmp"
path="res://.godot/imported/spinner_progress.png-86f02dffcaf2116a7c246c69b3b15eff.ctex"
metadata={
"vram_texture": false
}
     GST2   �   �     �����               � �       �  RIFF�  WEBPVP8X
          ALPH7  ���!�����֦�Ķ��m��[ol;Oڪ8���l�mƘ��q5=����;~��	�'1�X���!}� ��wb&�X4��˟���i�=�,��k7�;L�][.1��k�j��{"�~]��`��_�`ʘ��c6g�9��+8����1�n��%D�cS�`�s�O:�U;�bk�?��l�h�为
�������/M��^�d�H��_�߹c�G��3�G��K�z�!{+uy{O>�V����c�6�[OAٻ��h�'����O߱B(1��Eb�R��o��P�9 �Eb%�1}�=��9�\�_w�����{0���)?X1.�1��렲������j����(��eRx�3�'��H��g�
�MȮ��]ف�H�^�$��	|	�՚�.��<���'�Bj�'��D�� -8�Cx"ҳX�����Y[M�@W��S��7d[�/@���5|WrR	P���G%ANR��r!�6���#p&�p�4�i����:$���:�e�+	��4�'�1�=����.f�Pk�֫I4N�5��D��h^����t]�C�!�]��%	��Y��.��,��e8�|WB�Y+Nh{�bj�|C0��q2?@O�������<If����~I����2?�@���oŔ*���'E�L?� ��.��ݔ`Vd﷗���^1�/���#˸o�����Ut�-��L[ ��!�ד�@�4�V�0 ���Q���s)�V���)-���<������ Q�N��j2� u	"=`;����\g;=�����ǜ=��0�d�q& VP8 x   �
 �*� � >�F�J����� ��in�
k~�	ɵqAi��<��T�6�F�o	M�N<ґ6pK�J�����خ�c�_�|-�_�U��L���@ ���w��l�V�B�˙�����I0 �  RIFF�  WEBPVP8X
      ?  ?  ALPH3  �tk�!IoT�m۶m۶=��/�^�Ҷm�6۶�U�}��F���Zt�Zo�N�V����x��i5���c�i�A-.�C�g)�TieQJց���픒���j�[uۣQ����Q���f��nÊZ�[q����s���nԝW����`��܉���0�G����ơr��)�c��3.��qW)΢��[kD��q�u-��-�i��}j��t��4�����e����d��M�� ��\����Br@X��
FW� �7���W����|�)�=�D�iP(�R�+�:xlQA�T�4�;��E{�۰����zN�y	N�n��@
ʓb�v��5� �BJ�����x�Kawna#I���ۮ03�����u���H�� �)��#���� /;��UU��v��R��A�./�o�@��*���(b��CS��*�	@p0g���-�h(���i�7@�E
����2'�D̀t�����Ư<Ұ;��xR��PgUM(·z��^���}�:ܠ/<΢Y���jƄ�7NT1&�	�M�l���x�!��t�� VP8 H   � �*@ @ >�J�K%�"�� ��i( �;1��!���5����%� �� G���N������g����   �  RIFF�  WEBPVP8X
          ALPHN  ��m���ض�-��5�5�6'��ک�v�mۍm�{�7� ���͊]gL�lF�n׌��Y?�j�˶�o����,�>u��'���t��X���m���[n�1&��4�p�"���W>)l1>��)�X����X��?���_�\��FvG�~#����dp�]�)����>F�o��ğhƱ����4� 6��ڠ� g`T��u�V�J�n@�Ǧp�7i�q�G<�9�.�`�%�c�Mz�x����8X>I�v����+4��J�x�����b������!����tB�Q��@c@�N{&��t���m�ι�pMtZ���VP8 *    �*    >�J�K%�"�� ��i B�iG� �� G�� &  RIFF  WEBPVP8X
          ALPH�   ��m۱��m�������j�*$�Nz��m|�!"& ѲG#�fr�-����l1`GT;���.N~�D�P�ʸS�{���nr���;��y[W����tp�;>)ڴ���s���t����
�|�}�;LX��]�#��/�$�DT����[�A;�!v�C�\0?��x�  VP8 P   0 �*  @8%� Arަ-�  ���gZG�@����	�~�Nȼ����S�/�����\A�t���   �   RIFF�   WEBPVP8X
          ALPHA   $�� �L�     Y��   �Z����1��D� ˟@�a5 ���O nL   �� VP8 D    �*  @8%� ?7��X  ��p��鯘����ڸ�m����HBe�z˥?���ڹ�nr   b   RIFFZ   WEBPVP8X
          ALPH    a��]k��kl��lH��H VP8 "   � �*  @8%� :=@ �����)�A�  P   RIFFH   WEBPVP8X
          ALPH    ���� VP8    � �*  @8%� :=@ ���   H   RIFF@   WEBPVP8X
            ALPH    �VP8    0 �*  @8%� p ��            [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://dq4w5vi3um5u2"
path="res://.godot/imported/Trash.png-8431cd6d3690fc057ca327a6a124bc11.ctex"
metadata={
"vram_texture": false
}
               extends Control

@onready var listening_line : LineEdit = $TabContainer/Main/Main_VBox/VPair1/LineEdit
@onready var pushing_edit : LineEdit = $TabContainer/Main/Main_VBox/VPair2/LineEdit
@onready var timer_edit : SpinBox = $TabContainer/Main/Main_VBox/VPair3/SpinBox
@onready var toggle_button : Button = $TabContainer/Main/Main_VBox/StartStop
@onready var throbber : TextureProgressBar = $TabContainer/Main/Main_VBox/VPair3/TextureProgressBar
@onready var timer : Timer = $Utility/Timer
@onready var HTTPListener : HTTPRequest = $Utility/HTTPListener
@onready var HTTPPusher : HTTPRequest = $Utility/HTTPPusher
@onready var ListenerOutput : TextEdit = $TabContainer/Main/Main_VBox/HBoxContainer/ListenerOutput
@onready var PusherOutput : TextEdit = $TabContainer/Main/Main_VBox/HBoxContainer/PusherOutput
@onready var new_incoming : Label = $TabContainer/Main/Main_VBox/HBoxContainer2/NewIncoming
@onready var new_outgoing : Label = $TabContainer/Main/Main_VBox/HBoxContainer2/NewOutgoing

var listening_address : String
var pushing_address : String
var timer_length : float = 1.0

var toggle_state : bool = false
var stopped_color : Color = Color("ff8983")
var started_color : Color = Color("82ff88")

var last_command : String
var last_sender : String

var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	change_state()
	listening_address = listening_line.text
	pushing_address = pushing_edit.text
	timer_length = timer_edit.value

func _on_start_stop_toggled(toggled_on : bool):
	toggle_state = toggled_on
	change_state()
	
func _on_spin_box_value_changed(value : float):
	timer_length = value
	timer.set_wait_time(timer_length)

func change_state():
	match toggle_state:
		false:
			toggle_button.set_self_modulate(stopped_color)
			toggle_button.text = "Stopped"
			timer.stop()
			if tween:
				tween.kill()
			throbber.value = 0.0

		true:
			toggle_button.set_self_modulate(started_color)
			toggle_button.text = "Started"
			anim_throbber()
			timer.start()

func anim_throbber():
	if tween:
		tween.kill()
	throbber.value = 0.0
	tween = get_tree().create_tween()
	tween.tween_property(throbber, "value", 100, timer_length).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
func _on_timer_timeout():
	anim_throbber()
	try_listen()
	
func try_listen():
	if HTTPListener.get_http_client_status() != 0:
		HTTPListener.cancel_request()
	#HTTPListener.request(listening_address)
	var error = HTTPListener.request(listening_address, [], HTTPClient.METHOD_POST)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _on_http_listener_request_completed(result, response_code, headers, body):
	if body.size() > 2 or result == 999:
		var body_json
		if result == 999:
			body_json = body
		else:
			if JSON.parse_string(body.get_string_from_utf8()):
				body_json = JSON.parse_string(body.get_string_from_utf8())[0]
			else:
				return

		last_command = body_json["command"]
		last_sender = body_json["user_name"]
		ListenerOutput.text = "USER: " + last_sender + "\nCOMMAND: " + last_command
		
		new_incoming.set_self_modulate(Color("ffffffff"))
		var tween = get_tree().create_tween()
		tween.tween_property(new_incoming, "self_modulate", Color("ffffff00"), 1.0)
		
		translate_to_output()

func translate_to_output():
	var outgoing_command : String = "null"
	
	#match last_command:
		#"/lights-on":
			#pass
		#"/lights-off":
			#pass
		#"/backup-record":
			#outgoing_command = "/api/custom-variable/BackupRecord/value?value=1"
		#"/backup-stop":
			#outgoing_command = "/api/custom-variable/BackupRecord/value?value=0"


	for i in CommandMapper.command_dict:
		if last_command in CommandMapper.command_dict[i]:
			print("command " + str(last_command) + " found in " + str(CommandMapper.command_dict[i]))
			print("CC should be: " + str(CommandMapper.command_dict[i].values()[0]))
			outgoing_command = CommandMapper.command_dict[i].values()[0]

			new_outgoing.set_self_modulate(Color("ffffffff"))
			var tween = get_tree().create_tween()
			tween.tween_property(new_outgoing, "self_modulate", Color("ffffff00"), 1.0)

			PusherOutput.text = "COMMAND: " + last_command + "\nAPI CALL: " + pushing_address + outgoing_command
			var error = HTTPListener.request(pushing_address + outgoing_command, [], HTTPClient.METHOD_POST)
			if error != OK:
				push_error("An error occurred in the HTTP request.")
			return
	
	PusherOutput.text = "Slack Command " + str(last_command) + " has no API call mapping.\nGo to the Command Mapper and map it!"

func _on_lightson_pressed():
	var temp : Dictionary = {"api_app_id":"A063NTQB51D","channel_id":"C063NTX2ENT","channel_name":"arl_prod","command":"/lights-on","is_enterprise_install":"false","response_url":"https://hooks.slack.com/commands/T037Z7J1A02/7132084952514/prbxRsn3aWjsCBUMrH1rzjSx","team_domain":"coe22","team_id":"T037Z7J1A02","text":"","token":"RfkJYEx8Jcu3qxVzcrydlC0Y","trigger_id":"7134560157748.3271256044002.47b469f6426391d9b2d2724a7dec1bed","user_id":"U05HDAFHWJU","user_name":"debugman"}
	_on_http_listener_request_completed(999, null, null, temp)

func _on_lightsoff_pressed():
	var temp : Dictionary = {"api_app_id":"A063NTQB51D","channel_id":"C063NTX2ENT","channel_name":"arl_prod","command":"/lights-off","is_enterprise_install":"false","response_url":"https://hooks.slack.com/commands/T037Z7J1A02/7132084952514/prbxRsn3aWjsCBUMrH1rzjSx","team_domain":"coe22","team_id":"T037Z7J1A02","text":"","token":"RfkJYEx8Jcu3qxVzcrydlC0Y","trigger_id":"7134560157748.3271256044002.47b469f6426391d9b2d2724a7dec1bed","user_id":"U05HDAFHWJU","user_name":"debugman"}
	_on_http_listener_request_completed(999, null, null, temp)

func _on_video_pressed():
	var temp : Dictionary = {"api_app_id":"A063NTQB51D","channel_id":"C063NTX2ENT","channel_name":"arl_prod","command":"/backup-record","is_enterprise_install":"false","response_url":"https://hooks.slack.com/commands/T037Z7J1A02/7132084952514/prbxRsn3aWjsCBUMrH1rzjSx","team_domain":"coe22","team_id":"T037Z7J1A02","text":"","token":"RfkJYEx8Jcu3qxVzcrydlC0Y","trigger_id":"7134560157748.3271256044002.47b469f6426391d9b2d2724a7dec1bed","user_id":"U05HDAFHWJU","user_name":"debugman"}
	_on_http_listener_request_completed(999, null, null, temp)

func _on_audio_pressed():
	var temp : Dictionary = {"api_app_id":"A063NTQB51D","channel_id":"C063NTX2ENT","channel_name":"arl_prod","command":"/backup-stop","is_enterprise_install":"false","response_url":"https://hooks.slack.com/commands/T037Z7J1A02/7132084952514/prbxRsn3aWjsCBUMrH1rzjSx","team_domain":"coe22","team_id":"T037Z7J1A02","text":"","token":"RfkJYEx8Jcu3qxVzcrydlC0Y","trigger_id":"7134560157748.3271256044002.47b469f6426391d9b2d2724a7dec1bed","user_id":"U05HDAFHWJU","user_name":"debugman"}
	_on_http_listener_request_completed(999, null, null, temp)

func _on_weenio_pressed():
	var temp : Dictionary = {"api_app_id":"A063NTQB51D","channel_id":"C063NTX2ENT","channel_name":"arl_prod","command":"/weenio","is_enterprise_install":"false","response_url":"https://hooks.slack.com/commands/T037Z7J1A02/7132084952514/prbxRsn3aWjsCBUMrH1rzjSx","team_domain":"coe22","team_id":"T037Z7J1A02","text":"","token":"RfkJYEx8Jcu3qxVzcrydlC0Y","trigger_id":"7134560157748.3271256044002.47b469f6426391d9b2d2724a7dec1bed","user_id":"U05HDAFHWJU","user_name":"debugman"}
	_on_http_listener_request_completed(999, null, null, temp)

func _on_tab_container_tab_changed(tab):
	if tab == 2:
		$TabContainer/Debugging.update_logs()
    RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    content_margin_left    content_margin_top    content_margin_right    content_margin_bottom 	   bg_color    draw_center    skew    border_width_left    border_width_top    border_width_right    border_width_bottom    border_color    border_blend    corner_radius_top_left    corner_radius_top_right    corner_radius_bottom_right    corner_radius_bottom_left    corner_detail    expand_margin_left    expand_margin_top    expand_margin_right    expand_margin_bottom    shadow_color    shadow_size    shadow_offset    anti_aliasing    anti_aliasing_size    script 	   _bundled       Script    res://main.gd ��������
   Texture2D    res://UI/spinner_progress.png �*Dh�   Script     res://Scripts/CommandMapping.gd ��������   Script    res://Scripts/Debugger.gd ��������   Script    res://ErrorContainer.gd ��������      local://StyleBoxFlat_l3nqq f         local://StyleBoxFlat_eke64 �         local://PackedScene_pcbdr �         StyleBoxFlat                      ��/?         StyleBoxFlat          ���>���>��>  �?         PackedScene          	         names "   �      Main    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control    TabContainer    offset_right    offset_bottom    visible %   theme_override_constants/margin_left $   theme_override_constants/margin_top &   theme_override_constants/margin_right '   theme_override_constants/margin_bottom    MarginContainer 
   Main_VBox    VBoxContainer    Title    size_flags_horizontal    size_flags_vertical $   theme_override_font_sizes/font_size    text    Label    Spacer    size_flags_stretch_ratio    VPair1    HBoxContainer 	   LineEdit    custom_minimum_size    placeholder_text    VPair2    VPair3    SpinBox 
   min_value 
   max_value    step    value    Label2    TextureProgressBar    clip_contents 
   fill_mode    nine_patch_stretch    stretch_margin_left    stretch_margin_bottom    texture_progress    Spacer2 
   StartStop    self_modulate    toggle_mode    Button    HBoxContainer2    NewIncoming 	   modulate    NewOutgoing    ListenerOutput 	   editable 	   TextEdit    PusherOutput    ForceCommandLabel    horizontal_alignment    vertical_alignment    HBoxContainer3 $   theme_override_constants/separation 
   lights-on    lights-off    backuprecord    backupstop    weenio    Command Mapping    Header    DefaultButton 
   AddButton    CommandScroller    ScrollContainer    CommandHolder 
   Debugging    HTTPRequest    PostRequest_Label    PostRequest_LineEdit 	   SendCall    PostRequest_Log    Panel    PostRequest_Label2 
   LogHolder    CommandOutput    OtherOutput    Utility    Node    Timer    HTTPListener    HTTPPusher    ErrorContainer    ErrorBG    theme_override_styles/panel    ErrorWindow    anchor_left    anchor_top    offset_left    offset_top 	   TopPanel    color 
   ColorRect    Message_Title    Message_Body    autowrap_mode    ButtonContainer    Deny_Button    Confirm_Button    _on_tab_container_tab_changed    tab_changed    _on_spin_box_value_changed    value_changed    _on_start_stop_toggled    toggled    _on_lightson_pressed    pressed    _on_lightsoff_pressed    _on_video_pressed    _on_audio_pressed    _on_weenio_pressed    _on_default_button_pressed    _on_button_pressed #   _on_http_request_request_completed    request_completed    _on_timer_timeout    timeout $   _on_http_listener_request_completed    _on_deny_button_pressed    _on_confirm_button_pressed    	   variants    _                    �?                     �D     "D          -                  0         Slack2Companion    33�>      Listening to  
     D             N   https://coe22production-notifier-a4a45daf4ae5.herokuapp.com/retrieve-requests    !   [address to listen out for POST]       and Pushing to              http://127.0.0.1:8888       [address to push command to]       Every      �@)   �������?      seconds       
   �� A                       ���>   ��?  �?��?  �?
     HC  HB      Stopped    ��?  �?��w?  �?     �?  �?  �?          New incoming message!    ��a?  �?���>  �?      New outbound command!        Waiting for incoming command...        Waiting for outgoing command...             Force Commands             
     C  B      /lights-on 
   R�C          /lights-off       /backup-record       /backup-stop       /weenio               �?��i?��3?  �?      Restore Defaults       Command Mapping    ��?  �?��?  �?      Add New Command    (                        Send HTTP POST Request 
      D       /   http://127.0.0.1:8000/api/location/1/0/1/press       custom api call here 
      C  (B   
   Send Call 
         C      Waiting for HTTP Request 
         �A
       ff>@      Singleton Viewers    c   -- CommandMapper Viewer --

Displays all mapped commands held
within the singleton "CommandMapper"       Unused                                ?     7�     ��     7C     �B         
          B   �� >s� >���=  �?      Message Title 
      B   B   Q   You suck ass.
line2
okay this is line 3!!!!
woahhhh line 4 alert
whatever line 5      �?��?��?  �?
      C   B      Deny    ��	?  �?��?  �?      Confirm    ���=      node_count    F         nodes     6  ��������       ����                                                          	   	   ����         
                              ����                                                        ����                          ����            	      
                                ����                                       ����            	      
                          ����                                ����                                                !   ����            	      
             	             ����                   	             ����                                                "   ����            	      
                          ����                          #   #   ����         $      %      &      '                    (   ����                          )   )   ����   *                     	      	   &      +   	   ,      -      .      /                    0   ����                                 4   1   ����   2          !            	      	   3         "                 5   ����                       6   ����   7   #   2   $                   %                 8   ����   7   &   2   $                   '                    ����                           ;   9   ����                    (   :                 ;   <   ����                    )   :                    =   ����                         *      +   >   ,   ?   ,                 @   ����            	                A   -              4   B   ����      .            	      	      /              4   C   ����      0            	      	      1              4   D   ����      0            	      	      2              4   E   ����      0            	      	      3              4   F   ����      0            	      	      4                 G   ����                                          5                     ����             !          H   ����             "       4   I   ����   2   6                   7       "             ����                   
            8   >   ,   ?   ,       "       4   J   ����   2   9                   :       !       L   K   ����                    &          M   ����                                     N   ����                  ;      ;      ;      ;      <       (       O   O   ����        (             ����            	       *          P   ����            =      >   >   ,   ?   ,       *          Q   ����      ?            	      @       A       *       4   R   ����      B            	      	      C       *       ;   S   ����      D             E   :          *             ����      F             *       T   T   ����      G             *          0   ����      F             *          U   ����            =      H   >   ,   ?   ,       *          V   ����             3       ;   W   ����      D                    I   :          3       ;   X   ����      D                    J   :                  Z   Y   ����        6       [   [   ����        6       O   \   ����        6       O   ]   ����                   ^   ����      ,                                    K       :       T   _   ����      ,                                 `   L       :       T   a   ����      ,      M   b   N   c   N      N      N   d   O   e   P   
   Q      R               `   S       <             ����      ,                                     =       h   f   ����      T         g   U       >          i   ����	      ,                                    V   >   ,   ?   ,       =             ����                   	      	      	      	       @          j   ����      W                   X   >   ,   ?   ,   k          =          l   ����            	              B       4   m   ����   2   Y      Z            	      	      [       B       4   n   ����   2   \      Z            	      	      ]       =             ����                   ^             conn_count             conns     p          p   o                     r   q                     t   s                     v   u                     v   w                     v   x                     v   y                     v   z              #       v   {              %       v   |              )   (   ~   }              -   (   v   |              7       �                 8       ~   �              C   :   v   �              D   :   v   �                    node_paths              editable_instances              version             RSRC       extends Control

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
    [remap]

path="res://.godot/exported/133200997/export-1ea1666b9e7c9227f3425d55cfdad62b-command_line.scn"
       [remap]

path="res://.godot/exported/133200997/export-3070c538c03ee49b7677ff960a3f5195-main.scn"
               list=Array[Dictionary]([])
     <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
             �BT� *   res://Scenes/CommandLine/command_line.tscnu���n>'	   res://UI/icon.svg�*Dh�   res://UI/spinner_progress.png�;
N6�s   res://UI/Trash.pngڪ85�2(   res://main.tscn       ECFG	      application/config/name         Slack 2 Companion      application/run/main_scene         res://main.tscn    application/config/features(   "         4.2    GL Compatibility       application/config/icon         res://UI/icon.svg      autoload/CommandMapper,      "   *res://Singletons/CommandMapper.gd     autoload/ErrorHandling,      "   *res://Singletons/ErrorHandling.gd     display/window/stretch/mode         canvas_items#   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility     