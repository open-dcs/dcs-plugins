"""
Python 3D animation plugin.

For gi to find dcs this needs to be run before starting the application:
  export GI_TYPELIB_PATH=/usr/local/lib/girepository-1.0/:$GI_TYPELIB_PATH
"""
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
from mpl_toolkits.mplot3d import axes3d
import matplotlib.pyplot as plt
import numpy as np
import time
import threading

class Wire3DAnimPlugin(DcsUI.UIPlugin):
    __gtype_name__ = 'Wire3DAnimPlugin'

    object = GObject.property(type=GObject.Object)

    def do_activate(self):
        print("3D animation plugin activation")
        app = self.object.get_app()
        self.controller = app.get_controller()
        self.object.connect("enabled", self.do_enabled)
        self.object.connect("disabled", self.do_disabled)
        self.running = True
        # window = DcsUI.UIWindow()
        # window.set_property("id", "win3")
        # page = DcsUI.UIPage()
        # page.set_property("id", "pg3")
        # box = DcsUI.UIBox()
        # box.set_property("id", "plugbox3")
        plot = Wire3DAnimCanvas()
        self.thread = Wire3DAnimCanvasThread(plot)
        # self.controller.add(window, "/")
        # self.controller.add(page, "/win3")
        # self.controller.add(box, "/win3/pg3")
        self.controller.add(plot, "/win3/pg3/plugbox3")
        self.thread.start()

    def do_deactivate(self):
        print("3D animation plugin deactivation")
        self.thread.stop()
        self.thread.join()
        # self.controller.remove("/win3/pg3/plugbox3/plot0")
        # self.controller.remove("/win3/pg3/plugbox3")
        # self.controller.remove("/win3/pg3")
        # self.controller.remove("/win3")

    def do_update_state(self):
        print("3D animation plugin update state")

    def do_enabled(self, data):
        print("3D animation plugin enabled")

    def do_disabled(self, data):
        print("3D animation plugin disabled")

class Wire3DAnimConfigurable(GObject.Object, PeasGtk.Configurable):
    __gtype_name__ = 'Wire3DAnimConfigurable'

    def do_create_configure_widget(self):
        return Gtk.Label.new("3D animation plugin configure widget")

class Wire3DAnimCanvas(DcsUI.UISimpleWidget):
    __gtype_name__ = 'Wire3DAnimCanvas'

    def __init__(self, parent=None):
        super(Wire3DAnimCanvas, self).__init__(parent)
        self.parent = parent
        self.set_property("id", "3dplot0")
        self.set_property("expand", True)

        self.figure = plt.figure()
        self.ax = self.figure.add_subplot(111, projection='3d')

        r, g, b = 192./255., 192./255., 192./255.
        self.figure.patch.set_facecolor(color=(r, g, b))
        self.canvas = FigureCanvas(self.figure)
        self.pack_start(self.canvas, True, True, 0)

        self.wframe = None
        xs = np.linspace(-1, 1, 50)
        ys = np.linspace(-1, 1, 50)
        self.X, self.Y = np.meshgrid(xs, ys)
        Z = self.generate(self.X, self.Y, 0.0)    # XXX unecessary?
        self.frame = 0
        self.phi = np.linspace(0, 360 / 2 / np.pi, 360)

    def generate(self, X, Y, phi):
        R = 1 - np.sqrt(X**2 + Y**2)
        return np.cos(2 * np.pi * X + phi) * R

    def draw(self):
        phi = self.phi[self.frame]
        oldcol = self.wframe
        Z = self.generate(self.X, self.Y, phi)
        self.wframe = self.ax.plot_wireframe(self.X, self.Y, Z, rstride=2, cstride=2)

        if oldcol is not None:
            self.ax.collections.remove(oldcol)

        self.queue_draw()

        self.frame = self.frame + 1
        if self.frame == 100:
            self.frame = 0

class Wire3DAnimCanvasThread(threading.Thread):
    __gtype_name__ = 'Wire3DAnimCanvasThread'

    def __init__(self, plot):
        threading.Thread.__init__(self)
        self.plot = plot

    def stop(self):
        self.running = False

    def run(self):
        self.running = True
        while self.running:
            self.plot.draw()
            time.sleep(1./30)
