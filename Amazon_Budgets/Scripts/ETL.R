# Setup---------------------------------------------------------------------------------------------

# Clear memory
rm(list = ls(all.names = TRUE))

# Load libraries and install if not installed already
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  tidyverse,  # Grammar for data and graphics
  here,       # Relative file paths
  tidytext,   # Text analysis in a tidy format
  magrittr,   # More pipeable functions (eg., set_colnames())
  pdftools,   # Read PDFs Into R
  feather,    # Files that are fast to write and read
  furrr       # Run functions from purrr package (e.g., map_dfr()) in parallel
)


# Set up parallel computing for purrr functions
future::plan("multicore")



# Read in Amazon Annual Reports ---------------------------------------------------------------------------------------

# Function to read in one report
read_one <- function(year_numeric) {
  
  year_string = as.character(year_numeric)
  
  # Read in one pdf with name according to pattern
  pdftools::pdf_text(pdf = here(paste0("Amazon_Budgets/PDFs/", year_string, "-Annual-Report.pdf"))) |>
    as.data.frame() |>
    magrittr::set_colnames("text") |>
    # Get text into tidy format with one token (word) per row
    unnest_tokens(
      word, # Name of column of words in new dataframe
      text  # Name of column containing text in original dataframe
      ) |> 
    # Add Column indicating year
    mutate(year = year_string) 
  
}

# Run the function on all years in parallel and rbind into one tidy dataframe
all_budgets <- future_map_dfr(2005:2023, read_one)   # This will take a while to run. Go grab a coffee or something.



# Write Data ------------------------------------------------------------------------------------------------------------

# Save in feather format so that the script can be run from this point to save time in future
write_feather(all_budgets, here("Amazon_Budgets/Data/Intermediate/all_budgets_tidy_uncleaned.feather"))












