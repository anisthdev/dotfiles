import app from "ags/gtk3/app"
import style from "./style.scss"
import Bar from "./widget/Bar"
import PowerMenu from "./widget/PowerMenu"
import Notifications from "./widget/Notifications"

app.start({
  css: style,
  main() {
    app.get_monitors().map(Bar)
    PowerMenu()
    Notifications()
  },
})
