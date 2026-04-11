import { application } from "./application"

import CalendarController from "./calendar_controller"
import SidebarController from "./sidebar_controller"

application.register("calendar", CalendarController)
application.register("sidebar", SidebarController)


