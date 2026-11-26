make_msoa_map <- function(
  con_outline,
  msoa_outline,
  msoa_column,
  msoa_boundary_column
) {
  percentiles <- c(0.1, 0.25, 0.5, 0.75, 0.9)

  msoa_outline$msoa_label <- paste0(
    msoa_outline$Name,
    "<br>EPC: ",
    format(round(msoa_outline$EPC, 1), nsmall = 1)
  )
  
  value_bins <- c(
    min(msoa_column, na.rm = TRUE),
    quantile(
      msoa_column,
      probs = percentiles,
      na.rm = TRUE
    ),
    max(msoa_column, na.rm = TRUE)
  )

  bin_pal <- colorBin(
    "viridis",
    msoa_column,
    bins = value_bins,
    reverse = TRUE
  )

  leaflet(
    options = leafletOptions(
      attributionControl = FALSE,
      minZoom = 8,
      maxZoom = 14
    )
  ) |>

    addTiles(
      urlTemplate = "https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=cb1_335f_1_f476a5e771eef88937cf7cc5",
      attribution = '<a href="https://carto.com/">CARTO</a>'
    ) |>

    addPolygons(
      data = msoa_outline,
      color = "#ffffff",
      weight = 0.5,
      smoothFactor = 0,
      opacity = 1,
      fillOpacity = 0.7,
      fillColor = ~ bin_pal(msoa_boundary_column),
    ) |>
    addPolygons(
      data = con_outline,
      color = "#666666",
      weight = 3,
      opacity = 1,
      fillOpacity = 0,
      smoothFactor = 0
    ) |>
    addPolygons(
      data = msoa_outline,
      opacity = 0,
      fillOpacity = 0,
      label = ~lapply(msoa_label, HTML),
      labelOptions = labelOptions(
        style = list(
          "color" = "black",
          "font-family" = "Open Sans",
          "font-weight" = "bold",
          "font-size" = "13px",
          "border-color" = "rgba(0,0,0,0.5)"
        )
      ),
      group = "msoas"
    ) |>
    addLegend(
      "topleft",
      pal = bin_pal,
      msoa_boundary_column,
      title = "",
      opacity = 1,
      labFormat = labelFormat(digits = 1)
    )
}
