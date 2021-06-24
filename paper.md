---
title: 'Statsomat/CFA: A Shiny app for automated confirmatory factor analysis'
tags:
  - R
  - Shiny
  - CFA
  - automated 
  - interpretation 
  - explanation 
  - Statsomat  
authors:
  - name: Denise Welsch^[Corresponding author, [denise.welsch@reyar.de](denise.welsch@reyar.de)]
    orcid: 0000-0001-8904-1631
    affiliation: "1, 2"
  - name: Berit Hunsdieck
    affiliation: 3	
affiliations:
 - name: Rey Analytical Research (Independent), Germany
   index: 1
 - name: Statsomat, Germany  
   index: 2
 - name: Technische Universität Dortmund, Germany  
   index: 3
date: 23 April 2021
bibliography: paper.bib

---

# Summary

Confirmatory factor analysis (CFA) is a statistical analysis technique which is 
typically used by applied social sciences researchers (e.g. psychologists, sociologists). 
In a CFA, the researcher specifies a theoretically derived model which is either rejected 
or accepted based on its correspondence to the data [@kline]. The Statsomat/CFA app is a web-based
application for automated CFA based mainly on the R package lavaan [@lavaan] and created with the Shiny
technology [@shiny]. The user uploads its data as a CSV file, types the model directly in 
the browser and generates a PDF report. The report contains a data-driven interpretation and explanation of the 
CFA in plain English. The R code for the generation of the tables and graphics is included in the report and 
enables locally reproducibles results. The current version supports only approximately continuous data. Other restrictions to the data may apply. 
The app was calibrated and tested by using the HolzingerSwineford1939 dataset contained in the R package lavaan [@lavaan] 
and (simulated) data cases from the books @brown and @kline.  
The Statsomat/CFA app is hosted on [shinyapps.io](https://www.shinyapps.io/) and 
is one of several apps which can be accessed via the webpage of Statsomat \autoref{fig:statsomat} (see https://statsomat.com), 
a nonprofit company with the aim of developing, collecting and maintaining open-source apps for automated data analysis,
interpretation and explanation. 

![Statsomat Logo\label{fig:statsomat}](Statsomat.png)

# Statement of need

Applied researchers with intermediate to advanced statistical and R programming knowledge can 
perform a CFA by using for example functions from the R package lavaan [@lavaan] and [RStudio](https://www.rstudio.com/)
as the IDE. On top of that, they need to interpret and explain an extensive numerical and graphical output to finally 
decide for the acceptance or rejection of an assumed model. Finally they need to explain and write down the decision. 
In comparison, applied researchers unfamiliar with the aforementioned topics, could use the Statsomat/CFA app directly in the browser to generate
results that are similar to a human-based analysis. To the best of our knowledge, there are no other web-based applications enabling automated CFA interpretation. 
The graphical user interface of Statsomat/CFA offers a sufficient but minimal user-interaction with the aim of a maximal automation. 
For (continuous) data cases, the app will enable a quick, reproducible, understandable and 
explainable application of the CFA method. This will moreover facilitate a positive learning experience 
towards both R programming and statistical CFA theory. 


# References

