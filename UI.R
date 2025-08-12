source("UI_Load.R")
source("UI_Visualize.R")
source("UI_Analyze.R")
source("UI_Report.R")

# Define UI

ui <- dashboardPage(
  dashboardHeader(title = "Data Analysis Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Load Data", tabName = "load", icon = icon("upload")),
      menuItem("Visualize", tabName = "visualize", icon = icon("chart-line")),
      menuItem("Analyze", tabName = "analyze", icon = icon("calculator")),
      menuItem("Report", tabName = "report", icon = icon("file-alt"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Load Data Tab
      tab_load,
      
      # Visualize Tab
      tab_visualize,
      
      # Analyze Tab
      tab_analyze,
      
      # Report Tab
      tab_report
    )
  )
)