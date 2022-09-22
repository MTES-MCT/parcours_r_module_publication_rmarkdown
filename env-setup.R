renv::activate() # facultatif, nécessite 'renv'

needed_packages <- c(
  
  'devtools',
  
  'rmarkdown',
  'distill',
  'xaringan',
  'xaringanExtra',
  'xaringanthemer',
  'pagedown',
  'showtext',
  'webshot2',
  'metathis',
  
  'dplyr',
  'ggplot2',
  'COVID19',
  'bit64',
  'RSQLite',
  'tidyr'
)


install.packages(needed_packages)

devtools::install_github("hadley/emo")
devtools::install_github("spyrales/gouvdown.fonts")
