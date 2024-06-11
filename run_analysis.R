setwd("D:/~/Data/")
if(!file.exists("har")){dir.create("har")}


#download data from site
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "zipped.zip", method="curl")
list.files("har") 
#view the list of files in the zip folder
unzip("zipped.zip", list=TRUE)          
dateDownloaded <- date()
unzip("zipped.zip", exdir= "D:/~/Data/har/unzipped")


#import data function
loadfile <- function(directory,n){
        fileDir <- setwd("D:/~/Data/har")
        wantedfile = file.path(fileDir,directory,paste(n,".txt",sep = ""),fsep="/")
        return(read.table(wantedfile))
}

#Load data
subject_test <- loadfile("test","subject_test") 
X_test <- loadfile("test","X_test")
y_test <- loadfile("test","y_test")
subject_train <- loadfile("train","subject_train")
X_train <- loadfile("train","X_train")
y_train <- loadfile("train","y_train")
features <- read.table("D:/~/features.txt")
labelfile <- read.table("D:/~/activity_labels.txt")



#  Merge  (row labels= subject_test) (Activity=y_test) (data=x_test) 
testfile <- cbind(subject_test,y_test,X_test)
# Merge  (row labels= subject_train) to x & y train files
trainfile <- cbind(subject_train,y_train,X_train)
# Merge both test&train files
mergedfile <- rbind(testfile,trainfile)



# Extract second column of the df which contains all the column names (features) 
features <- features[,2]
# Add column nameses/labels col1 =subject   col2=activity  col3...=feature
cnames <- c("subject","activity",features)
colnames(mergedfile) <- cnames


# Extract certain cols targeting mean() and sd()
library(dplyr)
extracteddata <- mergedfile |>  select(grep("subject|activity|-[mM]ean()|-[sS]td()",names(mergedfile)))

# Replace activity code with a more descriptive description
extracteddata$activity <- case_match(
                        extracteddata$activity,
                        extracteddata$activity ~ tolower(labelfile[extracteddata$activity,2]))
 
# Calculate the mean of each variable for each ACTIVTY and each SUBJECT
library(data.table)
install.packages("reshape")
library(reshape)

#  Let's use melt to set the IDs(activity, subject) and variables(all the rest)
varnames <- c(names(extracteddata[3:81]))
meltdata  <- melt(extracteddata, id=c("activity", "subject"), measure.vars = varnames )

# Create dataset of the mean for each subject performing each activity
 persubfile <- reshape2::dcast(meltdata, activity + subject ~ variable, mean)
 
# Create a dataset of the mean of all subjects for each activity
 peractivityfile <- reshape2::dcast(meltdata, activity ~ variable, mean)


#________________SAVE TIDY DATASETS
 library(readr)
 if(!file.exists("har/meanPerSubject.csv")){write_csv(persubfile,"har/meanPerSubject.csv")}
 if(!file.exists("har/meanPerActivity.csv")){write_csv(peractivityfile,"har/meanPerActivity.csv")}
 #______Save in txt format as well
 if(!file.exists("har/meanPerSubject.txt"))write.table(persubfile,"har/meanPerSubject.txt")
 if(!file.exists("har/meanPerActivity.txt")){write_csv(peractivityfile,"har/meanPerActivity.txt")}
 # Verify 
 list.files("har")
 dateUploaded <- date()
