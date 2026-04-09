import app from "ags/gtk3/app"
import { Astal, Gtk } from "ags/gtk3"
import { createComputed, createState } from "ags"
import GLib from "gi://GLib"
import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import { For } from "gnim"
import Pango from "gi://Pango"

type SinkKind = "bluetooth" | "hdmi" | "internal"

type AudioSink = {
  description: string
  glyph: string
  mute: boolean
  name: string
  kind: SinkKind
  subtitle: string
  volume: number
}

function shellEscapeForDoubleQuotes(value: string) {
  return value.replace(/(["\\$`])/g, "\\$1")
}

function averageVolume(volume: any): number {
  if (!volume || typeof volume !== "object") return 0
  const channels = Object.values(volume) as any[]
  if (!channels.length) return 0
  const total = channels.reduce((sum, channel) => {
    const pct = Number.parseFloat(String(channel?.value_percent ?? "0"))
    return sum + (Number.isFinite(pct) ? pct : 0)
  }, 0)
  return Math.round(total / channels.length)
}

function classifySink(entry: any): Pick<AudioSink, "glyph" | "kind" | "subtitle"> {
  const props = entry?.properties ?? {}
  const name = String(entry?.name ?? "").toLowerCase()
  const description = String(entry?.description ?? "").toLowerCase()
  const nodeNick = String(props["node.nick"] ?? "").toLowerCase()
  const deviceApi = String(props["device.api"] ?? "").toLowerCase()
  const deviceBus = String(props["device.bus"] ?? "").toLowerCase()
  const formFactor = String(props["device.form_factor"] ?? "").toLowerCase()

  if (
    name.startsWith("bluez_output.")
    || deviceApi === "bluez5"
    || deviceBus === "bluetooth"
    || formFactor === "headset"
    || nodeNick.includes("headset")
    || description.includes("headset")
    || description.includes("bluetooth")
  ) {
    return { glyph: " ", kind: "bluetooth", subtitle: "Bluetooth headset" }
  }

  if (name.includes("hdmi") || description.includes("hdmi") || nodeNick.includes("hdmi")) {
    return { glyph: " ", kind: "hdmi", subtitle: "HDMI output" }
  }

  return { glyph: " ", kind: "internal", subtitle: "Internal speakers" }
}

function parseSinks(raw: string): AudioSink[] {
  try {
    const sinks = JSON.parse(raw)
    if (!Array.isArray(sinks)) return []

    return sinks.map((entry: any) => {
      const meta = classifySink(entry)
      return {
        description: String(entry?.description ?? entry?.name ?? "Audio"),
        glyph: meta.glyph,
        kind: meta.kind,
        mute: Boolean(entry?.mute),
        name: String(entry?.name ?? ""),
        subtitle: meta.subtitle,
        volume: averageVolume(entry?.volume),
      }
    })
  } catch (_) {
    return []
  }
}

function switchToSink(name: string) {
  const sink = shellEscapeForDoubleQuotes(name)
  const cmd = `bash -lc "pactl set-default-sink \"${sink}\"; for input in $(pactl list sink-inputs short | awk '{print $1}'); do pactl move-sink-input \"\$input\" \"${sink}\"; done"`
  return execAsync(cmd)
}

export default function AudioSwitcher() {
  const [selected, setSelected] = createState(0)
  const [revealed, setRevealed] = createState(false)
  const sinksRaw = createPoll("[]", 1500, "pactl -f json list sinks")
  const defaultSink = createPoll("", 1500, "pactl get-default-sink 2>/dev/null")

  const sinks = createComputed(() => parseSinks(sinksRaw()))

  let closeTimeout: number | null = null

  const closeSwitcher = () => {
    setRevealed(false)
    closeTimeout = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 220, () => {
      app.toggle_window("AudioSwitcher")
      closeTimeout = null
      return GLib.SOURCE_REMOVE
    })
  }

  const handleKeyPress = (_: any, event: any) => {
    const keyval = event.get_keyval()[1]
    const list = sinks()

    if (keyval === 65307) {
      closeSwitcher()
      return true
    }

    if (!list.length) return false

    if (keyval === 65364) {
      setSelected((selected() + 1) % list.length)
      return true
    }

    if (keyval === 65362) {
      setSelected((selected() - 1 + list.length) % list.length)
      return true
    }

    if (keyval === 65293 || keyval === 32) {
      const sink = list[selected()] ?? list.find((item) => item.name === defaultSink()) ?? list[0]
      if (sink) {
        switchToSink(sink.name)
          .then(() => closeSwitcher())
          .catch((err) => print(`[audio-switcher] switch failed: ${err}`))
      }
      return true
    }

    return false
  }

  return (
    <window
      name="AudioSwitcher"
      class="AudioSwitcher"
      anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT | Astal.WindowAnchor.BOTTOM}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.NORMAL}
      keymode={Astal.Keymode.ON_DEMAND}
      marginTop={10}
      visible={false}
      application={app}
      onKeyPressEvent={handleKeyPress}
      onShow={() => {
        if (closeTimeout !== null) {
          GLib.source_remove(closeTimeout)
          closeTimeout = null
        }
        const list = sinks()
        const idx = list.findIndex((sink) => sink.name === defaultSink())
        setSelected(idx >= 0 ? idx : 0)
        setRevealed(true)
      }}
    >
      <eventbox
        onButtonPressEvent={() => {
          closeSwitcher()
          return false
        }}
        hexpand
        vexpand
      >
        <box hexpand vexpand>
          <box class="audio-switcher-stage" hexpand vexpand halign={Gtk.Align.END} valign={Gtk.Align.START}>
            <revealer
              revealChild={revealed}
              transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
              transitionDuration={200}
              halign={Gtk.Align.END}
              valign={Gtk.Align.START}
            >
            <box class="audio-switcher-shell" vertical spacing={0} halign={Gtk.Align.END} valign={Gtk.Align.START}>
              <For each={sinks}>
                {(sink: AudioSink, idx) => {
                  const cardClass = createComputed(() => {
                    const isActive = sink.name === defaultSink()
                    const isSelected = selected() === idx()
                    return `audio-switcher-card${isActive ? " active" : ""}${isSelected ? " selected" : ""}`
                  })

                  return (
                    <button
                      class={cardClass}
                      onClicked={() => {
                        switchToSink(sink.name)
                          .then(() => closeSwitcher())
                          .catch((err) => print(`[audio-switcher] switch failed: ${err}`))
                      }}
                    >
                      <box spacing={12}>
                        <label class="audio-switcher-card-icon" label={sink.glyph} />
                        <label
                          class="audio-switcher-card-title"
                          label={sink.description}
                          ellipsize={Pango.EllipsizeMode.END}
                          maxWidthChars={28}
                          valign={Gtk.Align.CENTER}
                          hexpand
                        />
                        <label
                          class="audio-switcher-card-volume"
                          label={sink.mute ? "Muted" : `${sink.volume}%`}
                          valign={Gtk.Align.CENTER}
                        />
                      </box>
                    </button>
                  )
                }}
              </For>
            </box>
            </revealer>
          </box>
        </box>
      </eventbox>
    </window>
  )
}
