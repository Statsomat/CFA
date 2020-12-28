# Define server logic 
shinyServer(function(input, output, session) {
  
  # Reload app if disconnected
  observeEvent(input$disconnect, {
    session$close()
  })
  
  # Reload app button
  observeEvent(input$reload,session$reload())
  
  session_id <- reactive({
    url_params <- parseQueryString(session$clientData$url_search)
    url_params[["session_id"]]
  })
  
  
  # Upload data
  datainput <- reactive({ 
    
    ###############
    # Validations
    ###############
    
    validate(need(input$file$datapath != "", "Please upload a CSV file."))
    
    validate(need(tools::file_ext(input$file$datapath) == "csv", "Error. Not a CSV file. Please upload a CSV file."))
    
    
    if (input$fencoding == "unknown"){
      
      validate(need(try(datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "unknown", 
                                            data.table = FALSE, na.strings = "")),
                    "Error. File cannot be read. Please check that the file is not empty, fully whitespace, or skip has been set after the last non-whitespace."))
      
      validate(need(tryCatch(datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "unknown", 
                                           data.table = FALSE, na.strings = ""), warning=function(w) {}),
                    "Error. The file cannot be read unambigously. Check the characters for the field separator, quote or decimal."
                    ))

      validate(need(try(iconv(colnames(datainput1), guess_encoding(input$file$datapath)[[1]][1], "UTF-8")),
                        "Error. Encoding cannot be converted. Please try other upload options."))
      
               
      validate(need(try(sapply(datainput1[, sapply(datainput1, is.character)], function(col) iconv(col, guess_encoding(input$file$datapath)[[1]][1], "UTF-8"))),
                        "Error. Encoding cannot be converted. Please try other upload options."))
      
    }
    
   if (input$fencoding == "UTF-8"){
      
      validate(
       need(guess_encoding(input$file$datapath)[[1]][1] %in% c("UTF-8","ASCII") & 
               guess_encoding(input$file$datapath)[[2]][1] > 0.9,
             "Error. The file is probably not UTF-8 encoded. Please convert to UTF-8 or try the automatic encoding option.")
      )
     
      validate(need(try(datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "UTF-8", 
                                  data.table = FALSE, na.strings = "")), "Error. File cannot be read. Please check that the file is not empty, fully whitespace, or skip has been set after the last non-whitespace."))
      
      
      validate(need(tryCatch(datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "unknown", 
                                                 data.table = FALSE, na.strings = ""), warning=function(w) {}),
                    "Error. The file cannot be read unambigously. Check the characters for the field separator, quote or decimal."
      ))

   }
    
   

   if (is.null(input$file))
      return(NULL)
    
    
    ###############
    # Datainput code
    ################
    
    return(tryCatch(
      
      
      if (input$fencoding == "UTF-8" & input$decimal == "auto"){ 
        
        datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "UTF-8", data.table = FALSE, na.strings = "")
        
        # Probably comma as decimal
        colnames <- sapply(datainput1, function(col) is.numeric(col) & Negate(is.integer)(col))
        if (sum(colnames) == 0L){
          
          datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=",", encoding = "UTF-8", data.table = FALSE, na.strings = "")
          datainput1
          
        } else {datainput1}
        
      } else if (input$fencoding == "UTF-8" & input$decimal != "auto") {
        
        datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=input$decimal, encoding = "UTF-8", data.table = FALSE, na.strings = "")
        datainput1
        
        
      } else if (input$fencoding == "unknown" &  input$decimal == "auto"){
        
        enc_guessed <- guess_encoding(input$file$datapath)
        enc_guessed_first <- enc_guessed[[1]][1]
        datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=".", encoding = "unknown", data.table = FALSE, na.strings = "")
        
        # Probably comma as decimal
        colnames <- sapply(datainput1, function(col) is.numeric(col) & Negate(is.integer)(col))
        if (sum(colnames) == 0L){
          
          datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec=",", encoding = "unknown", data.table = FALSE, na.strings = "")
          colnames(datainput1) <- iconv(colnames(datainput1), enc_guessed_first, "UTF-8")
          col_names <- sapply(datainput1, is.character)
          datainput1[ ,col_names] <- sapply(datainput1[, col_names], function(col) iconv(col, enc_guessed_first, "UTF-8"))
          datainput1
          
        } else {
          
          colnames(datainput1) <- iconv(colnames(datainput1), enc_guessed_first, "UTF-8")
          col_names <- sapply(datainput1 , is.character)
          datainput1[ ,col_names] <- sapply(datainput1[, col_names], function(col) iconv(col, enc_guessed_first, "UTF-8"))
          datainput1}
        
      } else {
        
        enc_guessed <- guess_encoding(input$file$datapath)
        enc_guessed_first <- enc_guessed[[1]][1]
        datainput1 <- fread(input$file$datapath, header = "auto", sep="auto", dec = input$decimal, encoding = "unknown", data.table = FALSE, na.strings = "")
        colnames(datainput1) <- iconv(colnames(datainput1), enc_guessed_first, "UTF-8")
        col_names <- sapply(datainput1, is.character)
        datainput1[ ,col_names] <- sapply(datainput1[, col_names], function(col) iconv(col, enc_guessed_first, "UTF-8"))
        datainput1
        
      }
      
      ,error=function(e) stop(safeError(e))
      
    ))
    
    
  })
  
  
  # Select Variables
  output$selection1 <- renderUI({
    
    req(datainput())
    
    chooserInput("selection1", "Available", "Selected",
                 colnames(datainput()), c(), size = 15, multiple = TRUE)
    
  })
  
  
  # Stop if column names not distinct
  observe({
    
    req(input$file, datainput(), input$selection1$right)
    
    if (length(unique(input$selection1$left)) != length(input$selection1$left)){
      
      showNotification("Error in selection: The columns names of the dataset are not distinct. Please rename columns and restart the app.", duration=20)
      input$selection1$right <- NULL
      
    }
    
  })
  

  # This creates a short-term storage location for a filepath 
  report <- reactiveValues(filepath = NULL) 
  
  # Render report
  observeEvent(input$generate, {
    
    req(input$file, datainput(), input$selection1$right)
  
    src0 <- normalizePath('report_kernel.Rmd') 
    src1 <- normalizePath('report.Rmd')
    src2 <- normalizePath('Logo.jpg')
    src3 <- normalizePath('logo.Rmd')
    src4 <- normalizePath('references.bib')
    src5 <- normalizePath('report_code_unknown.Rmd') 
    src6 <- normalizePath('report_code_common.Rmd') 
    src7 <- normalizePath('report_code_UTF8.Rmd')
    src8 <- normalizePath('FiraSans-Bold.otf')
    src9 <- normalizePath('FiraSans-Regular.otf')
   # src10 <- normalizePath('word_template.docx')
   # src11 <- normalizePath('report_kernel_word.Rmd')
   # src12 <- normalizePath('report_word.Rmd')
    
    # Temporarily switch to the temp dir
    owd <- setwd(tempdir())
    on.exit(setwd(owd))
    file.copy(src0, 'report_kernel.Rmd', overwrite = TRUE)
    file.copy(src1, 'report.Rmd', overwrite = TRUE)
    file.copy(src2, 'Logo.jpg', overwrite = TRUE)
    file.copy(src3, 'logo.Rmd', overwrite = TRUE)
    file.copy(src4, 'references.bib', overwrite = TRUE)
    file.copy(src5, 'report_code_unknown.Rmd', overwrite = TRUE)
    file.copy(src6, 'report_code_common.Rmd', overwrite = TRUE)
    file.copy(src7, 'report_code_UTF8.Rmd', overwrite = TRUE)
    file.copy(src8, 'FiraSans-Bold.otf', overwrite = TRUE)
    file.copy(src9, 'FiraSans-Regular.otf', overwrite = TRUE)
   # file.copy(src10, 'word_template.docx', overwrite = TRUE)
   # file.copy(src11, 'report_kernel_word.Rmd', overwrite = TRUE)
   # file.copy(src12, 'report_word.Rmd', overwrite = TRUE)
    
    # Set up parameters to pass to Rmd document
    enc_guessed <- guess_encoding(input$file$datapath)
    enc_guessed_first <- enc_guessed[[1]][1]
    
    if (is.null(input$textprediction)){
      params <- list(data = datainput(), filename=input$file, fencoding=input$fencoding, decimal=input$decimal, enc_guessed = enc_guessed_first, 
                   vars1 = input$selection1$right, model = input$text, direction = NA)
    } else {
      params <- list(data = datainput(), filename=input$file, fencoding=input$fencoding, decimal=input$decimal, enc_guessed = enc_guessed_first, 
                     vars1 = input$selection1$right, model = input$text, direction = input$textprediction)
    }
    
    
    tryCatch({
      
      withProgress(message = 'Please wait, the Statsomat app is computing. This may take a while.', value=0, {
        
        for (i in 1:15) {
          incProgress(1/15)
          Sys.sleep(0.25)
          
        }
      
        if (input$rcode == "No"){
          
          tmp_file <- render('report.Rmd', pdf_document(latex_engine = "xelatex"),
                        params = params,
                        envir = new.env(parent = globalenv())
          )
          
        } else {
          
          if (input$fencoding == "UTF-8"){
            
            tmp_file <- render('report_code_UTF8.Rmd', pdf_document(latex_engine = "xelatex"),
                          params = params,
                          envir = new.env(parent = globalenv())
                          
            )} else {tmp_file <- render('report_code_unknown.Rmd', pdf_document(latex_engine = "xelatex"),
                                   params = params,
                                   envir = new.env(parent = globalenv())
            )}
          
        }
    
        report$filepath <- tmp_file 
    
      })
      
      showNotification("Now you can download the report.",duration=10)
      
    },
    
    error=function(e) {
      # Report not available 
      showNotification("Something went wrong. In most cases, this is due to severe problems with your data and/or model syntax. 
                       Please try again. ",duration=20)
      }
    )
    
  })
  
  
  # Enable downloadbutton 
  observe({
    req(!is.null(report$filepath))
    session$sendCustomMessage("check_generation", list(check_generation  = 1))
  })
  

  # Download report  
  output$download <- downloadHandler(
    
    filename = function() {
      paste('MyReport',sep = '.','pdf')
    },
    
    content = function(file) {

      file.copy(report$filepath, file)
         
    }
  )
  
  
})