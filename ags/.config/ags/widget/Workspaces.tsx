import { createBinding, createComputed } from "ags"
import { execAsync } from "ags/process"
import Hyprland from "gi://AstalHyprland?version=0.1"

export default function Workspaces() {
  const hypr = Hyprland.get_default()
  const focused = createBinding(hypr, "focusedWorkspace")
  const workspaces = createBinding(hypr, "workspaces")

  const state = createComputed(() => {
    const focusedId = focused()?.id
    const occupiedIds = new Set(workspaces().map((ws: any) => ws.id as number))
    const extra = ([...occupiedIds] as number[]).filter((id) => id > 5)
    if (focusedId && focusedId > 5) extra.push(focusedId)
    const visibleIds = new Set([
      ...Array.from({ length: 5 }, (_, i) => i + 1),
      ...(extra as number[]),
    ])
    return { focusedId, occupiedIds, visibleIds }
  })

  return (
    <box class="Workspaces">
      {Array.from({ length: 9 }, (_, i) => i + 1).map((id) => (
        <button
          visible={state((s) => s.visibleIds.has(id))}
          class={state((s) => {
            const active = s.focusedId === id
            const occupied = s.occupiedIds.has(id) && !active
            return `ws-btn${active ? " active" : ""}${occupied ? " occupied" : ""}`
          })}
          onClicked={() => execAsync(`hyprctl dispatch workspace ${id}`)}
        >
          <label label={String(id)} />
        </button>
      ))}
    </box>
  )
}
