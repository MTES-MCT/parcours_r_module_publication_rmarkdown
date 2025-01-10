renv::activate() # facultatif, nécessite 'renv'

needed_packages <- c(
  
  'bookdown',
  'tidyverse',
  'devtools',
  'rmarkdown',
  'kableExtra'
  
)


install.packages(needed_packages)

devtools::install_github("hadley/emo")

