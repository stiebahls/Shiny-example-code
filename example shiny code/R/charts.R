# Font + tooltip styling (used in plotly outputs)
font <- list(
  family = "Open Sans",
  size = 12,
  color = "#222222"
)

label <- list(
  bgcolor = "#FFFFFF", #"#F0EEED",
  bordercolor = "#555555",
  font = font
)

# Reusable plot themes applied across multiple charts

commons_theme_bar <-
  theme(
    panel.background = element_blank(),
    plot.background = element_blank(),
    panel.grid = element_blank(),
    axis.line = element_line(colour = "black", linewidth = 0.2),
    axis.text = element_text(family = "Open Sans"),
    axis.ticks.y = element_line(linewidth = 0.8),
    axis.ticks.x = element_blank(),
    axis.title = element_blank(),
    axis.ticks.length = unit(.2, "cm"),
    plot.margin = unit(c(5, 0, 0, 0), "mm")
  )

commons_theme_line <-
  theme(
    plot.background = element_rect(fill = "transparent", colour = NA),
    panel.background = element_rect(fill = "transparent", colour = NA),
    panel.grid.major = element_line(colour = "#DDDDDD"),
    panel.grid.major.x = element_blank(),
    axis.line = element_line(colour = "#DDDDDD"),
    axis.line.y = element_blank(),
    text = element_text(family = "Open Sans"),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    axis.ticks.length = unit(0, "pt"),
    plot.margin = unit(c(5, 0, 0, 0), "mm")
  )


# Functions to generate interactive charts taking input datasets
p_cost_line <- function(df) {
  {
    df |>
      ggplot(
        aes(
          text = paste0(
            "Heating cost: £",
            formatC(
              round(HEATING_COST_CURRENT, 0), #column in the relevant dataset
              format = "d",
              big.mark = ","
            ),
            "\n",
            format(INSPECTION_DATE, "%B %Y")
          ),
          group = 1
        )
      ) +
      geom_line(
        mapping = aes(
          x = INSPECTION_DATE,
          y = HEATING_COST_CURRENT,
        ),
        colour = "#006548",
        linewidth = 1
      ) +
      scale_y_continuous(
        expand = c(0, 0),
        limits = c(0, NA),
        breaks = pretty_breaks(n = 4),
        labels = scales::label_dollar(prefix = "£")
      ) +
      commons_theme_line #adds theme defined above
  } |>
    convert_2_plotly_line() #convert ggplot to interactive plotly object
}

p_rating_column <- function(df) {
  {
    ggplot(
      df,
      aes(
        text = paste0(
          "Rating: ",
          CURRENT_ENERGY_RATING,
          "\n",
          formatC(number, format = "d", big.mark = ","),
          " properties"
        )
      )
    ) +
      geom_bar(
        mapping = aes(x = CURRENT_ENERGY_RATING, y = number),
        stat = "identity",
        fill = "#006548",
        colour = "#006548"
      ) +
      scale_y_continuous(expand = c(0, 0), labels = scales::label_comma()) +

      commons_theme_bar #adds theme defined above
  } |>
    convert_2_plotly_bar()
}

# Functions to add interactive plotly elements to the charts
convert_2_plotly_line <- function(gplot) {
  ggplotly(gplot, tooltip = "text") |>
    config(
      scrollZoom = FALSE,
      editable = FALSE,
      showAxisDragHandles = FALSE,
      displayModeBar = FALSE
    ) |>
    layout(
      dragmode = FALSE,
      hoverlabel = label,
      hovermode = "x unified",
      xaxis = list(
        showspikes = TRUE,
        spikemode = 'across',
        spikesnap = 'cursor',
        spikedash = 'solid',
        spikemode = 'across+toaxis',
        fixedrange = TRUE
      ),
      yaxis = list(fixedrange = TRUE)
    )
}

convert_2_plotly_bar <- function(gplot) {
  ggplotly(gplot, tooltip = "text") |>
    config(
      scrollZoom = FALSE,
      editable = FALSE,
      showAxisDragHandles = FALSE,
      displayModeBar = FALSE
    ) |>
    layout(
      dragmode = FALSE,
      hoverlabel = label,
      font = font
    )
}