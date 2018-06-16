#Packages ####
library(shiny)
library(shinydashboard)
library(shinythemes)
library(ggplot2)
library(DT)
library("googlesheets")
library("openssl")
library("curl")
library("openssl")
library("httr")
library(lubridate)
library(dplyr)
library(ggplot2)
library(rsconnect)
library(ggmap)

#Get & clean data #### 
#Via googlesheets:
mydata <- gs_title('Coffee Tally v2')
mydata <- gs_read(mydata, col_names = TRUE)
mydata$date <- as.Date(mydata$date, "%m/%d/%Y")
mydata$day.name <- weekdays(mydata$date)

#UI ####
ui <- fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("Coffee Tally"),
  tabsetPanel(
    tabPanel("Date", 
              fluidRow(
                column(7, offset = 2, 
                         wellPanel(
                         sliderInput(inputId = "dateslider",
                         label = "Choose date range:",
                         min = as.Date(min(mydata$date)),
                         max = as.Date(max(mydata$date)),
                         ticks = TRUE,
                         animate = FALSE,
                         value = c(min(mydata$date), max(mydata$date))
                         )
                       )   
                    )
              ),
              fluidRow(plotOutput('plot1')
              )
            ),
    tabPanel("Time", plotOutput('plot2')
    ),
    tabPanel("About"
    ),
    tabPanel("Development", 
             p("App Icon -> html schrijven voor apple-touch-icon"),
             p("slider input voor Time grafiek"),
             p("Map -> grafische weergave lon/lat data"),
             p("Themes uitdokteren"),
             p("Server functionaliteit -> dashboard zelf hosten")
    )
  )
)

#Server ####
server <- function(input, output){
  
  #Bar chart #####
  output$plot1 <- renderPlot({
    dat1 <- mydata[as.Date(mydata$date, "%m/%d/%Y") >= input$dateslider[1] & as.Date(mydata$date) <= input$dateslider[2], ]
    ggplot(dat1, aes(date)) +
      geom_bar(fill = "dodgerblue") +
      theme_bw() +
      theme( axis.title.y  = element_blank(), text = element_text(size=8))
    }, height=200)
  
  #Histogram ####
  output$plot2 <- renderPlot({
    #dat2 <-
    ggplot(mydata, aes(time)) +
      geom_histogram(bins = 25, fill = "dodgerblue") +
      theme_bw() +
      theme( axis.title.y  = element_blank(), text = element_text(size=8))  
  }, height=200)
  

}

#ShinyApp ####
shinyApp(ui, server)
