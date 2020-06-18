
library(shiny)

source("chooser.R")

# Define UI for application 
shinyUI(fluidPage(
  
  tags$head(
    tags$style(HTML("
                   .shiny-notification{

                    position: fixed;
                    top: 10px;
                    left: calc(50% - 400px);;
                    width: 800px;
                    /* Make sure it draws above all Bootstrap components */
                    z-index: 2000;
                    background-color: #ff9900;
                
                   }
                
                    "))
    ),

  
  #Disable download button until check positive
  singleton(tags$head(HTML(
    '
  <script type="text/javascript">
    
    
    $(document).ready(function() {
      $("#download").attr("disabled", "true").attr("onclick", "return false;");
      Shiny.addCustomMessageHandler("check_generation", function(message) {
        $("#download").removeAttr("disabled").removeAttr("onclick").html("");
      });
    })
    
  
    
  </script>
  '
  ))),
  
  br(),
  
  tags$div(a(img(src='Logo.jpg', width=150), href="https://www.statsomat.com", target="_blank")),
  
  h1("Confirmatory Factor Analysis", 
     style = "font-family: 'Source Sans Pro';
     color: #fff; text-align: center;
     background-color: #396e9f;
     padding: 20px;
     margin-bottom: 0px;"),
  h2("Full Version", 
     style = "font-family: 'Source Sans Pro';
     color: #fff; text-align: center;
     background-color: #2fa42d;
     padding: 5px;
     margin-top: 0px;"),
  
  br(),
  
  
  fluidRow( 
              
      
      column(6, 
             
             wellPanel(style = "background: #fff;", includeHTML("www/Description.html")),
             wellPanel(style = "background: #fff;", includeHTML("www/Instructions.html"))

      ),
                 
      column(6,  
             
             
             wellPanel(style = "background: #adc7de;", 
                          
                          h3("Upload"),
                          
                          # File input
                          fileInput("file", "Choose CSV file",
                                    accept = c(
                                      "text/csv",
                                      "text/comma-separated-values",
                                      ".csv"), 
                                    buttonLabel = "Browse...",
                                    placeholder = "No file selected"),
                          
                          
                       # Input: Select encoding ----
                       radioButtons("fencoding", "Encoding",
                                    choices = c(Auto = "unknown", 
                                                "UTF-8" = "UTF-8"),
                                    selected = "unknown", inline=TRUE),
                       
                       
                       # Input: Select decimal ----
                       radioButtons("decimal", "Decimal",
                                    choices = c(Auto = "auto",
                                                Comma = ",",
                                                Dot = "."),
                                    selected = "auto", inline=TRUE),
                       
                       tags$b("By clicking the Browse button and uploading a file, you agree to the Statsomat",
                              style="color: #808080;"),
                       
                       tags$a(href="https://statsomat.com/terms", target="_blank", "Terms of Use.", style="
                              font-weight: bold;")
            ),
          
            
            wellPanel(style = "background: #adc7de;", 
                      
                      h3("Select Variables"),
                      
                      uiOutput("selection1")
                    
            ),
            
            
            wellPanel(style = "background: #adc7de;", 
                      
                      h3("Type Here Your Model"),
                      
                      h5("lavaan model syntax"),
                      
                      tags$textarea(id="text", placeholder="# latent variable definitions 
f1 =~ x1 + x2 + x3
f2 =~ x4 + x5 + x6
f3 =~ x7 + x8 + x9

# variances and covariances 
y1 ~~ y1 
y1 ~~ y2 
f1 ~~ f2
                                    
# intercepts 
y1 ~ 1 
f1 ~ 1", rows=15, cols=100)
                      
            ),
            
            
            
      )
                  
  )
  ,
  
  
  fluidRow( 
    
    
    column(12, 
           
           wellPanel(style = "background: #ff9900", align="center", 
                     
                     h3("Generate the Report"),
                     
                     radioButtons('rcode', 'Include R Code', c('Yes','No'), inline = TRUE),
                     
                     h5("Click the button to generate the report"),
                     
                     actionButton("generate", "", style="
                                    height:145px;
                                    width:84px;
                                    padding-top: 3px;
                                    color:#ff9900; 
                                    background-color: #ff9900; 
                                    border-color: #ff9900;
                                    background-image: url('Button.gif');")
                     
                     
           )
           
           )
  ),
  
  
  fluidRow( 
    
    
    column(12, 
           
           wellPanel(style = "background: #ff9900", align="center", 
                     
                     h3("Download the Report"),
                     
                     h5("Click the button to download the report"),
                     
                     downloadButton("download", "", style="
                                    height:145px;
                                    width:84px;
                                    padding-top: 3px;
                                    color:#ff9900; 
                                    background-color: #ff9900; 
                                    border-color: #ff9900;
                                    background-image: url('Button.gif');") 
                     
                     
           )
    )
  ),
  

  fluidRow( 
    
    
    column(6, 

           wellPanel(style = "background: #fff;", includeHTML("www/Secure.html")), 
           wellPanel(style = "background: #fff;", includeHTML("www/Other.html"))
          
    
    ),

    column(6, 
       
        wellPanel(style = "background: #fff;", includeHTML("www/Also.html")),
        wellPanel(style = "background: #fff;", includeHTML("www/OpenSource.html"))
       
    )

),

fluidRow( 
  
  column(12, 
         
         wellPanel(style = "background: #fff;", includeHTML("www/Contact.html"))
         
  )
  
),

  
 includeHTML("www/Footer.html"),
 
 hr()
 
))
