library(curl)
library(geo)
library(tidyverse)
# TODO Télécharger RPLS 2017 / géolocaliser et comparer les résultats avec la geoloc INSEE


# con <- curl::curl( "https://api-adresse.data.gouv.fr/search/?q=8+bd+du+port")
# data <- readLines(con)  %>% paste(collapse = "\n") %>% fromJSON(simplifyVector = FALSE)
# 
# curl -X POST -F data=@path/to/file.csv https://api-adresse.data.gouv.fr/reverse/csv
# 
# 
# library(httr)
# r <- POST("https://api-adresse.data.gouv.fr/reverse/csv", 
#           body = "Tim O'Reilly, Archbishop Huxley")
# stop_for_status(r)
# content(r, "parsed", "application/json")
# Charge les données qu'on veut géolocaliser
 
library(readr)
RPLS2018_detail <- read_delim("Region/RPLS2018_detail_reg27.csv", 
                                    ";", escape_double = FALSE, trim_ws = TRUE)

RPLS2018_detail <- unique(RPLS2018_detail[,c("DEPCOM","LIBCOM","CODEPOSTAL", "TYPVOIE", "NOMVOIE", "NUMVOIE")])

RPLS2018_detail <- RPLS2018_detail[1:1000,]

for (i in 1:nrow(RPLS2018_detail)){
  if (i == 1){
    coordinates <- tibble(x="", y="")
  }
  
# https://cran.r-project.org/web/packages/curl/vignettes/intro.html
  n = RPLS2018_detail$NUMVOIE[i]
  n = ifelse(is.na(n),"",as.character(n))
  t = RPLS2018_detail$TYPVOIE[i]
  t = ifelse(is.na(t),"",as.character(t))
  no = RPLS2018_detail$NOMVOIE[i]
  no = ifelse(is.na(no),"",as.character(no))
  
  adress = str_c(n,t,no)
  adress = str_replace_all(adress, pattern =  " ", replacement = "+")
  
  codePostal = RPLS2018_detail$CODEPOSTAL[i]
  codePostal = ifelse(is.na(codePostal),"",as.character(codePostal))
  
  codeInsee = RPLS2018_detail$DEPCOM[i]
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




# clean_data <- clean_data[clean_data$citycode %in% codeInsee | clean_data$postcode %in% codePostal,]
####

# WGS-84: pour l'instant on prend le premier
# TODO améliorer la recherche pour n'avoir qu'un résultat
coordinates[i,] <- ifelse(is.null(clean_data$coordinates[[1]]),"",clean_data$coordinates[[1]])
# coordinates[i,]$x <- clean_data$x[1]
# coordinates[i,]$y <- clean_data$y[1]
print(i)
}

