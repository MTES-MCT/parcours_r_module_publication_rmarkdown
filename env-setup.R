renv::activate() # facultatif, nécessite 'renv'

needed_packages <- c(
  
  'bookdown',
  
  'devtools'
  
)


install.packages(needed_packages)

devtools::install_github("hadley/emo")

install.packages ("rmarkdown")
library (rmarkdown)
