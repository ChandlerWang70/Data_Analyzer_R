tab_visualize <- tabItem(tabName = "visualize",
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
)