# Load required libraries
library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(ggplot2)
library(dplyr)
library(readr)
library(readxl)


source("UI.R")
source("Server.R")

# Run the application
shinyApp(ui = ui, server = server)