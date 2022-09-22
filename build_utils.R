clean_build_dir <- function()
{
  unlink('build', recursive=TRUE)
}

render_all <- function()
{
  dir.create('build')
  
  sitelog <- rmarkdown::render_site(
    input='./src/rmd/site'
  )
  
  
  
  # génération du book ------------------------------------------------------
  
  
  booklog <- bookdown::render_book(
    input='./src/rmd/book',
    output_dir = '../../../build/book'
  )
  
  
  
  # génération des 3 diaporama (dits 'atelier') -----------------------------
  
  
  dir.create('build/slides')
  
  slide1log <- rmarkdown::render(
    input='src/rmd/slides/rmarkdown.Rmd',
    output_file = '../../../build/slides/rmarkdown.html'
  )
  slide2log <- rmarkdown::render(
    input='src/rmd/slides/parametres.Rmd',
    output_file = '../../../build/slides/parametres.html'
  )
  slide3log <- rmarkdown::render(
    input='src/rmd/slides/templatespublications.Rmd',
    output_file = '../../../build/slides/templatespublications.html'
  )
  
  
  
  # génération des deux versions du rapport 'covid' -------------------------
  
  
  dir.create('build/report_examples')
  
  reportlog1 <- rmarkdown::render(
    input='src/rmd/report_examples/covid-report.Rmd',
    output_file = '../../../build/report_examples/covid-report.html'
  )
  report2log <- rmarkdown::render(
    input='src/rmd/report_examples/covid-report2.Rmd',
    output_file = '../../../build/report_examples/covid-report2.html'
  )
}    

clean_xaringan_themer_file <- function()
{
  file.remove('src/rmd/slides/xaringan-themer.css')
}


open_site <- function()
{
  browseURL(normalizePath('./build/index.html'))
}


run <- function()
{
  clean_build_dir()
  render_all()
  clean_xaringan_themer_file()
  open_site()
}


cat("Génération de tous les documents composants le site\n")
run()
cat("Fin de l'étape de génération.")