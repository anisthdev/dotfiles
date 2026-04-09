import { createBinding, createComputed } from "ags"
import { Gtk } from "ags/gtk3"
import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import Gdk from "gi://Gdk?version=3.0"
import Network from "gi://AstalNetwork?version=0.1"
import Bluetooth from "gi://AstalBluetooth?version=0.1"

let didLogAudioOutputs = false

const AUDIO_OUTPUT_GLYPH_CMD = `bash -lc 'default=$(pactl get-default-sink 2>/dev/null); if [ -z "$default" ]; then printf " "; exit; fi; if printf "%s\n" "$default" | grep -qi "^bluez_output\\."; then printf " "; elif pactl list sinks 2>/dev/null | grep -A5 -F "Name: $default" | grep -qi "Description: HDMI Output"; then printf " "; else printf " "; fi'`

const AUDIO_OUTPUT_LOG_CMD = `bash -lc 'printf "[audio-switcher] default-sink\\n"; pactl get-default-sink 2>/dev/null || true; printf "[audio-switcher] sinks\\n"; pactl list sinks | grep -E "^(Sink #|Name: |Description: )|State: |Active Port: |device\\.form_factor = |device\\.icon_name = |device\\.product\\.name = |node\\.nick = |api\\.bluez5\\.profile = |api\\.bluetooth\\.transport = |alsa\\.card_name = "'`

function logAudioOutputs(reason: string) {
  execAsync(AUDIO_OUTPUT_LOG_CMD)
    .then((out) => print(`[audio-switcher] ${reason}\n${out}`))
    .catch((err) => print(`[audio-switcher] ${reason} failed: ${err}`))
}

export default function Controls() {
  const network = Network.get_default()
  const bt = Bluetooth.get_default()

  // WiFi
  const wifiState = createBinding(network, "wifi")
  const wifiGlyph = createPoll(
    " ",
    3000,
    `bash -lc 'if [ "$(nmcli radio wifi)" != "enabled" ]; then printf " "; exit; fi; signal=$(nmcli -t -f IN-USE,SIGNAL dev wifi | awk -F: '\''/^\*:/ {print $2; found=1; exit} END {if (!found) print -1}'\''); if [ "$signal" -lt 0 ]; then printf " "; elif [ "$signal" -lt 35 ]; then printf " "; elif [ "$signal" -lt 70 ]; then printf " "; else printf " "; fi'`
  )
  const ssid = createPoll(
    "Wi-Fi",
    3000,
    `bash -lc "nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '/^yes:/{print substr($0,5); found=1; exit} END{if (!found) print \\"Wi-Fi\\"}'"`
  )

  // Bluetooth
  const btDevices = createBinding(bt, "devices")
  const btPowered = createBinding(bt, "isPowered")
  const btGlyph = createComputed(() => {
    if (!btPowered()) return " "
    const connecting = btDevices().find((d: any) => d.connecting)
    if (connecting) return " "
    const connected = btDevices().find((d: any) => d.connected)
    return connected ? " " : " "
  })
  const btLabel = createComputed(() => {
    const connected = btDevices().find((d: any) => d.connected)
    return connected ? (connected.alias || connected.name) : "Bluetooth"
  })

  // Battery
  const batCapacity = createPoll("0", 30000, "cat /sys/class/power_supply/BAT0/capacity")
  const batStatus = createPoll("Unknown", 30000, "cat /sys/class/power_supply/BAT0/status")
  const batGlyph = createComputed(() => {
    if (batStatus().trim() === "Charging") return " "
    const pct = parseInt(batCapacity())
    if (pct >= 80) return " "
    if (pct >= 60) return " "
    if (pct >= 20) return " "
    return " "
  })
  const batLabel = createComputed(() => `${batCapacity().trim()}`)

  // Volume
  const volRaw = createPoll("Volume: 1.00", 500, "wpctl get-volume @DEFAULT_AUDIO_SINK@")
  const volumeLabel = volRaw((raw: string) => {
    const pct = Math.round(parseFloat(raw.match(/[\d.]+/)?.[0] ?? "0") * 100)
    return `${pct}`
  })
  const audioOutputGlyph = createPoll(" ", 3000, AUDIO_OUTPUT_GLYPH_CMD)

  if (!didLogAudioOutputs) {
    didLogAudioOutputs = true
    logAudioOutputs("initial-scan")
  }

  return (
    <box class="Controls">
      <button
        class="controls-btn"
        onClicked={() => execAsync(`nmcli radio wifi ${network.wifi?.enabled ? "off" : "on"}`)}
      >
        <box>
          <label class="controls-icon controls-icon-wifi" label={wifiGlyph} />
          <label class="controls-label" label={ssid} />
        </box>
      </button>
      <button
        class="controls-btn"
        onClicked={() => execAsync(`bluetoothctl power ${bt.isPowered ? "off" : "on"}`)}
      >
        <box>
          <label class="controls-icon controls-icon-bt" label={btGlyph} />
          <label class="controls-label" label={btLabel} />
        </box>
      </button>
      <button
        class="controls-btn controls-btn-audio"
        onClicked={() => execAsync("/home/asif/.local/bin/rofi-audio-switcher")}
        onScroll={(_: unknown, event: any) => {
          const dir = event.direction
          const dy = Number(event.delta_y ?? 0)

          if (dir === Gdk.ScrollDirection.UP || dy < 0) {
            execAsync("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+")
            return
          }

          if (dir === Gdk.ScrollDirection.DOWN || dy > 0) {
            execAsync("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
          }
        }}
      >
        <box>
          <label class="controls-icon controls-icon-audio" label={audioOutputGlyph} />
          <label class="controls-label controls-label-audio-volume" label={volumeLabel} />
        </box>
      </button>
      <button class="controls-btn controls-btn-battery">
        <box>
          <label class="controls-icon controls-icon-bat" label={batGlyph} angle={90} valign={Gtk.Align.CENTER} />
          <label class="controls-label controls-label-bat" label={batLabel} valign={Gtk.Align.CENTER} />
        </box>
      </button>
    </box>
  )
}
