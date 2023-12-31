register_blueprint "buff_berserk"
{
    flags = { EF_NOPICKUP }, 
    text = {
        name = "Berserk!",
        desc = "Big damage resistance, faster movement, increased melee damage, but melee only white it lasts.",
		weapon_fail = "RIP AND TEAR! RIP AND TEAR!",
    },
    ui_buff = {
        color     = RED,
        priority  = 200,
        style     = 3,
    },
    attributes = {  
		damage_mult = 10.0,
		accuracy    = 10,
		pain_max    = -75,
		dodge_value = 20,
		dodge_max   = 20,
		move_time   = 0.7,
		splash_mod  = 0.1,				
		resist = {
			slash = 90,
			impact = 90,
			pierce = 90,
			plasma = 90,
			fire = 90,
			cold = 90,
			acid = 90,
			toxin = 90,
		},    
    },
	callbacks = {
        on_pre_command = [[
            function ( self, entity, command, w, coord )
                self.attributes.initialized = 1
                if command == COMMAND_USE then
                    if w then
                        if ( w.weapon and w.weapon.type ~= world:hash("melee") ) or ( w.skill and ( w.skill.weapon and ( not w.skill.melee ) ) ) then
                            ui:set_hint( "{R"..self.text.weapon_fail.."}", 2001, 0 )
                            return -1
                        end
                    end
                end
                return 0
            end
            ]],
        on_aim = [[
            function ( self, entity, target, weapon )
                if target and weapon then
                    if ( weapon.weapon and weapon.weapon.type ~= world:hash("melee") ) or ( weapon.skill and ( weapon.skill.weapon and ( not weapon.skill.melee ) ) ) then
                        return -1
                    end
                end
            end
        ]],
		on_kill = [[
            function ( self, entity, target, weapon )
				ui:set_hint( "{R"..self.text.weapon_fail.."}", 2001, 0 )
			end
        ]],
    },
}

register_blueprint "berserk_globe"
{
	flags = { EF_ITEM, EF_POWERUP }, 
	lists = {
		group    = "item",
		keywords = { "orb", "general" },
		weight   = 200,
	},
	text = {
		name = "Berserk Globe",
		desc = "Who's a man and a half? You're a man and a half!",
	},
	ascii     = {
		glyph     = "^",
		color     = MAGENTA,
	},
	callbacks = {
		on_enter = [=[
			function( self, entity )
				local attr = entity.attributes
				if attr.is_player then
					local hc      = entity.health
					local max     = entity.attributes.health
					local current = hc.current
					local mod     = world:get_attribute_mul( entity, "medkit_mod" ) or 1.0
					local episode = world:get_level().level_info.episode
					local heal    = 60 - math.clamp( episode - 1, 0, 3 ) * 10 
					hc.current    = math.min( current + math.floor( heal * mod ), 2 * max )
					world:add_buff( entity, "buff_berserk", 3000 )
					world:play_sound( "medkit_small", entity )
					ui:spawn_fx( entity, "fx_heal", entity )
					return 1 -- destroy
				end
				return 0
			end
		]=],
	},

}