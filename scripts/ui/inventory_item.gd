extends TextureRect

var item_name: String

func set_item(name: String, item_texture: Texture2D):
	texture = item_texture
	item_name = name

func set_index(index:int):
	%index.text = str(index)
