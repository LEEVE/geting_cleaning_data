# Background

---

Wearable computing seems to be the latest craze. Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users.
I'll import data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description of the data can be found here on the UC Irvine Machine Learning Repository: 

https://archive.ics.uci.edu/dataset/240/human+activity+recognition+using+smartphones

Here are the data for the project:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
  
An updated version of this dataset can be found at http://archive.ics.uci.edu/ml/datasets/Smartphone-Based+Recognition+of+Human+Activities+and+Postural+Transitions.
It includes labels of postural transitions between activities and also the full raw inertial signals instead of the ones pre-processed into windows. 

### Data Summary
Human Activity Recognition database built from the recordings of 30 subjects performing activities of daily living (ADL) while carrying a waist-mounted smartphone with embedded inertial sensors.

 * The data itself is Mutivariate, Time-Series
 * There are 10299 instances
 * Data was donate 12/9/2012
 * Has no Missing Values
 
# Purpose of Project

---

- The purpose of this project is to document a process of creading Tidy data (getting, and cleaning data).
- A code book "CodeBook" is also attached, it describes the variables, the data, and any transformation work I performed to clean up the data, the main reason behind the CodeBook is for anyone to be able to reproduce the Tidy data by following the steps outlined in the CodeBook.
- A tidy dataset is also created and saved in two separate files:
- meanPerSubject.txt provides the mean of all the variables for each subject performing every activity
- meanPerActivity.txt provides the mean of all the variables for each activity for all the subjects

