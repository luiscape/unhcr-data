## Script for updating and writing tables in ScraperWiki.

fetchRawData <- function() { 
    message('Storing raw data.')
    db <- dbConnect(SQLite(), dbname="scraperwiki.sqlite")
    if ("_raw_data" %in% dbListTables(db) == FALSE) { 
        dbWriteTable(db, 
                     "_raw_data", 
                     raw_data,
                     row.names = FALSE, 
                     overwrite = TRUE)
        
        # Generating scrape metadata.
        scrape_time <- as.factor(Sys.time())
        id <- paste(ceiling(runif(1, 1, 100)), format(Sys.time(), "%Y"), sep = "_")
        new_data <- TRUE
        scraperMetadata <- data.frame(scrape_time, id, new_data)
    }
    else { 
        oldData <- dbReadTable(db, "_raw_data")
        newData <- merge(raw_data,  # check if merge works here.
                         oldData, 
                         all = TRUE)
        dbWriteTable(db, 
                     "_raw_data", 
                     newData, 
                     row.names = FALSE, 
                     overwrite = TRUE)
        
        # Generating scrape metadata.
        scrape_time <- as.factor(Sys.time())
        id <- paste(ceiling(runif(1, 1, 100)), format(Sys.time(), "%Y"), sep = "_")
        new_data <- as.factor(identical(oldData, newData))
        scraperMetadata <- data.frame(scrape_time, id, new_data)
    }
    
    if ("_scraper_metadata" %in% dbListTables(db) == FALSE) {
        dbWriteTable(db, 
                     "_scraper_metadata", 
                     scraperMetadata, 
                     row.names = FALSE,
                     overwrite = TRUE)    
    }
    else { 
        dbWriteTable(db,
                     "_scraper_metadata", 
                     scraperMetadaota, 
                     row.names = FALSE, 
                     append = TRUE)  
    }
    newData
}

writeTables <- function() {
    message('Storing CPS-shaped data.')
    if ("value" %in% dbListTables(db) == FALSE) { 
        dbWriteTable(db, "value", 
                     raw_data, 
                     row.names = FALSE, 
                     overwrite = TRUE)
        dbWriteTable(db, "indicator", 
                     raw_data, 
                     row.names = FALSE, 
                     overwrite = TRUE)
        dbWriteTable(db, "dataset", 
                     raw_data, 
                     row.names = FALSE, 
                     overwrite = TRUE)
    }
    else {
        # Loading old entries
        dbWriteTable(db, "value", 
                     raw_data, 
                     row.names = FALSE, 
                     overwrite = TRUE)
        dbWriteTable(db, "indicator", 
                     raw_data, 
                     row.names = FALSE, 
                     overwrite = FALSE)
        dbWriteTable(db, "dataset", 
                     raw_data, 
                     row.names = FALSE, 
                     overwrite = TRUE)
    }
    
    # for testing purposes
    # dbListTables(db)
    # x <- dbReadTable(db, "_raw_data")
    # y <- dbReadTable(db, "_scraper_metadata")
    
    dbDisconnect(db)
    message('Done!')
}