register_blueprint "buff_berserk"
{
    flags = { EF_NOPICKUP },
    text = {
        name = "Berserk!",
        desc = "Big damage resistance, faster movement, increased melee damage, but melee only white it lasts.",
        weapon_fail = "GUNS ARE FOR WUSSES! RIP AND TEAR!",
        tech_smoke_fail = "SMOKE IS FOR WUSSES! RIP AND TEAR!",
        kill_text = "RIP AND TEAR! RIP AND TEAR!",
        door_kill_text = "KNOCK, KNOCK. WHO'S THERE? ME!",
    },
    data = {
        resource_before = 0
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
                    local klass = gtk.get_klass_id( entity )
                    if klass == "tech" then
                        local resource = entity:child( "resource_power" )
                        self.data.resource_before = resource.attributes.value
                    end
                end
                return 0
            end
        ]],
        on_post_command = [[
            function ( self, actor, cmt, tgt, time )
                -- Refund tech smoke cost as it won't work
                if cmt == COMMAND_USE then
                    local klass = gtk.get_klass_id( actor )
                    if klass == "tech" then
                        local resource = actor:child( "resource_power" )
                        local smoke_screen = actor:child("ktrait_smoke_screen")
                        local smoke_used_resource = self.data.resource_before - smoke_screen.skill.cost
                        if smoke_screen then
                            if smoke_used_resource == resource.attributes.value then
                                resource.attributes.value = self.data.resource_before
                                ui:set_hint( "{R"..self.text.tech_smoke_fail.."}", 2001, 0 )
                            end
                        end
                    end
                end
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
                if target and target.text and target.text.name == "door" then
                    ui:set_hint( "{R"..self.text.door_kill_text.."}", 2001, 0 )
                else
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