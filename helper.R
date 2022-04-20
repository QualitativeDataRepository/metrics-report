library(stringr)

checkif_member <- function(login, extension=NULL) {
  institutions <- structure(list(name = c("American", "Brown", "Case Western", 
                                          "Columbia", "Cornell", "Duke", "Fordham", "George Mason", "George Washington", 
                                          "Macalester", "Marine Corps", "3ie", "New York", "Palliative Care Research Cooperative", 
                                          "Princeton", "Syracuse", "California, Berkeley", "California, Merced", 
                                          "Cincinnati", "Iowa", "Maryland, Baltimore", "Michigan, Ann Arbor", 
                                          "New Mexico", "North Carolina, Chapel Hill", "Texas, Austin", 
                                          "Villanova", "Virginia Tech", "West Virginia"), 
                                 domain = c("american.edu", 
                                            "brown.edu", "case.edu", "columbia.edu", "cornell.edu", "duke.edu", 
                                            "fordham.edu", "gmu.edu", "gwu.edu", "macalester.edu", "usmcu.edu", 
                                            "3ieimpact.org", "nyu.edu", "palliativecareresearch.org", "princeton.edu", 
                                            "syr.edu", "berkeley.edu", "ucmerced.edu", "uc.edu", "uiowa.edu", 
                                            "umaryland.edu", "umich.edu", "unm.edu", "unc.edu", "utexas.edu", 
                                            "villanova.edu", "vt.edu", "wvu.edu")), 
                            class = "data.frame", row.names = c(NA, -28L))
  
  if (!is.null(extension)) {
    institutions <- rbind.data.frame(institutions, data.frame(name=extension, domain=NA))
  }
  
  login$Institution <- str_replace_all(login$Institution, "[[:punct:]]", "")
  institutions$name <- str_replace_all(institutions$name, "[[:punt:]]", "")

  login$Institution <- str_remove(login$Institution, " UNIVERSITY$")
  login$Institution <- str_remove(login$Institution, "^UNIVERSITY OF ")
  login$`Name/Email` <- str_extract(login$`Name/Email`, "[a-zA-Z0-9]+\\.edu$")
  
  institution_match <- unlist(lapply(login$Institution, function(x, name) {
    match <- str_which(name, paste0("^", x, "$"))
    if (length(match)==0) return(NA)
    return(match)
  }, str_to_upper(institutions$name))) # Need str_to_upper because we uppercase in the Rmd
  
  email_match <- unlist(lapply(login$`Name/Email`, function(x, domain) {
    match <- str_which(domain, paste0(x, "$"))
    if (length(match)==0) return(NA) 
    return(match[1])
  }, str_to_lower(institutions$domain)))
  
  matches <- dplyr::coalesce(institution_match, email_match)
  matches <- factor(matches, levels = 1:nrow(institutions), labels = institutions$name)
  return(matches)
}
