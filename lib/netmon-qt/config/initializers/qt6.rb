QApplication.set_organization_name("souk4711")
QApplication.set_application_name("NetmonQt")

root_path = File.expand_path("../..", __dir__)
QDir.add_search_path("assets", File.join(root_path, "app/assets"))

icon = QIcon.new("assets:/app.svg")
QApplication.set_window_icon(icon)
