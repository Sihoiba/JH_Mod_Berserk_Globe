register_blueprint "buff_berserk"
{
    flags = { EF_NOPICKUP },
    text = {
        name = "Berserk!",
        desc = "Big damage resistance, faster movement, increased melee damage, but melee only white it lasts.",
        weapon_fail = "GUNS ARE FOR WUSSES! RIP AND TEAR!",
        kill_text = "RIP AND TEAR! RIP AND TEAR!",
        door_kill_text = "KNOCK, KNOCK. WHO'S THERE? ME!",
        environmental_object_kill_text = "CHOO CHOO CHA'BOOGIE!",
    },
    data = {
        resource_before = 0,
        trigger_kill_text = true,
        trigger_door_kill_text = true,
        trigger_environmental_kill_text = true,
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
            ignite = 90,
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
                        if (w.weapon and not gtk.is_melee( w )) or ( w.skill and ( w.skill.weapon and ( not w.skill.melee ) ) ) then
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
                    if ( weapon.weapon and weapon.weapon.group == world:hash("env") ) then
                        return 0
                    end
                    if (weapon.weapon and not gtk.is_melee( weapon )) or ( weapon.skill and weapon.skill.weapon and not weapon.skill.melee ) then
                        return -1
                    end
                end
            end
        ]],
        on_kill = [[
            function ( self, entity, target, weapon )
                if entity ~= world:get_player() then return 0 end
                local is_door = false
                local level = world:get_level()
                local c = world:get_position(target)
                local d = level:get_entity(c,"door") or level:get_entity(c,"pdoor") or level:get_entity(c,"door2") or level:get_entity(c,"door2_l") or level:get_entity(c,"door2_r")
                if d and d == target then
                    is_door = true
                end
                if is_door then
                    if self.data.trigger_door_kill_text then
                        self.data.trigger_door_kill_text = false
                        ui:set_hint( "{R"..self.text.door_kill_text.."}", 2001, 0 )
                    end
                elseif target and not (target.data and target.data.ai) then
                    if self.data.trigger_environmental_kill_text then
                        self.data.trigger_environmental_kill_text = false
                        ui:set_hint( "{R"..self.text.environmental_object_kill_text.."}", 2001, 0 )
                    end
                elseif self.data.trigger_kill_text then
                    self.data.trigger_kill_text = false
                    ui:set_hint( "{R"..self.text.kill_text.."}", 2001, 0 )
                end
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