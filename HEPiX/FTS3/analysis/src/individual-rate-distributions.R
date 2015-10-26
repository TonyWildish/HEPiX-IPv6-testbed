plotDurationDistribution <- function(from=NULL, to=NULL) {
  link = transfers$From == from & transfers$To == to
  if ( !length(transfers$Duration[link]) ) { return() }
  xlim = range(transfers$Duration[link])
  xlim = c( as.integer(xlim[1]/100),
            100*as.integer((xlim[2]+100-1)/100) )
  breaks <- seq(from=xlim[1], to=xlim[2], length.out=50)

  cat('Plot duration distribution from',from,'to',to,"\n")

  h <- NULL
  tryCatch(
  h <- hist(transfers$Duration[link & OK],
       breaks = breaks,
       plot = FALSE
      )
  , error = function(e) {
     print(paste0('Whoops! ',e$message))
     print(xlim[1])
     print(xlim[2])
     print(breaks)
     print(h)
    })
  if ( is.null(h) ) { return(NULL) }
  ylim = range(h$counts)
  ylim[2] <- ylim[2] * 1.3
  suppressWarnings(
    hist(transfers$Duration[link & OK],
         xlab='Duration (seconds)',
         ylab='Frequency',
         main=paste('Transfer duration distribution,',from,'to',to),
         xlim = xlim,
         ylim = ylim,
         breaks = breaks,
         col='blue',
        )
  )

  n = length(transfers$Duration[link &  OK])
  m =   mean(transfers$Duration[link &  OK])
  s =     sd(transfers$Duration[link &  OK])
  e = length(transfers$Duration[link & !OK])
  smry <- data.frame('From'=from,'To'=to,N=n,Mean=m,StdDev=s,Errors=e,
                     stringsAsFactors=FALSE)
  n = format(n, digits=3)
  m = format(m, digits=3)
  s = format(s, digits=3)
  l = paste0('N=',n,' Mean=',m,' Std.Dev.=',s)
  legend("topright", inset=.05, title=NULL, c(l) )

  suppressWarnings(
  hist(transfers$Duration[link & !OK],
       xlab='Duration (seconds)',
       ylab='Frequency',
       xlim = xlim,
       breaks = breaks,
       col=rgb(1,0,0,0.5),
       add = TRUE
      )
  )
  return(smry)
}

plotTransferProfile <- function(from=NULL, to=NULL) {
  cat('Plot transfer profile distribution from',from,'to',to,"\n")
  link = transfers$From == from & transfers$To == to
  if ( !length(transfers$Duration[link]) ) { return() }

# ylim = range(transfers$Duration)
# ylim[1] = 0
# if ( ylim[2] == -Inf ) { ylim[2] = 1 }

  par(cex.axis=0.75, las=2, mar=c(5,4,4,2))
  plotDurationProfileLink(from=from,to=to,link=link,main=paste('Time profile of transfers from',from,'to',to))
  good = length(transfers$Duration[link &  OK])
  bad  = length(transfers$Duration[link & !OK])

  if ( bad > 0 ) {
    errorRate = paste0('error rate: ',round(100*bad/(bad+good),digits=1),'%')
  } else {
    errorRate = 'no errors'
  }
  if ( !is.null(errorRate) ) {
    legend("topright", inset=.0, title=NULL, legend=c(errorRate))
  }
}

startDev(devSize=devSize)

# The duration distribution and transfer profiles
#suppressWarnings(par(.parDefault))
errSmry <- NULL
for (f in Rows) {
  for (t in Cols) {
    if ( f != t ) {
      cat('Duration plots: from',f,'to',t,"\n")
      par(mfrow = c(2,1))
      smry = plotDurationDistribution(from=f, to=t)
      if ( !is.null(smry) ) {
        errSmry <- rbind(errSmry,smry)
        plotTransferProfile(from=f, to=t)
      }
      savePlot(filename=paste0('R-',f,'-to-',t,'.bmp'))
    }
  }
}
cache('errSmry')
