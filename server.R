
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
require(xlsx)
require(ggplot2)
require(markovchain)
require(reshape2)

data<-read.xlsx("import.xlsx", sheetIndex=1, as.data.frame = TRUE, header=TRUE)

ir<-data
ir_diff<-data
ir_diff<-ir_diff[-417,]
ir_diff[,2]<-data[1:416,2]-data[2:417,2]


mcFit<-markovchainFit(data=ir_diff[,2])
transition<-mcFit$estimate
transMatrix<-round(mcFit$estimate@transitionMatrix,digits=6)


findSucc<-function(data=transMatrix,from="0"){ 
  #find starting row
  from<-as.character(from)
  colIndices<-which(!data[from,]==0)
  myCumsum <- cumsum(data[from,colIndices])
  u<-runif(1) #draw a random number
  
  if(u>=max(myCumsum)){return(colnames(data)[max(colIndices)])}
  
  else{i<-which.max(myCumsum>u)
  return(colnames(data)[colIndices[i]])
  }
}


forecastMC<-function(currState="0", years=10){
  if(!is.character(currState)){currState<-as.character(currState)}
  
  period<-years*4
  #fcast<-(NaN, start=c(2016,3), frequency=4)
  fcast<-(length=period)
  fcast[1]<-findSucc(data=transMatrix, from=currState)
  for (i in 2:period){
    fcast[i]<-findSucc(data=transMatrix, from=fcast[i-1])}
  #return(ts(fcast, start=c(2016), frequency=4))
  return(fcast)
}


fcastIR<-function(series=ir, years=10){
  #Rate<-fcastIR(years=years)
  Rate<-cumsum(forecastMC(years=years))
  Rate[1]<-c(0.5)
  RateRep<-rep(Rate, each=3)
  Rate<-replace(RateRep, RateRep<(-0.05), 0)
  Date<-seq(from=Sys.Date(), by='month', length.out=years*12)
  dfFcast<-data.frame(Date,Rate)
  return(dfFcast)
}


mortgage<-function(price=10000,deposit=2000, firstTimer=TRUE, years=10, existCustomer=FALSE)
{
  months<-12*years
  LtV<-(price-deposit)/price
  temp<-fcastIR(series=ir,years=years)+LtV*1.5+ifelse(LtV>0.9,2,0)+ifelse(firstTimer,0.5,0)+ifelse(existCustomer,-0.1,0)
  start_balance<-c(price-deposit)
  
  temp$year_rate<-temp$Rate/12/100  
  temp$month<-seq(from=0, by=1, to=months-1)
  #calculate first values
  temp$payment<-start_balance*temp$year_rate*(1+temp$year_rate)^(months-temp$month)/((1+temp$year_rate)^(months-temp$month)-1)
  
  temp$interest<-start_balance*temp$year_rate  
  temp$principal_paid<-temp$payment-temp$interest
  temp$balance<-start_balance-temp$principal_paid
  
  #finish calculation of the balance and payments
  for(i in 2:months){
    temp$payment[i]<-temp$balance[i-1]*temp$year_rate[i]*(1+temp$year_rate[i])^(months-temp$month[i])/((1+temp$year_rate[i])^(months-temp$month[i])-1)
    temp$interest[i]<-temp$balance[i-1]*temp$year_rate[i]  
    temp$principal_paid[i]<-temp$payment[i]-temp$interest[i]
    temp$balance[i]<-temp$balance[i-1]-temp$principal_paid[i]
  }
  # round the values
  temp$balance<-round(temp$balance, digits = 2)
  temp$interest<-round(temp$interest, digits = 4)
  temp$payment<-round(temp$payment, digits = 2)
  temp$principal_paid<-round(temp$principal_paid, digits = 2)
  
  return(temp)
}

descriptive<-function(mortgage=temp){
  Tot_payment<-sum(mortgage$payment)
  Tot_interest<-sum(mortgage$interest)
  Mon_average<-mean(mortgage$payment)
    out<-data.frame(Tot_payment,Tot_interest,Mon_average)
  return(out)
}


###########################################################


shinyServer(function(input, output) {
  
  
  giveMeMortgage<-reactive({
    validate(need(input$deposit<input$price, "Deposit has to be lower than the value of the property. Please, submit correct values."))
    
    mortgage(price=input$price, deposit=input$deposit, years=input$years, firstTimer=input$firstTimer,existCustomer=input$existCustomer)
    })
  
  
  output$payments  <- renderPrint({
    themortgage<-giveMeMortgage()
    cat("Your average payment will be: £")
    cat(round(mean(themortgage$payment),2))
    cat(" per month.")
    cat("\n")
    cat("\nAt the end of the loan you will have payed a total of £")
    cat(round(sum(themortgage$payment),2))
    cat("\nAltogether you will have paid £")
    cat(round(sum(themortgage$interest),2))
    cat(" in interest payments,\nwith the monthly average interest of ")
    cat(round(mean(themortgage$Rate),2))
    cat(" percent per year. \n\nPlease, do read the Additional information tab to understand the results.")
    
     })
  
  output$balance<-renderPlot({
 #   themortgage<-mortgage(price=input$price, deposit=input$deposit, years=input$years, firstTimer=input$firstTimer,existCustomer=input$existCustomer)
    themortgage<-giveMeMortgage()
    
    qplot(themortgage$Date,themortgage$balance, main = "Repayment of a loan", ylab="Balance outstanding", xlab="Date")
    })
  
  
  output$IR<-renderPlot({
    themortgage<-giveMeMortgage()
    
  qplot(themortgage$Date, themortgage$Rate, main="Interest rate per month", ylab="Rate[%]", xlab="Date")  
  })
  output$rates<-renderPlot({
    
  #  themortgage<-mortgage(price=input$price, deposit=input$deposit, years=input$years, firstTimer=input$firstTimer,existCustomer=input$existCustomer)
    themortgage<-giveMeMortgage()
    
    tomelt<-data.frame(themortgage$Date,themortgage$payment,themortgage$principal_paid,themortgage$interest)
    test_melt<-melt(tomelt, id.vars = 'themortgage.Date')
    
    p<-ggplot(test_melt, aes(themortgage.Date, value, group=variable, colour=variable)) +geom_line()
    p+labs(title="Example of mortgage repayment", x="Date", y="£", colour="Legend")

     })
  

})
