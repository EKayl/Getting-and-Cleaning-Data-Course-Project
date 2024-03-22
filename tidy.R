if (!require(dplyr)) install.packages("dplyr")
library(dplyr)
# Set the data directory
dataDir <- "UCI HAR Dataset"

# Read the datasets
subject_train <- read.table(file.path(dataDir, "train", "subject_train.txt"))
subject_test <- read.table(file.path(dataDir, "test", "subject_test.txt"))
y_train <- read.table(file.path(dataDir, "train", "y_train.txt"))
y_test <- read.table(file.path(dataDir, "test", "y_test.txt"))
X_train <- read.table(file.path(dataDir, "train", "X_train.txt"))
X_test <- read.table(file.path(dataDir, "test", "X_test.txt"))

# Merge the training and test sets
subject <- rbind(subject_train, subject_test)
activity <- rbind(y_train, y_test)
features <- rbind(X_train, X_test)

# Combine into one dataset
data <- cbind(subject, activity, features)
featuresNames <- read.table(file.path(dataDir, "features.txt"))
meanStdIndices <- grep("-(mean|std)\\(\\)", featuresNames$V2)
data <- data[, c(1, 2, meanStdIndices+2)]
activityLabels <- read.table(file.path(dataDir, "activity_labels.txt"))
data$V2 <- factor(data$V2, levels = activityLabels$V1, labels = activityLabels$V2)
names(data)[1] <- "Subject"
names(data)[2] <- "Activity"
featuresNamesSubset <- featuresNames$V2[meanStdIndices]
names(data)[3:length(data)] <- featuresNamesSubset

# Clean and apply more descriptive names
names(data) <- gsub("^t", "Time", names(data))
names(data) <- gsub("^f", "Frequency", names(data))
names(data) <- gsub("Acc", "Accelerometer", names(data))
names(data) <- gsub("Gyro", "Gyroscope", names(data))
names(data) <- gsub("Mag", "Magnitude", names(data))
names(data) <- gsub("BodyBody", "Body", names(data))
tidyData <- data %>%
  group_by(Subject, Activity) %>%
  summarise_all(mean)

# Write the tidy dataset to a file
write.table(tidyData, file = "tidyData.txt", row.names = FALSE)
