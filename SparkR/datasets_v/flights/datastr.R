#Download Data
# 
require(data.table)
# 
# #Data used in the original benchmark is from years 2005, 2006, 2007
# #Create directory
# mainDir <- "~/datasets_v/"
# subDir <- "flights" # Please put the download data into this folder
# dir.create(file.path(mainDir), showWarnings = FALSE)
# dir.create(file.path(mainDir, subDir), showWarnings = FALSE)
# setwd( "~/datasets_v/flights")


# open a temporary directory to store data
# Each bz2 file is identified by a year
first.run <- 0 #Change this value to 1 for running the code the 1st time and download data
if(first.run == 1){
  for (i in 2005:2006) {
    # define the url	
    url <- paste("http://stat-computing.org/dataexpo/2009/", i, ".csv.bz2", sep = "")
    file <- paste("~/datasets_v/flights/", basename(url), sep = "")
    # download the zip file and store in the "file" object 
    download.file(url, file)
  }
}

#Read data
dt.2005 <- fread(sprintf("bzcat %s | tr -d '\\000'", "2005.csv.bz2"))
dt.2006  <- fread(sprintf("bzcat %s | tr -d '\\000'", "2006.csv.bz2"))

#Append years 2005 and 2006, to later use as train datasets
dt1 <- rbind(dt.2005, dt.2006)
rm(dt.2005, dt.2006); gc()

dt2 <- fread(sprintf("bzcat %s | tr -d '\\000'", "2007.csv.bz2"))

#Remove obs without info about Delay
dt1 <- dt1[!is.na(ArrDelay)]
dt2 <- dt2[!is.na(ArrDelay)]
gc()

#Convert calendar vars to characters ("pseudofactors" when saved to csv)
for (k in c("Month","DayofMonth","DayOfWeek")) {
  dt1[[k]] <- paste0("f-",as.character(dt1[[k]]))
  dt2[[k]] <- paste0("f-",as.character(dt2[[k]]))
}

#Create speed variable (MPH)
#airliners speed: https://www.quora.com/At-what-speed-do-airliners-generally-travel-Do-they-typically-fly-at-or-near-their-top-speed-Are-any-capable-of-mach-1
dt1[ ,Speed := Distance/(AirTime / 60)]
dt1 <- dt1[Speed > 0 & Speed < 1000] #Remove non-sense values
dt2[ ,Speed := Distance/(AirTime / 60)]
dt2 <- dt2[Speed > 0 & Speed < 1000] #Remove non-sense values

#Select columns to be used as features and target variable (ArrDelay)
cols <- c("Month", "DayofMonth", "DayOfWeek", "UniqueCarrier", 
          "Origin", "Dest", "Distance", "DepDelay", "Speed")
dt1 <- dt1[, cols, with = FALSE]
dt2 <- dt2[, cols, with = FALSE]

#Create train datasets of sizes: 10⁴, 10⁵, 10⁶, 10⁷
set.seed(123)
for (n in c(1e4,1e5,1e6,1e7)) {
  fwrite(dt1[sample(nrow(dt1),n),], file = paste0("train-",n/1e6,"m.csv"), sep = ",")
}

#Create test and valid datasets from dt2
idx_test <- sample(nrow(dt2), 1e5)
idx_valid <- sample(setdiff(1:nrow(dt2), idx_test), 1e5)
fwrite(dt2[idx_test,], file = "test.csv", sep = ",")
fwrite(dt2[idx_valid,], file = "valid.csv", sep = ",")
