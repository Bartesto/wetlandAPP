library(shiny)


# Define UI for application
shinyUI(fluidPage(
  # tags$img(height = 114,
  #          width = 285,
  #          src = "DPaW_logo.png"),
  # br(),
  # br(),
  titlePanel(("SWWMP Modeller")),
  sidebarLayout(
    sidebarPanel(
      h4("Model a wetland's depth using USGS Landsat band 5 data"),
      helpText("Choose a wetland to model"),
      selectInput("wland", "Wetland:",
                  choices = mychoices),
      helpText("Choose the number of days allowed between measured depth and 
               satellite data for the model"),
      numericInput("daydiff", "Days difference", value = 10),
      helpText("Choose margin of error for depth measurement"),
      numericInput("thresh", "Error threshold (m)", value = 0, min = 0, 
                   max = 0.1, step = 0.01),
      downloadButton('downloadModPlot', 'Download Model'),
      downloadButton('downloadPredPlot', 'Download Predictions'),
      downloadButton('downloadData', 'Download Predictions Data'),
      br(),
      br(),
      h4("General Info"),
      helpText("USGS Landsat band 5 data has been extracted from the historical 
               archive for each wetland available in the dropdown list above. 
               These values are then matched with depth measurements obtained from
               field visits. A logarithmic model is then used."),
      helpText("There are two variables available for adjustment to improve model 
               fit. 'Days difference' refers to the number of days allowed between
               a depth measurement in the field and available satellite data. 
               'Error threshold (m)' refers to allowable measurement error from 
               the field data. Adjusting these variables may improve the model 
               fit which can be guaged by the plot and model summary table. When 
               happy with the model use the 'Download' buttons to access the data.
               To be able to choose download location you might have to alter your 
               browser settings."),
      br(),
      br(),
      br(),
      tags$img(height = 114,
               width = 285,
               src = "DPaW_logo.png")
    ),
    
    mainPanel(
      plotOutput("mod"),
      tableOutput("modsum"),
      br(),
      br(),
      plotOutput("pred")
    )
  )
)
)

