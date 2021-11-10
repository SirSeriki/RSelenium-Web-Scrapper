#install Packages 
install.packages("RSelenium")
install.packages('Rcpp') # R and C++ integration (It solved the issue with RsDriver not running)
install.packages('rvest')

#Install libraries 
library(RSelenium)
library(Rcpp)
library(rvest)
library(dplyr)
library(tidyr)

#Download and run selenium 

rsDriver(browser="chrome",chromever = "95.0.4638.54",version = '2.53.1') 

con <- remoteDriver(remoteServerAddr = "localhost",
                    port = 4567L,
                    browserName = "chrome",
                    version = '95.0.4638.54')

#Making connection and navigating to url page

startServer()

con$getStatus()

con$open()

con$navigate("https://www.linkedin.com/login?fromSignIn=true&trk=guest_homepage-basic_nav-header-signin")

# Loading the config.txt file

ll <- readLines("config.txt")
username <- ll[1]
password <- ll[2]

#Login to to webpage 

con$findElement(using = "id", value = "consumer_login__text_plain__no_username") 
con$sendKeysToActiveElement(list(username))    #Sending username 


#tab <- con$findElement(using = 'id', value = "username")
#tab$sendKeysToElement("\ue004")

#passSys.sleep(5)

con$findElement(using = "id", value = "password")
con$sendKeysToActiveElement(list(password))  # Sending password


click <- con$findElement(using = "css", ".from__button--floating")

click$clickElement() 


#Links 

con$navigate("https://www.linkedin.com/search/results/people/?geoUrn=%5B%22103121230%22%5D&keywords=%22%20Chief%20Revenue%20Officer%22&origin=FACETED_SEARCH&sid=*8(")

link <- "https://www.linkedin.com/search/results/people/?geoUrn=%5B%22103121230%22%5D&keywords=%22%20Chief%20Revenue%20Officer%22&origin=FACETED_SEARCH&sid=*8("

page <- read_html(link)

Name <- page %>% 
  html_nodes('.v-align-middle') %>% 
  html_text()



Company <- page %>% 
  html_nodes(xpath = '//*[@id="main"]/div/div/div[2]/ul/li[1]/div/div/div[2]/div[1]/div[2]/div/div[2]') %>% 
  html_text()


Location <- page %>% 
  html_nodes(xpath = '//*[@id="main"]/div/div/div[2]/ul/li[1]/div/div/div[2]/div[1]/div[2]/div/div[1]') %>% 
  html_text()


people_profile <- data.frame(Name, company,Location, stringsAsFactors = FALSE)


#Scraping multiple pages using a For Loop 


people_profile <- rbind(people_profile, data.frame(Name,Company,Location, stringsAsFactors = FALSE))
for (page_result in seq(from = 1, to = 7, by = 1)) {
  link <- paste0("https://www.linkedin.com/search/results/people/?geoUrn=%5B%22103121230%22%5D&keywords=%22%20Chief%20Revenue%20Officer%22", page_result,"&sid=QZ-") #adding a paste0() function deletes  all spaces by default
  page <- read_html(link)
  Name <- page %>% 
    html_nodes('.v-align-middle') %>% 
    html_text()
  Company <- page %>% 
    html_nodes(xpath = '//*[@id="main"]/div/div/div[2]/ul/li[1]/div/div/div[2]/div[1]/div[2]/div/div[2]') %>% 
    html_text()
  Location <- page %>% 
    html_nodes(xpath = '//*[@id="main"]/div/div/div[2]/ul/li[1]/div/div/div[2]/div[1]/div[2]/div/div[1]') %>% 
    html_text()
  
  people_profile <- data.frame(Name,company,Location, stringsAsFactors = FALSE)
}

# Writing the data frame to a CSV file 
write.csv(people_profile, "people Profile.csv")

