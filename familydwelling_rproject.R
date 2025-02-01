# installing and loading packages

library(readxl)
library(dplyr)
library(tidyverse)
library(stringr)
library(magrittr)
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
  drop_na(gross_square_feet, sale_price)

## Arranging boroughs and neighborhoods observations alphabetically
NYC_property_sales <- NYC_property_sales %>%
  arrange(borough, neighborhood)

write_csv(NYC_property_sales, "NYC_property_sales.csv")

library(readr)
# Read in the CSV file we generated above
NYC_property_sales <- read_csv('NYC_property_sales.csv')

# Exploring bivariate relationships with scatterplot
```{r}
# looking for data with interesting points to select
sort(table(NYC_property_sales$building_class_at_present))

#filter data to include condos with elevators(miscellaneous) designated as D9
NYC_family_attached <- NYC_property_sales %>%
  filter(building_class_at_time_of_sale == "A5")

# Create the scatterplot with customizations
library(ggplot2)
library(scales)

ggplot(NYC_family_attached, aes(x = gross_square_feet, y = sale_price, color = borough)) +
  geom_point(alpha = 0.5) +  # Add transparency to points
  geom_smooth(method = "lm", se = FALSE) +  # Add linear trend line without confidence intervals
  scale_y_continuous(labels = comma, limits = c(0, 20000000)) +  # Format y-axis without scientific notation and adjust limits
  xlim(0,50000) +  # Adjust x-axis limits
  theme_minimal() +  # Change to minimal theme (optional)
  labs(
    title = "Relationship between Gross Square Feet and Sale Price of One family Attached Residences",
    x = "Gross Square Feet",
    y = "Sale Price"
  )

# Zoom into data to better visualize for each borough
ggplot(data = NYC_family_attached, 
       aes(x = gross_square_feet, y = sale_price)) +
  geom_point(alpha = 0.3) +
  facet_wrap(~ borough, scales = "free", ncol = 2) +
  scale_y_continuous(labels = scales::comma) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal() +
  labs(title = "One Family Attached Homes in NYC Generally Increases with Size",
       x = "Size (Gross Square Feet)",
       y = "Sale Price (USD)")

# Linear Regression model for family dwellings in all boroughs combined
```{r}
NYC_family_attachedlm <- lm(sale_price ~ gross_square_feet, data = NYC_family_attached) 
summary(NYC_family_attachedlm)

