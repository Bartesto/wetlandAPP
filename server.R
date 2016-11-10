library(shiny)
library(dplyr)
library(ggplot2)
library(broom)

source("global.R")

# Define server logic for app
shinyServer(function(input, output) {
  
  #Model Plot
  modPlotInput <- function(){
    df <- df2model(input$wland, input$daydiff, input$thresh)
    model <- mod(df)
    modData <- mData(df, model)
    
    ggplot()+
      geom_point(data = df, aes_string(x = 'b5', y = 'depth.i'))+
      geom_line(data = modData, aes(x = X1, y = ExpY), col = 'red', size = 1)+
      geom_ribbon(data = modData, aes(x = X1, ymax = ub, ymin = lb ), alpha = 0.2)+
      theme_bw()+
      ggtitle(paste0(input$wland, ' model'))+
      theme(plot.title = element_text(size = 15, face = "bold", hjust = 0))+
      xlab('Band 5')+
      ylab('Depth (m)')
    
  }
  
  output$mod <- renderPlot({
    modPlotInput()
    
  })
  
  #Stats Output
  output$modsum <- renderTable({
    df <- df2model(input$wland, input$daydiff, input$thresh)
    model <- mod(df)
    glance(model)},include.rownames = FALSE)
  
  #Predictions Plot
  predPlotInput <- function(){
    df <- df2model(input$wland, input$daydiff, input$thresh)
    model <- mod(df)
    hDepth.i <- dfpredhist(input$wland)
    b5.i <- dfpredb5(input$wland)
    b5modelled <- pData(b5.i, model)
    
    ggplot()+
      geom_point(data = hDepth.i,
                 aes(x = date,  y = depth, colour = 'measured\ndepth'),
                 size = 2, shape = 3)+
      geom_point(data = b5modelled, aes(x = date, y = exp, colour='model'))+
      geom_line(data = b5modelled, aes(x = date, y = exp, colour = 'model'))+
      guides(colour = guide_legend(override.aes = list(shape = c(16, 3))))+
      scale_colour_manual(values = c('red', 'blue'),
                          name = '',
                          breaks = c( 'model', 'measured\ndepth'),
                          labels = c('modelled', 'measured'))+
      theme_bw()+
      ggtitle(paste0(input$wland, ' predictions'))+
      theme(plot.title = element_text(size = 15, face = 'bold', hjust = 0))+
      ylab('Depth (m)')+
      xlab('Date')
  }

  output$pred <- renderPlot({
    predPlotInput()
  })
  
  #Data for export
  datasetInput <- function(){
    df <- df2model(input$wland, input$daydiff, input$thresh)
    model <- mod(df)
    hDepth.i <- dfpredhist(input$wland)
    b5.i <- dfpredb5(input$wland)
    b5modelled <- pData(b5.i, model)
    return(b5modelled)
  }
  
  ##Download Buttons
  #MODEL
  output$downloadModPlot <- downloadHandler(
    filename = function() { 
      paste(input$wland, '-Mod-', Sys.Date(), '.png', sep = '') 
    },
    content = function(file) {
      ggsave(file, plot = modPlotInput(), device = 'png', width = 15, 
             height = 10, units = 'cm')
    }
  )
  #PREDICTIONS
  output$downloadPredPlot <- downloadHandler(
    filename = function() { 
      paste(input$wland, '-Pred-', Sys.Date(), '.png', sep = '') 
    },
    content = function(file) {
      ggsave(file, plot = predPlotInput(), device = 'png', width = 15, 
             height = 10, units = 'cm')
    }
  )
  #PREDICTIONS DATA
  output$downloadData <- downloadHandler(
    filename = function() { 
      paste(input$wland, '-Pred-', Sys.Date(),'.csv', sep = '') 
    },
    content = function(file) {
      write.csv(datasetInput(), file)
    }
  )
})