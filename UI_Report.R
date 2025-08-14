tab_report <- tabItem(tabName = "report",
  fluidRow(
    box(
      title = "Report Generation", status = "primary", solidHeader = TRUE, width = 4,
      h4("Report Options:"),
      checkboxGroupInput("reportSections", "Include Sections:",
                         choices = c("Data Summary" = "summary",
                                     "Visualizations" = "plots",
                                     "Statistical Analysis" = "analysis",
                                     "Conclusions" = "conclusions"),
                         selected = c("summary", "plots", "analysis")),
      br(),
      textInput("reportTitle", "Report Title:", value = "Data Analysis Report"),
      textAreaInput("reportComments", "Additional Comments:", 
                    placeholder = "Enter any additional notes or observations..."),
      br(),
      downloadButton("downloadReport", "Download Report", class = "btn-primary"),
      br(), br(),
      actionButton("generatePreview", "Generate Preview", class = "btn-info")
    ),
    box(
      title = "Report Preview", status = "success", solidHeader = TRUE, width = 8,
      htmlOutput("reportPreview")
    )
  ),
  fluidRow(
    box(
      title = "Export Options", status = "warning", solidHeader = TRUE, width = 12,
      h4("Available Export Formats:"),
      # p("• HTML Report (recommended)"),
      # p("• PDF Report"),
      # p("• Word Document"),
      p("• CSV Data Export"),
      br(),
      downloadButton("downloadData", "Download Data as CSV", class = "btn-secondary")
    )
  )
)