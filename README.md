# Shiny example: a constituency dashboard

This repository is a working example of a small Shiny dashboard that shows Energy Performance Certificate (EPC) data for a UK parliamentary constituency. The user picks a constituency from a dropdown, and everything on the page (text, a table, two charts, a download button and a map) updates to match.

It is designed to be read and copied. Each page element (chart, table, map, text, download) is explained below with:

1. what you need in the **setup/helper files** (in the `R/` folder),
2. what you need in **`ui.R`**,
3. what you need in **`server.R`**,

so you can see how the three pieces connect and reuse the pattern for your own data.

## Contents

1. [What the dashboard does](#1-what-the-dashboard-does)
2. [Required packages](#2-required-packages)
3. [Project structure](#3-project-structure)
4. [How the files connect](#4-how-the-files-connect)
5. [Running the app](#5-running-the-app)
6. [The core pattern: input → reactive → output](#6-the-core-pattern-input--reactive--output)
7. [Element guide](#7-element-guide)
   - [7.1 Dropdown (the input)](#71-dropdown-the-input)
   - [7.2 Charts (plotly)](#72-charts-plotly)
   - [7.3 Tables (DT)](#73-tables-dt)
   - [7.4 Maps (leaflet)](#74-maps-leaflet)
   - [7.5 Text (static and dynamic)](#75-text-static-and-dynamic)
   - [7.6 Download button](#76-download-button)
   - [7.7 Tabs and layout](#77-tabs-and-layout)
   - [7.8 Styling (CSS)](#78-styling-css)
   - [7.9 URL bookmarking](#79-url-bookmarking)
8. [Adding a new element: checklist](#8-adding-a-new-element-checklist)
9. [Using your own data](#9-using-your-own-data)
10. [Troubleshooting](#10-troubleshooting)

## 1. What the dashboard does

| Tab | Contents |
| --- | --- |
| **Summary data** | Dynamic heading and blurb, a summary table comparing the constituency to its region and the UK, a bar chart of properties by EPC rating, and a download button |
| **Changes over time** | Dynamic heading and blurb, a line chart of heating costs over time, and a map of CO2 emissions by constituency |

A dropdown at the top of the page controls everything.

## 2. Required packages

You need [R](https://cran.r-project.org/){:target="_blank"} and (recommended) [Positron](https://positron.posit.co/download.html){target="_blank"}. You can find information on how to install this in our [R guidance folder](https://hopuk.sharepoint.com/sites/hct-RI/Guidance/Forms/AllItems.aspx?id=%2Fsites%2Fhct%2DRI%2FGuidance%2FStatistics%2C%20Charts%20and%20Tables%2FSection%20guidance%2FR%20guidance&viewid=4ecd91bd%2Dcf88%2D4a92%2Dab90%2D4b4777ec35d9&FolderCTID=0x01200010A813C065EC27459BBF6E40471E15A5){target="_blank"}.

The app loads these packages in `R/1_setup.R`:

| Package | Used for |
| --- | --- |
| `shiny` | The app framework |
| `bslib` | Page layout (`page_fluid`, `layout_columns`, `navset_pill`, `nav_panel`) |
| `shinyWidgets` | The searchable dropdown (`pickerInput`) |
| `plotly` | Interactive charts |
| `DT` | Interactive tables |
| `leaflet` | Interactive maps |
| `sf` | Reading map boundary files |
| `tidyverse` | Data wrangling and `ggplot2` (includes `dplyr`, `readr`) |
| `scales` | Axis label formatting |
| `viridis` | Colour palette |

Install them once:

```r
install.packages(c(
  "shiny", "bslib", "shinyWidgets", "plotly", "DT", "reactable",
  "leaflet", "sf", "tidyverse", "scales", "viridis"
))
```

Note that you can't install packages on parliamentary wifi or ethernet. You will need to use home wifi or WifiConnect.

## 3. Project structure

Shiny expects certain file and folder names. This is the layout the example uses:

```
my-app/
├── global.R              # runs once when the app starts (enables deep-linking)
├── ui.R                  # what the user sees
├── server.R              # the logic that fills the UI with content
├── R/                    # helper files: Shiny loads these automatically
│   ├── 1_setup.R         # libraries, loading in data
│   ├── charts.R          # chart-building functions
│   ├── table_function.R  # table-building functions
│   └── text.R            # dynamic heading/blurb functions and static text
├── data/                 # your data files (CSVs, GPKGs for maps)
│   ├── constituency_summary.csv
│   ├── constituency_ratings.csv
│   ├── cost_by_date.csv
│   ├── region_data.csv
│   ├── uk_data.csv
│   ├── geographies.csv
│   └── pcon_boundaries.gpkg
└── www/
    └── style.css         # custom Commons Library styling
```

Things worth knowing:

- **`R/` is loaded automatically.** Any `.R` file in a folder named `R` next to `ui.R`/`server.R` is sourced when the app starts, in alphabetical order. That is why the setup file is called `1_setup.R`: the `1_` makes it load first, so the libraries and data exist before the other files use them. You don't need `source()` calls.
- **`global.R` runs once** before the UI and server, and is the place for app-wide settings. We only really use this to enable deep-linking (ie the ability to refer to a specific constituency in the link we send to customers).
- **The `data/` file names are the ones the code reads.** If you rename them, update the `read_csv()` and `st_read()` calls in `R/1_setup.R`.

**Note on the data files:** the files in `data/` need the columns the code expects (listed in [section 9](#9-using-your-own-data)). Your own versions will contain different values so when you adapt the example code, make sure you edit the column names so that they match yours.

## 4. How the files connect

ISABEL MAKING CHART

The link between `ui.R` and `server.R` is the output ID string. If `server.R` defines `output$ratings_column`, `ui.R` shows it with `plotlyOutput("ratings_column")`. If the names don't match exactly, nothing appears.

The helper files from the `R/` folder hold the work (building a chart, formatting a table, writing a sentence). `server.R` stays short: it just filters the data and passes it to those functions, ie, it handles the reactive content that is controlled by the dropdown menu

## 5. Running the app

In Positron, open the **example shiny code** folder. Then, double click on `ui.R` or `server.R` to open the file. Then `CTRL + Shift + p` -> **Run App**, or in the R console, type:

```r
shiny::runApp()
```

## 6. The core pattern: input → reactive → output

Every element in this app follows the same three steps.

**1. An input (eg a constituency drop down) captures the user's choice** (`ui.R`):

```r
pickerInput(
  "conSelect",                                   # the input ID: read in server.R as input$conSelect
  "Select a constituency",                       # label shown above the dropdown
  choices = constituencies$CONSTITUENCY_LABEL,   # options in the dropdown, from geographies.csv, loaded in 1_setup.R
  selected = constituencies$CONSTITUENCY_LABEL[[1]],  # default value (first constituency that appears in the list)
  options = list(`live-search` = TRUE, size = 15, width = "150%") # enables search within dropdown (ie typing in a constituency name) and sets the number of visible items (15).
)
```

**2. Reactives filter the data using that choice** (`server.R`):

Reactives are used to get an input value to render an output object. For example, you may want the data that is presented to be dependent on the constituency that a customer selects.

For a fuller explanation of reactivity in Shiny, see the [Posit guidance on getting started in Shiny](https://shiny.posit.co/r/getstarted/build-an-app/reactive-flow/reactive-flow.html){target="_blank"}.

This code shows two reactives which filter a dataset based on the constituency dropdown:

```r
constituency_code <- reactive({
  row <- filter(constituency_summary, CONSTITUENCY_LABEL == input$conSelect)
  return(row$CONSTITUENCY[1])
})

ratings_con <- reactive({
  filter(constituency_ratings, CONSTITUENCY == constituency_code())
})
```
Note that the input is based on constituency names (`choices = constituencies$CONSTITUENCY_LABEL`) while the reactive filter uses constituency codes `filter(constituency_ratings, CONSTITUENCY == constituency_code())` that are linked to the names. This avoids issues that might arise from changes in names or (mis-)spellings.

In simpler cases, when you can filter directly on the input, you only need one reactive. For example, if `input$conSelect` was the constituency code, you could directly filter the data using the input:

```r
ratings_con <- reactive({
  filter(constituency_ratings, CONSTITUENCY == input$conSelect())
})
```

A `reactive()` re-runs automatically whenever something it depends on changes. Call it like a function: `ratings_con()`.

### Best practice for reactives

Please follow these instructions when creating reactives:

**Do:**

- Use `reactive()` as a default function for defining your reactive values. Almost all functionality for Library dashboards is most appropriate using this method and it makes code easier to read. There are other ways of defining reactives that are sometimes required (eg `reactiveVal()`), for example if you need a dashboard to remember certain states – ask a colleague if you need one of these.
- Use geographic codes (eg constituency codes) rather than names to filter datasets.
- Name your constituency slicer `conSelect` each time (so referred to as `input$conSelect` in the server file).
- Create functions for processes that you repeat in your server file – not just charts, maps and tables but also anything else repetitive. Where possible these should live in a setup script (eg `helper_functions.R`).
- Keep reactive definitions as short as possible. Do as little data manipulation as possible within reactives (eg summarising, pivoting, etc). Anything that can be done in the pipeline or `setup.R` should be.
- Comment your code to make it clear to a reader what’s happening.
- Use variable names that are descriptive but short (use `janitor::clean_names` if you need to, especially if variable names have spaces, dots, or allcaps).

**Don’t:**

- Create reactives that duplicate data already available in other reactives – for example, if your filtered constituency list also has a region field, don’t separately define a reactive for the region. (Exception would be for reactives you’re going to refer to several times in the same dashboard, ie reactive text or a figure that gets referred to a lot).
- Create more reactives than needed – if you have a wide dataset with one line per constituency, you don’t need more than one reactive.
- Create reactives that do exactly the same job as a different reactive for other parts of the dashboards.
- Create or manipulate data inside chart, map or table functions, unless this is unavoidable. Similarly, avoid complex calculations inside download handler functions (which are used to make download buttons).
- `observeEvent` if you don’t need to – this is not usually necessary with ordinary reactives. LLMs often suggest this but you only really need to use it for more complex interactions.
•	`req(input$conSelect)` is usually not needed in your reactive definitions. `req()` can be useful for protecting against errors in other types of interactivity but not in standard cases.

**3. Render functions turn the filtered data into outputs** (`server.R`), **and output functions make them visible on the page** (`ui.R`):

```r
# server.R
output$ratings_column <- renderPlotly({
  p_rating_column(ratings_con())
})

# ui.R
plotlyOutput("ratings_column")
```

The pairs of functions always match:

| Element | `ui.R` | `server.R` |
| --- | --- | --- |
| Plotly chart | `plotlyOutput()` | `renderPlotly()` |
| DT table | `DTOutput()` | `renderDT()` |
| Leaflet map | `leafletOutput()` | `renderLeaflet()` |
| Text | `textOutput()` | `renderText()` |
| Download | `downloadButton()` | `downloadHandler()` |

## 7. Element guide

### 7.1 Dropdown (the input)

**Where the choices come from:** `R/1_setup.R` loads `constituencies` from `data/geographies.csv`. The `geographies.csv` needs a `CONSTITUENCY_LABEL` column that contains the text that shows up in the dropdown menu.

```r
constituencies <- read_csv("data/geographies.csv", show_col_types = FALSE)
```

**`ui.R`**: a searchable dropdown from `shinyWidgets`:

```r
pickerInput(
  "conSelect",                                   # the input ID: read in server.R as input$conSelect
  "Select a constituency",                       # label shown above the dropdown
  choices = constituencies$CONSTITUENCY_LABEL,   # options in the dropdown, from geographies.csv, loaded in 1_setup.R
  selected = constituencies$CONSTITUENCY_LABEL[[1]],  # default value (first constituency that appears in the list)
  options = list(`live-search` = TRUE, size = 15, width = "150%") # enables search within dropdown (ie typing in a constituency name) and sets the number of visible items (15).
)
```

**`server.R`**: the value (constituency name) is available as `input$conSelect`. The example turns the chosen label into a constituency code once, in a reactive, and every other reactive uses that code (codes are safer to filter on than names):

```r
constituency_code <- reactive({
  row <- filter(constituency_summary, CONSTITUENCY_LABEL == input$conSelect)
  return(row$CONSTITUENCY[1])
})
```

The dashboard has a single dropdown ID (`conSelect`) used everywhere, so every output relates to the selected constituency.

### 7.2 Charts (plotly)

Charts are built with `ggplot2`, then converted to interactive `plotly` objects. The chart code lives in `R/charts.R`; `server.R` and `ui.R` only refer to it.

#### Setup file: `R/charts.R`

**Shared Library style** (defined once, reused by every chart):

```r
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
```

**One function per chart type.** Each takes a data frame and returns a plotly object:

```r
p_rating_column <- function(df) {
  {
    ggplot(
      df, #your data frame
      aes(
        text = paste0(
          "Rating: ",
          CURRENT_ENERGY_RATING, #relevant column name
          "\n",
          formatC(number, format = "d", big.mark = ","), #formats the number
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
    convert_2_plotly_bar() #turns ggplot static object into interactive plotly chart. This function is defined below.
}
```

**Notes:**

- The `text = ...` aesthetic is what the hover tooltip shows.
- The data frame passed in must contain the columns that you use (in this case `CURRENT_ENERGY_RATING` and `number`).
- For more example chart code, see the [clcharts](https://github.com/houseofcommonslibrary/clcharts){target="_blank"} `README`

**Converter functions** turn a ggplot into a plotly chart and switch off the controls you don't want (zoom, drag, the mode bar):

```r
convert_2_plotly_bar <- function(gplot) {
  ggplotly(gplot, tooltip = "text") |> #tells the function to use text defined above as tooltip
    config(
      scrollZoom = FALSE,
      editable = FALSE,
      displayModeBar = FALSE
      ) |>
    layout(
      dragmode = FALSE,
      hoverlabel = label, #label and font are defined in the shared style above
      font = font
      )

}
```

There is a second converter, `convert_2_plotly_line()`, which additionally sets a unified hover and spike line for time series. Use a separate converter per chart type when they need different behaviour.

The line chart (`p_cost_line()`) follows exactly the same pattern, using `geom_line()` and `commons_theme_line`, with `INSPECTION_DATE` on the x axis (which is why `1_setup.R` converts that column with `as.Date()`).

#### `server.R`

To generate a chart for the selected constituency, filter the data in a reactive, then pass it to the chart function:

```r
ratings_con <- reactive({
  filter(
    constituency_ratings, #dataframe loaded in /R/setup.R
    CONSTITUENCY == constituency_code()
  )
})

output$ratings_column <- renderPlotly({
  p_rating_column(ratings_con())
})
```

#### `ui.R`

```r
layout_columns(
  col_widths = c(8), #this goes up to 12 (full page width)
  plotlyOutput("ratings_column", height = "300")
)
```

### 7.3 Tables (DT)

The table compares the chosen constituency with its region and the UK. The table-building function lives in `R/table_function.R`.

#### Setup files

**`R/1_setup.R`** loads the three data frames the table is built from:

```r
constituency_summary <- read_csv("data/constituency_summary.csv", show_col_types = FALSE)
region_data          <- read_csv("data/region_data.csv", show_col_types = FALSE)
uk_data              <- read_csv("data/uk_data.csv", show_col_types = FALSE)
```

And creates a list of constituency codes and region names which is how the `server.R` code finds the right region for the selected constituency (more on this below).

```r
regions <- as.list(constituencies$Region)
names(regions) <- as.list(constituencies$CONSTITUENCY)
```

**`R/table_function.R`** takes the constituency data (`df_c`) and region data (`df_r`), adds the UK row, stacks them, and returns a `DT` table:

```r
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
```

**Notes:**

- Rename each data frame's label column to the same name (eg, `Geography`) before `rbind()`, so the three can be stacked.
- `rbind()` needs identical columns in each data frame, in the same order.
- `formatCurrency(2, ...)` refers to the column by position (the second column), so if you change the column order, update the number.

#### `server.R`

Two reactives provide the filtered rows (constituency and region), and `renderDT()` calls the `p_summary_table` function:

```r
df_con <- reactive({
  filter(constituency_summary, CONSTITUENCY == constituency_code())
})

df_reg <- reactive({
  filter(region_data, Region == regions[constituency_code()])
})

output$overview_table <- renderDT({
  p_summary_table(df_con(), df_reg())
})
```

`regions` is a named list built in `1_setup.R` (names are constituency codes, values are region names), which is how the code finds the right region for the selected constituency:

```r
regions <- as.list(constituencies$Region)
names(regions) <- as.list(constituencies$CONSTITUENCY)
```

#### `ui.R`

The `ui.R` renders the table and makes it appear in the app with the filtered data.

```r
div(DTOutput("overview_table"), class = "summary-table-container")
```

### 7.4 Maps (leaflet)

The national map is a choropleth (areas shaded by value) of CO2 emissions by constituency. Unlike the charts and table, the map code sits directly in `server.R`; the **data preparation** is in `R/1_setup.R`.

If you prefer, you could define the map in a separate setup file (eg `maps.R`) but since this does not require reactivity it's not really necessary.

#### Setup file: `R/1_setup.R`

Load the boundary file with `sf`, filter it, join your data on, and create a hover label column:

```r
boundaries <- st_read("data/pcon_boundaries.gpkg", quiet = TRUE) |>
  # keep England and Wales only
  filter(startsWith(PCON24CD, "E") | startsWith(PCON24CD, "W")) |>
  # join the data to the shapes
  left_join(constituency_summary, by = c("PCON24CD" = "CONSTITUENCY")) |>
  # build the hover label
  mutate(
    label = paste0(
      "Average CO2 emissions in<br>", PCON24NM, "<br>were ", CO2_EMISSIONS
    )
  )
```

The `leaflet` map needs from this object:

- **geometry** (the shapes), which comes from the `.gpkg` file,
- **join code** matching your data (here `PCON24CD` ↔ `CONSTITUENCY`),
- **value column** to colour by (`CO2_EMISSIONS`),
- **label column** for the hover text (`label`).

#### `server.R`

```r
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
```

The example moves the zoom buttons to the top right with a small piece of JavaScript via `htmlwidgets::onRender()`. If you need any functionality adding to your interactives via JavaScript, ask Louie for help.

#### `ui.R`

```r
leafletOutput("map", height = "500")
```

**Note:**
This map doesn't react to the dropdown: it always shows every constituency, so its code does not call any `reactive()`. Because the bins never change, you could move the `percentiles`, `value_bins` and `palette` lines into `R/1_setup.R` so they run once at start-up rather than each time the map renders.

### 7.5 Text (static and dynamic)

All text content is defined in `R/text.R`, which keeps wording out of `server.R` and `ui.R` so it is easy to read and edit.

#### Setup file: `R/text.R`

**Static text** is a plain string:

```r
text_intro <- "It's a good idea to have some text here that provides context, a general introduction to the dashboard, 
  and explains any non-obvious user interface features. This goes for every part of the dashboard."
```

**Dynamic text** is a function that takes the filtered data and builds a sentence:

```r
make_heading_one <- function(data) {
  paste0("Summary of data for ", data$CONSTITUENCY_LABEL)
}

make_ratings_blurb <- function(ratings_data) {
ratings_data <- filter(ratings_data,CURRENT_ENERGY_RATING == "A")
  paste("In",
  ratings_data$CONSTITUENCY_LABEL,
  ratings_data$number[1],
"properties have an energy rating of A.")
}
```

#### `server.R`

```r
# static: just returns the string
output$blurb <- renderText({
  text_intro
})

# dynamic: passes the reactive data into the function
output$heading_one <- renderText({
  make_heading_one(data = df_con())
})

output$ratings_blurb <- renderText({
  make_ratings_blurb(ratings_data = ratings_con())
})
```

#### `ui.R`

```r
h2(textOutput("heading_one"))     # a dynamic heading
textOutput("blurb")               # a paragraph
```

A heading that is **not** dynamic doesn't need the server at all. Eg:

```r
h2("Map of CO2 emissions by constituency")
```

### 7.6 Download button

This lets the user download the data for their chosen constituency as a CSV. There is nothing to add to the setup files, since it reuses a reactive that already exists.

#### `server.R`

```r
output$download_constituency <- downloadHandler(
  filename = function() {
    paste0(input$conSelect, "_data.csv")      # file name changes with the selection
  },
  content = function(file) {
    write_csv(cost_over_time_con(), file)     # write the filtered data
  }
)
```

#### `ui.R`

```r
downloadButton(
  "download_constituency",
  "Download data for this constituency",
  class = "download"      # CSS class defined in www/style.css
)
```

### 7.7 Tabs and layout

`ui.R` is a function (needed for bookmarking, see [7.9](#79-url-bookmarking)) that returns a `bslib` page:

```r
ui <- function(request) {
  page_fluid(
    # dropdown
    layout_columns(col_widths = c(7), pickerInput("conSelect", ...)),

    # tabs
    navset_pill(
      nav_panel(title = "Summary data",     ...),
      nav_panel(title = "Changes over time", ...)
    )
  )
}
```

- `page_fluid()` makes a full-width responsive page.
- `navset_pill()` creates the tab bar; each `nav_panel()` is one tab.
- `layout_columns(col_widths = c(...))` arranges content on a 12-column grid. `c(12)` is full width, `c(8)` is two thirds, and so on.
- Content placed *above* `navset_pill()` (the dropdown) shows on every tab.

Accessibility: elements are given `tabindex = 0` through `tagAppendAttributes()` so keyboard users can focus them:

```r
textOutput("blurb") |>
  tagAppendAttributes(style = "margin-bottom:-10px", tabindex = 0)
```

#### Notes on accessibility

**Assistive technology**
Some things are a matter of judgement. Ultimately, your dashboard must be simple to navigate for keyboards and assistive software. This means:

- pressing tab cycles through items in a logical order
- when an object receives focus, a screen reader says something sensible
- pressing "h" will cycle through Heading level tags
- pressing "p" will cycle through paragraph tags
- as much functionality as possible is exposed to the keyboard

To test accessibility, start your application in an internet browser. Press `CTRL-Windows-enter` on your keyboard to open Microsoft Narrator. With the application tab open, press the home key on your keyboard. Unplug your mouse. Using the tab, p, and h keys, can you navigate the entire dashboard?

When focusing on an interactive element (e.g dropdown, tab headers, or leaflet map), press `capslock + space` to enter "scan off" mode. Can you interact with the widget using just the keyboard? If the answer to either these questions is "no" then you must make it so.

**Do:**

- Use a title panel at the top of the dashboard
- Break up text with `<h2>` headings
- Use `<p>` tags for text. If you need dynamic text, use `renderText()`. Avoid `renderUI()` for dynamic text.
- Wrap `plotlyOutput()` elements in a `<div>` with `role="img"` and `aria-label="my alt text"`:
```r
div(
  role = "img",
  `aria-label` = "Line chart of unemployment, 1967 to 2015, peaking at 15.4 million in 2010.",
  plotlyOutput("chart")
)
```

- Provide downloads wherever possible. If you have a chart-specific download, place the link / button immediately after the chart object

**Don’t:**

- Use `<br>` tags to space out text. It messes up screen reader hierarchy. Use `CSS` styles instead
- Add UI elements to force a certain spacing or align other elements. Give the elements you want to arrange a class and target them with CSS properties.
- Use unnecessary interactivity
  - don't use plot tooltips if you don't need them
  - avoid dropdown lists that interact with each other if possible. If you feel you really want them, consider the possibility that the dashboard format is not appropriate for your use case

### 7.8 Styling (CSS)

Custom styles live in `www/style.css` and are linked in `ui.R`:

```r
tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css"))
```

To style an element, it is given a class in `ui.R` and that class is defined in the CSS:

```r
# ui.R
downloadButton("download_constituency", "Download", class = "download")
```

```css
/* www/style.css */
.download {
  background-color: #ffffff !important;
  font-weight: bold !important;
}
.download:hover {
  background-color: #7FCBBD !important;
}
```

The stylesheet also sets fonts, heading colour (`h2`), tab/pill colours (`.nav-pills`), the dropdown (`.bootstrap-select`), and map controls (`.leaflet-*`).

This keeps colours consistent between the CSS and the chart code. The example uses `#006548` (dark green) in both `style.css` and in the `fill`/`colour` settings in `R/charts.R`.

We have a Library style CSS that lives in the example code -> www folder. Use this - if anything doesn't look right or needs to be adapted, please talk to Louie or Sonja.

### 7.9 URL bookmarking

`global.R` contains one line:

```r
shiny::enableBookmarking(store = "url")
```

This lets the current state of the app (for example, which constituency is selected) be saved in the URL, so a link can be shared. The share link will look something like this:

`https://commonslibrary.parliament.uk/research-briefings/cbp-10897/?conSelect=%22Stalybridge%20and%20Hyde%22`

Because of this, `ui` must be written as a **function** that takes `request`:

```r
ui <- function(request) { ... }
```

If you don't need bookmarking (eg yours is not a local data dashboard), you can delete `global.R` and write `ui <- page_fluid(...)` instead.

## 8. Adding a new element: checklist

Use this order every time:

1. **Data**: put any new file in `data/` and load it in `R/1_setup.R`.
2. **Helper function**: write a function in `R/` that takes a data frame and returns a chart, table or string (put charts in `charts.R`, tables in `table_function.R`, text in `text.R`, or create a new file).
3. **Reactive** (if the data depends on the dropdown): add a `reactive()` in `server.R` that filters on `constituency_code()`.
4. **Render**: add `output$my_new_thing <- renderXxx({ my_function(my_reactive()) })` in `server.R`.
5. **Place it**: add the matching `xxxOutput("my_new_thing")` in `ui.R`, in the right tab and column.
7. **Run and test** with a few different dropdown selections.

## 9. Using your own data

The example code expects certain columns and object names. Replace the example data with your own and update the code that uses these column names them. (An easy way to do this is to use `Ctrl+F` and replace all instances of the variable name.)

| File | Columns used by the code |
| --- | --- |
| `constituency_summary.csv` | `CONSTITUENCY` (code), `CONSTITUENCY_LABEL` (name), `HEATING_COST_CURRENT`, `CO2_EMISSIONS`, `CURRENT_ENERGY_EFFICIENCY` |
| `region_data.csv` | `Region`, plus the same three measure columns as above |
| `uk_data.csv` | `GEOGRAPHY`, plus the same three measure columns as above |
| `constituency_ratings.csv` | `CONSTITUENCY`, `CONSTITUENCY_LABEL`, `CURRENT_ENERGY_RATING` (A–G), `number` |
| `cost_by_date.csv` | `CONSTITUENCY`, `INSPECTION_DATE` (formatted `dd/mm/yyyy`), `HEATING_COST_CURRENT` |
| `geographies.csv` | `CONSTITUENCY`, `CONSTITUENCY_LABEL`, `Region` |
| `pcon_boundaries.gpkg` | `PCON24CD` (code), `PCON24NM` (name), plus geometry |

Things that must line up:

- **Codes must match across files.** `CONSTITUENCY` in the data files must match `PCON24CD` in the boundary file for the map join to work.
- **The three table inputs must have the same measure columns** in the same order, because `rbind()` stacks them.
- **Date format.** `INSPECTION_DATE` is parsed with `format = "%d/%m/%Y"`; change that in `1_setup.R` if your dates look different.
- **File encoding.** If place names contain accents or special characters and show up garbled, save your CSVs as UTF-8.

To use a different geography (local authorities, regions, schools...), swap `constituency`/`CONSTITUENCY` for your equivalent throughout, and keep the same pattern: one dropdown, one code-lookup reactive, filtered reactives, and render/output pairs.

For template code for different maps, see the Code projects folder on the H drive. Also see our [guidance on creating maps in R](https://hopuk.sharepoint.com/sites/hct-RI/Guidance/Forms/AllItems.aspx?viewid=4ecd91bd%2Dcf88%2D4a92%2Dab90%2D4b4777ec35d9&FolderCTID=0x01200010A813C065EC27459BBF6E40471E15A5&id=%2Fsites%2Fhct%2DRI%2FGuidance%2FStatistics%2C%20Charts%20and%20Tables%2FSection%20guidance%2FR%20guidance%2FMapping%20in%20R%2Ehtml&parent=%2Fsites%2Fhct%2DRI%2FGuidance%2FStatistics%2C%20Charts%20and%20Tables%2FSection%20guidance%2FR%20guidance){target="_blank"}.

## 10. Troubleshooting

| Problem | Likely cause |
| --- | --- |
| `could not find function "page_fluid"` (or similar) | The package isn't loaded. Check `library()` calls in `R/1_setup.R`, and that the file is in the `R/` folder |
| `object 'constituencies' not found` | `R/1_setup.R` didn't run: check it's inside a folder named `R` (capital R) next to `ui.R` |
| An output element is blank | The ID in `ui.R` doesn't exactly match `output$...` in `server.R` (IDs are case-sensitive) |
| `Operation not allowed without an active reactive context` | `input$...` or a reactive was used outside `reactive()`, `render...()` or `observe()` |
| Table errors with `names do not match previous names` | The data frames passed to `rbind()` have different column names or order |
| Map shows grey areas | The join between data and boundaries failed (codes don't match), or the value is `NA` |
| `Object of type 'closure' is not subsettable` | The reactive object does not have brackets at the end (eg `cost_over_time_con` instead of `cost_over_time_con()`)

## Other resources

- [For layout and design, see our dashboard guidance](https://hopuk.sharepoint.com/sites/hct-RI/Guidance/Forms/AllItems.aspx?id=%2Fsites%2Fhct%2DRI%2FGuidance%2FStatistics%2C%20Charts%20and%20Tables%2FGroups%20and%20software%20guidance%2FDashboard%20guidance%20%2D%20R%20Shiny%20and%20Power%20BI%2F3%20Designing%20and%20building%20a%20dashboard&viewid=4ecd91bd%2Dcf88%2D4a92%2Dab90%2D4b4777ec35d9&d=w101e20879ba4465786928f0a12c1ad50&csf=1&siteid=e27c9d83%2D59e7%2D4ce6%2Da1cf%2D413a4dcc8d5f&webid=465ce727%2Dfedd%2D4f5f%2D88b6%2D6141eef04a1a&uniqueid=101e2087%2D9ba4%2D4657%2D8692%2D8f0a12c1ad50&FolderCTID=0x01200010A813C065EC27459BBF6E40471E15A5){target="_blank"}
- [Mastering Shiny](https://mastering-shiny.org/){target="_blank"} (free online book, paper version lives on Sonja's desk)
- [Shiny documentation](https://shiny.posit.co/r/getstarted/){target="_blank"}
- [bslib](https://rstudio.github.io/bslib/){target="_blank"} for page layouts
- [plotly for R](https://plotly.com/r/){target="_blank"}, [DT](https://rstudio.github.io/DT/){target="_blank"}, and [leaflet for R](https://rstudio.github.io/leaflet/){target="_blank"}
- [More general guidance on dashboards](https://hopuk.sharepoint.com/sites/hct-RI/Guidance/Forms/AllItems.aspx?id=%2Fsites%2Fhct%2DRI%2FGuidance%2FStatistics%2C%20Charts%20and%20Tables%2FGroups%20and%20software%20guidance%2FDashboard%20guidance%20%2D%20R%20Shiny%20and%20Power%20BI&viewid=4ecd91bd%2Dcf88%2D4a92%2Dab90%2D4b4777ec35d9&d=w101e20879ba4465786928f0a12c1ad50&csf=1&siteid=e27c9d83%2D59e7%2D4ce6%2Da1cf%2D413a4dcc8d5f&webid=465ce727%2Dfedd%2D4f5f%2D88b6%2D6141eef04a1a&uniqueid=101e2087%2D9ba4%2D4657%2D8692%2D8f0a12c1ad50&FolderCTID=0x01200010A813C065EC27459BBF6E40471E15A5){target="_blank"}

