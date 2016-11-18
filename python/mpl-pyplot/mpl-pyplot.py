#
# Python plot.ly plugin.
#
# For gi to find dcs this needs to be run before starting the application:
#   export GI_TYPELIB_PATH=/usr/local/lib/girepository-1.0/:$GI_TYPELIB_PATH

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Peas', '1.0')
gi.require_version('PeasGtk', '1.0')
gi.require_version('DcsCore', '0.2')
gi.require_version('DcsUI', '0.2')
from gi.repository import GObject
from gi.repository import Gtk
from gi.repository import Peas
from gi.repository import PeasGtk
from gi.repository import DcsCore
from gi.repository import DcsUI

from matplotlib.backends.backend_gtk3agg import FigureCanvasGTK3Agg as FigureCanvas
import matplotlib.pyplot as plt
import numpy as np

class MplPyplotPlugin(DcsUI.UIPlugin):
    __gtype_name__ = 'MplPyplotPlugin'

    object = GObject.property(type=GObject.Object)

    def __init__(self):
        self.plot = MplPyplotCanvas()
        self.connect("enabled", self.do_enabled)
        self.connect("disabled", self.do_disabled)

    def do_activate(self):
        print("Matplotlib plugin activation")
        app = self.object.get_app()
        controller = app.get_controller()
        window = DcsUI.UIWindow()
        window.set_property("id", "win3")
        page = DcsUI.UIPage()
        page.set_property("id", "pg3")
        box = DcsUI.UIBox()
        box.set_property("id", "plugbox3")
        controller.add(window, "/")
        controller.add(page, "/win3")
        controller.add(box, "/win3/pg3")
        controller.add(self.plot, "/win3/pg3/plugbox3")
        self.plot.draw()

    def do_deactivate(self):
        print("Matplotlib plugin deactivation")
        app = self.object.get_app()
        controller = app.get_controller()
        controller.remove("/win3/pg3/plugbox3/plot0")
        controller.remove("/win3/pg3/plugbox3")
        controller.remove("/win3/pg3")
        controller.remove("/win3")

    def do_update_state(self):
        print("Matplotlib plugin update state")

    def do_enabled(self, data):
        print("Matplotlib plugin enabled")

    def do_disabled(self, data):
        print("Matplotlib plugin disabled")

class MplPyplotConfigurable(GObject.Object, PeasGtk.Configurable):
    __gtype_name__ = 'MplPyplotConfigurable'

    def do_create_configure_widget(self):
        return Gtk.Label.new("MplPyplot plugin configure widget")

class MplPyplotCanvas(DcsUI.UISimpleWidget):
    __gtype_name__ = 'MplPyplotCanvas'

    def __init__(self, parent=None):
        super(MplPyplotCanvas, self).__init__(parent)
        self.parent = parent
        self.set_property("id", "plot0")
        self.set_property("expand", True)
        self.figure = plt.figure(figsize=(20, 30))
        r, g, b = 192./255., 192./255., 192./255.
        self.figure.patch.set_facecolor(color=(r, g, b))
        self.canvas = FigureCanvas(self.figure)
        self.pack_start(self.canvas, True, True, 0)

    def draw(self):
        # create an axis
        ax = self.figure.add_subplot(111, frame_on=True)
        # plot data
        x = np.arange(1, 3.2, 0.2)
        y = 6 * np.sin(x)
        r, g, b = 39./255., 40./255., 34./255.
        ax.plot(x, y, ls='o', color=(r, g, b), linewidth=3)
        ax.set_title('Trace', fontsize=14)
        ax.set_xlim(0.0, 10.0)
        ax.set_ylim(-10.0, 10.0)
        r, g, b = 249./255., 38./255., 114./255.
        ax.fill(x, y, color=(r, g, b))
        ax.set_aspect('equal')
