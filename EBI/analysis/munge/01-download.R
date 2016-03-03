# Get the data from CERN and cache it!

if ( !file.exists('cache/transfers.RData') ) {
  csvFile <- 'transfer-data.csv'
  if ( !file.exists( csvFile ) ) {
    stop("Woah, no cached data and no CSV to read it from. Game over!")
  }
  transfers <- read.csv(csvFile)
  cat("Caching data...\n")
  cache('transfers')
} else {
  cat("Skip downloading data, it's already cached\n")
}
