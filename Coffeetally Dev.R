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

#working directory kiezen
setwd('C:/Users/chris/OneDrive/Rstudio/Coffeetally')

#Getting data and cleaning it #### 

#Via googlesheets:
my_sheets <- gs_ls()
gs_mydata <- gs_title('Coffee Tally')
gs_mydata <- gs_read(gs_mydata, col_names = FALSE)

#Drop unwanted columns
gs_mydata$X2 <- NULL
gs_mydata$X3 <- NULL
gs_mydata$X6 <- NULL
gs_mydata$X7 <- NULL

#Renaming columns
gs_mydata <- gs_mydata %>% rename(ogdate = X1, 
                                  longitude = X4, 
                                  latitude = X5
)

#getting timestamp from string, convert it into date and time
gs_mydata$timestamp <- parse_date_time2(gs_mydata$ogdate, "BdYH24M")
gs_mydata$date <- as_date(gs_mydata$timestamp)
gs_mydata$time <- format(gs_mydata$timestamp, "%H:%M")

gs_mydata <- gs_mydata %>% select(5, 2, 3)

# Geomapping ####

#Getting a coordinate column
# gs_mydata$longlat <- substr(gs_mydata$X2, 50, 79)
# gs_mydata$city <- revgeocode(gs_mydata$longlat, output = "more", messaging = FALSE)
# something is going wrong, see: https://stackoverflow.com/questions/22911642/applying-revgeocode-to-a-list-of-longitude-latitude-coordinates
#Get ggmap to work and find locality for each known coordinate set -> doesn't seem to work
# gs_mydata$coordinate <- lapply(with(gs_mydata, paste(gs_mydata$longitude, gs_mydata$latitude, sep = ",")), geocode, output = "more")
# gs_mydata$locale <- transform(gs_mydata, city = sapply(gs_mydata$coordinate, "[[", "locality"))


# Oude meuk ####

# decrease coordinate length
#gs_mydata$longitude <- substr(gs_mydata$longitude, 1, 4)
#gs_mydata$latitude <- substr(gs_mydata$latitude, 1, 4)

# merge two coordinate columns (longitude & latitude) into one
#gs_mydata$coordinate <- paste(gs_mydata$longitude, gs_mydata$latitude, sep=", ")

# add a new variable: location ID
#gs_mydata$location_id[gs_mydata$coordinate %in% c("NA, NA")] <- 0
#gs_mydata$location_id[gs_mydata$coordinate %in% c("5208, 4281")] <- 1
#gs_mydata$location_id[gs_mydata$coordinate %in% c("5204, 4503")] <- 2
#gs_mydata$location_id[gs_mydata$coordinate %in% c("5222, 5954")] <- 3
#gs_mydata$location_id[gs_mydata$coordinate %in% c("5202, 4426")] <- 4

# build location reference table
#location <- c("Geen data","Thuis, Den Haag", "KR, Zoetermeer", "Daendelsweg, Apeldoorn", "Pijnacker")
#location_id <- c(0, 1, 2, 3, 4)
#LocationRef <- data.frame(location, location_id)

#Join data sets
#mydata <- merge(x = gs_mydata, y = LocationRef, by.x = "location_id", by.y = "location_id")

#Rearange dataset
#mydata <- mydata %>% select(6,7,8,1,9)





# Visualise gs_mydata #####
#plot barchar, count only only
bar_gs <- ggplot(gs_mydata, aes(date)) +
  geom_bar(fill = "dodgerblue") +
  theme_bw() +
  ggtitle("Coffee Tally") +
  theme( axis.title.y  = element_blank(), text = element_text(size=8))

print(bar_gs)

# Visualise mydata (geomapping) ####

#plot barchar, count only only
#bar1 <- ggplot(mydata, aes(date)) +
#  geom_bar(fill = "dodgerblue") +
#  theme_bw() +
#  facet_grid(mydata$location ~ .) +
#  ggtitle("Coffee Tally") +
#  theme( axis.title.y  = element_blank(), text = element_text(size=8))

#print(bar1)

#plot barchart, tally data vs location

#bar2 <- ggplot(mydata, aes(date)) +
#  geom_bar(aes(fill = mydata$location)) +
#  scale_fill_brewer(palette = "Accent", name = "Location") +
#  theme_gray() +
#  labs(x = "Date", y = "Cups of Coffee",
#       title = "Coffee Tally",
#       subtitle = "Insight into my coffee habbits"
#       )

#print(bar2)

# plotting data on a map ####
library('rworldmap')
newmap <- getMap(resolution = "low")
plot(newmap, xlim = c(0, 10), ylim = c(50, 54), asp = 1)
points(gs_mydata$longitude, gs_mydata$latitude, col = "red", cex = .6)

# via ggmap
library(ggmap)
map <- get_map(location = 'Zoetermeer, The Netherlands', zoom = 10)
mapPoints <- ggmap(map) +
              geom_point(aes(x = gs_mydata$longitude, 
                             y = gs_mydata$latitude), 
                             data = gs_mydata, 
                             alpha = .5
                         )
plot(map)


