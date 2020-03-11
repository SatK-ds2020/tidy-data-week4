## getting the working directory
getwd()
dir.create("./Working data")
## download the dataset
fileURL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL,destfile = "./Working data/Dataset.zip")
unzip("./Working data/Dataset.zip")

## loading activity labels with class labels and activity names
activity<-read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("class","activity"))
head(activity)

## loading features      
features<-read.table("UCI HAR Dataset/features.txt",col.names = c("index","feature"))
head(features)

## search for "mean/std" in featurenames through grep function
msfeature <- grep("(mean|std)\\(\\)", features[, "feature"])
mstd_features <- features[msfeature, "feature"]
head(mstd_features)
## [1] "tBodyAcc-mean()-X" "tBodyAcc-mean()-Y" "tBodyAcc-mean()-Z"
## [4] "tBodyAcc-std()-X"  "tBodyAcc-std()-Y"  "tBodyAcc-std()-Z" 

## replacing the "[()]" using gsub function
mstd_features <- gsub('[()]', '', mstd_features)
head(mstd_features)
## [1] "tBodyAcc-mean-X" "tBodyAcc-mean-Y" "tBodyAcc-mean-Z"
## [4] "tBodyAcc-std-X"  "tBodyAcc-std-Y"  "tBodyAcc-std-Z" 

## loading training data files
X_train <- fread("UCI HAR Dataset/train/X_train.txt")[, msfeature, with = FALSE]
data.table::setnames(X_train, colnames(X_train), mstd_features)
Y_train <- fread("UCI HAR Dataset/train/Y_train.txt", col.names = c("Activity"))
subjects_train <- fread("UCI HAR Dataset/train/subject_train.txt", col.names = c("Subject"))
## adding the two columns with train dataset
train <- cbind(subjects_train, Y_train, X_train)
head(train,3)

# Load test data files
X_test <- fread("UCI HAR Dataset/test/X_test.txt")[, msfeature, with = FALSE]
data.table::setnames(X_test, colnames(X_test), mstd_features)
Y_test <- fread("UCI HAR Dataset/test/Y_test.txt", col.names = c("Activity"))
subjects_test <- fread("UCI HAR Dataset/test/subject_test.txt", col.names = c("Subject"))
## adding the two columns with testdataset
test <- cbind(subjects_test, Y_test, X_test)
head(test,3)

# merging the two datasets and thier labels
train_test <- rbind(train, test)
head(train_test,3)

# Converting classLabels to activityName using factor
train_test[["Activity"]] <- factor(train_test[, Activity], levels = activity[["class"]], labels = activity[["activity"]])

train_test[["Subject"]] <- as.factor(train_test[, Subject])

## melt and dcast the dataset with desired columns and their mean
train_test<- reshape2::melt(train_test, id = c("Subject", "Activity"))
train_test<- reshape2:: dcast(train_test, Subject + Activity ~ variable, fun.aggregate = mean)
head(train_test,2)

## creating the tidydata

write.table(train_test, "tidydata.txt",row.names= FALSE)

