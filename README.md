# tidy-data-week4
getting and cleaning data assignment week4

#1. Getting the working directory and creating a new directory named "Working data"

#2. Download the dataset and unzip
fileURL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL,destfile = "./Working data/Dataset.zip")
unzip("./Working data/Dataset.zip")

#3. load activity and features files and named the variables

activity<-read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("class","activity"))
features<-read.table("UCI HAR Dataset/features.txt",col.names = c("index","feature"))

#4. Extracts only the measurements on the mean and standard deviation for each measurement.
msfeature <- grep("(mean|std)\\(\\)", features[, "feature"])
mstd_features <- features[msfeature, "feature"]
*replacing the "[()]" using gsub function
mstd_features <- gsub('[()]', '', mstd_features)

#5.load train and Uses descriptive activity names to name the activities in the data set
X_train <- fread("UCI HAR Dataset/train/X_train.txt")[, msfeature, with = FALSE]
data.table::setnames(X_train, colnames(X_train), mstd_features)
Y_train <- fread("UCI HAR Dataset/train/Y_train.txt", col.names = c("Activity"))
subjects_train <- fread("UCI HAR Dataset/train/subject_train.txt", col.names = c("Subject"))

#6. merge all the train data
train <- cbind(subjects_train, Y_train, X_train)

#7. Load test data files and Uses descriptive activity names to name the activities in the data set
X_test <- fread("UCI HAR Dataset/test/X_test.txt")[, msfeature, with = FALSE]
data.table::setnames(X_test, colnames(X_test), mstd_features)
Y_test <- fread("UCI HAR Dataset/test/Y_test.txt", col.names = c("Activity"))
subjects_test <- fread("UCI HAR Dataset/test/subject_test.txt", col.names = c("Subject"))

#8. merge all the test data
test <- cbind(subjects_test, Y_test, X_test)

#9.Merges the training and the test sets to create one data set.
train_test <- rbind(train, test)

#10.Appropriately labels the data set with descriptive variable names

train_test[["Activity"]] <- factor(train_test[, Activity], levels = activity[["class"]], labels = activity[["activity"]])
train_test[["Subject"]] <- as.factor(train_test[, Subject])

#11.creates a second, independent tidy data set with the average of each variable for each activity and each subject.
train_test<- reshape2::melt(train_test, id = c("Subject", "Activity"))
train_test<- reshape2:: dcast(train_test, Subject + Activity ~ variable, fun.aggregate = mean)

#12. writing the tidydata as txt.file
write.table(train_test, "tidydata.txt",row.names= FALSE)
