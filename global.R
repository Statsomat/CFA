MAX_FILE_SIZE_MB <- 5
options(shiny.maxRequestSize = MAX_FILE_SIZE_MB*1024^2)
options(shiny.sanitize.errors = TRUE)

library(shiny)
library(rmarkdown)
library(anytime)
library(mailR)
library(data.table)
library(readr)
library(shinydisconnect)

source("chooser.R")
source("helpers/Functions.R")