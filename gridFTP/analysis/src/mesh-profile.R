plotDurationDistributionSmall <- function(from=NULL, to=NULL) {
  link = transfers$From == from & transfers$To == to
  xMax = 500
  xlim = range(0,xMax)
  xCut = transfers$Duration < xMax
  if ( !length(transfers$Duration[link & OK & xCut]) ) {
    plot(c(0,1), main='', xlab='', ylab='', yaxt='n', type='n')
    return()
  }
  cat('Plot duration distribution from',from,'to',to,"\n")

  suppressWarnings(
    hist(transfers$Duration[link & OK & xCut],
         main='',
         xlab='', ylab='',
         xlim = xlim,
         yaxt='n', xaxt='n',
         col='lightblue',
         freq=FALSE,
        )
  )
  n = format(length(transfers$Duration[link & OK]), digits=3)
  m = format(  mean(transfers$Duration[link & OK]), digits=3)
  s = format(    sd(transfers$Duration[link & OK]), digits=3)
# l = c(paste0('N=',n),paste0('M=',m))
  k = strtoi(n)
  if ( k > 500 ) {
    l = c(paste0(floor(k/1000+0.5),'K'))
  } else {
    l = n
  }
  legend("topright", inset=c(.1,-0.05), title=NULL, l, bty='n', cex=1.5 )
}

startDev(devSize=devSize, ask=FALSE)
#suppressWarnings(par(.parDefault))
#devAskNewPage(ask=TRUE)
par(oma=c(0,3,3,0), mar=c(0,0,0,0))
par(mfrow=c(length(Rows),length(Cols)))
print('Now the NxN duration distributions, for comparison')
for ( f in Rows ) {
  for ( t in Cols ) {
    if ( f != t ) {
      cat('Duration plots: from',f,'to',t,"\n")
      plotDurationDistributionSmall(from=f, to=t)
    } else {
      plot(c(),
           main='', xlab='', ylab='',
           xlim=range(-1:1), ylim=range(-1:1),
           xaxt='n', yaxt='n'
           )
      text(0, y=0, labels=f, cex=1.8 * 9/length(Nodes) )
    }
  }
}
mtext('To',   side=3, outer=TRUE, cex=1.5)
mtext('From', side=2, outer=TRUE, cex=1.5)
savePlot(filename='R-combined-all.bmp')
