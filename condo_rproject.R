# Install and load the readxl package
install.packages("readxl")
library(readxl)
# install dplyr for manipulation
install.packages("dplyr")
library(dplyr)

install.packages("tidyverse")
library(tidyverse)

# load maggitr and stringr packages
install.packages("stringr")
install.packages("maggrittr")
library(stringr)
library(magrittr)

install.packages("tidyr")
library(tidyr)

# loading excel file for each borough
bronx <- read_excel('rollingsales_bronx.xlsx', skip = 4)
brooklyn <- read_excel('rollingsales_brooklyn.xlsx', skip = 4)
manhattan <- read_excel('rollingsales_manhattan.xlsx', skip = 4)
queens <- read_excel('rollingsales_queens.xlsx', skip = 4)
statenisland <- read_excel('rollingsales_statenisland.xlsx', skip = 4)

# stack 5 data frames together
NYC_property_sales <- bind_rows(bronx, brooklyn, manhattan, queens, statenisland)

#removing data frames from each borough
rm(brooklyn, bronx, manhattan, statenisland, queens)

# Replace borough number with borough name, for clarity
NYC_property_sales <- NYC_property_sales %>% 
  mutate(BOROUGH = 
           case_when(BOROUGH == 1 ~ "Manhattan",
                     BOROUGH == 2 ~ "Bronx",
                     BOROUGH == 3 ~ "Brooklyn",
                     BOROUGH == 4 ~ "Queens",
                     BOROUGH == 5 ~ "Staten_Island"))

#formatting data by converting column names to lower case-uniformity
colnames(NYC_property_sales) %<>% str_replace_all("\\s", "_") %>% tolower()

# convert capital columns to lower case
NYC_property_sales <- NYC_property_sales %>% 
  mutate(neighborhood = str_to_title(neighborhood)) %>% 
  mutate(building_class_category = 
           str_to_title(building_class_category)) %>% 
  mutate(address = str_to_title(address)) 

# filtering data
NYC_property_sales <- NYC_property_sales %>%
  filter(sale_price > 10000) %>% #property exchanges between family members (assume threshold is 10000)
  filter(gross_square_feet > 0) %>% #removing gross square footage that is 0
  select(- "apartment_number") #remove apartment number column
select(- "easement") %>% #remove easement column
  drop_na(gross_square_feet, sale_price, apartment_number)

# install dplyr for manipulation
library(dplyr)

## Arranging boroughs and neighborhoods observations alphabetically
NYC_property_sales <- NYC_property_sales %>%
  arrange(borough, neighborhood)

write_csv(NYC_property_sales, "NYC_property_sales.csv")
