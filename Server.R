# Define Server Handlers

# Download Handlers
download_handler <- downloadHandler(
  filename = function() {
    paste("analysis-report-", Sys.Date(), ".html", sep = "")
  },
  content = function(file) {
    # Create a simple HTML report
    report_content <- paste0(
      "<html><head><title>", input$reportTitle, "</title></head><body>",
      "<h1>", input$reportTitle, "</h1>",
      "<p>Generated on: ", Sys.Date(), "</p>",
      "<h2>Data Summary</h2>",
      "<p>This report was generated using R Shiny.</p>",
      "</body></html>"
    )
    writeLines(report_content, file)
  }
)

download_data_handler <- downloadHandler(
  filename = function() {
    paste("data-export-", Sys.Date(), ".csv", sep = "")
  },
  content = function(file) {
    write.csv(values$data, file, row.names = FALSE)
  }
)

# Data Loading Handlers
input_file_handler <- function(input, values) {
  req(input$file)
  
  ext <- tools::file_ext(input$file$datapath)
  
  if(ext == "csv") {
    values$data <- read_csv(input$file$datapath, 
                            locale = locale(encoding = "UTF-8"))
  } else if(ext %in% c("xlsx", "xls")) {
    values$data <- read_excel(input$file$datapath)
  }
}

sample_data_load_handler <- function(values) {
  values$data <- mtcars
  values$data$car_name <- rownames(mtcars)
  rownames(values$data) <- NULL
}

# Data Display Handlers
data_table_output_handler <- function(values) {
  req(values$data)
  datatable(values$data, options = list(scrollX = TRUE, pageLength = 10))
}

data_summary_handler <- function(values) {
  req(values$data)
  summary(values$data)
}

column_info_handler <- function(values) {
  req(values$data)
  col_info <- data.frame(
    Column = names(values$data),
    Type = sapply(values$data, class),
    Missing = sapply(values$data, function(x) sum(is.na(x))),
    Unique = sapply(values$data, function(x) length(unique(x)))
  )
  datatable(col_info, options = list(pageLength = 15))
}

# UI Generation Handlers
x_variable_ui_handler <- function(values) {
  req(values$data)
  selectInput("xVar", "X Variable:", choices = names(values$data))
}

y_variable_ui_handler <- function(values) {
  req(values$data)
  numeric_vars <- names(select_if(values$data, is.numeric))
  selectInput("yVar", "Y Variable:", choices = numeric_vars)
}

color_variable_ui_handler <- function(values) {
  req(values$data)
  selectInput("colorVar", "Color Variable (optional):", 
              choices = c("None" = "", names(values$data)))
}

analysis_variables_ui_handler <- function(input, values) {
  req(values$data)
  switch(input$analysisType,
         "descriptive" = selectInput("descVars", "Select Variables:", 
                                     choices = names(values$data), multiple = TRUE),
         "correlation" = selectInput("corrVars", "Select Numeric Variables:", 
                                     choices = names(select_if(values$data, is.numeric)), multiple = TRUE),
         "regression" = {
           tagList(
             selectInput("depVar", "Dependent Variable:", 
                         choices = names(select_if(values$data, is.numeric))),
             selectInput("indepVars", "Independent Variables:", 
                         choices = names(select_if(values$data, is.numeric)), multiple = TRUE)
           )
         },
         "anova" = {
           tagList(
             selectInput("anovaDepVar", "Dependent Variable:", 
                         choices = names(select_if(values$data, is.numeric))),
             selectInput("anovaIndepVar", "Independent Variable:", 
                         choices = names(values$data))
           )
         }
  )
}

# Plot Generation Handlers
main_plot_handler <- function(input, values) {
  req(values$data, input$xVar, input$plotType)
  
  p <- switch(input$plotType,
              "scatter" = {
                req(input$yVar)
                if(input$colorVar != "") {
                  ggplot(values$data, aes_string(x = input$xVar, y = input$yVar, color = input$colorVar)) +
                    geom_point() + theme_minimal()
                } else {
                  ggplot(values$data, aes_string(x = input$xVar, y = input$yVar)) +
                    geom_point() + theme_minimal()
                }
              },
              "boxplot" = {
                req(input$yVar)
                ggplot(values$data, aes_string(x = input$xVar, y = input$yVar)) +
                  geom_boxplot() + theme_minimal()
              },
              "histogram" = {
                ggplot(values$data, aes_string(x = input$xVar)) +
                  geom_histogram(bins = 30) + theme_minimal()
              },
              "bar" = {
                ggplot(values$data, aes_string(x = input$xVar)) +
                  geom_bar() + theme_minimal()
              }
  )
  
  ggplotly(p)
}

distribution_plot_handler <- function(values) {
  req(values$data)
  numeric_data <- select_if(values$data, is.numeric)
  if(ncol(numeric_data) > 0) {
    p <- ggplot(stack(numeric_data), aes(x = values)) +
      geom_histogram(bins = 30) +
      facet_wrap(~ind, scales = "free") +
      theme_minimal()
    ggplotly(p)
  }
}

