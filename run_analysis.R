
# run_analysis.R

# Load necessary libraries
library(dplyr)

# Set file paths
features_file <- "UCI HAR Dataset/features.txt"
activity_labels_file <- "UCI HAR Dataset/activity_labels.txt"
x_train_file <- "UCI HAR Dataset/train/X_train.txt"
y_train_file <- "UCI HAR Dataset/train/y_train.txt"
subject_train_file <- "UCI HAR Dataset/train/subject_train.txt"
x_test_file <- "UCI HAR Dataset/test/X_test.txt"
y_test_file <- "UCI HAR Dataset/test/y_test.txt"
subject_test_file <- "UCI HAR Dataset/test/subject_test.txt"

# Load the data
features <- read.table(features_file)
activity_labels <- read.table(activity_labels_file, col.names = c("ActivityID", "Activity"))

x_train <- read.table(x_train_file)
y_train <- read.table(y_train_file, col.names = "ActivityID")
subject_train <- read.table(subject_train_file, col.names = "Subject")

x_test <- read.table(x_test_file)
y_test <- read.table(y_test_file, col.names = "ActivityID")
subject_test <- read.table(subject_test_file, col.names = "Subject")

# Merge the training and test datasets
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

# Assign feature names to columns in the x_data
colnames(x_data) <- features$V2

# Extract only the measurements on the mean and standard deviation for each measurement
selected_features <- grep("-(mean|std)\\(\\)", features$V2)
x_data <- x_data[, selected_features]

# Merge all data into one dataset
all_data <- cbind(subject_data, y_data, x_data)

# Use descriptive activity names
all_data <- merge(all_data, activity_labels, by = "ActivityID")

# Appropriately label the dataset with descriptive variable names
names(all_data) <- gsub("^t", "Time", names(all_data))
names(all_data) <- gsub("^f", "Frequency", names(all_data))
names(all_data) <- gsub("Acc", "Accelerometer", names(all_data))
names(all_data) <- gsub("Gyro", "Gyroscope", names(all_data))
names(all_data) <- gsub("Mag", "Magnitude", names(all_data))
names(all_data) <- gsub("BodyBody", "Body", names(all_data))

# Create a second independent tidy dataset with the average of each variable for each activity and each subject
tidy_data <- all_data %>%
  group_by(Subject, Activity) %>%
  summarise_all(mean)

# Write the tidy data to a file
write.table(tidy_data, "tidy_data.txt", row.names = FALSE)
