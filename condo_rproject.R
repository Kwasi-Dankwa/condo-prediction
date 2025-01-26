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

# Exploring bivariate relationships with scatterplot
# looking for data with interesting points to select
sort(table(NYC_property_sales$building_class_at_present))

#filter data to include condos with elevators(miscellaneous) designated as D9
NYC_condos <- NYC_property_sales %>%
  filter(building_class_at_time_of_sale == "D9")

# Create the scatterplot with customizations
library(ggplot2)
library(scales)

ggplot(NYC_condos, aes(x = gross_square_feet, y = sale_price, color = borough)) +
  geom_point(alpha = 0.5) +  # Add transparency to points
  geom_smooth(method = "lm", se = FALSE) +  # Add linear trend line without confidence intervals
  scale_y_continuous(labels = comma, limits = c(0, 80000000)) +  # Format y-axis without scientific notation and adjust limits
  xlim(0,250000) +  # Adjust x-axis limits
  theme_minimal() +  # Change to minimal theme
  labs(
    title = "Relationship between Gross Square Feet and Sale Price of NYC Condos",
    x = "Gross Square Feet",
    y = "Sale Price"
  ) # Adding label


# Zoom into data to better visualize for each borough
ggplot(data = NYC_condos, 
       aes(x = gross_square_feet, y = sale_price)) +
  geom_point(alpha = 0.3) +
  facet_wrap(~ borough, scales = "free", ncol = 2) +
  scale_y_continuous(labels = scales::comma) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal() +
  labs(title = "Condominium Sale Price in NYC Generally Increases with Size",
       x = "Size (Gross Square Feet)",
       y = "Sale Price (USD)")

# Investigating manhattan outliers
# filtering the apartments that increase as size increase
manhattan_outliers <- NYC_condos %>% #storing in new df
  filter(borough == "Manhattan") %>% #filtering by borough
  filter(sale_price >= 20000000) %>%
  arrange(sale_price)


