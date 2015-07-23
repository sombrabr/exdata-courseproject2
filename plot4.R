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
## 4. Across the United States, how have emissions from coal combustion-related 
##    sources changed from 1999–2008?

library(ggplot2)
library(plyr)

coal.combustion <- grepl(".* Comb - .* - coal", SCC$EI.Sector, ignore.case = TRUE)
scc.codes <- SCC[coal.combustion, ]$SCC
nei.coal.combustion <- NEI[NEI$SCC %in% scc.codes, ]

emissions.year = ddply(nei.coal.combustion, .(year), summarize, sum=sum(Emissions))

emissions.x = c(1999,2008)
emissions.y = emissions.year[emissions.year$year %in% emissions.x,]$sum

decay = emissions.y[2] / emissions.y[1] - 1

png("plot4.png")

plot(emissions.year, 
     ylab="total emissions (tons)", 
     main="Total Emissions x Year (Coal Combustion)",
     pch = 19)

lines(emissions.x, emissions.y, col=2)

text(emissions.x[2], emissions.y[2], paste0(round(decay * 100,1), "%"), pos=2)

dev.off()
