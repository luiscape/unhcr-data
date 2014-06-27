### Validate for CPS. 
# Series of tests that validate data for CPS. 
# 

validateCPS <- function(region = NULL) {
    
    # Check if vectors are present. 
    a <- is.data.frame(value)
    b <- is.data.frame(indicator)
    c <- is.data.frame(dataset)
    x <- c(a,b,c)
    if (any(x) == FALSE) message('Vector check: FAIL!')
    else message('Vector check: PASS.')
    
    
    # The region parameter helps to test if the entities
    # are being correclty used. Breakdown: 
    # - country: if country, the codes have to be p-codes.
    # - global: if global, the codes have to be ISO3.
    if (region == 'global') {
        if (any(nchar(as.character(value$region)) == 3) == FALSE) {
            message('Entity check (global): FAIL!')
        }
        else message('Entity check (global): PASS.')
    }
    if (region == 'country') {
        if (any(nchar(as.character(value$region)) < 4) == TRUE) {
            message('Entity check (country): FAIL!')
        }
        else message('Entity check (country): PASS.')
    }
    
    # Testing if the three files are there
    # (Soon to have 4 with the configuration file.)
    vector_list <- c(value, indicator, dataset)
    for (i in 1:3) {
        if (i == 1) z <- is.vector(vector_list[i])
        else z[i] <- is.vector(vector_list[i])
    } 
    if (any(z) == FALSE) {
        message('Files check: FAIL!')
        if (verbose == TRUE) message('Check that the three files are being correctly generated and named.')
    }
    else message('Files check: PASS.')
    
    # Number of columns.
    if (ncol(value) != 7) message('Col-check for "value.csv": FAIL!')
    else message('Col-check for "value.csv": PASS.')
    if (ncol(indicator) != 3) message('Col-check for "indicator.csv": FAIL!')
    else message('Col-check for "indicator.csv": PASS.')
    if (ncol(dataset) != 4) message('Col-check for "dataset.csv": FAIL!')
    else message('Col-check for "dataset.csv": PASS.')
}