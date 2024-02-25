nova.require "data/lua/gfx/common"

register_gfx_blueprint "mod_exalted_gatekeeper_elevator_inactive"
{
    equip = {},
    uisprite = {
        icon = "data/texture/ui/icons/ui_tooltip_elevator",
        orientation = "FLOOR",
        offset = 1.5,
        propagate = true,
        color = vec4(1.5,0.75,2.25,1.0),
        visibility = "REVEAL",
    },
    light = {
        position    = vec3(0.5,0,0),
        color       = vec4(1.5,0.75,2.25,2.0),
        range       = 2.5,
    },
}