# fonction pour générer book pdf du module 6

bookdown::render_book("index.Rmd", "bookdown::gitbook")

pages_psts <- list.files("_book/", full.names = FALSE, pattern = "html$") |> setdiff("404.html")
chap_html <- c(
    "index.html",
    "get-started.html",
    "la-publication-reproductible.html",
    "le-fichier-r-markdown.html",
    "chunks.html",
    "outputs.html",
    "parametres.html",
    "de-la-page-au-livre-le-package-bookdown.html",
    "du-rmarkdown-interactif.html",
    "publier.html",
    "pour-aller-plus-loin.html",
    "pour-aller-plus-loin-sur-pagedown.html"
  )

# Verif : character(0) attendu deux fois
setdiff(pages_psts, chap_html) ; setdiff(chap_html, pages_psts)

# Commande pour générer un support pdf du module 6
propre.rpls::creer_pdf_book(chemin_book = "_book/", pages_html = chap_html, 
                            nom_pdf = paste0("../", "support_M6_Rmarkdown.pdf"))

