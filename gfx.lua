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

register_gfx_blueprint "buff_berserk"
{
	equip = {},
	persist = true,
	point_generator = {
		type    = "cylinder",
		extents = vec3(0.2,0.9,0.0),
	},
	particle = {
		material       = "data/texture/particles/shapes_01/blick_01",
		group_id       = "pgroup_fx",
		orientation    = PS_ORIENTED,
		destroy_owner  = true,
	},
	particle_emitter = {
		rate     = 96,
		size     = vec2(0.05,0.1),
		velocity = 0.1,
		lifetime = 0.5,
		color    = vec4(1.0,0.1,0.1,0.5),
	},
	particle_transform = {
		force = vec3(0,3,0),
	},
	particle_fade = {
		fade_out = 0.5,
	},
}