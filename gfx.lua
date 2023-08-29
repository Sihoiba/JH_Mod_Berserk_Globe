nova.require "data/lua/gfx/common"

register_gfx_blueprint "berserk_globe"
{
	uisprite = {
		icon = "data/texture/ui/icons/ui_consumable_medglobe",
		color = vec4( 0.8, 0.0, 0.8, 1.0 ),
		animation = "PULSE",
	},
	light = {
		position    = vec3(0,0.1,0),
		color       = vec4(1,0.2,1,1),
	},
}