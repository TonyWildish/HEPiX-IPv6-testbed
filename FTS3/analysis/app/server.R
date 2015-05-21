library(shiny)

shinyServer(function(input, output) {
  
  interval <- reactive({
    switch(input$interval,
           "4 hours"  = -4,
           "12 hours" = -12,
           "1 day"    = 1,
           "1 week"   = 7,
           "all data" = 999999
        )
    })

  # load('../cache/transfers.RData')
  srcURL = 'http://wildish.home.cern.ch/wildish/Data/IPv6/transfer-data.csv'
  transfers <- read.csv(srcURL, header=TRUE)

  plotTimeWindow <- function(from=NULL, to=NULL, data=transfers, showAxis=FALSE, compact=FALSE, xMax=500) {
    link = data$From == from & data$To == to & data$Status == 0
    xlim = range(0,xMax)
    xCut = data$Duration < xMax
    if ( !length(data$Duration[link & xCut]) ) {
      plot(c(0,1), main='', xlab='', ylab='', yaxt='n', xaxt='n', type='n')
      return()
    }

    suppressWarnings(
      if ( compact ) {
        hist(data$Duration[link & xCut],
             main='',
             xlab='', ylab='',
             xlim = xlim,
             yaxt='n', xaxt='n',
             col='lightblue',
             freq=FALSE,
            )
      } else {
        myxaxt='n'
        if ( showAxis ) { myxaxt='s' }
        hist(data$Duration[link & xCut],
             main='',
             xlab='', ylab='',
             xlim = xlim,
             yaxt='n', xaxp=c(0,xMax,1),
             xaxt=myxaxt,
             col='lightblue',
             freq=FALSE,
             cex.axis=0.9,
             mgp=c(3,0.7,0),
            )
      }
    )
    n = format(length(data$Duration[link]), digits=3)
    m = format(  mean(data$Duration[link]), digits=3)
    s = format(    sd(data$Duration[link]), digits=3)
    k = strtoi(n)
    if ( k > 500 ) {
      l = c(paste0(floor(k/1000+0.5),'K'))
    } else {
      l = n
    }
  }

  plotMeshTimeWindow <- function(start_days=0, start_hours=0, interval_days=0, interval_hours=0, xMax=500) {
    start    <-    start_days * 86400 +    start_hours * 3600
    interval <- interval_days * 86400 + interval_hours * 3600
    if ( start <= 0 ) {
      start = 86400
    }
    if ( interval <= 0 ) {
      interval = 86400
    }
    now   <- unclass(Sys.time())
    data  <- transfers[transfers$Start > now-start & transfers$Start < now-start+interval,]
    Nodes <- levels( factor( data$From ) )

    par(oma=c(0,3,3,0), mar=c(2,0,0,1))
    validate(
      need(
        length(Nodes) > 0,
        paste0("No data in selected range (",input$interval,"), try a wider time-bin!" )
      )
    )

    par(mfrow=c(length(Nodes),length(Nodes)))
    for ( f in Nodes ) {
      showAxis = FALSE
      if ( f == Nodes[length(Nodes)] ) { showAxis = TRUE }
      if ( f == Nodes[1] ) { showAxis = TRUE }
      for ( t in Nodes ) {
        if ( f != t ) {
          plotTimeWindow(
            from=f,
            to=t,
            data=data,
            showAxis=showAxis,
            xMax=xMax
          )
        } else {
          plot(c(),
               main='', xlab='', ylab='',
               xlim=range(-1:1), ylim=range(-1:1),
               xaxt='n', yaxt='n'
               )
          text(0, y=0, labels=f, cex=1.8 * 7/length(Nodes) )
        }
      }
    }
    mtext('To',   side=3, outer=TRUE, cex=1.5)
    mtext('From', side=2, outer=TRUE, cex=1.5)
  }

  output$distPlot <- renderPlot({
    i <- interval()
    if ( i < 0 ) {
      sdays <- 0
      shours <- -i
    } else {
      sdays <- i
      shours <- 0
    }
    plotMeshTimeWindow(start_days=sdays,
                       interval_days=,sdays,
                       start_hours=shours,
                       interval_hours=shours
                       )
  },
  width=600, height=600
)

})