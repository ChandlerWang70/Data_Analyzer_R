tab_analyze <- tabItem(tabName = "analyze",
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
)