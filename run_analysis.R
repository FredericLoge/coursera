rm(list=ls())
library(stringr)

# Queston 1 : merging the datasets

  # Method used to merge data for training/testing data
  mergingData = function(trainOrTest="train", dataPath){
    
    
    # data - measurements
    
    fileNames = list.files(paste0(dataPath, "/", trainOrTest, "/Inertial Signals"), full.names = FALSE)
    fullFileNames = list.files(paste0(dataPath, "/", trainOrTest, "/Inertial Signals"), full.names = TRUE)
    
    measures = read.table(fullFileNames[1])
    measures = cbind(rowMeans(measures), apply(measures, 1, sd))
    for(file in fullFileNames[-1]){
      temp =  read.table(file)
      temp = cbind(rowMeans(temp), apply(temp, 1, sd))
      measures = cbind(measures, temp)  
    }
    
    measures = as.data.frame(measures)
    columnNames = c(paste0(fileNames, "_mean"), paste0(fileNames, "_std"))
    columnNames = str_replace(columnNames, paste0("_",trainOrTest,".txt"), "")
    colnames(measures) = sort(columnNames)
    
    # data - features
    
    x = read.table(paste0(dataPath, "/",trainOrTest,"/X_",trainOrTest,".txt"))
    x = as.data.frame(x)
  
    features = read.table(paste0(dataPath, "/features.txt"))
    features = array(features[,2])
    colnames(x) = features
                            
    # data - activity id
    
    y = read.table(paste0(dataPath, "/",trainOrTest,"/y_",trainOrTest,".txt"))
    colnames(y) = "activityID"
    activities = read.table(paste0(dataPath, "/activity_labels.txt"))
    colnames(activities) = c("activityID", "activityLabel")
    activities = merge(y, activities, by="activityID")
    
    # data - subject id
  
    subject = read.table(paste0(dataPath, "/",trainOrTest,"/subject_",trainOrTest,".txt"))
    
    # merging data
    
    mergedData = cbind.data.frame(subject, activities, measures, x)
    colnames(mergedData)[1] = "subjectID"
    
    return (mergedData)
  
  }

  # We get the training data
  trainingData = mergingData("train", "D:/JHDataset")
  trainingData$test = FALSE
  dim(trainingData)
  
  # We get the testing data
  testingData = mergingData("test", "D:/JHDataset")
  testingData$test = TRUE
  dim(testingData)

  # We check if we have the same columns
  all(names(testingData) == names(trainingData))

  # Merged data for training & testing data
  mergedData = rbind(trainingData, testingData)
  names(mergedData)


# Qestion 2 : Extraction only of means and standard deviations

  columnNamesExpr = ".mean$|.mean\\(\\)|.std$|.std\\(\\)|^subjectID$|^activityID$|^activityLabel$|^test$"
  meanAndStdData = mergedData[, grepl(columnNamesExpr, colnames(mergedData))]
  dim(meanAndStdData)


# Question 3 : already done


# Question 4 : Change the variable names to make them more understandable

  colnames(meanAndStdData)
  modifications = matrix(nrow=14, ncol=2)
  modifications[1, ] = c("Acc|acc", "Acceleration")
  modifications[2, ] = c("-mean\\(\\)|_mean", "-Mean")
  modifications[3, ] = c("-std\\(\\)|_std", "-StandardDeviation")
  modifications[4, ] = c("body_", "Body")
  modifications[5, ] = c("total_", "Total")
  modifications[6, ] = c("_x", "-X")
  modifications[7, ] = c("_y", "-Y")
  modifications[8, ] = c("_z", "-Z")
  modifications[9, ] = c("Mag", "Magnitude")
  modifications[10,] = c("Gyro|gyro", "Gyroscope")
  modifications[11,] = c("test", "Test")
  modifications[12,] = c("^t", "Time-")
  modifications[13,] = c("^f", "FourierTransformedSignal-")
  modifications[14,] = c("BodyBody", "Body")
  
  for(i in 1:nrow(modifications)){
    colnames(meanAndStdData) = str_replace(colnames(meanAndStdData), modifications[i, 1], modifications[i, 2])  
  }


# Question 5 : Tidy data set

  tidyData = meanAndStdData
  colnames(tidyData)
  tidyDataAgg = aggregate(tidyData[,!colnames(tidyData) %in% c("Test", "activityLabel", "subjectID", "activityID")], 
                          by=list(tidyData$subjectID, tidyData$activityID, tidyData$activityLabel), FUN=mean, na.rm=TRUE)
  colnames(tidyDataAgg)[1:3] = c("SubjectID", "ActivityID", "ActivityLabel")
  View(tidyDataAgg)


# Saving the datasets in text files

  write.table(x = tidyDataAgg, file = "D:/tidyData.txt", row.names = FALSE)
  write.table(x = meanAndStdData, file = "D:/meanAndStdData.txt", row.names = FALSE)
