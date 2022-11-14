# Kinematic Data Analysis (KDA)

## Authors

Elise Carter - elise.carter@cuanschutz.edu

## Overview

Performs kinematic data analysis of mouse reach events
with CLARA generated data. Paths to Curator
and Matlab_3D folders are required. 

## Required Toolboxes

interparc by John D'Errico: https://www.mathworks.com/matlabcentral/fileexchange/34874-interparc

arclength by John D'Errico: https://www.mathworks.com/matlabcentral/fileexchange/34871-arclength

## General Workflow

Note: At any time, the session may be saved using the File menu. This creates a file within the kdaFiles folder in the output directory with the following naming convention: mouseID_status.kda

1) Load raw data using the File menu. 

2) Extract kinematic features using the Analysis menu.

3) Compute correlation coefficients using the Analysis menu.

4) Export session means to an excel file using the Export menu.