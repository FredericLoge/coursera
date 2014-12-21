coursera
========

The main part of the R script concerns the merger of all the text files. The process is the same whether people belong to the testing or the training population :

 - we start by getting all the measurements from the "Inertial Signals" files
   for all of those files we calculate the mean and std of the variables
 - we then gather the features in the "X_test/train" file
 - we bind those together
 - we set the column names based on the "features" file
 - we identify the activity & it's name based on "Y_test/train" and the activity labels
 - we add also the subject ID & whether he belongs to the test sample or training (variable test)
