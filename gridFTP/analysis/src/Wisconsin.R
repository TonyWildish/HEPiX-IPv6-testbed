plotWisconsinToFrom <- function(from=NULL, to=NULL,
                                data=transfers, Main='') {
  link = data$From == from & data$To == to & data$Status == 0

  hist(data$Duration[link],
       main=Main,
       xlab='', ylab='',
       col='lightblue',
       cex.axis=0.9,
       mgp=c(3,0.7,0),
      )
}

plotWisconsin <- function(days=0, hours=0) {
  interval <- days*86400 + hours*3600
  interval <- unclass(Sys.time()) - interval
  data  <- transfers[transfers$Start > interval,]
  Nodes <- levels( factor( data$From ) )

  startDev(devSize=devSize, ask=FALSE)
  par(oma=c(2,1,0,0), mar=c(2,2,1,1))
  N = length(Nodes)-1
  par(mfrow=c(ceiling(N/2),4))
  print('Now the Nx2 duration distributions for Wisconsin')
  for ( f in Nodes ) {
    if ( f != 'Wisc' ) {
      plotWisconsinToFrom( from='Wisc', to=f, data=data, Main=paste('to',f) )
      plotWisconsinToFrom( from=f, to='Wisc', data=data, Main=paste('from',f) )
    }
  }
  savePlot(filename='R-Wisconsin.bmp')
}
