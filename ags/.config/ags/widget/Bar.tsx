import app from "ags/gtk3/app"
import { Astal, Gtk, Gdk } from "ags/gtk3"
import Clock from "./Clock"
import Workspaces from "./Workspaces"
import Logo from "./Logo"
import FocusedClient from "./FocusedClient"
import Controls from "./Controls"

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  return (
    <window
      class="Bar"
      title="ags-bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox>
        <box $type="start" halign={Gtk.Align.START}>
          <Logo />
          <Clock />
          <Workspaces />
        </box>
        <box $type="center">
          <FocusedClient />
        </box>
        <box $type="end" halign={Gtk.Align.END}>
          <Controls />
        </box>
      </centerbox>
    </window>
  )
}
