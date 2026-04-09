import { Astal } from "ags/gtk3"

export default function Logo() {
  const handleClick = () => {
    Astal.exec("fuzzel")
  }

  return (
    <button
      class="Logo"
      onClicked={handleClick}
    >
      <box class="logo-icon" />
    </button>
  )
}
