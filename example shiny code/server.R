server <- function(input, output, session) {


# Reactives --------------------------------------------------------------

  #defined reactive values that will be used in dashboard widgets

  #obtain constituency code from the dropdown - we use this to filter everything else
  constituency_code <- reactive({
    row <- filter(
      constituency_summary,
      CONSTITUENCY_LABEL == input$conSelect
    )
    return(row$CONSTITUENCY[1])
  })

  #filter dataframes using the active constituency code
  cost_over_time_con <- reactive({
    filter(
      cost_by_date, #dataframe loaded in /R/setup.R
      `CONSTITUENCY` == constituency_code()
    )
  })

  ratings_con <- reactive({
    filter(
      constituency_ratings, #dataframe loaded in /R/setup.R
      CONSTITUENCY == constituency_code()
    )
  })

  df_con <- reactive({
    filter(
      constituency_summary, #dataframe loaded in /R/setup.R
      CONSTITUENCY == constituency_code()
    )
  })

  df_reg <- reactive({
    filter(
      region_data, #dataframe loaded in /R/setup.R
      Region == regions[constituency_code()]
    )
  })

 
# Plot outputs -----------------------------------------------------------

  # renderPlotly re-runs whenever reactive inputs inside are updated

  output$ratings_column <- renderPlotly({
    # Pass reactive dataset into plotting function
    #p_rating_column() is a chart creating function defined in /R/charts.R
    p_rating_column(ratings_con())
  })

  output$cost_line <- renderPlotly({
    #p_cost_line() is a chart creating function defined in /R/charts.R
    p_cost_line(cost_over_time_con())
  })

  # --- Table output ---
  # DT::renderDT creates an interactive table
  output$overview_table <- renderDT({
    #p_summary_table() is a table creating function defined in /R/charts.R
    p_summary_table(df_con(), df_reg())
  })


# Static text outputs ----------------------------------------------------

  # renderText returns text, and the contents of the blurbs are defined in /R/setup.R

  output$blurb <- renderText({
    text_intro
  })

  output$blurb2 <- renderText({
    text_intro2
  })

  output$blurb3 <- renderText({
    text_intro3
  })

  # Dynamic headings and blurbs that change depend on constituency selection
  # These are made using functions defined in /R/dynamictext.R

  output$heading_one <- renderText({
    make_heading_one(data = df_con())
  })

  output$heading_two <- renderText({
    make_heading_two(data = df_con())
  })

  output$heading_three <- renderText({
    make_heading_three(data = df_con())
  })

  output$ratings_blurb <- renderText({
    make_ratings_blurb(ratings_data = ratings_con())
  })


# Download handler -------------------------------------------------------

  # Lets user download filtered data as a CSV
  output$download_constituency <- downloadHandler(
    filename = function() {
      paste0(input$conSelect, "_data.csv") #define a dynamic filename based on the input constituency
    },
    content = function(file) {
      write_csv(cost_over_time_con(), file) #write the dataset filtered to this constituency to a file
    }
  )


# Leaflet map output -----------------------------------------------------
output$map <- renderLeaflet({
    # Define percentiles for binning CO2 values
    percentiles <- c(0.1, 0.25, 0.5, 0.75, 0.9)

    # Build bin thresholds: min -> percentiles -> max
    value_bins <- c(
      min(boundaries$CO2_EMISSIONS, na.rm = TRUE),
      quantile(boundaries$CO2_EMISSIONS, probs = percentiles, na.rm = TRUE),
      max(boundaries$CO2_EMISSIONS, na.rm = TRUE)
    )

    # Create colour palette function using bins
    palette <- colorBin(
      "viridis",
      boundaries$CO2_EMISSIONS, #a column in the boundaries file which is loaded in /R/setup.R
      bins = value_bins,
      reverse = TRUE,
      na.color = "#999999"
    )

    # Initialize leaflet map
    leaflet(
      boundaries, #boundaries file which is loaded in /R/setup.R
      options = leafletOptions(
        zoomControl = FALSE,
        attributionControl = FALSE,
        minZoom = 5,
        maxZoom = 10
      )
    ) |>
      # Add polygons (e.g. constituency shapes)
      addPolygons(
        color = "#ffffff", # border colour
        weight = 0.3,
        opacity = 1,
        fillOpacity = 1,
        smoothFactor = 0.1,
        fillColor = ~ palette(CO2_EMISSIONS), # colour based on data column in boundaries dataframe
        label = lapply(boundaries$label, HTML), # hover labels based on a column in the boundaries file
        labelOptions = labelOptions(
          style = list(
            "color" = "black",
            "font-family" = "Open Sans",
            "font-size" = "13px",
            "border-color" = "black"
          )
        )
      ) |>

      # Restrict map panning bounds
      setMaxBounds(lng1 = -23, lat1 = 48, lng2 = 17.7, lat2 = 60) |>

      # Legend settings
      addLegend(
        "topleft",
        pal = palette, #defined above
        values = boundaries$CO2_EMISSIONS, #column from boundaries file that we're using for the palette
        title = "CO2 emissions",
        labFormat = labelFormat(digits = 2),
        opacity = 1
      ) |>

      #adds zoom control in top right
      htmlwidgets::onRender(
        "function(el, x) {
          L.control.zoom({position:'topright'}).addTo(this);
        }"
      )
  })
}
