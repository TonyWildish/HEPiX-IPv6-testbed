#helper.function <- function() { return(1) }

savePlot <- function(filename=NULL,width=1024,height=1024, save=FALSE) {
  if ( !savePlots & !save ) { return(); }
  cur=dev.cur()
  bmp(width=width,height=height,filename=paste0('graphs/',filename))
# png(width=width,height=height,units='px',res=200,filename=paste0('graphs/',filename))
  new=dev.cur()
  dev.set(which=cur)
  dev.copy(which=new)
  dev.off(new)
}

startDev <- function(devSize=8, width=NULL, height=NULL, ask=TRUE) {
  for (i in dev.list()) {
    dev.off()
  }
  if ( !is.null(devPDF) && devPDF ) {
    print('Starting a PDF device')
    pdf()
  } else {
    if ( is.null(width)  ) { width = devSize }
    if ( is.null(height) ) { height = devSize }
    dev.new(width=width,height=height)
    if ( !dontAsk ) { devAskNewPage(ask=ask) }
    par(mfrow=c(2,1), mgp=c(2,0.75,0))
    .parDefault <- par()
  }
}

plotDurationProfileLink <- function(from=NULL, to=NULL, link=NULL, main=NULL) {
  par(mgp=c(3,0.6,0))
  ylim = range(transfers$Duration[link])
  ylim[1] = 0
  if ( ylim[2] == -Inf ) { ylim[2] = 1 }
  xlim = range(transfers$Start,transfers$Stop)
  plot(
        transfers$Stop[link],
        transfers$Duration[link],
        type='n',
        xlab='',
        ylab='Transfer duration',
        xaxt='n',
        ylim=ylim,
        xlim=xlim,
        main=main,
      )

# Calculate x-axis markers. Start at 12 hours, but thin out until I have less than
# 5 labels to print. More than that clutters up the plot too much
  interval = 3600 * 12
  xlower = as.integer(xlim[1]/interval + 1)
  xupper = as.integer(xlim[2]/interval - 1)
  nBins  = xupper-xlower
  while ( nBins > 5 ) {
    interval = interval * 2
    xlower = as.integer(xlim[1]/interval + 1)
    xupper = as.integer(xlim[2]/interval)
    nBins  = xupper-xlower
  }
  xupper = (xlower + nBins) * interval
  xlower = xlower * interval
  at <- seq(from=xlower, to=xupper, length.out=nBins+1)
  labels <- lapply(
    at,
    as.POSIXct,
    origin="1970-01-01"
  )
  if ( interval < 86400 ) {
    labels <- lapply(labels, format, format="%m/%d %H")
  } else {
    labels <- lapply(labels, format, format="%m/%d")
  }
  axis(side=1,at=at,labels=labels,las=1,cex.axis=1.2);

  points(transfers$Stop[link & OK],transfers$Duration[link & OK],type='p',
         pch=19,
         cex=0.3,
         col='blue'
         )
  if ( !noRed ) {
    points(transfers$Stop[link & !OK],transfers$Duration[link & !OK],type='p',
           pch=19,
           cex=0.3,
           col='red'
           )
  }
}
