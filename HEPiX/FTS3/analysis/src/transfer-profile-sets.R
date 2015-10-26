plotTransferProfileSetFrom <- function(from=NULL) {
  cat('Plot transfer profile distribution set from',from,"\n")

  n = length(Cols) - 1
  par(cex.axis=0.75, las=2, mfrow=c(n,1))
  par(mar=c(2,5,1,1))
  for ( to in Cols ) {
    link = transfers$From == from & transfers$To == to
    if ( !length(transfers$Duration[link]) ) { next }
    if ( from == to ) {
      next;
    }
    plotDurationProfileLink(from=from,to=to,link=link,main=paste('From',from,'to',to))
  }
}

plotTransferProfileSetTo <- function(to=NULL) {
  cat('Plot transfer profile distribution set to',to,"\n")

  n = length(Rows) - 1
  par(cex.axis=0.75, las=2, mfrow=c(n,1))
  par(mar=c(2,5,1,1))
  for ( from in Rows ) {
    link = transfers$From == from & transfers$To == to
    if ( !length(transfers$Duration[link]) ) { next }

    plotDurationProfileLink(from=from,to=to,link=link,main=paste('From',from,'to',to))
  }
}

startDev(devSize=devSize)
for (f in Rows) {
  plotTransferProfileSetFrom(from=f)
  savePlot(filename=paste0('R-set-',f,'-to-all.bmp'))
  plotTransferProfileSetTo(    to=f)
  savePlot(filename=paste0('R-set-all-to-',f,'.bmp'))
}
