local lgi = require 'lgi'

local GObject = lgi.GObject
local Introspection = lgi.Introspection
local Peas = lgi.Peas
local DcsCore = lgi.DcsCore
local DcsUI = lgi.DcsUI

local LuaTestPlugin = GObject.Object:derive('LuaTestPlugin', {
    DcsUI.UIPlugin,
    Introspection.Base,
    Introspection.Callable,
    Introspection.HasPrerequisite
})

LuaTestPlugin._property.object =
    GObject.ParamSpecObject('object', 'object', 'object',
                            GObject.Object._gtype,
                            { GObject.ParamFlags.READABLE,
                              GObject.ParamFlags.WRITABLE })

function LuaTestPlugin:_init()
    app = self.object.get_app()
    self.controller = app.get_controller()
end

function LuaTestPlugin:do_activate()
    collectgarbage('restart')
    box = DcsUI.UIBox()
    box.set_id("lua-box0")
    self.controller.add(box, "/pg0/box0")
end

function LuaTestPlugin:do_deactivate()
    collectgarbage('stop')
    self.controller.remove("/pg0/box0/lua-box0")
end

function LuaTestPlugin:do_update_state()
    self.priv.update_count = self.priv.update_count + 1
end

return { LuaTestPlugin }