correlation_plot_handler <- function(values) {
  req(values$data)
  numeric_data <- select_if(values$data, is.numeric)
  if(ncol(numeric_data) > 1) {
    cor_matrix <- cor(numeric_data, use = "complete.obs")
    plot_ly(z = cor_matrix, type = "heatmap", colorscale = "RdBu")
  }
}

# Analysis Handlers
run_analysis_handler <- function(input, values) {
  req(values$data, input$analysisType)
  
  switch(input$analysisType,
         "descriptive" = {
           req(input$descVars)
           summary(values$data[input$descVars])
         },
         "correlation" = {
           req(input$corrVars)
           if(length(input$corrVars) > 1) {
             cor(values$data[input$corrVars], use = "complete.obs")
           }
         },
         "regression" = {
           req(input$depVar, input$indepVars)
           formula_str <- paste(input$depVar, "~", paste(input$indepVars, collapse = " + "))
           model <- lm(as.formula(formula_str), data = values$data)
           values$analysis_results <- model
           summary(model)
         },
         "anova" = {
           req(input$anovaDepVar, input$anovaIndepVar)
           formula_str <- paste(input$anovaDepVar, "~", input$anovaIndepVar)
           model <- aov(as.formula(formula_str), data = values$data)
           summary(model)
         }
  )
}

statistical_tests_handler <- function(values) {
  if(!is.null(values$data)) {
    cat("Available statistical tests based on your data:\n\n")
    cat("• T-test (numeric variables)\n")
    cat("• Chi-square test (categorical variables)\n")
    cat("• Shapiro-Wilk test (normality)\n")
    cat("• Correlation tests\n")
    cat("• ANOVA (analysis of variance)\n")
  }
}

# Report Generation Handlers
report_preview_handler <- function(input, values) {
  req(values$data)
  
  HTML(paste0(
    "<h2>", input$reportTitle, "</h2>",
    "<hr>",
    "<h3>Data Overview</h3>",
    "<p>Dataset contains ", nrow(values$data), " observations and ", ncol(values$data), " variables.</p>",
    if("summary" %in% input$reportSections) {
      paste0("<h3>Data Summary</h3>",
             "<p>Key statistics and variable information included in full report.</p>")
    } else "",
    if("plots" %in% input$reportSections) {
      paste0("<h3>Visualizations</h3>",
             "<p>Generated plots and charts included in full report.</p>")
    } else "",
    if("analysis" %in% input$reportSections) {
      paste0("<h3>Statistical Analysis</h3>",
             "<p>Analysis results and model outputs included in full report.</p>")
    } else "",
    if("conclusions" %in% input$reportSections) {
      paste0("<h3>Conclusions</h3>",
             "<p>Key findings and recommendations included in full report.</p>")
    } else "",
    if(input$reportComments != "") {
      paste0("<h3>Additional Comments</h3>",
             "<p>", input$reportComments, "</p>")
    } else ""
  ))
}

# Main Server Function
server <- function(input, output, session) {
  # Reactive values to store data
  values <- reactiveValues(
    data = NULL,
    analysis_results = NULL,
    plots = list()
  )
  
  # Load Data Tab Logic
  observeEvent(input$file, input_file_handler(input, values))
  observeEvent(input$loadSample, sample_data_load_handler(values))
  
  # Data Display Outputs
  output$dataTable <- renderDT(data_table_output_handler(values))
  output$dataSummary <- renderPrint(data_summary_handler(values))
  output$columnInfo <- renderDT(column_info_handler(values))
  
  # Visualize Tab UI Elements
  output$xVariable <- renderUI(x_variable_ui_handler(values))
  output$yVariable <- renderUI(y_variable_ui_handler(values))
  output$colorVariable <- renderUI(color_variable_ui_handler(values))
  
  # Plot Outputs
  observeEvent(input$generatePlot, {
    output$mainPlot <- renderPlotly(main_plot_handler(input, values))
  })
  
  output$distributionPlot <- renderPlotly(distribution_plot_handler(values))
  output$correlationPlot <- renderPlotly(correlation_plot_handler(values))
  
  # Analysis Tab Logic
  output$analysisVariables <- renderUI(analysis_variables_ui_handler(input, values))
  
  observeEvent(input$runAnalysis, {
    output$analysisResults <- renderPrint(run_analysis_handler(input, values))
  })
  
  output$statisticalTests <- renderPrint(statistical_tests_handler(values))
  
  # Report Tab Logic
  observeEvent(input$generatePreview, {
    output$reportPreview <- renderUI(report_preview_handler(input, values))
  })
  
  # Download Handlers
  output$downloadData <- download_data_handler
  output$downloadReport <- download_handler
}