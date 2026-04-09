import { createState } from "ags"
import { createPoll } from "ags/time"
import GLib from "gi://GLib"

export default function Clock() {
  const [expanded, setExpanded] = createState(false)
  const [fading, setFading] = createState(false)

  const time = createPoll("", 1000, "date '+%H:%M'")
  const datetime = createPoll("", 1000, "date '+%a %b %d  %H:%M'")

  const toggle = () => {
    setFading(true)
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 150, () => {
      setExpanded(!expanded())
      setFading(false)
      return GLib.SOURCE_REMOVE
    })
  }

  return (
    <button class="Clock" onClicked={toggle}>
      <label
        class={fading((f) => `clock-label${f ? " fading" : ""}`)}
        label={expanded((e) => e ? datetime() : time())}
      />
    </button>
  )
}
