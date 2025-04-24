#' deposits_get
#' Scrape list of all deposits on a dataverse instance
#'
#' @param domain Domain of dataverse instance (e.g. demo.dataverse.org)
#' @param key API key for dataverse (optional)
#'
#' @return a tibble
#' @import httr, dplyr, magrittr, stringr, tibble
#' @export
#'
#' @examples \dontrun{ deposits_get("demo.dataverse.org") }
deposits_get <- function(domain, key=NULL) {
  response <- content(GET(paste0('http://', domain,
                                 "/api/search/?q=*&type=dataset&per_page=1000"),
                          config=add_headers("X-Dataverse-Key"=key)))

  # If there's an error on the server side, return it
  # e.g. key needed
  if (response$status=="ERROR") {
    stop(response$message)
  }

  deposits <- tibble(deposit=response$data$items) %>% unnest_wider(deposit)

  # Do we need to paginate?
  while (response$data$start + response$data$count_in_response < response$data$total_count) {
    Sys.sleep(3) # Be NICE to the API! This can take a while if there's lots of projects
    start <- response$data$start + response$data$count_in_response
    message(paste("at", start, "of", response$data$total_count))
    response <- content(GET(paste0('http://', domain,
                                   "/api/search/?q=*&type=dataset&per_page=1000",
                                   "&start=", start),
                            config=add_headers("X-Dataverse-Key"=key)))
    deposits <- tibble(deposit=deposits$data$items) %>% unnest_wider(deposit) %>%
      bind_rows(deposits)
  }
  
  deposits$versionState <- recode(deposits$versionState, RELEASED="Published", DRAFT="Unpublished")
  # Remove duplicates, but remove draft duplicates preferentially
  dup_doi <- deposits$global_id[duplicated(deposits$global_id)]
  dups <- deposits %>% filter(global_id %in% dup_doi & versionState=="Published") %>%
    group_by(global_id) %>% slice_head()
  deposits <- deposits %>% filter(!global_id %in% dup_doi) %>% bind_rows(dups)

  deposits$name <- stringr::str_trunc(deposits$name, 75, "right")
  

  return(deposits)
}

#' deposit_affiliations
#' 
#' Get author affiliations associated with a dataverse project
#'
#' @param url Full url of Dataverse deposit (i.e. https://demo.dataverse.org/dataset.xhtml?persistentId=doi:XXXX/YYYY)
#' @param key API key for Dataverse instance (optional, necessary for drafts)
#'
#' @return list of vectors, each top-level entry representing a deposit
#' @import httr, dplyr, magrittr, stringr, tibble
#' @export
#'
#' @examples deposit_affiliations("https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/DJTMJC")
deposit_affiliations <- function(url, key=NULL) {
  metadata <- content(GET(url, config=add_headers("X-Dataverse-Key"=key)))

  metadata <- 
    tibble(info=metadata$data$latestVersion$metadataBlocks$citation$fields) %>% 
    unnest_wider(info)
  print(url)
  affiliations <-
    metadata %>% filter(typeName == "author") %>% select("value") %>%
    unnest_auto(value) %>% unnest_auto(value)
  
  # check if there's no affiliation entry in the metadata
  if (is.null(affiliations$authorAffiliation)) {
    return(NA)
  }
  
  affiliations %>%
    select("authorAffiliation") %>% unnest_wider(authorAffiliation) %>%
    select("value") %>% .$value
}

