
#functions to make dynamic text from the input data - these form headings and blurbs

make_heading_one <- function(data) {
  paste0("Summary of data for ", data$CONSTITUENCY_LABEL)
}

make_heading_two <- function(data) {
  paste0("Breakdown of properties by EPC rating in ", data$CONSTITUENCY_LABEL)
}

make_heading_three <- function(data) {
  paste0("Changes over time in ", data$CONSTITUENCY_LABEL)
}

make_ratings_blurb <- function(ratings_data) {
ratings_data <- filter(ratings_data,CURRENT_ENERGY_RATING == "A")
  paste("In",
  ratings_data$CONSTITUENCY_LABEL,
  ratings_data$number[1],
"properties have an energy rating of A.")
}

# text content for blurbs used in the server file
text_intro <- "It's a good idea to have some text here that provides context, a general introduction to the dashboard, 
  and explains any non-obvious user interface features. This goes for every part of the dashboard."

text_intro2 <- "Another blurb here would probably be good."

text_intro3 <- "Some words about the chart and what it shows and (if necessary) how to use it."