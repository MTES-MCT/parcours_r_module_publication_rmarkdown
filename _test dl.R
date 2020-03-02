library(stringr)

url = "https://www.statistiques.developpement-durable.gouv.fr/sites/default/files/2019-02/RPLS%202018%20-%20Donnees%20detaillees%20au%20logement.zip"

# url = "https://www.statistiques.developpement-durable.gouv.fr/sites/default/files/2019-01/RPLS%202017%20-%20Donnees%20detaillees%20et%20geolocalisees%20au%20logement_0.zip"

# Localisation du dossier de destination
destfolder = str_c(getwd(), "/R/parcours-r/m6_documents_reproductibles/DATA")
dest_file = str_c(destfolder, "/RPLS_DATA.zip")

  
# On télécharge et dézippe le fichier dans 
download.file(url, dest_file)

# Détail du contenu du dossier
details_dossier <- unzip(destfile, list = TRUE,
                         exdir = destfolder)


# On dézippe le fichier
unzip(dest_file,
      exdir = destfolder)


# On prend un des fichiers les moins lourds
chosen_file = str_c(destfolder,"/", details_dossier[order(details_dossier$Length),"Name"][7])


library(readr)
RPLS_data <- read_delim(chosen_file,";", escape_double = FALSE, locale = locale(decimal_mark = ",", 
                        encoding = "ASCII"), trim_ws = TRUE, col_types = cols(.default = col_character()))



library(curl)
# library(geo)
library(tidyverse)

# Liste des variables récupérables par la requête
var_list = 

# Poucentage du fichier que l'on veut géolocaliser 
facteur_division = 0.01
for (i in 1:round(nrow(RPLS_data)*facteur_division)){
  
  
  # On crée une table servant à récupérer les coordonnées des logements
    
  if (i == 1){
    RPLS_data$x <- ""
    RPLS_data$y <- ""
    RPLS_data$adresse_trouvée <- ""
    temps1 = Sys.time()
  }
  
  # https://cran.r-project.org/web/packages/curl/vignettes/intro.html
  n = RPLS_data$NUMVOIE[i]
  n = ifelse(is.na(n),"",as.character(n))
  t = RPLS_data$TYPVOIE[i]
  t = ifelse(is.na(t),"",as.character(t))
  no = RPLS_data$NOMVOIE[i]
  no = ifelse(is.na(no),"",as.character(no))
  
  adress = str_c(n,t,no)
  adress = str_replace_all(adress, pattern =  " ", replacement = "+")
  
  codePostal = RPLS_data$CODEPOSTAL[i]
  codePostal = ifelse(is.na(codePostal),"",as.character(codePostal))
  
  codeInsee = RPLS_data$DEPCOM[i]
  codeInsee = ifelse(is.na(codeInsee),"",as.character(codeInsee))
  
  
  req <- curl::curl_fetch_memory(str_c("https://api-adresse.data.gouv.fr/search/?q=",adress,"&postcode=", 
                                       codePostal,"&citycode=", codeInsee))
  # req <- curl::curl_fetch_memory(str_c("https://api-adresse.data.gouv.fr/search/?q=",n,"+",t,"+",no))
  
  
  # Pour voir comment sont les données
  # str(req)
  # parse_headers(req$headers)
  
  clean_data <- jsonlite::prettify(rawToChar(req$content))
  clean_data <- jsonlite::fromJSON(clean_data)
  clean_data <- tibble::as_tibble(clean_data$features)
  clean_data <- tibble::as_tibble(bind_cols(clean_data$properties,clean_data$geometry))
  
  # A partir d'ici on peut filtrer sur beaucoup de choses
  
  
  # WGS-84: pour l'instant on prend le premier
  # TODO améliorer la recherche pour n'avoir qu'un résultat
  
  # On charge les coordonnées dans les données RPLS
  RPLS_data[i,c("x","y")] <- clean_data$coordinates[1][[1]]
  # RPLS_data[i,"y"] <- ifelse(is.null(clean_data$y[[1]]),"",clean_data$y[[1]])
  
  # On prend l'adresse qu'il a trouvé
  RPLS_data[i,c("adresse_trouvée")] <- ifelse(is.null(clean_data$label[[1]]),"",clean_data$label[[1]])
  # coordinates[i,]$x <- clean_data$x[1]
  # coordinates[i,]$y <- clean_data$y[1]
  if(i == nrow(RPLS_data)*facteur_division){
    temps2 = Sys.time()
    temps_execution = temps2 - temps1
    print(str_c(temps_execution, " minutes pour ", as.character(nrow(RPLS_data)*facteur_division), " logements."))
  }
  
  
}

library(shiny)
library(leaflet) 
library(googleway)

# On va regarder ou sont ces logements et combien il y en a par
map_data = RPLS_data[RPLS_data$x != "", c("LIBCOM", "x", "y", "adresse_trouvée")] %>% group_by(LIBCOM, x, y, adresse_trouvée) %>% count()


map_data$x <- as.numeric(map_data$x)
map_data$y <- as.numeric(map_data$y)

# Create a color palette with handmade bins.
mybins=seq(1, max(map_data$n), by=10)
mypalette = colorBin( palette="YlOrBr", domain=map_data$n , na.color="transparent", bins=mybins)

mytext=paste("Commune ", map_data$LIBCOM, "<br/>", "Adresse: ", map_data$adresse_trouvée, "<br/>", "Latitude: ", map_data$y, "<br/>", "Longitude: ", map_data$x, sep="") %>%
  lapply(htmltools::HTML)



# carte2 = leaflet(map_data) %>% 
#   addTiles()  %>% 
#   # setView( lat=-27, lng=170 , zoom=4) %>%
#   # addProviderTiles("Esri.WorldImagery") %>%
#   addCircleMarkers(~x, ~y, fillOpacity = 0.7, color="white", radius=8, stroke=FALSE,
#                    label = mytext,
#                    labelOptions = labelOptions( style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "13px", direction = "auto")
#   ) %>%
#   addLegend( pal=mypalette, values=~n, opacity=0.9, title = "Nombre de logements", position = "bottomright" )

## define the layerId as a value from the data
output$map <- renderLeaflet({
 carte <- leaflet() %>%
    addTiles() %>%
    addMarkers(data = map_data, lat = ~y, lng = ~x, clusterOptions = markerClusterOptions(), 
               label = mytext)
 
 
 # %>%
 # addAwesomeMarkers(., lat = ~y, lng = ~x, clusterOptions = markerClusterOptions(), icon = "builing")
 
 
 # addProviderTiles(providers$OpenStreetMap, group = 'Open SM')  %>%
 # addProviderTiles(provider = providers$CartoDB.DarkMatter ) %>%
 # addProviderTiles("Esri.WorldImagery") %>% 
  ## observing a click will return the `id` you assigned in the `layerId` argument
  # observeEvent(input$map_marker_click, {
  #   
  #   click <- input$map_marker_click
  #   
  #   # Affiche les données au clic
  #   output$table <- renderTable({
  #     map_data
  #   })
  # })
  
  return(carte)
})




















# Télécharge les données dans le fichier temporaire
download.file(url,temp)

# Liste des fichiers disponibles dans le fichier temporaire
details_dossier <- unzip(zipfile = temp, list = TRUE)

# On prend celui qui nous plait

data <- read.delim(unz(temp, "Region/RPLS_data_reg76.csv"), sep = ";",col.names =  TRUE,
                    row.names = FALSE)
unlink(temp)