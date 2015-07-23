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
## 6. Compare emissions from motor vehicle sources in Baltimore City with 
##    emissions from motor vehicle sources in Los Angeles County, California 
##    (fips == "06037"). Which city has seen greater changes over time in motor 
##    vehicle emissions?

library(ggplot2)
library(plyr)
library(tidyr)

motor.vehicles <- grepl("Vehicles", SCC$EI.Sector, ignore.case = TRUE)
scc.codes <- SCC[motor.vehicles, ]$SCC

NEI.filtered <- NEI[NEI$fips %in% c("24510","06037"),]
NEI.filtered <- NEI.filtered[NEI.filtered$SCC %in% scc.codes,]
emissions <- ddply(NEI.filtered, .(fips, year), summarize, sum=sum(Emissions))
emissions$fips <- factor(emissions$fips, levels=c("06037", "24510"), labels=c("Los Angeles", "Baltimore"))

emissions.cols <- spread(emissions, year, sum)
emissions.cols <- mutate(emissions.cols, decay=round((emissions.cols$`2008` / emissions.cols$`1999` - 1) * 100, 1))

g <- ggplot(emissions, aes(year, sum)) + 
     geom_point() + 
     geom_segment(aes(x=1999, y=emissions.cols$"1999", xend=2008, yend=emissions.cols$"2008"), color="red", data=emissions.cols) +
     geom_text(aes(x=2008, y=emissions.cols$`2008`, label=paste0(emissions.cols$decay, "%"), hjust=1), data=emissions.cols) +
     facet_grid(. ~ fips) +
     ggtitle("Total Emissions x Year (Motor Vehicles)") +
     ylab("total emissions (tons)")

png("plot6.png")
print(g)
dev.off()
