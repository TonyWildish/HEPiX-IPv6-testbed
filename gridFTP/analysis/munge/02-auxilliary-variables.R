# Prepare a few standard logicals
OK = transfers$Status == 0
Table <- table( transfers$From, transfers$To )
Rows <- dimnames(Table)[1][[1]]
Cols <- dimnames(Table)[2][[1]]

devSize = 8
options(digits=3)

devPDF    = FALSE
savePlots = TRUE
dontAsk   = FALSE
noRed     = FALSE
compact   = FALSE
