# Install and load the readxl package
install.packages("readxl")
library(readxl)

update.packages("readxl")

# loading excel file for each borough
bronx <- read_excel('rollingsales_bronx.xlsx', skip = 4)
brooklyn <- read_excel('rollingsales_brooklyn.xlsx', skip = 4)
manhattan <- read_excel('rollingsales_manhattan.xlsx', skip = 4)
queens <- read_excel('rollingsales_queens.xlsx', skip = 4)
statenisland <- read_excel('rollingsales_statenisland.xlsx', skip = 4)

