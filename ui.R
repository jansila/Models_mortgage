
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(
  headerPanel("Stochastic Mortgage Calculator"),
  
  sidebarLayout(
    
    
    sidebarPanel(
      h4("Enter mortgage details"),
      br(),
      
      checkboxInput("existCustomer", label="Existing customer"),
      helpText("Tick if you are already a company's customer"),
      br(),
      sliderInput(inputId = "years", label="Mortgage term", min = 1, max = 50, value = 20, step=1), 
      helpText("How long do you wish to be repaying the mortgage for?"),
      
      tags$hr(),
      numericInput("price", label="Value of the property [£]",min = 2000, max = 100000,value = 10000, step=500),
      numericInput("deposit", label="Your deposit [£]", min=0, max=100000, value=0, step=500),
      helpText("Enter the value of the property and the amount of your deposit"),
      tags$hr(),
      
      checkboxInput("firstTimer", label="A first time buyer?"),
      helpText("Tick if it is your first time buying/renting a property.")
    ),
    
    mainPanel(
      tabsetPanel(
        
        tabPanel("Results",
                 h4("Your payments:") ,
                 verbatimTextOutput("payments"),
                 
                 plotOutput("balance"),

                 plotOutput("IR")
        ),
        
        tabPanel("Detail of payments",
                 tags$br(),
                 HTML("This graph shows payments and their allocation each time."),
                 plotOutput("rates"),
                 HTML("<p><mark class='red'>Red</mark> is the total monthly payment.</p>
                      <p><mark class='green'>Green</mark> is the amount going towards repaying the principal (loan).</p>
                      <p><mark class='blue'>Blue</mark> represent the proportion the monthly payment to amortise the interest.</p>")
                 
                 
                 ),
        
        tabPanel("Additional information",
                 tags$h4("Welcome to the Stochastic Mortgage Calculator"),
                  tags$hr(),
                 tags$h5("Application explained"),
                 HTML("<p>This application quotes a fictional mortgage amortization plan based on an interest rate prediction with underlying <a href='https://en.wikipedia.org/wiki/Markov_chain'>Markov Chain</a> model. The interest rate is <strong>variable</strong> and is recalculated every three months (MPC of the Bank of England).</p>
                      <p>Every evaluation of the model produces a new result, as it is stochastic without any fixation. Hence, a result for the same set-up will be 'always' different. Even if the page is only reloaded</p><p> Also, the forecast variance tends to increase for longer contract periods. Hence it can produce rather high interest rates either way. For that reason, negative rates were eliminated, as they make no economical sense for a mortgage. However, there is no cap on the positive side, for the sake of this being more of a mathematical, than business exercise, and to illustrate the Markov chain model behaviour. </p><p>For a more detailed discussion, please refer to the <a href='https://github.com/jansila/Models_mortgage'> documentation</a>.
                      </p>"),
                 tags$hr(),
                 tags$h5("References"),
                 HTML("The engine uses R packages <a href='https://cran.rstudio.com/web/packages/markovchain/index.html'> markovchain</a>, graphes are produced with <a href='http://ggplot2.org'> ggplot2.</a> Powered by <a href='http://www.rstudio.com/shiny/'>Shiny</a> and hosted by <a href='http://www.rstudio.com/'>RStudio</a>. Code hosted at <a href='https://github.com/jansila/Models_mortgage'>GitHub.</a>"),
                 tags$hr(),
                 tags$h5("Disclaimer"),
                 HTML("This is implementation of a project at <a href='https://le.ac.uk'>University of Leicester</a> for module <em>MA7404 Models</em>. Project documentation with detailed description of the underlying method and functionality is available <a href='https://www.dropbox.com/s/c59yrcfybo9zmo6/project_documentation.pdf?dl=0'>here</a> and <a href='https://github.com/jansila/Models_mortgage'>here.</a> 
                      <p> Hence, this <strong>application is not</strong>, and cannot be, <strong>associated with any real financial product.</strong></p>"),
                 tags$h4("Author:"),HTML("<p><a href='https://cz.linkedin.com/in/jansila'>Jan Sila</a></p>
                                         <p> I would like to thank those who kindly supported me and enabled me to study at Leicester, namely: Ondrej Brcak, David Koubek and Vaclav Potesil.</p>")

                 
                 )
        
        
        
      )
    )
    
)
))
