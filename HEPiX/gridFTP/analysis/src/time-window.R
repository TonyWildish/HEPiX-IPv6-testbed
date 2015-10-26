plotTimeWindow <- function(from=NULL, to=NULL, data=transfers, showAxis=FALSE, compact=FALSE, xMax=500) {
  link = data$From == from & data$To == to & data$Status == 0
  xlim = range(0,xMax)
  xCut = data$Duration < xMax
  if ( !length(data$Duration[link & xCut]) ) {
    cat('*** No data from',from,'to',to,"\n")
    plot(c(0,1), main='', xlab='', ylab='', yaxt='n', xaxt='n', type='n')
    return()
  }
  # cat('Plot duration distribution from',from,'to',to,"\n")

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
  # legend("topright", inset=c(.1,-0.05), title=NULL, l, bty='n', cex=1.5 )
}

plotMeshTimeWindow <- function(start_days=0, start_hours=0, interval_days=0, interval_hours=0, xMax=500) {
  start    <-    start_days * 86400 +    start_hours * 3600
  interval <- interval_days * 86400 + interval_hours * 3600
  if ( start <= 0 ) {
    print('Start is zero, take 24 hours by default')
    start = 86400
  }
  if ( interval <= 0 ) {
    print('Interval is zero, take 24 hours by default')
    interval = 86400
  }
  now   <- unclass(Sys.time())
  data  <- transfers[transfers$Start > now-start & transfers$Start < now-start+interval,]
  Nodes <- levels( factor( data$From ) )

  startDev(devSize=devSize, ask=FALSE)
  #suppressWarnings(par(.parDefault))
  #devAskNewPage(ask=TRUE)
  par(oma=c(0,3,3,0), mar=c(2,0,0,1))
  if ( compact ) {
    par(mar=c(0.1,0.1,0,0.1))
  }
  par(mfrow=c(length(Nodes),length(Nodes)))
  print('Now the NxN duration distributions, for comparison')
  for ( f in Nodes ) {
    showAxis = FALSE
    if ( f == Nodes[length(Nodes)] ) { showAxis = TRUE }
    if ( f == Nodes[1] ) { showAxis = TRUE }
    for ( t in Nodes ) {
      if ( f != t ) {
        cat('Duration plot: from',f,'to',t,' ',sum(data$To==t) + sum(data$From==f)," entries\n")
        plotTimeWindow(
      		from=f,
      		to=t,
      		data=data,
      		showAxis=showAxis,
      		compact=compact,
          xMax=xMax
    		)
      } else {
        cat('Key plot: from',f,'to',t,"\n")
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
  savePlot(filename='R-combined-all.bmp')
}
