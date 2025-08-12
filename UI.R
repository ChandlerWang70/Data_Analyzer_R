

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
      tabItem(tabName = "load",
              fluidRow(
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
      ),
      
      # Visualize Tab
      tabItem(tabName = "visualize",
              fluidRow(
                box(
                  title = "Plot Controls", status = "primary", solidHeader = TRUE, width = 4,
                  selectInput("plotType", "Plot Type:",
                              choices = c("Scatter Plot" = "scatter",
                                          "Box Plot" = "boxplot",
                                          "Histogram" = "histogram",
                                          "Bar Chart" = "bar")),
                  uiOutput("xVariable"),
                  uiOutput("yVariable"),
                  uiOutput("colorVariable"),
                  br(),
                  actionButton("generatePlot", "Generate Plot", class = "btn-success")
                ),
                box(
                  title = "Visualization", status = "success", solidHeader = TRUE, width = 8,
                  plotlyOutput("mainPlot", height = "400px")
                )
              ),
              fluidRow(
                box(
                  title = "Additional Plots", status = "info", solidHeader = TRUE, width = 12,
                  tabsetPanel(
                    tabPanel("Distribution", plotlyOutput("distributionPlot")),
                    tabPanel("Correlation", plotlyOutput("correlationPlot")),
                    tabPanel("Missing Data", plotlyOutput("missingDataPlot"))
                  )
                )
              )
      ),
      
      # Analyze Tab
      tabItem(tabName = "analyze",
              fluidRow(
                box(
                  title = "Analysis Options", status = "primary", solidHeader = TRUE, width = 4,
                  selectInput("analysisType", "Analysis Type:",
                              choices = c("Descriptive Statistics" = "descriptive",
                                          "Correlation Analysis" = "correlation",
                                          "Linear Regression" = "regression",
                                          "ANOVA" = "anova")),
                  uiOutput("analysisVariables"),
                  br(),
                  actionButton("runAnalysis", "Run Analysis", class = "btn-success")
                ),
                box(
                  title = "Analysis Results", status = "success", solidHeader = TRUE, width = 8,
                  verbatimTextOutput("analysisResults")
                )
              ),
              fluidRow(
                box(
                  title = "Statistical Tests", status = "info", solidHeader = TRUE, width = 6,
                  h4("Available Tests:"),
                  verbatimTextOutput("statisticalTests")
                ),
                box(
                  title = "Model Performance", status = "warning", solidHeader = TRUE, width = 6,
                  verbatimTextOutput("modelPerformance")
                )
              )
      ),
      
      # Report Tab
      tabItem(tabName = "report",
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
                  p("• HTML Report (recommended)"),
                  p("• PDF Report"),
                  p("• Word Document"),
                  p("• CSV Data Export"),
                  br(),
                  downloadButton("downloadData", "Download Data as CSV", class = "btn-secondary")
                )
              )
      )
    )
  )
)