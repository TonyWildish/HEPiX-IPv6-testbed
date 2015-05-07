plotCombinedWireActivity <- function(node=NULL, dir=NULL) {
  if ( is.null(dir) || is.null(node) ) { return() }
  if ( dir != 'from' && dir != 'to' ) { return() }
  if ( dir == 'from' ) {
    link = transfers$From == node
    dir  = 'From'
    rDir = 'To'
  }
  if ( dir == 'to'   ) {
    link = transfers$To == node
    dir  = 'To'
    rDir = 'From'
  }
  if ( length(transfers$Start[link]) == 0 ) { return() }

  colours <- data.frame(
               node = c('CERN','Caltech','INFN','GARR','GRIDKA','FZU','Imperial','PIC'),
               colour = c('blue','green','grey','orange','wheat','turquoise','magenta','brown'),
               stringsAsFactors = FALSE
             )

  xrange = range(transfers$Start[link], transfers$Stop[link])
  yrange = range(0, transfers$Duration[link])
  plot(
        xrange,
        yrange,
        type='n',
        xlab='',
        ylab='Combined Activity',
        xaxt='n',
        main=paste('All nodes',dir,node),
      )
  d <- transfers[link,]
  for (i in 1:length(d$Start)) {
    row = d[i,]
    n = row[rDir]
    if ( row$Status == 0 ) {
      if ( n == 'CERN'    ) { colour = 'blue' }
      if ( n == 'Caltech' ) { colour = 'green' }
      if ( n == 'INFN'    ) { colour = 'grey' }
      if ( n == 'GARR'    ) { colour = 'orange' }
      if ( n == 'GRIDKA'  ) { colour = 'wheat' }
      if ( n == 'FZU'     ) { colour = 'turquoise' }
    }
    else                    { colour = 'red' }
    x = c(row$Start,row$Stop)
    y = c(row$Duration,row$Duration)
    lines(x,y,col=colour,lwd=2)
  }

  nLabels = 5
  at <- seq( from=xrange[1], to=xrange[2], length.out=nLabels )
  labels <- lapply(
    at,
    as.POSIXct,
    origin="1970-01-01"
  )
  labels <- lapply(labels, format, format="%m/%d %H:%M")
  axis(1, labels=labels, at=at)
  if ( dir == 'From' ) {
    legend(x='topright',
           legend = colours$node[colours$node != node],
           col = colours$colour[ colours$node != node],
           pch = rep( 19,length(colours$node)-1),
           cex = rep(0.6,length(colours$node)-1)
          )
  }
}

startDev(devSize=devSize)
#suppressWarnings(par(.parDefault))
# Now the combined wire activity per site
print('Now for the combined wire activity per site')
for (n in Rows) {
  saveIt = FALSE
  cat('Combined activity: from',n,"\n")
  plotCombinedWireActivity(node=n, dir='from')
  cat('Combined activity: to',n,"\n")
  plotCombinedWireActivity(node=n, dir='to')
  savePlot(filename=paste0('R-combined-',n,'.bmp'))
}
