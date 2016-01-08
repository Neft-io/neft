exports.in = do (i=0) ->
	SCREEN_SIZE: i++
	SCREEN_ORIENTATION: i++
	NAVIGATOR_LANGUAGE: i++
	NAVIGATOR_ONLINE: i++
	DEVICE_PIXEL_RATIO: i++
	DEVICE_IS_PHONE: i++
	POINTER_PRESS: i++
	POINTER_RELEASE: i++
	POINTER_MOVE: i++
	DEVICE_KEYBOARD_SHOW: i++
	DEVICE_KEYBOARD_HIDE: i++
	KEY_PRESS: i++
	KEY_HOLD: i++
	KEY_INPUT: i++
	KEY_RELEASE: i++
	IMAGE_SIZE: i++
	TEXT_SIZE: i++
	FONT_LOAD: i++
	SCROLLABLE_CONTENT_X: i++
	SCROLLABLE_CONTENT_Y: i++

exports.out = do (i=0) ->
	DEVICE_SHOW_KEYBOARD: i++
	DEVICE_HIDE_KEYBOARD: i++

	SET_WINDOW: i++

	CREATE_ITEM: i++
	SET_ITEM_PARENT: i++
	INSERT_ITEM_BEFORE: i++
	SET_ITEM_VISIBLE: i++
	SET_ITEM_CLIP: i++
	SET_ITEM_WIDTH: i++
	SET_ITEM_HEIGHT: i++
	SET_ITEM_X: i++
	SET_ITEM_Y: i++
	SET_ITEM_Z: i++
	SET_ITEM_SCALE: i++
	SET_ITEM_ROTATION: i++
	SET_ITEM_OPACITY: i++
	SET_ITEM_BACKGROUND: i++
	SET_ITEM_KEYS_FOCUS: i++

	CREATE_IMAGE: i++
	SET_IMAGE_SOURCE: i++
	SET_IMAGE_SOURCE_WIDTH: i++
	SET_IMAGE_SOURCE_HEIGHT: i++
	SET_IMAGE_FILL_MODE: i++
	SET_IMAGE_OFFSET_X: i++
	SET_IMAGE_OFFSET_Y: i++

	CREATE_TEXT: i++
	SET_TEXT: i++
	SET_TEXT_WRAP: i++
	UPDATE_TEXT_CONTENT_SIZE: i++
	SET_TEXT_COLOR: i++
	SET_TEXT_LINE_HEIGHT: i++
	SET_TEXT_FONT_FAMILY: i++
	SET_TEXT_FONT_PIXEL_SIZE: i++
	SET_TEXT_FONT_WORD_SPACING: i++
	SET_TEXT_FONT_LETTER_SPACING: i++
	SET_TEXT_ALIGNMENT_HORIZONTAL: i++
	SET_TEXT_ALIGNMENT_VERTICAL: i++

	CREATE_TEXT_INPUT: i++
	SET_TEXT_INPUT_TEXT: i++
	SET_TEXT_INPUT_COLOR: i++
	SET_TEXT_INPUT_LINE_HEIGHT: i++
	SET_TEXT_INPUT_MULTI_LINE: i++
	SET_TEXT_INPUT_ECHO_MODE: i++
	SET_TEXT_INPUT_FONT_FAMILY: i++
	SET_TEXT_FONT_INPUT_PIXEL_SIZE: i++
	SET_TEXT_FONT_INPUT_WORD_SPACING: i++
	SET_TEXT_FONT_INPUT_LETTER_SPACING: i++
	SET_TEXT_INPUT_ALIGNMENT_HORIZONTAL: i++
	SET_TEXT_INPUT_ALIGNMENT_VERTICAL: i++

	LOAD_FONT: i++

	CREATE_RECTANGLE: i++
	SET_RECTANGLE_COLOR: i++
	SET_RECTANGLE_RADIUS: i++
	SET_RECTANGLE_BORDER_COLOR: i++
	SET_RECTANGLE_BORDER_WIDTH: i++

	CREATE_SCROLLABLE: i++
	SET_SCROLLABLE_CONTENT_ITEM: i++
	SET_SCROLLABLE_CONTENT_X: i++
	SET_SCROLLABLE_CONTENT_Y: i++
	ACTIVATE_SCROLLABLE: i++
