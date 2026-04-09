import app from "ags/gtk3/app"
import { Astal, Gtk } from "ags/gtk3"
import { For } from "gnim"
import { createState } from "ags"
import Notifd from "gi://AstalNotifd"
import GdkPixbuf from "gi://GdkPixbuf"
import GLib from "gi://GLib"
import Pango from "gi://Pango"

const notifd = Notifd.get_default()

function getHintStr(n: any, key: string): string | null {
  const v = n.get_hint(key)
  if (!v) return null
  try {
    const t = v.get_type_string()
    if (t === "s") return v.get_string()[0]
    if (t === "v") return getHintStr({ get_hint: () => v.get_variant() }, key)
    return String(v.unpack())
  } catch (_) { return null }
}

function getHintInt(n: any, key: string): number | null {
  const v = n.get_hint(key)
  if (!v) return null
  try {
    const t = v.get_type_string()
    print(`[notif] hint "${key}" type="${t}" raw=${v.print(false)}`)
    if (t === "i" || t === "u") return Number(t === "i" ? v.get_int32() : v.get_uint32())
    if (t === "d") return v.get_double()
    if (t === "v") return getHintInt({ get_hint: () => v.get_variant() }, key)
    return Number(v.unpack())
  } catch (_) { return null }
}

function NotificationCard(n: any) {
  const urgencyClass = n.urgency === 2 ? "notif-card urgent"
    : n.urgency === 0 ? "notif-card low"
    : "notif-card"

  const syncTag = getHintStr(n, "x-canonical-private-synchronous")
  const valueHint = getHintInt(n, "value")

  // n.appIcon = the sending app's icon
  // n.image   = image-path hint (event icon, website favicon, etc.)
  const bodyImage = (() => {
    if (!n.image) return null
    if (n.image.startsWith("/")) {
      try {
        const pb = GdkPixbuf.Pixbuf.new_from_file_at_size(n.image, 48, 48)
        const img = new Gtk.Image({ visible: true, pixbuf: pb, halign: Gtk.Align.START })
        return img as any
      } catch (_) {}
    }
    return <icon class="notif-image" icon={n.image} halign={Gtk.Align.START} /> as any
  })()

  // Synchronized (OSD-style): gradient fill shows level directly on the card
  if (syncTag) {
    const rawValue = valueHint !== null ? Math.round(Math.max(0, valueHint)) : null
    const fillPct = rawValue !== null ? Math.min(100, rawValue) : null
    const fillCss = fillPct !== null
      ? `background: linear-gradient(to right, rgba(184,207,132,0.75) ${fillPct}%, rgba(18,20,13,0.65) ${fillPct}%);`
      : ""

    const osdIcon = (() => {
      switch (syncTag) {
        case "volume":
        case "volume-notification": {
          const muted = rawValue === 0 || n.summary?.toLowerCase().includes("muted")
          if (muted) return " "
          if (rawValue !== null && rawValue > 66) return " "
          if (rawValue !== null && rawValue > 33) return " "
          return " "
        }
        case "brightness":
          if (rawValue !== null && rawValue < 25) return "󰃞"
          if (rawValue !== null && rawValue < 60) return "󰃟"
          return "󰃠"
        default: return "󰂚"
      }
    })()

    return (
      <box class={`${urgencyClass} osd`} css={fillCss} spacing={12}>
        <label class="notif-osd-icon" label={osdIcon} valign={Gtk.Align.CENTER} />
        <box hexpand />
        <label
          class="notif-osd-value"
          label={rawValue !== null ? String(rawValue) : ""}
          halign={Gtk.Align.END}
          valign={Gtk.Align.CENTER}
        />
      </box>
    ) as any
  }

  return (
    <box class={urgencyClass} vertical spacing={6}>
      <box class="notif-header" spacing={8}>
        <icon
          class="notif-app-icon"
          icon={n.appIcon || n.desktopEntry || "dialog-information-symbolic"}
          pixelSize={16}
        />
        <label
          class="notif-app-name"
          label={n.appName || "Notification"}
          hexpand
          halign={Gtk.Align.START}
          ellipsize={Pango.EllipsizeMode.END}
          maxWidthChars={24}
        />
        <button class="notif-close" onClicked={() => n.dismiss()}>
          <icon icon="window-close-symbolic" pixelSize={12} />
        </button>
      </box>
      <box spacing={10}>
        {bodyImage}
        <box vertical spacing={4} hexpand>
          <label
            class="notif-summary"
            label={n.summary}
            halign={Gtk.Align.START}
            ellipsize={Pango.EllipsizeMode.END}
            maxWidthChars={36}
            wrap
          />
          {n.body ? (
            <label
              class="notif-body"
              label={n.body}
              halign={Gtk.Align.START}
              ellipsize={Pango.EllipsizeMode.END}
              maxWidthChars={36}
              lines={3}
              wrap
            />
          ) : null}
        </box>
      </box>
      {n.actions.length > 0 ? (
        <box class="notif-actions" spacing={6}>
          {n.actions.map((action: any) => (
            <button
              class="notif-action-btn"
              hexpand
              onClicked={() => { n.invoke(action.id); n.dismiss() }}
            >
              <label label={action.label} halign={Gtk.Align.CENTER} />
            </button>
          ))}
        </box>
      ) : null}
    </box>
  ) as any
}

export default function Notifications() {
  const [ids, setIds] = createState<number[]>([])
  const dismissTimers = new Map<number, number>()   // id → GLib source id
  const syncTagMap = new Map<string, number>()       // tag → current notif id

  const schedDismiss = (id: number, ms: number) => {
    const src = GLib.timeout_add(GLib.PRIORITY_DEFAULT, ms, () => {
      notifd.get_notification(id)?.dismiss()
      dismissTimers.delete(id)
      return GLib.SOURCE_REMOVE
    })
    dismissTimers.set(id, src)
  }

  const cancelDismiss = (id: number) => {
    const src = dismissTimers.get(id)
    if (src !== undefined) { GLib.Source.remove(src); dismissTimers.delete(id) }
  }

  notifd.connect("notified", (_: any, id: number) => {
    const n = notifd.get_notification(id)
    if (!n) return

    const tag = getHintStr(n, "x-canonical-private-synchronous")
    const current = ids()

    if (tag) {
      const oldId = syncTagMap.get(tag)
      syncTagMap.set(tag, id)

      if (oldId !== undefined && oldId !== id) {
        cancelDismiss(oldId)
        // Replace old id in-place so the card doesn't jump
        const idx = current.indexOf(oldId)
        if (idx >= 0) {
          const next = [...current]
          next[idx] = id
          setIds(next)
          schedDismiss(id, 3000)
          return
        }
      }
    }

    if (!current.includes(id)) {
      setIds([...current, id])
    }
    schedDismiss(id, tag ? 3000 : 5000)
  })

  notifd.connect("resolved", (_: any, id: number) => {
    cancelDismiss(id)
    setIds(ids().filter((x) => x !== id))
    syncTagMap.forEach((v, k) => { if (v === id) syncTagMap.delete(k) })
  })

  return (
    <window
      name="Notifications"
      class="Notifications"
      anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE_EXCLUSIVE}
      marginTop={10}
      marginRight={10}
      application={app}
      visible={ids((list) => list.length > 0)}
    >
      <box vertical spacing={8} valign={Gtk.Align.START} halign={Gtk.Align.END}>
        <For each={ids}>
          {(id: number) => {
            const n = notifd.get_notification(id)
            return n ? NotificationCard(n) : <box />
          }}
        </For>
      </box>
    </window>
  )
}
