ui <- function(request) {

  # page_fluid() creates a full-width responsive page
  page_fluid(

    
# CSS --------------------------------------------------------------------
# --- Include external CSS for custom styling. Draws from a file in the /www/ subfolder

    tags$head(tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "style.css"
    )),

    title = "Energy Performance Certificates",

# Top control: constituency selector -------------------------------------

    layout_columns(
      col_widths = c(7),
      div(
        class = "picker", # CSS class for styling
        pickerInput(
          "conSelect", #name of the dropdown - should always be conSelect for a constituency dashboard
          "Select a constituency", #text that will show above the dropdown
          choices = constituencies$CONSTITUENCY_LABEL, # dropdown options
          selected = constituencies$CONSTITUENCY_LABEL[[1]], # default value
          options = list(
            `live-search` = TRUE, # enables search within dropdown
            size = 15,  # number of visible items
            width = "150%"
          )
        ) |>
          # Add HTML attributes (styling + accessibility)
          tagAppendAttributes(
            style = "margin-bottom:-5px;",
            tabindex = 0
          )
      )
    ),


# Start of tabs ----------------------------------------------------------

    navset_pill(

      #new tab
      nav_panel(
        title = "Summary data",
      
        layout_columns(
          col_widths = c(12),

          # Dynamic heading (heading_one is generated in server.R as output$heading_one)
          h2(textOutput("heading_one")) |>
            tagAppendAttributes(
              style = "margin-bottom:-15px;margin-top:25px",
              tabindex = 0
            ),

          # Dynamic text (blurb is generated in server.R as output$blurb)
          textOutput("blurb") |>
            tagAppendAttributes(
              style = "margin-bottom:-10px",
              tabindex = 0
            ),

          textOutput("ratings_blurb") |> 
            tagAppendAttributes(
              tabindex = 0
            ),

          # Data table output (DT) - generated in server.R as output$`overview-table`
          div(DTOutput("overview_table"), class = "summary-table-container") |>
            tagAppendAttributes(
              style = "margin-bottom:-15px",
              tabindex = 0
            )
        ),
        
        layout_columns(
          col_widths = c(12),

          # Dynamic heading (heading_two is generated in server.R as output$heading_two)
          h2(textOutput("heading_two")) |>
            tagAppendAttributes(
              style = "margin-bottom:-15px;margin-top:5px",
              tabindex = 0
            ),

          # Dynamic text (blurb2 is generated in server.R as output$blurb2)
          textOutput("blurb2") |>
            tagAppendAttributes(
              style = "margin-bottom:-10px",
              tabindex = 0
            )
        ),
        layout_columns(
          col_widths = c(8),

          #chart output (ratings_column is generated in server.R as output$ratings_column)
          plotlyOutput("ratings_column", height = "300")
        ),
        layout_columns(
          col_widths = c(8),

          #download button which is defined in server.R as output$download_constituency
          downloadButton(
            'download_constituency',
            "Download data for this constituency",
            class = "download"
          ) |>
            tagAppendAttributes(style = "margin-top:5px",
            tabindex = 0)
        )
      ),

      #new tab
      nav_panel(
        title = "Changes over time",
        layout_columns(
          col_widths = c(12),

          # Dynamic heading (heading_two is generated in server.R as output$heading_two)
          h2(textOutput("heading_three")) |>
            tagAppendAttributes(
              style = "margin-bottom:-15px;margin-top:25px",
              tabindex = 0
            ),
          
          # Dynamic text (blurb3 is generated in server.R as output$blurb3)
          textOutput("blurb3") |>
            tagAppendAttributes(
              style = "margin-bottom:-20px",
              tabindex = 0
            )
        ),

        layout_columns(
          col_widths = c(8),

          #time series chart which is generated in server.R as output$`cost-line`
          plotlyOutput("cost_line")
        ),

        layout_columns(
          col_widths = c(12),

          #non-dynamic heading which does not refer to server.R
          h2("Map of CO2 emissions by constituency") |>
            tagAppendAttributes(
              style = "margin-top:10px;margin-bottom:-15px",
              tabindex = 0
            ),
          
          #map output, generated in server.R as output$map
          leafletOutput("map", height = "500")
        )
      )
    )
  )
}
