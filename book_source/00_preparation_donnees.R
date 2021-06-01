library("banR") # Géolocalisation
library("stringr")
library("curl") # Requêtage
library("dplyr")
library("leaflet") # Cartes
library("readxl")
library("DT")
library("highcharter") # Graphiques
library("fs")
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Téléchargement du fichier ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

url = "https://www.statistiques.developpement-durable.gouv.fr/sites/default/files/2019-02/RPLS%202018%20-%20Donnees%20detaillees%20au%20logement.zip"


# Localisation du dossier de destination

destfolder = str_c(getwd(), "/data")
if ( dir.exists(destfolder)){
  dir.create(destfolder)
}

dest_file = str_c(destfolder, "/RPLS_data.zip")

# Enlever le commentaire pour télécharger le fichier
# Normalement, le fichier est déjà téléchargé sur votre ordinateur

download.file(url, destfile = dest_file)

# Détail du contenu du dossier
details_dossier <- unzip(dest_file, list = TRUE)

# On dézippe le deuxième fichier du zip
unzip(dest_file, exdir = destfolder, files = details_dossier$Name[2])

# On prend un des fichiers les moins lourds
chosen_file = str_c(destfolder,"/", details_dossier$Name[2])


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Géolocalisation du fichier ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Essayer de mettre input$chosen_file pour permettre la selection du fichier utilisé
RPLS_data <- read_delim(chosen_file,";",
                        escape_double = FALSE,
                        locale = locale(decimal_mark = ",",
                                        encoding = "ASCII"), trim_ws = TRUE,
                        col_types = cols(.default = col_character()))

# On crée une adresse à partir des variables disponibes
RPLS_data$ADRESSE = str_c(RPLS_data$NUMVOIE,RPLS_data$TYPVOIE, RPLS_data$NOMVOIE, sep = " ")

# On elève ensuite les adresses ayant des problèmes d'encodages
RPLS_data$ADRESSE = iconv(RPLS_data$ADRESSE, to = "ASCII")

# On ne géolocalise une même adresse qu'une seule fois
RPLS_data_chunked = unique(RPLS_data[!is.na(RPLS_data$ADRESSE), c("ADRESSE", "CODEPOSTAL", "DEPCOM")] )

RPLS_data_chunked = RPLS_data_chunked[,] %>%
  geocode_tbl(adresse = ADRESSE, code_insee = DEPCOM, code_postal = CODEPOSTAL)
head(RPLS_data_chunked)

# ~~~~~~~~~~~~~~~~~~~~~~~~~ Cartographie des données géolocalisées ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# On va regarder ou sont ces logements et combien il y en a par adresse trouvée

# % de logements non géolocalisés
pourcent = nrow(RPLS_data_chunked[is.na(RPLS_data_chunked$latitude),])*100/nrow(RPLS_data_chunked)
paste(str_c(round(pourcent,3), "% de logements non géolocalisés"))

# Create a color palette with handmade bins.
mybins=seq(1, max(RPLS_data_chunked$n), by=10)
mypalette = colorBin( palette="YlOrBr", domain=RPLS_data_chunked$n ,
                      na.color="transparent", bins=mybins)

mytext = paste(
  "Commune ",
  RPLS_data_chunked$result_city,
  "<br/>",
  "Adresse: ",
  RPLS_data_chunked$result_label,
  "<br/>",
  "Latitude: ",
  RPLS_data_chunked$latitude,
  "<br/>",
  "Longitude: ",
  RPLS_data_chunked$longitude,
  sep = ""
) %>%
  lapply(htmltools::HTML)


carte <- leaflet() %>%
  addTiles() %>%
  addMarkers(
    data = RPLS_data_chunked,
    lat = ~ latitude,
    lng = ~ longitude,
    clusterOptions = markerClusterOptions(),
    label = mytext
  )


# ~~~~~~~~~~~~~~~~~~~~~~~~~ Statistiques ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Comparateur de territoire
url_base_cc = "https://www.insee.fr/fr/statistiques/fichier/2521169/base_cc_comparateur.zip"

destfile_base_cc = str_c(destfolder, "/BASECC.zip")

download.file(url = url_base_cc, destfile = destfile_base_cc)
unzip(zipfile = destfile_base_cc, exdir = destfolder)

base_cc_comparateur <- read_excel("data/base_cc_comparateur.xls",
                                  skip = 5)

RPLS_data <- left_join(RPLS_data, RPLS_data_chunked[,-c("DEPCOM")], by = "ADRESSE") %>%
  left_join(., base_cc_comparateur, by = c("DEPCOM" = "CODGEO"))
