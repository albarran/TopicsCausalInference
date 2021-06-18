---
title: "Causal Trees"
output: html_document
---

The data is from Gerber, Green, and Larimer (2008): ["Social Pressure and Voter Turnout: Evidence from a Large-Scale Field Experiment"](http://isps.yale.edu/sites/default/files/publication/2012/12/ISPS08-001.pdf).



A large sample of voters were _randomly assigned_ to two groups: 

- Treatment group D=1 that received a message stating that, after the election, the recent voting record of everyone on their households would be sent to their neighbors.
- Control group D=0 that did not receive any message.

This study seeks evidence for a "social pressure" effect on voters turnout.



Outcome, treatment and attributes


- __`outcome_voted`__: Dummy where 1 indicates voted in the August 2006
- __`treat_neighbors`__: Dummy where 1 indicates _Neighbors mailing_ treatment
- `sex`: male / female
- `yob`: Year of birth
- `g2000`: voted in the 2000 general
- `g2002`: voted in the 2002 general
- `p2000`: voted in the 2000 primary
- `p2002`: voted in the 2002 primary
- `p2004`: voted in the 2004 primary
- `city`: City index
- `hh_size`: Household size
- `totalpopulation_estimate`: City population
- `percent_male`: percentage of males in household

- `median_age`: Median age in household
- `median_income`: Median income in household
- `percent_62yearsandover`: percent. of subjects of age higher than 62 yo
- `percent_white`: percent. white in household
- `percent_black`: percent. black in household
- `percent_asian`: percent. Asian in household
- `percent_hispanicorlatino`: percent. Hispanic or Latino in household
- `employ_20to64`: percent. of employed subjects of age 20 to 64 yo 
- `highschool`: percent. having only high school degree
- `bach_orhigher`: percent. having bachelor degree or higher



* [R code](https://github.com/albarran/TopicsCausalInference/blob/main/code/CT.R)