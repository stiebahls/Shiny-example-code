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


tableHeaderStyle <-
  list(
    fontWeight = "bold",
    padding = "10px 18px",
    background = "#F0EEED",
    color = "#333",
    borderBottom = "1px solid rgba(0, 0, 0, 0.3)",
    borderTop = "none",
    textTransform = "none",
    fontSize = "1em"
  )

 
# Turn column names like "HEATING_COST_CURRENT" into "Heating cost current"
clean_header <- function(value) {
  value |>
    gsub("_", " ", x = _) |>
    tolower() |>
    (\(x) paste0(toupper(substring(x, 1, 1)), substring(x, 2)))()
}
 
p_summary_table_reactable <- function(df_c, df_r) {
  df_c <- df_c |>
    subset(select = -c(CONSTITUENCY)) |>
    rename("Geography" = "CONSTITUENCY_LABEL")
 
  df_r <- df_r |>
    rename("Geography" = "Region")
 
  uk <- uk_data |>
    rename("Geography" = GEOGRAPHY)
 
  table_data <- rbind(df_c, df_r, uk)
 
  table_data |>
    reactable(
      defaultColDef = colDef(
        header = clean_header,
        sortable = TRUE,
        headerStyle = tableHeaderStyle
      ),
      # only override what differs from the default
      columns = list(
        HEATING_COST_CURRENT = colDef(
          format = colFormat(prefix = "£", separators = TRUE, digits = 0)
        )
      ),
      showSortable = TRUE,
      pagination = FALSE
    )
}
 
make_msoa_table <- function(msoa_outline) {
  df <- msoa_outline |>
    st_drop_geometry() |>
    select(-Code) |>
    arrange(desc(EPC))

  reactable(
    df,
    selection = "single",
    onClick = "select",
    columns = list(
      .selection = colDef(show = FALSE),
      EPC = colDef(format = colFormat(separators = TRUE, digits = 1))
    ),
    defaultColDef = colDef(
      sortable = TRUE,
      headerStyle = tableHeaderStyle
    ),
    theme = reactableTheme(
      cellPadding = "4px 8px",
      cellStyle = list(fontSize = "0.8rem"),
      rowSelectedStyle = list(backgroundColor = "#c9c6c4")
    ),
    showSortable = TRUE,
    pagination = FALSE
  )
}