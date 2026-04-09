import { createBinding } from "ags"
import Hyprland from "gi://AstalHyprland?version=0.1"
import Pango from "gi://Pango"

export default function FocusedClient() {
  const hypr = Hyprland.get_default()
  const client = createBinding(hypr, "focusedClient")

  return (
    <box
      class="FocusedClient"
      visible={client((c) => !!c)}
    >
      <icon
        class="focused-icon"
        icon={client((c) => c?.class ?? "application-x-executable")}
      />
      <label
        class="focused-title"
        label={client((c) => c?.title ?? "")}
        maxWidthChars={40}
        ellipsize={Pango.EllipsizeMode.END}
      />
    </box>
  )
}
