library(shiny)

# Define UI for dataset viewer application
shinyUI(
  fluidPage(
  
    # Application title.
    titlePanel("IPv6 testbed status"),
    
    sidebarLayout(
      sidebarPanel(
        selectInput("interval", "Choose a time interval:", 
                    choices = c("4 hours", "12 hours", "1 day", "1 week", "all data")
                   )
        ),

      mainPanel(
        h4("IPv6 Testbed"),
        plotOutput("distPlot")
      )
    )
  )
)