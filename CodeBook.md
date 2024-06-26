# Background

---

### Dataset Information

- The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years.
- Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist.
- Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and
- 3-axial angular velocity at a constant rate of 50Hz.
- The experiments have been video-recorded to label the data manually.
- The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating 
the training data and 30% the test data.
- The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then
- sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window).
- The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter
into body acceleration and gravity.
- The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used
- From each window, a vector of features was obtained by calculating variables from the time and frequency domain.



### Variable Information

For each record in the dataset it is provided:

 - Triaxial acceleration from the accelerometer (total acceleration) and
 - The estimated body acceleration.
 - Triaxial Angular velocity from the gyroscope. 
 - A 561-feature vector with time and frequency domain variables (described in "features.txt"). 
 - Its activity label. 
 - An identifier of the subject who carried out the experiment. 

#### Features
The features.txt file shows a list of 561 variables in total. Here is the breakdown for this file:


### Data Files


 - All the data is listed in 18 files in directory: UCI HAR Dataset
 - 9 files are located in ~\getdata_projectfiles_UCI HAR Dataset\UCI HAR Dataset\test\Inertial Signals
 - 9 files are located in ~\getdata_projectfiles_UCI HAR Dataset\UCI HAR Dataset\train\Inertial Signals
 - Files are in .txt format
 - Here is a list of files that were used for this project

                "activity_labels.txt" "features.txt"
                "features_info.txt"   "README.txt" 
                "subject_test.txt" "X_test.txt"       "y_test.txt"
                "subject_train.txt" "X_train.txt"       "y_train.txt"



What follows is a detailed explanation of the process taken to load, clean and create the tidy dataset needed.


# Download Data

---

- Setup directory for project
- Download data from Url 
- Verify the download
- Set timestamp for download
- Unzip downloaded file
```
setwd("D:/~/Data/")
if(!file.exists("har")){dir.create("har")}
setwd("D:/~/Data/har")

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "zipped.zip", method="curl")
list.files("har")                       
unzip("zipped.zip", list=TRUE)          
dateDownloaded <- date()

unzip("zipped.zip", exdir= "D:/~/Data/har/unzipped")
```

# Import Data

---

- Create function loadfile() that returns a table of the data
- Import these .txt files: 
        subject_test, x_test, y_test, subject_train,
        x-train, y-train, features, activity_labels
```
subject_test <- loadfile("test","subject_test") 
X_test <- loadfile("test","X_test")
y_test <- loadfile("test","y_test")
subject_train <- loadfile("train","subject_train")
X_train <- loadfile("train","X_train")
y_train <- loadfile("train","y_train")
features <- read.table("D:/~/features.txt")
labelfile <- read.table("D:/~/activity_labels.txt")
```


# Merdge Data Tables

---

- Merge (cbind) subjext_test: a one column table displaying all the subjects (1-30) in each row
- x_test & y_test are to be cbind with subject_text which will give us testfile, a table (2947x563)
- Merge subjext_train with x_train & y_train
- subject_* are the columns that identify the subject for each observation
- Merge (row bind) the above merged files togetherto give us 1 dataset for all observations (10299x563)


```
testfile <- cbind(subject_test,y_test,X_test)
trainfile <- cbind(subject_train,y_train,X_train)
mergedfile <- rbind(testfile,trainfile)
```


# Add Column Names

---

- Subjects: We already know that the first column contains all the subject identifiers from above subject_* files we merged in the step above. The first column will be named (subject)
- y_test, is the second column in the table, this column contains all the activity identifiers for each row/observation. So the second column will be named (activity)
- The remaining 561 columns are the features which will be assigned from the second column of the features table we loaded earlier

```
features <- features[,2]
cnames <- c("subject","activity",features)
colnames(mergedfile) <- cnames
```

# Filter the Data

---

- At this time we are only interested in certain features that involve the mean() or the std()
- I'll use grep() to identify the columns that meet the criteria
- Then I'll use select to extract the desired columns and assign it to (extracteddata)

```
library(dplyr)
extracteddata <- mergedfile |>  select(grep("subject|activity|-[mM]ean()|-[sS]td()",names(mergedfile)))
```

# Edit Values

---

- labelfile from above contains the 6 key identifiers for the activity that the subjects participated in
- The second column named "activity" contains numbers from 1-6 which correspond to the keys for each activity
- It would make more sense to replace the integers in column 2 with their respective description "walking, standing....
- The keys are all capitalized, so it's more appropriate to convert them to lowercase before inserting them into the data table
- I'll use case_match to convert the values in column 2 to a more descriptive string
```
extracteddata$activity <- case_match(
                        extracteddata$activity,
                        extracteddata$activity ~ tolower(labelfile[extracteddata$activity,2]))
```

# Create Tidy Dataset

---

Now that I've cleaned and rearranged the data. I will create a dataset that:
- Remember the data tracked 30 subjects (column 1)
- Subjects participated in 6 activities (identified in column 2)
- Measurements were recorded in columns 3 to 81
- So the data can be grouped in 2 groups, subject and activity
- I'm going to create one dataset that shows the mean of all the results for ALL the subjects for EACH activity (6 activites). So we should have a 6x80 table  (peractivityfile.txt)
- I'll also create one dataset for the mean of all measurements for EACH subject for ALL activities. Since we have 30 subjects involved in 6 activities, we should have a 180x81. 81 as opposed to 80 because we have a column identifying the activity per subject (persubfile.txt)
- I'll create a .txt and a .csv file for each
```
library(data.table)
install.packages("reshape")
library(reshape)

 #let's use melt to set the IDs(activity, subject) and variables will be (all the rest)
 varnames <- c(names(extracteddata[3:81]))
 meltdata  <- melt(extracteddata, id=c("activity", "subject"), measure.vars = varnames )

 #______mean for each subject performing each activity
 persubfile <- reshape2::dcast(meltdata, activity + subject ~ variable, mean)
 
 #________mean of all subjects for each activity
 peractivityfile <- reshape2::dcast(meltdata, activity ~ variable, mean)
```

# Save Tidy Dataset

---

- I'll save both files in .txt and .csv formats
- Verify the files were saved in the correct directory
- Confirm operation with a timestamp
```
 library(readr)
 if(!file.exists("har/meanPerSubject.csv")){write_csv(persubfile,"har/meanPerSubject.csv")}
 if(!file.exists("har/meanPerActivity.csv")){write_csv(peractivityfile,"har/meanPerActivity.csv")}
 #______Save in txt format as well
 if(!file.exists("har/meanPerSubject.txt"))write.table(persubfile,"har/meanPerSubject.txt")
 if(!file.exists("har/meanPerActivity.txt")){write_csv(peractivityfile,"har/meanPerActivity.txt")}
 
 list.files("har")
 dateUploaded <- date()
```

