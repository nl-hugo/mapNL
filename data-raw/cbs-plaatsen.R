library(dplyr)
library(cbsodataR)

versions <- cbsodataR::get_table_list() %>%
  filter(grepl("Woonplaatsen in Nederland", Title)) %>%
  select(Identifier, Period)

download <- function(t) {
  cbsodataR::get_data(t["Identifier"]) %>%
    mutate(jaar = t["Period"]) %>%
    select(-ID)
}

# merge into one dataframe
cities <- bind_rows(apply(versions, 1, download))
cities <-
  data.frame(lapply(cities, trimws), stringsAsFactors = FALSE)

names(cities) <-
  c(
    "wp_naam",
    "wp_code",
    "gm_naam",
    "gm_code",
    "pv_naam",
    "pv_code",
    "ld_naam",
    "ld_code",
    "jaar",
    "code_1"
  )

# tidy codes
cities$wp_code[is.na(cities$wp_code)] <-
  cities$code_1[is.na(cities$wp_code)]
cities$code_1 <- NULL

cities$wp_code[nchar(cities$wp_code) == 4] <-
  paste0("WP", cities$wp_code[nchar(cities$wp_code) == 4])

cities$gm_code[nchar(cities$gm_code) == 4] <-
  paste0("GM", cities$gm_code[nchar(cities$gm_code) == 4])

cities$pv_code[nchar(cities$pv_code) == 2] <-
  paste0("PV", cities$pv_code[nchar(cities$pv_code) == 2])

cities$ld_code[nchar(cities$ld_code) == 2] <-
  paste0("LD", cities$ld_code[nchar(cities$ld_code) == 2])

# save
save("cities", file = "data/cities.rdata")
