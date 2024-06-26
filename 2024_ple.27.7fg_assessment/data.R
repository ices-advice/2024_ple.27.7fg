### ------------------------------------------------------------------------ ###
### Preprocess data, write TAF data tables ####
### ------------------------------------------------------------------------ ###

## Before: boot/data/PLE LPUE.csv
##         boot/data/advice_history.csv
##         boot/data/IC_combined.csv
## After:  data/idx.csv
##         data/idx.rds
##         data/advice_history.csv
##         data/advice_history.rds
##         data/length_data.csv
##         data/length_data.rds

library(icesTAF)
taf.libPaths()
library(tidyr)
library(dplyr)

### create folder to store data
mkdir("data")

### ------------------------------------------------------------------------ ###
### Biomass index data ####
### ------------------------------------------------------------------------ ###
### use UK(E&W)-BTS-Q3

### load data from csv
idx <- read.csv("boot/data/PLE LPUE.csv")

### required biomass index is in column "BC"
idxB <- idx %>%
  select(year = X, index = BC)

### save in data directory
write.taf(idxB, file = "data/idx.csv")
saveRDS(idxB, file = "data/idx.rds")


### ------------------------------------------------------------------------ ###
### catch and advice data ####
### ------------------------------------------------------------------------ ###

catch <- read.csv("boot/data/advice_history.csv")
write.taf(catch, file = "data/advice_history.csv")
saveRDS(catch, file = "data/advice_history.rds")


### ------------------------------------------------------------------------ ###
### length data ####
### ------------------------------------------------------------------------ ###
### raised data from InterCatch

### load data
lngth_full <- read.csv("boot/data/IC_combined.csv")

### summarise data
lngth <- lngth_full %>% 
  ### treat "BMS landing"/"Logbook Registered Discard" as discards
  mutate(CatchCategory = ifelse(CatchCategory == "Landings", 
                                "Landings", "Discards")) %>%
  #filter(CatchCategory %in% c("Discards", "Landings")) %>%
  select(year = Year, catch_category = CatchCategory, length = AgeOrLength, 
         numbers = CANUM) %>%
  group_by(year, catch_category, length) %>%
  summarise(numbers = sum(numbers)) %>%
  filter(numbers > 0)
write.taf(lngth, file = "data/length_data.csv")
saveRDS(lngth, file = "data/length_data.rds")

