# Kinematic Data Analysis (KDA)

## Author

Elise Carter - elise.carter@cuanschutz.edu

## Overview

This software serves as a data pipeline with the purpose of extracting kinematic features from three-dimensional paw tracking data sets generated during behavioral experiments conducted using the closed-loop automated reaching apparatus (CLARA).  

## General workflow: create a spreadsheet with session means

For more detailed information, see the kinematics protocol in the install kit.

1)	Create a curators folder with a subfolder for each curation to process. Each curation folder should contain the excel files generated during curation for each session to analyze (same file structure as created by the Curator).

2)	Run kda.m in MATLAB making sure that bioelectrics-kda is the working directory. Keep the command window visible as important messages will be displayed there.

3) In the File menu, select Load Raw Data and select the curators folder created in step 1. This loads in the Curation and MATLAB 3D files for all the sessions contained in the curators folder and saves this raw data in the specified output directory as kda files. Alternatively, if you have already loaded the raw data in the past, you may load raw kda files using the File menu. Note: Yellow warning messages indicate that a reach was deleted due to a mistake in the curator file (details provided in displayed message).

4) In the Analysis menu, select Extract Kinematics. Click through the pop-up menus to input plotting and filtering options. Deleted reaches are shown in the command line. The extracted kinematic features defined in Appendix A are saved as kda files (hdf5 format) in the output directory.

5) In the Export menu, select Session Means. This exports session means to an excel file in the specified output directory. Select “yes” when prompted by the option to group by experimental condition to populate the “group” column in this file.
