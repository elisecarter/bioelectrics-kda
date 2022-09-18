# Kinematic Data Analysis (KDA)

## Authors and Contact Info

Elise Carter - elise.carter@cuanschutz.edu

Spencer Bowles

## Overview

Performs kinematic data analysis of mouse reach events with data obtained from the CLARA. Locations of Curator and Matlab_3D folders are required. 

## Required Toolboxes

interparc by John D'Errico: https://www.mathworks.com/matlabcentral/fileexchange/34874-interparc

arclength by John D'Errico: https://www.mathworks.com/matlabcentral/fileexchange/34871-arclength

## General Workflow

### File Menu

#### Load Raw Data

User chooses from a list of mice from the selected curators folder to load (can use multiselect). If there is data in the workplace, the user chooses to start a new session or add to the current session. **Note** that if a curator file is open, the program will not be able to access the file and will skip that mouse.

#### Load Saved Session File

Load saved .kda files - these can be raw or processed data files. 

#### Save Session

The current workspace is saved in a user specifified output folder.

### Analysis Menu

#### Extract Kinematics

Reach events are located using start, max, and end frames from session curator files.

## Variable Info

Each mouse will have the following data in the resulting output structure:



|Feature         |Units           | Description    |
|:---------------|:---------------|:---------------|
|StartIndex      |frames          |frame that initialtion of the reach occurs|
|EndIndex        |frames          |frame that reach max or end occurs|
|ReachDuration   |seconds         |time from reach start to reach max/end|
|HandPosition    |mm              |euclidean matrix of hand position relative to pellet| 
|RawVelocity     |mm/sec          |
|Stim Logical    |unitless        |logical array to indicate if a reach resulted in a stimulus|
|ExpertReach     |frames          |Average of succussful reaches on final day of training|


