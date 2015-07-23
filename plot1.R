###
### Download and unzip the data.
###

if(! dir.exists("data")) dir.create("data")

FILENAME = file.path("data", "NEI_data.zip")

if(! file.exists(FILENAME)) {
    download.file(
        url = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip",
        destfile = FILENAME, method = "curl"
    )
    
    unzip(FILENAME, exdir = "data")
}

###
### Read the data.
###

NEI <- readRDS(file.path("data", "summarySCC_PM25.rds"))
SCC <- readRDS(file.path("data", "Source_Classification_Code.rds"))


### Plot
# 1. Have total emissions from PM2.5 decreased in the United States from 1999 to
#    2008? Using the base plotting system, make a plot showing the total PM2.5 
#    emission from all sources for each of the years 1999, 2002, 2005, and 2008.

library(plyr)

# Calculate the total emissions by year
emissions.year = ddply(NEI, .(year), summarize, sum=sum(Emissions))

emissions.x = c(1999,2008)
emissions.y = emissions.year[emissions.year$year %in% emissions.x,]$sum

decay = emissions.y[2] / emissions.y[1] - 1

png("plot1.png")

plot(emissions.year, 
     ylab="total emissions (tons)", 
     main="Total Emissions x Year",
     pch = 19)

lines(emissions.x, emissions.y, col=2)

text(emissions.x[2], emissions.y[2], paste0(round(decay * 100,1), "%"), pos=2)

dev.off()