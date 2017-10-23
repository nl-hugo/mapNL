library(dplyr)

URL <- "https://www.vektis.nl/uploads/Docs%20per%20pagina/Open%20Data%20Bestanden/"
fn <- "Vektis%20Open%20Databestand%20Zorgverzekeringswet"
years <- c("2011", "2012", "2013", "2014", "2015")

gm.vektis <- c(
  "S GRAVENHAGE",
  "S HERTOGENBOSCH",
  "BERGEN LB",
  "BERGEN NH",
  "HAARLEMMERLIEDE CA",
  "KOLLUMERLAND CA",
  "NOORD BEVELAND",
  "NUENEN CA",
  "SUDWEST-FRYSLAN"
)
gm.cbs <- c(
  "'S-GRAVENHAGE",
  "'S-HERTOGENBOSCH",
  "BERGEN (L.)",
  "BERGEN (NH.)",
  "HAARLEMMERLIEDE EN SPAARNWOUDE",
  "KOLLUMERLAND EN NIEUWKRUISLAND",
  "NOORD-BEVELAND",
  "NUENEN, GERWEN EN NEDERWETTEN",
  "SÃºDWEST-FRYSLÃ¢N"
)

# download file for the specified layer and year
download <- function(layer, year) {
  f <-
    paste(paste(fn, year, "-", layer, sep = "%20"), "csv", sep = ".")
  csv <- paste0("data-raw/vektis/", f)
  if (!file.exists(csv)) {
    download.file(paste0(URL, f), destfile = csv)
  }
  read.csv(csv, sep = ";", stringsAsFactors = FALSE) %>%
    filter(GEMEENTENAAM != "") %>%
    mutate(jaar = year)
}

# merge into one tidy df
df <- bind_rows(lapply(years, function(y) download("gemeente", y)))
names(df) <- tolower(names(df))
df$gemeentenaam <-
  plyr::mapvalues(df$gemeentenaam, from = gm.vektis, to = gm.cbs)

gm <- cities %>%
  filter(jaar == "2017") %>%
  select(gm_code, gm_naam) %>%
  mutate(gm_naam = toupper(gm_naam)) %>%
  distinct()

zvw_gemeente <- df %>%
  left_join(gm, by = c("gemeentenaam" = "gm_naam")) %>%
  select(c(24, 3, 31, 1, 2, 4:23, 25:30))

# save
save(list = "zvw_gemeente" , file = "data/zvw_gemeente.rdata")
