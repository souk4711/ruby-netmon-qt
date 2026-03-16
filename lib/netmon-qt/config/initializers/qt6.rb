QApplication.set_organization_name("souk4711")
QApplication.set_application_name("NetmonQt")
QApplication.set_window_icon(QIcon.from_theme("netmon-qt"))

root_path = File.expand_path("../..", __dir__)
QDir.add_search_path("assets", File.join(root_path, "app/assets"))
