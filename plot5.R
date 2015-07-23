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
## 5. How have emissions from motor vehicle sources changed from 1999–2008 in 
##    Baltimore City?

library(ggplot2)
library(plyr)

NEI.baltimore <- NEI[NEI$fips == "24510", ]

motor.vehicles <- grepl("Vehicles", SCC$EI.Sector, ignore.case = TRUE)
scc.codes <- SCC[motor.vehicles, ]$SCC
neil.motor.vehicles.baltimore <- NEI.baltimore[NEI.baltimore$SCC %in% scc.codes, ]

emissions.year = ddply(neil.motor.vehicles.baltimore, .(year), summarize, sum=sum(Emissions))

emissions.x = c(1999,2008)
emissions.y = emissions.year[emissions.year$year %in% emissions.x,]$sum

decay = emissions.y[2] / emissions.y[1] - 1

png("plot5.png")

plot(emissions.year, 
     ylab="total emissions (tons)", 
     main="Total Emissions x Year (Baltimore - Motor Vehicles)",
     pch = 19)

lines(emissions.x, emissions.y, col=2)

text(emissions.x[2], emissions.y[2], paste0(round(decay * 100,1), "%"), pos=2)

dev.off()