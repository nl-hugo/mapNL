library(xlsx)
library(ggmap)

URL <-
  "https://www.volksgezondheidenzorg.info/sites/default/files/ziekenhuizen2016_dec.xlsx"

download <- function() {
  xl <- paste0("data-raw/vz-info/", basename(URL))
  if (!file.exists(xl)) {
    download.file(URL, destfile = xl, mode = "wb")
  }
  xlsx::read.xlsx(
    xl,
    sheetIndex = 1,
    startRow = 3,
    colIndex = c(1:10),
    stringsAsFactors= FALSE
  )
}

df <- download()
names(df) <- tolower(names(df))

df[df$ziekenhuisnummer == 103809, c("adres")] <- "Krimkade 20" # fix typo
df$address <- paste(df$adres, df$postcode, df$plaats, sep = ",")
df <- cbind(df, geocode(df$address, output = "latlon"))

# another run to add geocodes that were missed in the first run (due to "failed
# with status OVER_QUERY_LIMIT")
df[is.na(df$lat), c("lon", "lat")] <-
  geocode(df[is.na(df$lat), c("address")], output = "latlon")

# save
ziekenhuizen <- df[, c(2,1,3,5:7,4,8,10,12,13)]
save(list = "ziekenhuizen" , file = "data/ziekenhuizen.rdata")
