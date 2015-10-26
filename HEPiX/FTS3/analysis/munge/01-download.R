# Get the data from CERN and cache it!

if ( !file.exists('cache/transfers.RData') ) {
#  cat("Downloading processed data from CERN\n")
#  srcURL = 'http://wildish.home.cern.ch/wildish/Data/IPv6/transfer-data.RData'
#  download.file(srcURL, destfile='cache/transfers.RData', ,method='curl', extra='--insecure')
#  load('cache/transfers.RData')

  cat("Downloading dataset from CERN\n")
  srcURL = 'http://wildish.home.cern.ch/wildish/Data/IPv6/transfer-data.csv'
  transfers <- read.csv(srcURL, header=TRUE)
  cat("Caching data...\n")
  cache('transfers')
} else {
  cat("Skip downloading data, it's already cached\n")
}
