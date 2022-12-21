
gene_doc <- function(nom_espece, impression)
{
  outfile <- paste0("doc-",nom_espece,".Rmd")
  
  rmarkdown::render("mon_premier_document.Rmd", 
                    params = list(
                      espece = nom_espece,
                      printcode = impression),
                    output_file = outfile
                    )
  
}