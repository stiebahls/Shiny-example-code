
# Libraries --------------------------------------------------------------

library(shiny)
library(bslib)
library(plotly)
library(tidyverse)
library(scales)
library(DT)
library(reactable)
library(shinyWidgets)
library(leaflet)
library(viridis)
library(sf)

# Load datasets used by the app ------------------------------------------

constituency_summary <- read_csv(
  "data/constituency_summary.csv",
  show_col_types = FALSE
)
region_data <- read_csv("data/region_data.csv", show_col_types = FALSE)

uk_data <- read_csv("data/uk_data.csv", show_col_types = FALSE)

constituency_ratings <- read_csv(
  "data/constituency_ratings.csv",
  show_col_types = FALSE
)
cost_by_date <- read_csv("data/cost_by_date.csv", show_col_types = FALSE) |>
  mutate(INSPECTION_DATE = as.Date(INSPECTION_DATE, format = "%d/%m/%Y"))

constituencies <- read_csv("data/geographies.csv", show_col_types = FALSE)


# Load constituency geographical boundaries ------------------------------

boundaries <- st_read("data/pcon_boundaries.gpkg", quiet = TRUE) |>
  #filter to england and wales
  filter(startsWith(PCON24CD, "E") | startsWith(PCON24CD, "W")) |>
  #join with data file
  left_join(constituency_summary, by = c("PCON24CD" = "CONSTITUENCY")) |>
  #create label column based on data columns
  mutate(
    label = paste0(
      "Average CO2 emissions in<br>",
      PCON24NM,
      "<br>were ",
      CO2_EMISSIONS
    )
  )


# Create list of regions -------------------------------------------------

regions <- as.list(constituencies$Region)
names(regions) <- as.list(constituencies$CONSTITUENCY)


