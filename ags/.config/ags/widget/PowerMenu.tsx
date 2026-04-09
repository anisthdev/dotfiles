import app from "ags/gtk3/app"
import { Astal, Gtk } from "ags/gtk3"
import { execAsync } from "ags/process"
import { createState } from "ags"

const powerOptions = [
  { label: "Lock",      cmd: "hyprlock",           icon: "\ue98f" },
  { label: "Suspend",   cmd: "systemctl suspend",   icon: "\ue9a3" },
  { label: "Hibernate", cmd: "systemctl hibernate", icon: "\ue9af" },
  { label: "Reboot",    cmd: "systemctl reboot",    icon: "\ue9c4" },
  { label: "Shutdown",  cmd: "systemctl poweroff",  icon: "\ue9c0", danger: true },
]

export default function PowerMenu() {
  const [selected, setSelected] = createState(0)
  const n = powerOptions.length

  const closePowerMenu = () => {
    app.toggle_window("PowerMenu")
  }

  const handleKeyPress = (_: any, event: any) => {
    const keyval = event.get_keyval()[1]

    if (keyval === 65307) {
      // Escape
      closePowerMenu()
      return true
    }
    if (keyval === 65364) {
      // Down arrow
      setSelected((selected() + 1) % n)
      return true
    }
    if (keyval === 65362) {
      // Up arrow
      setSelected((selected() - 1 + n) % n)
      return true
    }
    if (keyval === 65293 || keyval === 32) {
      // Enter or Space
      const opt = powerOptions[selected()]
      closePowerMenu()
      execAsync(opt.cmd).catch(console.error)
      return true
    }

    return false
  }

  return (
    <window
      name="PowerMenu"
      class="PowerMenu"
      anchor={Astal.WindowAnchor.TOP}
      marginTop={10}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE_EXCLUSIVE}
      keymode={Astal.Keymode.EXCLUSIVE}
      application={app}
      visible={false}
      onKeyPressEvent={handleKeyPress}
      onShow={() => setSelected(0)}
    >
      <eventbox
        onButtonPressEvent={() => {
          closePowerMenu()
          return false
        }}
      >
        <box
          class="power-menu-container"
          halign={Gtk.Align.CENTER}
          valign={Gtk.Align.CENTER}
          spacing={0}
        >
          {powerOptions.map((opt: any, idx: number) => (
            <box
              class="power-menu-item"
              vertical
              spacing={8}
              halign={Gtk.Align.CENTER}
            >
              <button
                class={selected(
                  (s: number) =>
                    `power-btn${opt.danger ? " danger" : ""}${s === idx ? " active" : ""}`,
                )}
                onClicked={() => {
                  closePowerMenu()
                  execAsync(opt.cmd).catch(console.error)
                }}
              >
                <box vertical spacing={4} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER} hexpand vexpand>
                  <label class="power-icon" halign={Gtk.Align.CENTER} label={opt.icon} />
                  <label class="power-label" halign={Gtk.Align.CENTER} label={opt.label} />
                </box>
              </button>
            </box>
          ))}
        </box>
      </eventbox>
    </window>
  )
}
