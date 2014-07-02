## Validation test for is_number ##
# In R, this kind of for loops are very inneficient. ALWAYS 
# use vectorized operations. Otherwise it may take a few hours to
# complete.
isNumber <- function(df = NULL) {
    message('Validating numbers.')
    pb <- txtProgressBar(min = 0, max = nrow(df), style = 3)
    for (i in 1:nrow(df)) {
        setTxtProgressBar(pb, i)
        if (is.numeric(df$value) == TRUE) { df$is_number[i] <- as.integer(1) }
        else { df$is_number[i] <- as.integer(0) }
    }
    return(df)
}