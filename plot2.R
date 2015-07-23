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
## 2. Have total emissions from PM2.5 decreased in the Baltimore City, Maryland 
##   (fips == "24510") from 1999 to 2008? Use the base plotting system to make a
##   plot answering this question.

library(plyr)

# Calculate the total emissions by year
NEI.baltimore = NEI[NEI$fips == "24510", ]
emissions.year = ddply(NEI.baltimore, .(year), summarize, sum=sum(Emissions))

emissions.x = c(1999,2008)
emissions.y = emissions.year[emissions.year$year %in% emissions.x,]$sum

decay = emissions.y[2] / emissions.y[1] - 1

png("plot2.png")

plot(emissions.year, 
     ylab="total emissions (tons)", 
     main="Total Emissions x Year (Baltimore)",
     pch = 19)

lines(emissions.x, emissions.y, col=2)

text(emissions.x[2], emissions.y[2], paste0(round(decay * 100,1), "%"), pos=2)

dev.off()