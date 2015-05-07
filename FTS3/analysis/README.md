# This package contains code for producing the mesh plots

## Producing the static plot
The plots are produced with R. You need the **ProjectTemplate** library installed, so install that first if you don't have it:

> R> install.packages('ProjectTemplate')

That's a one-time operation. Now, every time you start R, load the library, then the project:

> R> library(ProjectTemplate)
> R> load.project()

when you run this the first time it will download the latest dataset from CERN and cache it on disk. Next time it starts it will see the cached data and simply start from that. If you want to refresh with new data, remove the old cached data first:

> rm cache/transfers.RData

Now load the script with the plotting function in it:

> source('src/time-window.R')

the plotting function is called **plotMeshTimeWindow**. It takes two arguments, **start\_days** and **interval\_days**. **start\_days** is how many days ago you want to start plotting from, the default value is one day. **interval\_days** is the number of days of data you want to plot, also defaulting to one. So, here are some sample calls:

> R> plotMeshTimeWindow(start_days=7,interval_days=7) # plot last weeks data
> R> plotMeshTimeWindow(start_days=7,interval_days=1) # plot data from this day a week ago
> R> plotMeshTimeWindow() # plot the last 24 hours of data

If you want finer-grained control, you can use the **start\_hours** and **interval\_hours** arguments too, they work correctly in appropriate combinations.

N.B. days and hours are counted from the current time, not from midnight or the beginning of an hour.

To get a PDF file, set **devPDF** to true and plot again:

> devPDF=TRUE
> plotMeshTimeWindow()
> dev.off() # you have to 'close' the plotting device...

now there is a file **Rplots.pdf** in the current directory which contains the plot.

## An interactive 'shiny' plot
This is an experimental feature. Install (if you don't already have it) the 'shiny' library:

> R> install.package('shiny')

then load the library...

> R> library(shiny)

then run the app. It should open your default browser automatically:

> R> runApp('app')

then play with the time-select dropdown to see different intervals.