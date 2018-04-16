#Admin ####
#packages
library("googlesheets")
library("openssl")
library("curl")
library("openssl")
library("httr")
library(lubridate)
library(dplyr)
library(ggplot2)
library(rsconnect)
library(ggmap)
library(DT)

#working directory kiezen
setwd('C:/Users/chris/OneDrive/Rstudio/Coffeetally')

#Get & clean data #### 
#Via googlesheets:
#my_sheets <- gs_ls()
mydata <- gs_title('Coffee Tally v2')
mydata <- gs_read(mydata, col_names = TRUE)
mydata$date <- as.Date(mydata$date, "%m/%d/%Y")
mydata$day.name <- weekdays(mydata$date)
mydata$is.weekday <- 1
mydata$is.weekday[mydata$day.name %in% c("zaterdag", "zondag")] <- 0

res <- lapply(with(mydata, paste(lat, lon, sep = ",")), geocode, output = "more")
mydata$city <- transform(mydata, city = sapply(locatie, "[[", "locality"))

#niet de beste oplossing, krijg te veel precieze info (adres) en er zitten ook een boel N/A's tussen
#mydata$address <- mapply(FUN = function(lon, lat) revgeocode(c(lon, lat)), mydata$lon, mydata$lat)


#Chart #####
plot1 <- ggplot(mydata, aes(date)) +
  geom_bar(fill = "dodgerblue") +
  theme_bw() +
  ggtitle("Barchart Date") +
  theme(axis.title.y  = element_blank(), text = element_text(size=8))

print(plot1)

plot2 <- ggplot(mydata, aes(time)) +
  geom_histogram(bins = 25, fill = "dodgerblue") +
  theme_bw() +
  ggtitle("Histogram Time") +
  theme(axis.title.y  = element_blank(), text = element_text(size=8))

print(plot2)

plot3 <- ggplot(mydata, aes(city)) +
  geom_histogram(bins = 25, fill = "dodgerblue") +
  theme(axis.title.y  = element_blank(), text = element_text(size=8))

print(plot3)

# ggmap -> beter #####  
#library(ggmap)
#map <- get_map(location = 'The Netherlands', zoom = 8, maptype = "terrain")
#mapPoints <- ggmap(map) +
#             geom_point(data = mydata, 
#                        aes(x = mydata$lon, y = mydata$lat), 
#                        fill = 'red',
#                        alpha = .5,
#                        size = 5, 
#                        shape = 21
#             ) +
#             guides(fill=FALSE, alpha=FALSE, size=FALSE)
#plot(mapPoints)


# rworldmap -> shit####
#library('rworldmap')
#newmap <- getMap(resolution = "low")
#plot(newmap, xlim = c(3, 6), ylim = c(51, 53), asp = 1)
#points(mydata$lon, mydata$lat, col = "red", cex = .6)

#Google map API key
# register_google(key = AIzaSyCTn4NwqVfTqFW1Wr_btZWc0PODw0H3iGU)
# devtools::install_github("dkahle/ggmap")

#number of coffees, number of days and avg.intake
coffee <- nrow(mydata)
days <- length(unique(mydata$date))
avg.intake <- round(coffee/days, digits = 2)

# aantal koffie en gemiddelde per werkdag -> subsetten naar alleen regels met werkdagen, dan dezelfde 
mydata.work <- subset(mydata, is.weekday == 1)
coffee.work <- nrow(mydata.work)
days.work <- length(unique(mydata.work$date))
avg.intake.work <- round(coffee.work/days.work, digits = 2)

