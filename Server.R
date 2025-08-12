
# Define Server

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

server <- function(input, output, session) {
  # Reactive values to store data
  values <- reactiveValues(
    data = NULL,
    analysis_results = NULL,
    plots = list()
  )
  
  # Load Data Tab Logic
  observeEvent(input$file, input_file_handler(input, values))
  
  # Load sample data
  observeEvent(input$loadSample, {
    values$data <- mtcars
    values$data$car_name <- rownames(mtcars)
    rownames(values$data) <- NULL
  })
  
  # Data table output
  output$dataTable <- renderDT({
    req(values$data)
    datatable(values$data, options = list(scrollX = TRUE, pageLength = 10))
  })
  
  # Data summary
  output$dataSummary <- renderPrint({
    req(values$data)
    summary(values$data)
  })
  
  # Column information
  output$columnInfo <- renderDT({
    req(values$data)
    col_info <- data.frame(
      Column = names(values$data),
      Type = sapply(values$data, class),
      Missing = sapply(values$data, function(x) sum(is.na(x))),
      Unique = sapply(values$data, function(x) length(unique(x)))
    )
    datatable(col_info, options = list(pageLength = 15))
  })
  
  # Visualize Tab Logic
  output$xVariable <- renderUI({
    req(values$data)
    selectInput("xVar", "X Variable:", choices = names(values$data))
  })
  
  output$yVariable <- renderUI({
    req(values$data)
    numeric_vars <- names(select_if(values$data, is.numeric))
    selectInput("yVar", "Y Variable:", choices = numeric_vars)
  })
  
  output$colorVariable <- renderUI({
    req(values$data)
    selectInput("colorVar", "Color Variable (optional):", 
                choices = c("None" = "", names(values$data)))
  })
  
  # Main plot
  observeEvent(input$generatePlot, {
    output$mainPlot <- renderPlotly({
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
    })
  })
  
  # Distribution plot
  output$distributionPlot <- renderPlotly({
    req(values$data)
    numeric_data <- select_if(values$data, is.numeric)
    if(ncol(numeric_data) > 0) {
      p <- ggplot(stack(numeric_data), aes(x = values)) +
        geom_histogram(bins = 30) +
        facet_wrap(~ind, scales = "free") +
        theme_minimal()
      ggplotly(p)
    }
  })
  
  # Correlation plot
  output$correlationPlot <- renderPlotly({
    req(values$data)
    numeric_data <- select_if(values$data, is.numeric)
    if(ncol(numeric_data) > 1) {
      cor_matrix <- cor(numeric_data, use = "complete.obs")
      plot_ly(z = cor_matrix, type = "heatmap", colorscale = "RdBu")
    }
  })
  
  # Analyze Tab Logic
  output$analysisVariables <- renderUI({
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
  })
  
  # Run analysis
  observeEvent(input$runAnalysis, {
    req(values$data, input$analysisType)
    
    output$analysisResults <- renderPrint({
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
    })
  })
  
  # Statistical tests
  output$statisticalTests <- renderPrint({
    if(!is.null(values$data)) {
      cat("Available statistical tests based on your data:\n\n")
      cat("• T-test (numeric variables)\n")
      cat("• Chi-square test (categorical variables)\n")
      cat("• Shapiro-Wilk test (normality)\n")
      cat("• Correlation tests\n")
      cat("• ANOVA (analysis of variance)\n")
    }
  })
  
  # Report Tab Logic
  observeEvent(input$generatePreview, {
    output$reportPreview <- renderUI({
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
    })
  })
  
  # Download handlers
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("data-export-", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(values$data, file, row.names = FALSE)
    }
  )
  
  output$downloadReport <- download_handler
}