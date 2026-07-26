import { application } from "./application"

import DropdownController from "./dropdown_controller"
import CalendarController from "./calendar_controller"
import SidebarController from "./sidebar_controller"
import AllDayController from "./all_day_controller"


application.register("dropdown", DropdownController)
application.register("calendar", CalendarController)
application.register("sidebar", SidebarController)
application.register("all-day", AllDayController)

