library(tidyverse)
library(rmarkdown)

render_mg_pays <- function(pays){
  rmarkdown::render("cheesedown_exo5_params.Rmd", 
                    params = list(country = pays),
                    output_file = paste0("mat-gr_", pays, ".html"))
}


list('France', 'Italy', 'United States') %>% 
  map(render_mg_pays)
