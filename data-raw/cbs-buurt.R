library(rgdal)
library(ggplot2)
library(dplyr)

URL <- "https://www.cbs.nl/-/media/_pdf/2017/36/buurt_2017.zip"
dsn <- "data-raw/cbs-buurt"
layers <- c("gem", "wijk", "buurt")

# extract year from URL
year <- unlist(strsplit(basename(URL), "\\.|_"))[2]

# download only when file does not exists
if (!file.exists(dsn)) {
  tmp <- tempfile(fileext = ".zip")
  download.file(URL, tmp)
  unzip(tmp, exdir = dsn)
}

# read layer and reproject to WGS84
layer_WGS84 <- function(layer) {
  nl <-
    readOGR(
      dsn = dsn,
      layer = paste(layer, year, sep = "_"),
      verbose = FALSE,
      stringsAsFactors = FALSE
    ) %>% subset(WATER == "NEE")
  spTransform(nl, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))
}

# save map
save_map <- function(layer, obj) {
  id <- names(obj@data[1])
  map <- fortify(obj, region = id) %>%
    left_join(obj@data, by = c("id" = id)) %>%
    mutate(group = as.character(group))
  names(map) <- tolower(names(map))
  save("map", file = paste0("data/", layer, "_2017.rdata"))
}

# get all layers from shapefile and save (this may take a while)
sapply(layers, FUN = function(x) save_map(x, layer_WGS84(x)))
