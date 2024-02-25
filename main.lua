register_blueprint "mod_exalted_gatekeeper_elevator_inactive"
{
    text = {
        short = "inactive",
        failure = "It won't open until an exalted gatekeeper has been slain!",
    },
    callbacks = {
        on_activate = [=[
            function( self, who, level )
                if who == world:get_player() then
                    if level.level_info.cleared and level.level_info.enemies == 0 then
                        for e in level:entities() do
                            if world:get_id( e ) == "elevator_01" or world:get_id( e ) == "elevator_01_branch" then
                                local child = e:child( "mod_exalted_gatekeeper_elevator_inactive" )
                                if child then
                                    world:mark_destroy( child )
                                end
                            end
                        end
                        world:flush_destroy()
                        ui:set_hint( "Elevators unlocked", 2001, 0 )
                    else
                        ui:set_hint( self.text.failure, 2001, 0 )
                        world:play_voice( "vo_refuse" )
                        for b in level:beings() do
                            if b:child("exalted_kw_gatekeeper") and not (b.minimap and b.minimap.always) then
                                b:equip("tracker")
                                b.minimap.always = true
                            end
                        end
                    end
                end
                return 1
            end
        ]=],
        on_attach = [=[
            function( self, parent )
                parent.flags.data =  { EF_NOSIGHT, EF_NOMOVE, EF_NOFLY, EF_NOSHOOT, EF_BUMPACTION, EF_ACTION }
            end
        ]=],
        on_detach = [=[
            function( self, parent )
                if not parent:child("elevator_inactive_completionist") then
                    parent.flags.data =  {}
                end
            end
        ]=],
    },
}

register_blueprint "level_event_gatekeeper_on_clear"
{
    callbacks = {
        on_cleared = [[
            function ( self, level )
                local unlocked = false
                for e in level:entities() do
                    if world:get_id( e ) == "elevator_01" or world:get_id( e ) == "elevator_01_branch" then
                        local child = e:child( "mod_exalted_gatekeeper_elevator_inactive" )
                        if child then
                            world:mark_destroy( child )
                            unlocked = true
                        end
                    end
                end
                world:flush_destroy()
                if unlocked then
                    ui:set_hint( "Elevators unlocked", 2001, 0 )
                end
            end
        ]],
    }
}

register_blueprint "exalted_kw_gatekeeper"
{
    flags = { EF_NOPICKUP },
    text = {
        status = "GATEKEEPER",
        sdesc  = "Meaner, tougher and locks main and branch elevators until it has been slain",
    },
    armor = {},
    data = {
        modded = true
    },
    attributes = {
        damage_mult = 1.3,
        splash_mod = 0.75,
        armor = {
            3,
        },
        resist = {
            acid   = 25,
            toxin  = 25,
            ignite = 25,
            bleed  = 25,
            emp    = 25,
            cold   = 25,
        },
    },
    callbacks = {
        on_activate = [=[
            function( self, entity )
                local level = world:get_level()
                local lock = false
                for e in level:entities() do
                    if world:get_id( e ) == "elevator_01" or world:get_id( e ) == "elevator_01_branch" then
                        if not ( e:child("elevator_inactive") or e:child("elevator_locked") or e:child("elevator_01_off") or e:child("elevator_broken") or e:child("elevator_secure") ) and not ( world:get_id( e ) == "elevator_01_branch" and world.data.level[ world.data.current ].branch_lock ) then
                            if not e:child("mod_exalted_gatekeeper_elevator_inactive") then
                                nova.log("Gatekeeper locking "..world:get_id( e ))
                                e:equip("mod_exalted_gatekeeper_elevator_inactive")
                            end
                            lock = true
                        end
                    end
                end
                if lock then
                    entity:attach( "exalted_kw_gatekeeper" )
                    entity.attributes.health = math.floor(entity.attributes.health * 1.25)
                    entity.health.current = entity.attributes.health
                    world:attach( level, world:create_entity( "level_event_gatekeeper_on_clear" ) )
                end
            end
        ]=],
        on_action = [=[
            function ( self, entity, time_passed, last )
                if entity:child( "disabled" ) or entity:child( "friendly" ) then
                    local unlocked = false
                    local level = world:get_level()
                    for e in level:entities() do
                        if world:get_id( e ) == "elevator_01" or world:get_id( e ) == "elevator_01_branch" then
                            local child = e:child( "mod_exalted_gatekeeper_elevator_inactive" )
                            if child then
                                world:mark_destroy( child )
                                unlocked = true
                            end
                        end
                    end
                    world:flush_destroy()
                    if unlocked then
                        ui:set_hint( "Elevators unlocked", 2001, 0 )
                    end
                end
            end
        ]=],
        on_die = [[
            function ( self )
                local unlocked = false
                local level = world:get_level()
                for e in level:entities() do
                    if world:get_id( e ) == "elevator_01" or world:get_id( e ) == "elevator_01_branch" then
                        local child = e:child( "mod_exalted_gatekeeper_elevator_inactive" )
                        if child then
                            world:mark_destroy( child )
                            unlocked = true
                        end
                    end
                end
                world:flush_destroy()
                if unlocked then
                    ui:set_hint( "Elevators unlocked", 2001, 0 )
                end
            end
        ]],
    },
}