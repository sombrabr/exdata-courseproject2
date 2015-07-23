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
## 3. Of the four types of sources indicated by the type (point, nonpoint, 
##    onroad, nonroad) variable, which of these four sources have seen decreases
##    in emissions from 1999–2008 for Baltimore City? Which have seen increases 
##    in emissions from 1999–2008? Use the ggplot2 plotting system to make a plot 
##    answer this question.

library(ggplot2)
library(plyr)
library(tidyr)

# Calculate the total emissions by year
NEI.baltimore <- NEI[NEI$fips == "24510", ]
NEI.sums <- ddply(NEI.baltimore, .(type, year), summarize, sum=sum(Emissions))
NEI.sums$type <- factor(NEI.sums$type, levels = c("POINT", "NONPOINT", "ON-ROAD", "NON-ROAD"))
NEI.cols <- spread(NEI.sums, year, sum)
NEI.cols <- mutate(NEI.cols, decay=round((NEI.cols$`2008` / NEI.cols$`1999` - 1) * 100, 1))


g <- ggplot(NEI.sums, aes(year, sum)) + 
     geom_point() +
     geom_segment(aes(x=1999, y=NEI.cols$"1999", xend=2008, yend=NEI.cols$"2008"), color="red", data=NEI.cols) +
     geom_text(aes(x=2008, y=NEI.cols$`2008`, label=paste0(NEI.cols$decay, "%"), hjust=1), data=NEI.cols) +
     facet_grid( . ~ type) +
     ggtitle("Emissions by source in Baltimore") +
     ylab("total emissions (tons)")

png("plot3.png", width=960)
print(g)
dev.off()