
# Introduction
The Statsomat/CFA app is a web-based
application for automated Confirmatory Factor Analysis (CFA) based mainly on the R package `lavaan` and created with the Shiny
technology. The Statsomat/CFA app is hosted on [shinyapps.io](https://www.shinyapps.io/) and 
is one of several apps which can be accessed via the webpage of *Statsomat* (see https://statsomat.com), a nonprofit company with the aim of developing, 
collecting and maintaining open-source apps for automated data analysis, interpretation and explanation. You can also access the app directly here https://statsomat.shinyapps.io/Confirmatory-factor-analysis/. 


# Installation 
There is no need to install the Statsomat/CFA app since it runs in the browser. If you really want to run it locally, you can install it from this repository by following these steps:

Install the R package `devtools`

Install the app 
```
devtools::install_github("statsomat/cfa")
```

Run the app from the app folder
```
shiny::runApp()
```

Before running the app locally, please consider to install required packages (check them in `global.R` and `report_kernel.Rmd`). A list of complete dependencies can be found in `dependencies.txt`. 


# Example Usage
You can find testing cases (datasets as CSV files and corresponding CFA models in lavaan model syntax) in the testing repository of the app https://github.com/Statsomat/CFA-Testing. Follow the *Instructions* described directly on the webpage of the app https://statsomat.shinyapps.io/Confirmatory-factor-analysis/. 


# Functionality
The user uploads its data as a CSV file, types the CFA model in `lavaan` model syntax directly in 
the browser and generates a PDF report. The report contains a data-driven interpretation and explanation of the 
CFA in plain English. The R code for the generation of the tables and graphics is included in the report and 
enables locally reproducibles results. The current version supports only approximately continuous data. Other restrictions to the data may apply. 


# Tests 
The app was calibrated and tested by using the HolzingerSwineford1939 dataset contained in the R package `lavaan`
and (simulated) data cases from literature. The repository https://github.com/Statsomat/CFA-Testing contains the test data cases and results for this version.   



# Community 
1) Contribute to the software:
You are welcome to improve and extend the functionality of the app. If you want to make a pull request, please check that you can run test cases locally without any errors or warnings. Please consider to test your changes also on [shinyapps.io] (ignore the non-fatal errors mentioned also above). 

2) Report issues or problems with the software:
Please open an issue in this repository to report any bugs. 

3) Seek support:
We try to answer all questions in reasonable time  but general support is limited. 
