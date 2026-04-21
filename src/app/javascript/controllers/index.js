import { application } from "./application"

import DropdownController from "./dropdown_controller"
import CalendarController from "./calendar_controller"
import SidebarController from "./sidebar_controller"


application.register("dropdown", DropdownController)
application.register("calendar", CalendarController)
application.register("sidebar", SidebarController)


