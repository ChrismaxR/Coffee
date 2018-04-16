## Not run:  map queries drag R CMD check


## extents and legends
##################################################
hdf <- get_map("houston, texas")
ggmap(hdf, extent = "normal")
ggmap(hdf) # extent = "panel", note qmap defaults to extent = "device"
ggmap(hdf, extent = "device")



# make some fake spatial data
mu <- c(-95.3632715, 29.7632836); nDataSets <- sample(4:10,1)
chkpts <- NULL
for(k in 1:nDataSets){
  a <- rnorm(2); b <- rnorm(2);
  si <- 1/3000 * (outer(a,a) + outer(b,b))
  chkpts <- rbind(
    chkpts,
    cbind(MASS::mvrnorm(rpois(1,50), jitter(mu, .01), si), k)
  )
}
chkpts <- data.frame(chkpts)
names(chkpts) <- c("lon", "lat","class")
chkpts$class <- factor(chkpts$class)
qplot(lon, lat, data = chkpts, colour = class)

# show it on the map
ggmap(hdf, extent = "normal") +
  geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)

ggmap(hdf) +
  geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)

ggmap(hdf, extent = "device") +
  geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)

theme_set(theme_bw())
ggmap(hdf, extent = "device") +
  geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)

ggmap(hdf, extent = "device", legend = "topleft") +
  geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)

# qmplot is great for this kind of thing...
qmplot(lon, lat, data = chkpts, color = class, darken = .6)
qmplot(lon, lat, data = chkpts, geom = "density2d", color = class, darken = .6)

## maprange
##################################################
hdf <- get_map()
mu <- c(-95.3632715, 29.7632836)
points <- data.frame(MASS::mvrnorm(1000, mu = mu, diag(c(.1, .1))))
names(points) <- c("lon", "lat")
points$class <- sample(c("a","b"), 1000, replace = TRUE)

ggmap(hdf) + geom_point(data = points) # maprange built into extent = panel, device
ggmap(hdf) + geom_point(aes(colour = class), data = points)

ggmap(hdf, extent = "normal") + geom_point(data = points)
# note that the following is not the same as extent = panel
ggmap(hdf, extent = "normal", maprange = TRUE) + geom_point(data = points)

# and if you need your data to run off on a extent = device (legend included)
ggmap(hdf, extent = "normal", maprange = TRUE) +
  geom_point(aes(colour = class), data = points) +
  theme_nothing(legend = TRUE) + theme(legend.position = "right")

# again, qmplot is probably more useful
qmplot(lon, lat, data = points, color = class, darken = .4, alpha = I(.6))
qmplot(lon, lat, data = points, color = class, darken = 0,
       maptype = "toner-lite"
)

## cool examples
##################################################

# contour overlay
ggmap(get_map(maptype = "satellite"), extent = "device") +
  stat_density2d(aes(x = lon, y = lat, colour = class), data = chkpts, bins = 5)


# adding additional content
library(grid)
baylor <- get_map("baylor university", zoom = 15, maptype = "satellite")
ggmap(baylor)

# use gglocator to find lon/lat"s of interest
(clicks <- clicks <- gglocator(2) )
expand.grid(lon = clicks$lon, lat = clicks$lat)

ggmap(baylor) + theme_bw() +
  annotate("segment", x=-97.110, xend=-97.1188, y=31.5450, yend=31.5485,
           colour=I("red"), arrow = arrow(length=unit(0.3,"cm")), size = 1.5) +
  annotate("rect", xmin=-97.122, ymin=31.5439, xmax=-97.1050, ymax=31.5452,
           fill = I("white"), alpha = I(3/4)) +
  annotate("text", x=-97.113, y=31.5445, label = "Department of Statistical Science",
           colour = I("red"), size = 3.5) +
  labs(x = "Longitude", y = "Latitude") + ggtitle("Baylor University")

baylor <- get_map("baylor university", zoom = 16, maptype = "satellite")

ggmap(baylor, extent = "panel") +
  annotate("segment", x=-97.1175, xend=-97.1188, y=31.5449, yend=31.5485,
           colour=I("red"), arrow = arrow(length=unit(0.4,"cm")), size = 1.5) +
  annotate("rect", xmin=-97.122, ymin=31.5441, xmax=-97.113, ymax=31.5449,
           fill = I("white"), alpha = I(3/4)) +
  annotate("text", x=-97.1175, y=31.5445, label = "Department of Statistical Science",
           colour = I("red"), size = 4)



# a shapefile like layer
data(zips)
ggmap(get_map(maptype = "satellite", zoom = 8), extent = "device") +
  geom_polygon(aes(x = lon, y = lat, group = plotOrder),
               data = zips, colour = NA, fill = "red", alpha = .2) +
  geom_path(aes(x = lon, y = lat, group = plotOrder),
            data = zips, colour = "white", alpha = .4, size = .4)

library(plyr)
zipsLabels <- ddply(zips, .(zip), function(df){
  df[1,c("area", "perimeter", "zip", "lonCent", "latCent")]
})
ggmap(get_map(maptype = "satellite", zoom = 9),
      extent = "device", legend = "none", darken = .5) +
  geom_text(aes(x = lonCent, y = latCent, label = zip, size = area),
            data = zipsLabels, colour = I("red")) +
  scale_size(range = c(1.5,6))

qmplot(lonCent, latCent, data = zipsLabels, geom = "text",
       label = zip, size = area, maptype = "toner-lite", color = I("red")
)