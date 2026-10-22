library(tidyverse)
library(stats)

#function to create a table in the dashboard

p_summary_table <- function(df_c, df_r) {
  
  constituency_name <- df_c$CONSTITUENCY_LABEL[[1]] #name of chosen constituency

  df_c <- df_c |> #adjust input constituency dataframe
    subset(select = -c(CONSTITUENCY)) |>
    rename("Geography" = "CONSTITUENCY_LABEL")
  df_r <- df_r |> #adjust input region dataframe
    rename("Geography" = "Region")
  uk <- uk_data |> #UK data for use in every table
    rename("Geography" = GEOGRAPHY)

  table_data <- rbind(df_c, df_r, uk) |> #creating table data based on the above
    rename(
      "Heating cost" = "HEATING_COST_CURRENT",
      "CO2 emissions" = "CO2_EMISSIONS",
      "Energy efficiency" = "CURRENT_ENERGY_EFFICIENCY"
    )

  #create the table itself
  DT::datatable(
    table_data, #data defined above

    #options for how the table will display
    rownames = FALSE,
    options = list(
      dom = 'tp',
      paging = FALSE, #stops pagination on table
      scrollY = "150px", #max height of the table before it will add a scrollbar
      filter = "none" #removes filter / search box at the top of the table
    ),
    class = "compact",
    selection = "none" #disables selecting rows
  ) |>
    formatCurrency(2, currency = "£") #format second column as currency
}


tableHeaderStyle  <-
  list(
    fontWeight    = "bold",
    textAlign     = "left",
    padding       = "10px 18px",
   #background    = "#F0EEED",
    color         = "#333",
    borderBottom  = "1px solid rgba(0, 0, 0, 0.3)",
    borderTop     = "none",
    textTransform = "none",
    fontSize      = "1em",
    textAlign = "right"
)



p_summary_table_reactable <- function(df_c, df_r) {
  
  constituency_name <- df_c$CONSTITUENCY_LABEL[[1]] #name of chosen constituency

  df_c <- df_c |> #adjust input constituency dataframe
    subset(select = -c(CONSTITUENCY)) |>
    rename("Geography" = "CONSTITUENCY_LABEL")
  df_r <- df_r |> #adjust input region dataframe
    rename("Geography" = "Region")
  uk <- uk_data |> #UK data for use in every table
    rename("Geography" = GEOGRAPHY)

  table_data <- rbind(df_c, df_r, uk) #|> #creating table data based on the above
    # rename(
    #   "Heating cost" = "HEATING_COST_CURRENT",
    #   "CO2 emissions" = "CO2_EMISSIONS",
    #   "Energy efficiency" = "CURRENT_ENERGY_EFFICIENCY"
    # )

  #create the table itself
    table_data |>
    reactable(
      # columns is a named list; dataframe_column = colDef( options ...)
      columns = list(
        Geography = colDef(show = TRUE, name = "Geography"),
        HEATING_COST_CURRENT = colDef(show = TRUE, name = "Heating cost", format = colFormat(prefix = "£", separators = TRUE, digits = 0)),
        CO2_EMISSIONS = colDef(show = TRUE, name = "CO2 emissions"),
        CURRENT_ENERGY_EFFICIENCY   = colDef(show = TRUE, name = "Energy efficiency")
      ),
      # if your df is large, use a defaultColDef
      # to hide other columns with show =  FALSE
      # these options get applied to all columns,
      # but can be overridden with colDefs above
      defaultColDef = colDef(
        show        = FALSE,
        sortable    = TRUE,
        headerStyle = tableHeaderStyle
      ),
      # reactable-level option examples:
      # show short buttons on each column
      showSortable = TRUE,
      # disable pagination; forces all items to be in 1 page
      pagination   = FALSE,
      # options for clicking a row
      #selection    = "single",
      #onClick      = "select",
      # show a highlight on mouse hovering
      #highlight    = TRUE
    )
}
