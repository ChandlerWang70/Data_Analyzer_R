tab_load <- tabItem(tabName = "load",  fluidRow(
    box(
      title = "Data Upload", status = "primary", solidHeader = TRUE, width = 12,
      fileInput("file", "Choose CSV/Excel File",
                accept = c(".csv", ".xlsx", ".xls")),
      checkboxInput("header", "Header", TRUE),
      checkboxInput("stringsAsFactors", "Strings as factors", FALSE),
      radioButtons("sep", "Separator",
                   choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
                   selected = ","),
      tags$hr(),
      actionButton("loadSample", "Load Sample Data", class = "btn-info")
    )
  ),
  fluidRow(
    box(
      title = "Data Preview", status = "success", solidHeader = TRUE, width = 12,
      DTOutput("dataTable")
    )
  ),
  fluidRow(
    box(
      title = "Data Summary", status = "info", solidHeader = TRUE, width = 6,
      verbatimTextOutput("dataSummary")
    ),
    box(
      title = "Column Information", status = "warning", solidHeader = TRUE, width = 6,
      DTOutput("columnInfo")
    )
  )
)

