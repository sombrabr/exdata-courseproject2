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

